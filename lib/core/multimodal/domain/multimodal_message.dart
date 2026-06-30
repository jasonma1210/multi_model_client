// v0.43.0 实现 多模态统一抽象
//
// 设计目标：
// 1. 跨 LLM Provider 统一多模态内容表示（OpenAI / Anthropic / Gemini / Ollama / 本地 llama.cpp）
// 2. 支持图片 / 音频 / 文件 / 文本 4 种内容类型
// 3. 通过 sealed class 强制类型安全 + 模式匹配
// 4. 提供 provider-specific 序列化方法（toProviderFormat）
//
// 参考：
// - OpenAI Vision: content: [{type: text}, {type: image_url: {url}}]
// - Anthropic Vision: content: [{type: text}, {type: image, source: {type, media_type, data}}]
// - Gemini Vision: parts: [{text}, {inline_data: {mime_type, data}}]
// - Ollama Vision: images: [base64_array]

import 'dart:convert';
import 'dart:typed_data';

/// LLM Provider 标识 - 用于多模态内容序列化
enum LLMProvider {
  openai,
  anthropic,
  gemini,
  ollama,
  localLLM, // llama.cpp FFI
}

/// 多模态内容片段 - sealed class 强制子类实现
sealed class ContentPart {
  const ContentPart();

  /// 序列化为 provider-specific JSON
  Map<String, dynamic> toProviderFormat(LLMProvider provider);
}

/// 纯文本内容
class TextPart extends ContentPart {
  final String text;
  const TextPart(this.text);

  @override
  Map<String, dynamic> toProviderFormat(LLMProvider provider) {
    switch (provider) {
      case LLMProvider.openai:
      case LLMProvider.ollama:
        return {'type': 'text', 'text': text};
      case LLMProvider.anthropic:
        return {'type': 'text', 'text': text};
      case LLMProvider.gemini:
        return {'text': text};
      case LLMProvider.localLLM:
        return {'type': 'text', 'text': text};
    }
  }
}

/// 图片源类型
enum ImageSourceType { base64, httpUrl, fileUri }

/// 图片内容 - 支持 base64 / HTTP URL / 本地文件 URI
class ImagePart extends ContentPart {
  final Uint8List? bytes; // 原始字节（base64 / file 模式使用）
  final String? base64Data; // 预编码的 base64（base64 模式使用）
  final String? url; // HTTP URL（httpUrl 模式使用）
  final String? fileUri; // 本地文件路径（fileUri 模式使用）
  final String? mimeType; // 'image/jpeg' / 'image/png' / 'image/webp' / 'image/gif'
  final ImageSourceType sourceType;
  final ImageMetadata? metadata;

  const ImagePart({
    this.bytes,
    this.base64Data,
    this.url,
    this.fileUri,
    this.mimeType,
    this.sourceType = ImageSourceType.base64,
    this.metadata,
  }) : assert(
          sourceType == ImageSourceType.base64 && (base64Data != null || bytes != null) ||
              sourceType == ImageSourceType.httpUrl && url != null ||
              sourceType == ImageSourceType.fileUri && fileUri != null,
          'ImagePart: sourceType and data must match',
        );

  /// 便捷构造：从 base64 字符串
  factory ImagePart.fromBase64(String base64, {String? mimeType, ImageMetadata? metadata}) {
    return ImagePart(
      base64Data: base64,
      mimeType: mimeType ?? 'image/jpeg',
      sourceType: ImageSourceType.base64,
      metadata: metadata,
    );
  }

  /// 便捷构造：从 URL
  factory ImagePart.fromUrl(String url, {String? mimeType, ImageMetadata? metadata}) {
    return ImagePart(
      url: url,
      mimeType: mimeType,
      sourceType: ImageSourceType.httpUrl,
      metadata: metadata,
    );
  }

  /// 便捷构造：从文件路径
  factory ImagePart.fromFile(String filePath, {String? mimeType, ImageMetadata? metadata}) {
    return ImagePart(
      fileUri: filePath,
      mimeType: mimeType,
      sourceType: ImageSourceType.fileUri,
      metadata: metadata,
    );
  }

  /// 便捷构造：从字节数组
  factory ImagePart.fromBytes(Uint8List bytes, {String? mimeType, ImageMetadata? metadata}) {
    return ImagePart(
      bytes: bytes,
      base64Data: base64Encode(bytes),
      mimeType: mimeType ?? 'image/jpeg',
      sourceType: ImageSourceType.base64,
      metadata: metadata,
    );
  }

  /// 获取最终用于传输的 base64 字符串
  String? get effectiveBase64 {
    if (base64Data != null) return base64Data;
    if (bytes != null) return base64Encode(bytes!);
    return null;
  }

  /// 获取 data URI（OpenAI 格式）
  String? get dataUri {
    final b64 = effectiveBase64;
    if (b64 == null || mimeType == null) return null;
    return 'data:$mimeType;base64,$b64';
  }

  /// 估算 token 数量（OpenAI vision 估算公式）
  /// 参考：https://platform.openai.com/docs/guides/vision
  int estimateTokens() {
    final est = metadata?.estimatedTokens;
    if (est != null) return est;
    final w = metadata?.width;
    final h = metadata?.height;
    if (w == null || h == null) return 85; // 默认 low

    // OpenAI vision 估算：512x512 = 85 tokens, 每翻倍 token 数也翻倍
    final tiles = ((w / 512).ceil()) * ((h / 512).ceil());
    return 85 * tiles;
  }

  @override
  Map<String, dynamic> toProviderFormat(LLMProvider provider) {
    switch (provider) {
      case LLMProvider.openai:
        if (sourceType == ImageSourceType.httpUrl && url != null) {
          return {
            'type': 'image_url',
            'image_url': {'url': url},
          };
        }
        return {
          'type': 'image_url',
          'image_url': {'url': dataUri},
        };

      case LLMProvider.anthropic:
        if (sourceType == ImageSourceType.httpUrl && url != null) {
          return {
            'type': 'image',
            'source': {
              'type': 'url',
              'url': url,
            },
          };
        }
        return {
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': mimeType ?? 'image/jpeg',
            'data': effectiveBase64,
          },
        };

      case LLMProvider.gemini:
        return {
          'inline_data': {
            'mime_type': mimeType ?? 'image/jpeg',
            'data': effectiveBase64,
          },
        };

      case LLMProvider.ollama:
        return {
          // Ollama 直接在顶层 images 数组中提供 base64，不在 content 内
          // 此处由调用方提取
          'type': 'image',
          'data': effectiveBase64,
        };

      case LLMProvider.localLLM:
        // llama.cpp mtmd 协议：content 为字符串数组
        return {
          'type': 'image',
          'data': effectiveBase64 ?? url,
        };
    }
  }
}

/// 图片元数据
class ImageMetadata {
  final int? width;
  final int? height;
  final int? fileSizeBytes;
  final int? estimatedTokens;
  final String? originalName;

  const ImageMetadata({
    this.width,
    this.height,
    this.fileSizeBytes,
    this.estimatedTokens,
    this.originalName,
  });
}

/// 音频内容（v0.43.0 占位，v0.44.0 完善）
class AudioPart extends ContentPart {
  final Uint8List? bytes;
  final String? base64Data;
  final String mimeType; // 'audio/wav' / 'audio/mp3' / 'audio/ogg'
  final int? durationMs;

  const AudioPart({
    this.bytes,
    this.base64Data,
    required this.mimeType,
    this.durationMs,
  });

  String? get effectiveBase64 {
    if (base64Data != null) return base64Data;
    if (bytes != null) return base64Encode(bytes!);
    return null;
  }

  @override
  Map<String, dynamic> toProviderFormat(LLMProvider provider) {
    switch (provider) {
      case LLMProvider.openai:
        return {
          'type': 'input_audio',
          'input_audio': {
            'data': effectiveBase64,
            'format': mimeType.split('/').last,
          },
        };
      case LLMProvider.gemini:
        return {
          'inline_data': {
            'mime_type': mimeType,
            'data': effectiveBase64,
          },
        };
      default:
        return {
          'type': 'audio',
          'data': effectiveBase64,
        };
    }
  }
}

/// 通用文件内容（PDF/文档）- 用于文档问答
class FilePart extends ContentPart {
  final Uint8List? bytes;
  final String? base64Data;
  final String? fileUri;
  final String? url;
  final String mimeType; // 'application/pdf' 等
  final String? fileName;

  const FilePart({
    this.bytes,
    this.base64Data,
    this.fileUri,
    this.url,
    required this.mimeType,
    this.fileName,
  });

  String? get effectiveBase64 {
    if (base64Data != null) return base64Data;
    if (bytes != null) return base64Encode(bytes!);
    return null;
  }

  @override
  Map<String, dynamic> toProviderFormat(LLMProvider provider) {
    switch (provider) {
      case LLMProvider.anthropic:
        return {
          'type': 'document',
          'source': {
            if (url != null) ...{'type': 'url', 'url': url}
            else ...{
              'type': 'base64',
              'media_type': mimeType,
              'data': effectiveBase64,
            },
          },
        };
      case LLMProvider.openai:
        if (url != null) {
          return {'type': 'file_url', 'file_url': {'url': url}};
        }
        return {'type': 'file', 'file': {'data': effectiveBase64, 'mime_type': mimeType}};
      case LLMProvider.gemini:
        return {
          'inline_data': {
            'mime_type': mimeType,
            'data': effectiveBase64,
          },
        };
      default:
        return {
          'type': 'file',
          'data': effectiveBase64 ?? url,
          'mime_type': mimeType,
        };
    }
  }
}

/// 多模态消息 - 替代 v0.42.0 的 ChatMessage
///
/// 保留向下兼容：[text] getter 返回所有 TextPart 拼接
class MultimodalMessage {
  final String role; // 'system' | 'user' | 'assistant' | 'tool'
  final List<ContentPart> parts;
  final String? name;
  final String? toolCallId;

  const MultimodalMessage({
    required this.role,
    required this.parts,
    this.name,
    this.toolCallId,
  });

  /// 纯文本便捷构造
  factory MultimodalMessage.text(String role, String text, {String? name}) {
    return MultimodalMessage(role: role, parts: [TextPart(text)], name: name);
  }

  /// 用户消息 - 文本 + 图片
  factory MultimodalMessage.userWithImage(String text, ImagePart image) {
    return MultimodalMessage(
      role: 'user',
      parts: [TextPart(text), image],
    );
  }

  /// 用户消息 - 文本 + 多张图片
  factory MultimodalMessage.userWithImages(String text, List<ImagePart> images) {
    return MultimodalMessage(
      role: 'user',
      parts: [TextPart(text), ...images],
    );
  }

  /// 提取所有文本片段拼接（向后兼容 ChatMessage.content）
  String get text => parts
      .whereType<TextPart>()
      .map((p) => p.text)
      .join('\n');

  /// 提取所有图片（向后兼容 ChatMessage.images）
  List<ImagePart> get images => parts.whereType<ImagePart>().toList();

  /// 是否有图片
  bool get hasImages => parts.any((p) => p is ImagePart);

  /// 总 token 估算（图片 + 文本）
  int estimateTotalTokens({int charsPerToken = 4}) {
    int total = 0;
    for (final part in parts) {
      if (part is TextPart) {
        total += (part.text.length / charsPerToken).ceil();
      } else if (part is ImagePart) {
        total += part.estimateTokens();
      }
    }
    return total;
  }

  /// 序列化为 provider 格式
  /// - OpenAI/Ollama/llama.cpp: content 为数组
  /// - Anthropic: content 为数组
  /// - Gemini: 直接传 parts
  Map<String, dynamic> toProviderJson(LLMProvider provider) {
    if (provider == LLMProvider.gemini) {
      return {
        'role': role == 'assistant' ? 'model' : role,
        'parts': parts.map((p) => p.toProviderFormat(provider)).toList(),
      };
    }

    return {
      'role': role,
      if (name != null) 'name': name,
      if (toolCallId != null) 'tool_call_id': toolCallId,
      'content': parts.map((p) => p.toProviderFormat(provider)).toList(),
    };
  }
}
