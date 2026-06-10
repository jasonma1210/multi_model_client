import 'dart:convert' as dart_convert;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// ════════════════════════════════════════════════════════════════
// 音频格式检测 + MIME 类型映射 + 跨平台转码工具
//
// 解决的问题：
// 1. 文件扩展名可能不准确（iOS 录音可能 .wav 实际是 M4A 容器）
// 2. 不同 TTS 服务支持的参考音频格式不同
// 3. 需要根据实际音频格式设置正确的 MIME 类型
// 4. 不支持的格式需要转码为 WAV
// ════════════════════════════════════════════════════════════════

/// 音频格式枚举
enum AudioFormat {
  wav,    // RIFF/WAVE
  mp3,    // MPEG Audio Layer 3
  m4a,    // MPEG-4 / M4A / AAC 容器
  aac,    // Raw AAC (ADTS)
  ogg,    // OGG Vorbis/Opus
  flac,   // Free Lossless Audio Codec
  pcm,    // Raw PCM (无文件头)
  webm,   // WebM (Opus/Vorbis)
  unknown;

  /// 获取标准 MIME 类型
  String get mimeType => switch (this) {
    wav  => 'audio/wav',
    mp3  => 'audio/mpeg',
    m4a  => 'audio/mp4',      // M4A/AAC 容器
    aac  => 'audio/aac',      // Raw AAC (ADTS)
    ogg  => 'audio/ogg',
    flac => 'audio/flac',
    pcm  => 'audio/pcm',      // 非 IANA 标准，但常用
    webm => 'audio/webm',
    unknown => 'application/octet-stream',
  };

  /// 获取常见文件扩展名
  String get extension => switch (this) {
    wav  => 'wav',
    mp3  => 'mp3',
    m4a  => 'm4a',
    aac  => 'aac',
    ogg  => 'ogg',
    flac => 'flac',
    pcm  => 'pcm',
    webm => 'webm',
    unknown => 'bin',
  };
}

/// TTS 服务对参考音频格式的支持情况
enum TTSServiceType {
  mimo,        // MiMo TTS VoiceClone API
  cosyvoice,   // CosyVoice 本地 Docker
  fishaudio,   // Fish Audio 本地 MLX
  volcano,     // 火山引擎（字节跳动）
}

/// 各 TTS 服务支持的参考音频格式
const _supportedFormats = <TTSServiceType, Set<AudioFormat>>{
  TTSServiceType.mimo: {AudioFormat.wav, AudioFormat.mp3, AudioFormat.m4a, AudioFormat.aac, AudioFormat.ogg, AudioFormat.flac},
  TTSServiceType.cosyvoice: {AudioFormat.wav, AudioFormat.mp3, AudioFormat.m4a, AudioFormat.flac},
  TTSServiceType.fishaudio: {AudioFormat.wav, AudioFormat.mp3, AudioFormat.m4a, AudioFormat.flac},
  TTSServiceType.volcano: {AudioFormat.wav, AudioFormat.mp3, AudioFormat.ogg, AudioFormat.m4a, AudioFormat.aac, AudioFormat.pcm},
};

class AudioFormatUtils {
  static const String _tag = 'AudioFormatUtils';

  // ════════════════════════════════════════════════════════════
  // 1. 音频格式检测（基于文件头魔数）
  // ════════════════════════════════════════════════════════════

  /// 基于文件头魔数检测音频格式
  ///
  /// 优先使用文件头魔数（更可靠），扩展名作为后备
  /// 读取前 12 字节即可识别大多数格式
  static Future<AudioFormat> detectFormat(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint('[$_tag] 文件不存在: $filePath');
      return AudioFormat.unknown;
    }

    try {
      final randomAccess = await file.open();
      final header = await randomAccess.read(12);
      await randomAccess.close();

      if (header.length < 4) {
        return _detectByExtension(filePath);
      }

      final format = _detectByMagicBytes(header);
      if (format != AudioFormat.unknown) {
        debugPrint('[$_tag] 魔数检测: $filePath → ${format.name}');
        return format;
      }

      // 魔数未识别，尝试扩展名
      final extFormat = _detectByExtension(filePath);
      debugPrint('[$_tag] 魔数未识别，扩展名检测: $filePath → ${extFormat.name}');
      return extFormat;
    } catch (e) {
      debugPrint('[$_tag] 格式检测失败: $e');
      return _detectByExtension(filePath);
    }
  }

  /// 基于魔数检测音频格式
  ///
  /// 常见音频文件头：
  /// - WAV:  RIFF....WAVE  (52 49 46 46 xx xx xx xx 57 41 56 45)
  /// - MP3:  ID3 或 FF FB / FF F3 / FF F2
  /// - M4A:  ftyp + brand (66 74 79 70) — 可能偏移 4 字节
  /// - AAC:  ADTS 同步字   (FF F1 / FF F9)
  /// - OGG:  OggS          (4F 67 67 53)
  /// - FLAC: fLaC           (66 4C 61 43)
  /// - WebM: 1A 45 DF A3   (EBML header)
  static AudioFormat _detectByMagicBytes(Uint8List header) {
    if (header.length < 4) return AudioFormat.unknown;

    // WAV: RIFF....WAVE
    if (header[0] == 0x52 && header[1] == 0x49 &&
        header[2] == 0x46 && header[3] == 0x46) {
      if (header.length >= 12 &&
          header[8] == 0x57 && header[9] == 0x41 &&
          header[10] == 0x56 && header[11] == 0x45) {
        return AudioFormat.wav;
      }
      // RIFF 但不是 WAVE，可能是其他格式
      return AudioFormat.wav;
    }

    // MP3: ID3 tag 或 MPEG sync word
    if (header[0] == 0x49 && header[1] == 0x44 && header[2] == 0x33) {
      return AudioFormat.mp3; // ID3 tag
    }
    if (header[0] == 0xFF && (header[1] & 0xE0) == 0xE0) {
      return AudioFormat.mp3; // MPEG sync word (FF FB/F3/F2)
    }

    // M4A/MP4: ftyp box
    // MP4 文件结构: [4字节大小][ftyp][4字节brand]
    if (header.length >= 8) {
      // ftyp 可能在偏移 4 的位置
      if (header[4] == 0x66 && header[5] == 0x74 &&
          header[6] == 0x79 && header[7] == 0x70) {
        return AudioFormat.m4a;
      }
    }
    // 某些 M4A 文件以 00 00 00 开头（box size），然后是 ftyp
    if (header.length >= 12 &&
        header[4] == 0x66 && header[5] == 0x74 &&
        header[6] == 0x79 && header[7] == 0x70) {
      return AudioFormat.m4a;
    }

    // AAC: ADTS 同步字
    if (header[0] == 0xFF && (header[1] & 0xF0) == 0xF0) {
      return AudioFormat.aac;
    }

    // OGG: OggS
    if (header[0] == 0x4F && header[1] == 0x67 &&
        header[2] == 0x67 && header[3] == 0x53) {
      return AudioFormat.ogg;
    }

    // FLAC: fLaC
    if (header[0] == 0x66 && header[1] == 0x4C &&
        header[2] == 0x61 && header[3] == 0x43) {
      return AudioFormat.flac;
    }

    // WebM: EBML header
    if (header[0] == 0x1A && header[1] == 0x45 &&
        header[2] == 0xDF && header[3] == 0xA3) {
      return AudioFormat.webm;
    }

    return AudioFormat.unknown;
  }

  /// 基于文件扩展名检测音频格式（后备方案）
  static AudioFormat _detectByExtension(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    return switch (ext) {
      'wav' || 'wave' => AudioFormat.wav,
      'mp3' || 'mpeg' => AudioFormat.mp3,
      'm4a' => AudioFormat.m4a,
      'aac' => AudioFormat.aac,
      'ogg' || 'oga' => AudioFormat.ogg,
      'flac' => AudioFormat.flac,
      'pcm' || 'raw' => AudioFormat.pcm,
      'webm' => AudioFormat.webm,
      _ => AudioFormat.unknown,
    };
  }

  // ════════════════════════════════════════════════════════════
  // 2. MIME 类型获取（基于实际格式检测）
  // ════════════════════════════════════════════════════════════

  /// 获取音频文件的 MIME 类型
  ///
  /// 优先使用魔数检测实际格式，确保 MIME 类型与实际内容匹配
  /// 这对于 iOS 录音文件特别重要（扩展名可能不准确）
  static Future<String> getMimeType(String filePath) async {
    final format = await detectFormat(filePath);
    return format.mimeType;
  }

  /// 构建 DataURL 格式（用于 MiMo VoiceClone API）
  ///
  /// 格式: data:{MIME_TYPE};base64,{BASE64_AUDIO}
  static Future<String> buildDataUrl(String filePath) async {
    final file = File(filePath);
    final audioBytes = await file.readAsBytes();
    final base64Audio = base64Encode(audioBytes);
    final mimeType = await getMimeType(filePath);
    return 'data:$mimeType;base64,$base64Audio';
  }

  /// 简单 Base64 编码（避免额外导入）
  static String base64Encode(List<int> bytes) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final buf = StringBuffer();
    for (var i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      buf.write(chars[(b0 >> 2) & 0x3F]);
      buf.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      buf.write(i + 1 < bytes.length ? chars[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      buf.write(i + 2 < bytes.length ? chars[b2 & 0x3F] : '=');
    }
    return buf.toString();
  }

  // ════════════════════════════════════════════════════════════
  // 3. 格式兼容性检查 + 转码
  // ════════════════════════════════════════════════════════════

  /// 检查音频格式是否被目标 TTS 服务支持
  static bool isFormatSupported(AudioFormat format, TTSServiceType service) {
    return _supportedFormats[service]?.contains(format) ?? false;
  }

  /// 获取 TTS 服务支持的音频格式列表
  static Set<AudioFormat> getSupportedFormats(TTSServiceType service) {
    return _supportedFormats[service] ?? {};
  }

  /// 确保音频文件与目标 TTS 服务兼容
  ///
  /// 如果格式不支持，自动转码为 WAV（16kHz, 单声道, PCM 16-bit）
  /// 返回兼容的文件路径（可能是原始路径或转码后的新路径）
  static Future<String> ensureCompatibility(
    String filePath,
    TTSServiceType service,
  ) async {
    final format = await detectFormat(filePath);
    debugPrint('[$_tag] 检测到格式: ${format.name}, 目标服务: ${service.name}');

    if (isFormatSupported(format, service)) {
      debugPrint('[$_tag] ✅ 格式兼容，无需转码');
      return filePath;
    }

    debugPrint('[$_tag] ⚠️ 格式不兼容（${format.name}），需要转码为 WAV');
    return await transcodeToWav(filePath);
  }

  /// 将音频文件转码为 WAV 格式（16kHz, 单声道, PCM 16-bit）
  ///
  /// 转码策略（按优先级）：
  /// 1. macOS/Linux: 使用系统 ffmpeg
  /// 2. iOS/Android: 使用 just_audio 解码 + 手动编码 WAV
  /// 3. 后备: 返回原始文件（让 TTS 服务尝试处理）
  static Future<String> transcodeToWav(String inputPath) async {
    debugPrint('[$_tag] 开始转码: $inputPath → WAV');

    // 方案 1: 使用系统 ffmpeg（macOS/Linux）
    if (Platform.isMacOS || Platform.isLinux) {
      try {
        final outputPath = await _getTempWavPath();
        final result = await Process.run('ffmpeg', [
          '-i', inputPath,
          '-acodec', 'pcm_s16le',
          '-ac', '1',
          '-ar', '16000',
          '-y',
          outputPath,
        ]);

        if (result.exitCode == 0) {
          debugPrint('[$_tag] ✅ ffmpeg 转码成功: $outputPath');
          return outputPath;
        } else {
          debugPrint('[$_tag] ⚠️ ffmpeg 转码失败: ${result.stderr}');
        }
      } catch (e) {
        debugPrint('[$_tag] ⚠️ ffmpeg 不可用: $e');
      }
    }

    // 方案 2: iOS/Android — 使用 just_audio 解码 + 手动编码 WAV
    // 注意：just_audio 不提供原始 PCM 数据访问，此方案不可行
    // 改用方案 3: 直接返回原始文件，依赖正确的 MIME 类型

    // 方案 3: 后备 — 返回原始文件
    // 大多数 TTS 服务支持多种格式，只要 MIME 类型正确即可
    debugPrint('[$_tag] ⚠️ 无法转码，返回原始文件（依赖正确 MIME 类型）');
    return inputPath;
  }

  /// 生成临时 WAV 文件路径
  static Future<String> _getTempWavPath() async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/transcode_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  // ════════════════════════════════════════════════════════════
  // 4. 便捷方法：一步完成格式检测 + 兼容性保证 + DataURL 构建
  // ════════════════════════════════════════════════════════════

  /// 为 MiMo VoiceClone API 准备参考音频 DataURL
  ///
  /// 完整流程：
  /// 1. 检测实际音频格式（魔数 + 扩展名）
  /// 2. 检查格式兼容性
  /// 3. 不兼容则转码为 WAV
  /// 4. 读取文件并构建 DataURL
  static Future<String> prepareMiMoVoiceDataUrl(String filePath) async {
    debugPrint('[$_tag] prepareMiMoVoiceDataUrl() 开始: filePath=$filePath');

    // 1. 确保格式兼容
    final compatiblePath = await ensureCompatibility(filePath, TTSServiceType.mimo);
    debugPrint('[$_tag] prepareMiMoVoiceDataUrl() ensureCompatibility 完成: compatiblePath=$compatiblePath');

    // 2. 读取文件
    final file = File(compatiblePath);
    if (!await file.exists()) {
      debugPrint('[$_tag] prepareMiMoVoiceDataUrl() ❌ 文件不存在: $compatiblePath');
      throw Exception('参考音频文件不存在: $compatiblePath');
    }
    debugPrint('[$_tag] prepareMiMoVoiceDataUrl() 文件存在');

    final audioBytes = await file.readAsBytes();
    debugPrint('[$_tag] prepareMiMoVoiceDataUrl() 读取文件: ${audioBytes.length} bytes');
    if (audioBytes.length > 10 * 1024 * 1024) {
      throw Exception('参考音频文件过大（最大 10MB），当前: ${(audioBytes.length / 1024 / 1024).toStringAsFixed(2)}MB');
    }

    // 3. 检测实际格式并获取 MIME 类型
    final mimeType = await getMimeType(compatiblePath);
    debugPrint('[$_tag] prepareMiMoVoiceDataUrl() mimeType=$mimeType');
    final base64Audio = base64Encode(audioBytes);
    debugPrint('[$_tag] prepareMiMoVoiceDataUrl() base64 长度: ${base64Audio.length}');
    final voiceData = 'data:$mimeType;base64,$base64Audio';

    debugPrint('[$_tag] prepareMiMoVoiceDataUrl() ✅ DataURL 构建完成: '
        'totalLength=${voiceData.length}, format=${(await detectFormat(compatiblePath)).name}, '
        'mimeType=$mimeType, audioSize=${audioBytes.length} bytes');

    return voiceData;
  }

  /// 为火山引擎 API 准备参考音频
  ///
  /// 火山引擎需要 audio_format 字段和 base64 编码的音频数据
  static Future<({String audioBytes, String audioFormat})> prepareVolcanoAudio(String filePath) async {
    final compatiblePath = await ensureCompatibility(filePath, TTSServiceType.volcano);
    final format = await detectFormat(compatiblePath);

    final file = File(compatiblePath);
    final audioBytes = await file.readAsBytes();
    final base64Audio = dart_convert.base64Encode(audioBytes);

    // 火山引擎 audio_format 字段值
    final formatStr = switch (format) {
      AudioFormat.wav => 'wav',
      AudioFormat.mp3 => 'mp3',
      AudioFormat.m4a => 'm4a',
      AudioFormat.aac => 'aac',
      AudioFormat.ogg => 'ogg',
      AudioFormat.pcm => 'pcm',
      _ => 'wav',  // 默认 wav
    };

    return (audioBytes: base64Audio, audioFormat: formatStr);
  }
}
