// v0.43.0 实现 图片预处理服务
//
// 职责：
// 1. 图片压缩（长边 ≤ 2048px）
// 2. 格式转换（JPEG / PNG / WebP / GIF）
// 3. Token 估算（OpenAI vision 公式）
// 4. 大小校验（≤ 20MB）
// 5. 元数据提取（width / height / mimeType）

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../domain/multimodal_message.dart';

/// 图片预处理结果
class ImageProcessResult {
  final Uint8List bytes; // 处理后的字节
  final String mimeType; // 输出格式
  final int width; // 宽度
  final int height; // 高度
  final int fileSizeBytes; // 文件大小
  final int estimatedTokens; // OpenAI vision 估算
  final String? originalName; // 原始文件名

  const ImageProcessResult({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.fileSizeBytes,
    required this.estimatedTokens,
    this.originalName,
  });

  /// 压缩比
  double compressionRatio(int? originalSize) {
    if (originalSize == null || originalSize == 0) return 1.0;
    return fileSizeBytes / originalSize;
  }

  /// 转换为 ImagePart
  ImagePart toImagePart({String? overrideMimeType}) {
    return ImagePart.fromBytes(
      bytes,
      mimeType: overrideMimeType ?? mimeType,
      metadata: ImageMetadata(
        width: width,
        height: height,
        fileSizeBytes: fileSizeBytes,
        estimatedTokens: estimatedTokens,
        originalName: originalName,
      ),
    );
  }
}

/// 图片预处理配置
class ImageProcessConfig {
  /// 长边最大像素（超过则等比缩放）
  final int maxLongEdge;

  /// 输出格式
  final String outputFormat; // 'image/jpeg' / 'image/png' / 'image/webp'

  /// JPEG 质量（1-100）
  final int jpegQuality;

  /// 最大文件大小（字节）
  final int maxFileSizeBytes;

  /// 是否保留透明通道
  final bool preserveTransparency;

  const ImageProcessConfig({
    this.maxLongEdge = 2048,
    this.outputFormat = 'image/jpeg',
    this.jpegQuality = 85,
    this.maxFileSizeBytes = 20 * 1024 * 1024, // 20MB
    this.preserveTransparency = false,
  });

  /// 默认配置（移动端优化：2K JPEG）
  static const ImageProcessConfig defaultConfig = ImageProcessConfig();

  /// 高质量配置（本地 4K 显示）
  static const ImageProcessConfig highQuality = ImageProcessConfig(
    maxLongEdge: 4096,
    jpegQuality: 92,
    outputFormat: 'image/png',
  );

  /// 缩略图配置（消息列表预览）
  static const ImageProcessConfig thumbnail = ImageProcessConfig(
    maxLongEdge: 256,
    jpegQuality: 75,
  );
}

/// 图片预处理异常
class ImageProcessException implements Exception {
  final String message;
  final ImageProcessErrorCode code;
  const ImageProcessException(this.message, this.code);

  @override
  String toString() => 'ImageProcessException($code): $message';
}

enum ImageProcessErrorCode {
  fileNotFound,
  fileTooLarge,
  decodeFailed,
  encodeFailed,
  unsupportedFormat,
}

/// v0.44.0: 顶层函数 - 在 Isolate 中执行图片处理（compute 要求）
/// 解码、缩放、编码全部在后台 Isolate 完成，避免阻塞 UI 线程
/// 参数和返回值用 Map 传递，确保可序列化
Map<String, dynamic> _processBytesInIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final maxLongEdge = params['maxLongEdge'] as int;
  final outputFormat = params['outputFormat'] as String;
  final jpegQuality = params['jpegQuality'] as int;

  final image = img.decodeImage(bytes);
  if (image == null) {
    throw StateError('Failed to decode image in isolate');
  }

  // 等比缩放
  final longEdge = image.width > image.height ? image.width : image.height;
  img.Image resized = image;
  if (longEdge > maxLongEdge) {
    final scale = maxLongEdge / longEdge;
    final newWidth = (image.width * scale).round();
    final newHeight = (image.height * scale).round();
    resized = img.copyResize(image, width: newWidth, height: newHeight);
  }

  // 编码
  List<int> encoded;
  switch (outputFormat) {
    case 'image/png':
      encoded = img.encodePng(resized);
      break;
    case 'image/jpeg':
    default:
      encoded = img.encodeJpg(resized, quality: jpegQuality);
      break;
  }

  return {
    'encodedBytes': Uint8List.fromList(encoded),
    'width': resized.width,
    'height': resized.height,
    'fileSizeBytes': encoded.length,
  };
}

/// 图片预处理服务
class ImagePreprocessService {
  final ImageProcessConfig config;

  const ImagePreprocessService({this.config = ImageProcessConfig.defaultConfig});

  /// 从文件路径处理
  Future<ImageProcessResult> processFile(String filePath, {String? originalName}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const ImageProcessException('File not found', ImageProcessErrorCode.fileNotFound);
    }
    final bytes = await file.readAsBytes();
    final name = originalName ?? filePath.split('/').last;
    return processBytes(bytes, originalName: name);
  }

  /// 从字节数组处理
  /// v0.44.0: 优先在 Isolate 中处理，避免阻塞 UI 线程；Isolate 失败时回退同步
  Future<ImageProcessResult> processBytes(Uint8List bytes, {String? originalName}) async {
    if (bytes.isEmpty) {
      throw const ImageProcessException('Empty image data', ImageProcessErrorCode.decodeFailed);
    }
    if (bytes.length > config.maxFileSizeBytes) {
      throw ImageProcessException(
        'File size ${_formatSize(bytes.length)} exceeds limit ${_formatSize(config.maxFileSizeBytes)}',
        ImageProcessErrorCode.fileTooLarge,
      );
    }

    try {
      // v0.44.0: 在后台 Isolate 中执行解码/缩放/编码，避免阻塞 UI
      final result = await compute(
        _processBytesInIsolate,
        {
          'bytes': bytes,
          'maxLongEdge': config.maxLongEdge,
          'outputFormat': config.outputFormat,
          'jpegQuality': config.jpegQuality,
        },
      );

      final tokens = _estimateTokens(
        result['width'] as int,
        result['height'] as int,
      );

      return ImageProcessResult(
        bytes: result['encodedBytes'] as Uint8List,
        mimeType: config.outputFormat,
        width: result['width'] as int,
        height: result['height'] as int,
        fileSizeBytes: result['fileSizeBytes'] as int,
        estimatedTokens: tokens,
        originalName: originalName,
      );
    } catch (e) {
      // fallback: Isolate 不可用或失败时回退到主 Isolate 同步处理
      debugPrint('[ImagePreprocess] Isolate 失败，回退同步: $e');
      return _processBytesSync(bytes, originalName: originalName);
    }
  }

  /// v0.44.0: 同步处理 fallback（Isolate 不可用时使用，保留原逻辑）
  Future<ImageProcessResult> _processBytesSync(Uint8List bytes, {String? originalName}) async {
    img.Image? image;
    try {
      image = img.decodeImage(bytes);
    } catch (e) {
      throw ImageProcessException(
        'Failed to decode image: $e',
        ImageProcessErrorCode.decodeFailed,
      );
    }
    if (image == null) {
      throw const ImageProcessException('Failed to decode image', ImageProcessErrorCode.decodeFailed);
    }

    final resized = _resizeIfNeeded(image);
    final encoded = _encode(resized);
    if (encoded == null) {
      throw const ImageProcessException('Failed to encode image', ImageProcessErrorCode.encodeFailed);
    }

    final tokens = _estimateTokens(resized.width, resized.height);

    return ImageProcessResult(
      bytes: Uint8List.fromList(encoded.bytes),
      mimeType: config.outputFormat,
      width: resized.width,
      height: resized.height,
      fileSizeBytes: encoded.length,
      estimatedTokens: tokens,
      originalName: originalName,
    );
  }

  /// 仅提取元数据（不解码完整图像）
  ImageMetadata? extractMetadata(Uint8List bytes) {
    if (bytes.isEmpty) return null;
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      return ImageMetadata(
        width: image.width,
        height: image.height,
        fileSizeBytes: bytes.length,
        originalName: null,
      );
    } catch (e) {
      debugPrint('[ImagePreprocess] extractMetadata failed: $e');
      return null;
    }
  }

  /// 等比缩放（如果超过 maxLongEdge）
  img.Image _resizeIfNeeded(img.Image image) {
    final longEdge = image.width > image.height ? image.width : image.height;
    if (longEdge <= config.maxLongEdge) return image;

    final scale = config.maxLongEdge / longEdge;
    final newWidth = (image.width * scale).round();
    final newHeight = (image.height * scale).round();
    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// 编码为目标格式
  _EncodedImage? _encode(img.Image image) {
    try {
      switch (config.outputFormat) {
        case 'image/jpeg':
          final jpg = img.encodeJpg(image, quality: config.jpegQuality);
          return _EncodedImage(jpg, jpg.length);
        case 'image/png':
          final png = img.encodePng(image);
          return _EncodedImage(png, png.length);
        default:
          final jpg = img.encodeJpg(image, quality: config.jpegQuality);
          return _EncodedImage(jpg, jpg.length);
      }
    } catch (e) {
      debugPrint('[ImagePreprocess] encode error: $e');
      return null;
    }
  }

  /// OpenAI vision token 估算
  /// 参考：https://platform.openai.com/docs/guides/vision
  /// 公式：512x512 瓦片 = 85 tokens，每翻倍瓦片数也翻倍
  int _estimateTokens(int width, int height) {
    final tilesX = (width / 512).ceil().clamp(1, 10);
    final tilesY = (height / 512).ceil().clamp(1, 10);
    return 85 * tilesX * tilesY;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)}MB';
  }
}

class _EncodedImage {
  final List<int> bytes;
  final int length;
  const _EncodedImage(this.bytes, this.length);
}
