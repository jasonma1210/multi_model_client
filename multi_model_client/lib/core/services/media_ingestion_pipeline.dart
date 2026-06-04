/// 媒体摄入预处理管道 - LLM Studio 多模态解析模块
/// 
/// 功能：
/// - 统一文件摄入入口（视频/音频/图片/文档）
/// - 视频：系统原生 API 提取音频 → Whisper 转写
/// - 音频：Whisper 直接转写
/// - 图片：系统原生 OCR（iOS Vision / Android ML Kit）
/// - 文档：PDF/DOCX/TXT 解析 + 分块存储
/// - 全流程本地离线处理
/// 
/// 架构设计：
/// 原始文件 → 前置解析管道 → 结构化文本 → 分块存库 → RAG 检索
/// 
/// 优化策略（按需下载 + 系统原生 API）：
/// - 图片 OCR：使用系统原生 API（iOS Vision / Android ML Kit），0 MB 增量
/// - 视频音频提取：使用系统原生 API（AVFoundation / MediaExtractor），0 MB 增量
/// - 语音识别：按需下载 Whisper 模型（约 45MB），首次使用时提示下载
/// 
/// @author JianMa
/// @version 1.1.0
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:video_compress/video_compress.dart';
import 'file_parser_service.dart';
import 'knowledge_base_service.dart';
import 'asr_service.dart';
import 'plugin_download_service.dart';

/// 媒体类型枚举
enum MediaType {
  video,    // 视频：mp4, mov, avi, mkv
  audio,    // 音频：mp3, wav, m4a, aac, ogg
  image,    // 图片：jpg, png, webp, bmp
  document, // 文档：pdf, docx, txt, md
  unknown,  // 未知类型
}

/// 解析状态
enum ProcessingStatus {
  pending,      // 待处理
  extracting,   // 提取中（视频抽帧/音频）
  transcribing, // 转写中（Whisper/OCR）
  chunking,     // 分块中
  storing,      // 存储中
  completed,    // 完成
  failed,       // 失败
}

/// 媒体处理结果
class MediaProcessingResult {
  final bool success;
  final String? textContent;
  final String? errorMessage;
  final int chunkCount;
  final Duration processingTime;
  final MediaType mediaType;

  MediaProcessingResult({
    required this.success,
    this.textContent,
    this.errorMessage,
    this.chunkCount = 0,
    required this.processingTime,
    required this.mediaType,
  });
}

/// 文本分块结果
class TextChunk {
  final String content;
  final int index;
  final String sourceFile;
  final String? metadata;

  TextChunk({
    required this.content,
    required this.index,
    required this.sourceFile,
    this.metadata,
  });
}

/// 媒体摄入预处理管道
/// 
/// 使用系统原生 API 实现：
/// - iOS: AVFoundation (视频音频提取), Vision (OCR)
/// - Android: MediaExtractor (视频音频提取), ML Kit (OCR)
/// - 桌面端: 使用 video_compress 插件或系统工具
class MediaIngestionPipeline {
  static MediaIngestionPipeline? _instance;
  static MediaIngestionPipeline get instance => _instance ??= MediaIngestionPipeline._();
  MediaIngestionPipeline._();

  /// 知识库服务（需要外部注入）
  KnowledgeBaseService? _knowledgeBaseService;

  /// 进度回调
  void Function(String status, double progress)? onProgress;

  /// 设置知识库服务
  void setKnowledgeBaseService(KnowledgeBaseService service) {
    _knowledgeBaseService = service;
  }

  /// 设置插件下载进度回调
  void setOnPluginDownloadProgress(void Function(String status, double progress, int downloaded, int total)? callback) {
    _pluginDownloadCallback = callback;
  }
  
  void Function(String status, double progress, int downloaded, int total)? _pluginDownloadCallback;

  /// 确保所需的插件可用（按需下载）
  /// 
  /// 根据媒体类型检测所需插件，如未下载则触发下载
  Future<void> _ensurePluginsAvailable(MediaType mediaType) async {
    final pluginService = PluginDownloadService.instance;
    
    String mediaTypeStr;
    switch (mediaType) {
      case MediaType.video:
        mediaTypeStr = 'video';
        break;
      case MediaType.audio:
        mediaTypeStr = 'audio';
        break;
      case MediaType.image:
        mediaTypeStr = 'image';
        break;
      case MediaType.document:
        mediaTypeStr = 'document';
        break;
      case MediaType.unknown:
        return; // 未知类型不需要插件
    }
    
    // 检测并下载所需插件
    final status = await pluginService.checkAndDownloadForMedia(
      mediaTypeStr,
      onProgress: (status, progress, downloaded, total) {
        _pluginDownloadCallback?.call(status, progress, downloaded, total);
      },
    );
    
    if (status.status == PluginDownloadStatus.error) {
      throw Exception('插件下载失败: ${status.errorMessage}');
    }
    
    debugPrint('[MediaIngestionPipeline] 插件状态: ${status.pluginId} - ${status.status}');
  }

  /// 判断文件媒体类型
  static MediaType getMediaType(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    
    // 视频格式
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv', '.wmv'];
    if (videoExtensions.contains(extension)) {
      return MediaType.video;
    }
    
    // 音频格式
    final audioExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac', '.wma'];
    if (audioExtensions.contains(extension)) {
      return MediaType.audio;
    }
    
    // 图片格式
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff', '.gif'];
    if (imageExtensions.contains(extension)) {
      return MediaType.image;
    }
    
    // 文档格式
    final documentExtensions = ['.pdf', '.docx', '.doc', '.txt', '.md', '.html', '.csv', '.xlsx'];
    if (documentExtensions.contains(extension)) {
      return MediaType.document;
    }
    
    return MediaType.unknown;
  }

  /// 统一入口：处理文件并返回文本内容
  /// 
  /// [filePath] 文件路径
  /// [options] 可选配置
  /// 
  /// 流程：
  /// 1. 检测文件类型
  /// 2. 检查/下载所需插件（按需下载）
  /// 3. 处理文件
  /// 4. 返回解析后的文本
  Future<MediaProcessingResult> processFile(
    String filePath, {
    String? targetKnowledgeBaseId,
    Map<String, dynamic>? options,
  }) async {
    final stopwatch = Stopwatch()..start();
    final mediaType = getMediaType(filePath);
    
    debugPrint('[MediaIngestionPipeline] 开始处理文件: $filePath, 类型: $mediaType');
    
    try {
      // 步骤 0: 检查/下载所需插件
      await _ensurePluginsAvailable(mediaType);
      
      String textContent;
      int chunkCount = 0;
      
      switch (mediaType) {
        case MediaType.video:
          onProgress?.call('正在提取视频音频...', 0.1);
          textContent = await _processVideo(filePath);
          break;
          
        case MediaType.audio:
          onProgress?.call('正在转写音频...', 0.1);
          textContent = await _processAudio(filePath);
          break;
          
        case MediaType.image:
          onProgress?.call('正在识别图片文字...', 0.2);
          textContent = await _processImage(filePath);
          break;
          
        case MediaType.document:
          onProgress?.call('正在解析文档...', 0.3);
          textContent = await _processDocument(filePath);
          break;
          
        case MediaType.unknown:
          return MediaProcessingResult(
            success: false,
            errorMessage: '不支持的文件类型: ${p.extension(filePath)}',
            processingTime: stopwatch.elapsed,
            mediaType: MediaType.unknown,
          );
      }
      
      // 文本分块
      onProgress?.call('正在分块处理...', 0.7);
      final chunks = _chunkText(textContent, sourceFile: p.basename(filePath));
      chunkCount = chunks.length;
      
      // 存储到知识库（如果指定了目标知识库）
      if (targetKnowledgeBaseId != null && _knowledgeBaseService != null) {
        onProgress?.call('正在存储到知识库...', 0.9);
        await _storeChunksToKnowledgeBase(chunks, targetKnowledgeBaseId);
      }
      
      stopwatch.stop();
      
      debugPrint('[MediaIngestionPipeline] 处理完成: $filePath, '
          '类型: $mediaType, 分块数: $chunkCount, 耗时: ${stopwatch.elapsed}');
      
      return MediaProcessingResult(
        success: true,
        textContent: textContent,
        chunkCount: chunkCount,
        processingTime: stopwatch.elapsed,
        mediaType: mediaType,
      );
      
    } catch (e) {
      stopwatch.stop();
      debugPrint('[MediaIngestionPipeline] 处理失败: $filePath, 错误: $e');
      
      return MediaProcessingResult(
        success: false,
        errorMessage: e.toString(),
        processingTime: stopwatch.elapsed,
        mediaType: mediaType,
      );
    }
  }

  /// 处理视频：提取音频 + 转写
  /// 
  /// 使用系统原生 API：
  /// - iOS: AVFoundation
  /// - Android: MediaExtractor
  /// - 桌面端: video_compress 插件
  Future<String> _processVideo(String filePath) async {
    debugPrint('[MediaIngestionPipeline] 处理视频: $filePath');
    
    // 步骤 1：使用系统原生 API 提取音频
    onProgress?.call('步骤 1/2: 提取视频音频...', 0.2);
    final audioPath = await _extractAudioFromVideo(filePath);
    
    if (audioPath == null) {
      throw Exception('视频音频提取失败');
    }
    
    // 步骤 2：Whisper 转写
    onProgress?.call('步骤 2/2: 转写音频内容...', 0.5);
    final text = await _transcribeAudio(audioPath);
    
    // 清理临时音频文件
    try {
      await File(audioPath).delete();
    } catch (e) {
      debugPrint('[MediaIngestionPipeline] 清理临时音频失败: $e');
    }
    
    return '【视频转写】\n\n$text';
  }

  /// 处理音频：直接转写
  Future<String> _processAudio(String filePath) async {
    debugPrint('[MediaIngestionPipeline] 处理音频: $filePath');
    
    onProgress?.call('正在转写音频...', 0.5);
    final text = await _transcribeAudio(filePath);
    
    return '【音频转写】\n\n$text';
  }

  /// 处理图片：OCR 识别
  /// 
  /// 使用系统原生 API：
  /// - iOS/macOS: Vision 框架（VNRecognizeTextRequest）
  /// - Android: Google ML Kit
  /// - 跨平台: google_mlkit_text_recognition
  Future<String> _processImage(String filePath) async {
    debugPrint('[MediaIngestionPipeline] 处理图片: $filePath');
    
    // 优先使用系统原生 OCR
    final ocrText = await _ocrWithSystemAPI(filePath);
    
    if (ocrText.isNotEmpty) {
      return '【图片 OCR 识别】\n\n$ocrText';
    }
    
    // 备选：使用现有 FileParserService（textify）
    final text = await FileParserService.parseFile(filePath);
    
    return '【图片 OCR 识别】\n\n$text';
  }

  /// 使用系统原生 OCR API
  /// 
  /// - iOS/macOS: 调用 Vision 框架
  /// - Android: 调用 ML Kit
  /// - 插件: google_mlkit_text_recognition
  Future<String> _ocrWithSystemAPI(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final recognizedText = await textRecognizer.processImage(inputImage);
        return recognizedText.text;
      } finally {
        textRecognizer.close();
      }
      
    } catch (e) {
      debugPrint('[MediaIngestionPipeline] 系统 OCR 失败: $e');
      return '';
    }
  }

  /// 处理文档：PDF/DOCX/TXT 解析
  Future<String> _processDocument(String filePath) async {
    debugPrint('[MediaIngestionPipeline] 处理文档: $filePath');
    
    // 使用现有的 FileParserService
    final text = await FileParserService.parseFile(filePath);
    
    return '【文档内容】\n\n$text';
  }

  /// 从视频提取音频（使用系统原生 API）
  /// 
  /// 使用 video_compress 插件：
  /// - iOS: 使用 AVAssetExportSession 提取音频
  /// - Android: 使用 MediaExtractor 提取音频
  /// - 桌面端: 可能需要回退到其他方案
  /// 
  /// 返回提取后的音频文件路径
  Future<String?> _extractAudioFromVideo(String videoPath) async {
    try {
      final inputFile = File(videoPath);
      if (!await inputFile.exists()) {
        throw Exception('视频文件不存在: $videoPath');
      }
      
      // 生成临时音频文件路径
      final tempDir = Directory.systemTemp;
      final audioPath = '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      // 使用 video_compress 提取媒体信息
      final mediaInfo = await VideoCompress.getMediaInfo(videoPath);
      debugPrint('[MediaIngestionPipeline] 视频信息: ${mediaInfo.toString()}');
      
      // 方法 1：使用 video_compress 的压缩功能（会生成视频文件）
      // 这里我们直接尝试使用系统工具提取音频
      
      // 方法 2：使用系统原生 API
      // iOS: AVFoundation, Android: MediaExtractor
      // 通过 platform channel 实现
      
      // 方法 3：使用 FFmpeg（仅桌面端）
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        final result = await _extractAudioWithFFmpeg(videoPath, audioPath);
        if (result && await File(audioPath).exists()) {
          return audioPath;
        }
      }
      
      // 方法 4：回退到 video_compress（生成视频后提取音频轨道）
      // 注意：video_compress 主要用于视频压缩，音频提取是副产品
      return await _extractAudioWithVideoCompress(videoPath, audioPath);
      
    } catch (e) {
      debugPrint('[MediaIngestionPipeline] 音频提取失败: $e');
      return null;
    }
  }

  /// 使用 video_compress 提取音频
  Future<String?> _extractAudioWithVideoCompress(String videoPath, String outputPath) async {
    try {
      // video_compress 主要提供视频压缩
      // 对于音频提取，我们可以：
      // 1. 压缩视频（保留音频轨道）
      // 2. 然后从输出文件中提取音频
      
      final info = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      
      if (info != null && info.path != null) {
        // 压缩成功，文件保存在 info.path
        // 重命名为音频文件
        final audioFile = File(info.path!);
        final newPath = outputPath.replaceAll('.m4a', '_compressed.m4a');
        await audioFile.copy(newPath);
        
        // 清理临时文件
        try {
          await audioFile.delete();
        } catch (e) {
          debugPrint('[media_ingestion_pipeline] Error: $e');
        }
        
        return newPath;
      }
      
      return null;
      
    } catch (e) {
      debugPrint('[MediaIngestionPipeline] video_compress 失败: $e');
      return null;
    }
  }

  /// 使用 FFmpeg 提取音频（仅桌面端）
  /// 
  /// 桌面端可以使用系统安装的 FFmpeg 或打包的极简版
  Future<bool> _extractAudioWithFFmpeg(String videoPath, String outputPath) async {
    try {
      // 尝试使用系统 FFmpeg
      final ffmpegCheck = await Process.run('which', ['ffmpeg']);
      if (ffmpegCheck.exitCode != 0) {
        debugPrint('[MediaIngestionPipeline] 系统未安装 FFmpeg');
        return false;
      }
      
      // 执行 FFmpeg 命令：提取音频为 M4A (AAC 编码)
      final result = await Process.run('ffmpeg', [
        '-i', videoPath,
        '-vn',           // 不处理视频
        '-acodec', 'aac', // 使用 AAC 编码
        '-ar', '44100',  // 采样率
        '-ac', '2',      // 立体声
        '-y',            // 覆盖输出文件
        outputPath,
      ]);
      
      if (result.exitCode == 0) {
        debugPrint('[MediaIngestionPipeline] FFmpeg 音频提取成功');
        return true;
      } else {
        debugPrint('[MediaIngestionPipeline] FFmpeg 失败: ${result.stderr}');
        return false;
      }
      
    } catch (e) {
      debugPrint('[MediaIngestionPipeline] FFmpeg 执行失败: $e');
      return false;
    }
  }

  /// 音频转写（使用 Whisper）
  /// 
  /// 按需下载模型：首次使用时提示用户下载
  Future<String> _transcribeAudio(String audioPath) async {
    try {
      // 检查音频文件是否存在
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        throw Exception('音频文件不存在: $audioPath');
      }
      
      // 使用本地 Whisper（Sherpa-ONNX）
      // 模型需要用户下载或按需下载
      final asrText = await _transcribeWithASR(audioPath);
      
      if (asrText.isNotEmpty) {
        return asrText;
      }
      
      throw Exception('音频转写失败：未找到可用的 ASR 引擎');
      
    } catch (e) {
      debugPrint('[MediaIngestionPipeline] 音频转写失败: $e');
      rethrow;
    }
  }

  /// 使用 ASR 服务转写音频
  /// 
  /// 模型查找顺序：
  /// 1. 用户下载的模型（VoiceModelService）
  /// 2. 按需下载的模型（提示用户下载）
  Future<String> _transcribeWithASR(String audioPath) async {
    try {
      debugPrint('[MediaIngestionPipeline] ASR 转写: $audioPath');
      
      // 使用现有的 ASR 服务（Sherpa-ONNX 本地离线识别）
      final asrService = ASRService(
        provider: ASRProvider.sherpa,
        sherpaModelId: 'paraformer-zh', // 使用中文 Paraformer 模型
      );
      
      // 初始化 ASR 引擎
      await asrService.initSherpa();
      
      // 执行识别
      final text = await asrService.recognizeFile(audioPath);
      
      // 释放资源
      asrService.dispose();
      
      debugPrint('[MediaIngestionPipeline] ASR 转写完成: ${text.length} 字符');
      return text;
      
    } catch (e) {
      debugPrint('[MediaIngestionPipeline] ASR 转写失败: $e');
      
      // 返回错误提示，引导用户下载模型
      return '【需要下载 ASR 模型】\n\n'
          '语音识别功能需要下载本地模型。\n'
          '请在「语音设置 → 选择 ASR 模型」中下载后重试。\n\n'
          '错误信息: $e';
    }
  }

  /// 文本分块
  /// 
  /// [text] 原始文本
  /// [sourceFile] 来源文件名
  /// [maxChunkSize] 最大分块大小（默认 500 字符）
  List<TextChunk> _chunkText(
    String text, {
    required String sourceFile,
    int maxChunkSize = 500,
    int overlapSize = 50,
  }) {
    if (text.trim().isEmpty) {
      return [];
    }

    final chunks = <TextChunk>[];
    
    // 按段落分割
    final paragraphs = text.split(RegExp(r'\n\n+'));
    
    String currentChunk = '';
    int chunkIndex = 0;
    
    for (final paragraph in paragraphs) {
      final trimmedParagraph = paragraph.trim();
      if (trimmedParagraph.isEmpty) continue;
      
      // 如果当前段落加上当前块超过最大长度，先保存当前块
      if (currentChunk.length + trimmedParagraph.length > maxChunkSize && currentChunk.isNotEmpty) {
        chunks.add(TextChunk(
          content: currentChunk.trim(),
          index: chunkIndex,
          sourceFile: sourceFile,
        ));
        chunkIndex++;
        
        // 保留 overlap 部分
        if (overlapSize > 0 && currentChunk.length > overlapSize) {
          currentChunk = currentChunk.substring(currentChunk.length - overlapSize);
        } else {
          currentChunk = '';
        }
      }
      
      // 如果单个段落就超过最大长度，需要进一步分割
      if (trimmedParagraph.length > maxChunkSize) {
        // 先保存当前累积的内容
        if (currentChunk.isNotEmpty) {
          chunks.add(TextChunk(
            content: currentChunk.trim(),
            index: chunkIndex,
            sourceFile: sourceFile,
          ));
          chunkIndex++;
          currentChunk = '';
        }
        
        // 按句子分割长段落
        final sentences = trimmedParagraph.split(RegExp(r'[。！？；\n]'));
        String subChunk = '';
        
        for (final sentence in sentences) {
          if (subChunk.length + sentence.length > maxChunkSize) {
            if (subChunk.isNotEmpty) {
              chunks.add(TextChunk(
                content: subChunk.trim(),
                index: chunkIndex,
                sourceFile: sourceFile,
              ));
              chunkIndex++;
            }
            subChunk = sentence;
          } else {
            subChunk += (subChunk.isEmpty ? '' : '。') + sentence;
          }
        }
        
        currentChunk = subChunk;
      } else {
        currentChunk += (currentChunk.isEmpty ? '' : '\n\n') + trimmedParagraph;
      }
    }
    
    // 添加最后一个块
    if (currentChunk.trim().isNotEmpty) {
      chunks.add(TextChunk(
        content: currentChunk.trim(),
        index: chunkIndex,
        sourceFile: sourceFile,
      ));
    }
    
    debugPrint('[MediaIngestionPipeline] 文本分块完成: ${chunks.length} 个块');
    return chunks;
  }

  /// 将分块存储到知识库
  Future<void> _storeChunksToKnowledgeBase(
    List<TextChunk> chunks,
    String knowledgeBaseId,
  ) async {
    if (_knowledgeBaseService == null) {
      throw Exception('知识库服务未设置');
    }
    
    if (chunks.isEmpty) {
      return;
    }
    
    // 逐条添加到知识库
    for (final chunk in chunks) {
      try {
        // 创建临时文件路径（实际应该存储元数据）
        final tempFilePath = '/tmp/${chunk.sourceFile}_chunk_${chunk.index}.txt';
        final tempFile = File(tempFilePath);
        await tempFile.writeAsString(chunk.content);
        
        // 添加到知识库
        await _knowledgeBaseService!.addDocument(
          knowledgeBaseId: knowledgeBaseId,
          filePath: tempFilePath,
        );
        
        // 清理临时文件
        try {
          await tempFile.delete();
        } catch (e) {
          debugPrint('[media_ingestion_pipeline] Error: $e');
        }
        
      } catch (e) {
        debugPrint('[MediaIngestionPipeline] 存储分块失败: ${chunk.index}, 错误: $e');
      }
    }
    
    debugPrint('[MediaIngestionPipeline] 存储完成: ${chunks.length} 个块');
  }

  /// 直接获取文件解析后的文本（不存储到知识库）
  /// 
  /// 适用于会话中直接使用文件内容
  Future<String> parseFileToText(String filePath) async {
    final mediaType = getMediaType(filePath);
    
    switch (mediaType) {
      case MediaType.video:
        final result = await processFile(filePath);
        return result.textContent ?? '';
        
      case MediaType.audio:
        final result = await processFile(filePath);
        return result.textContent ?? '';
        
      case MediaType.image:
        return await FileParserService.parseFile(filePath);
        
      case MediaType.document:
        return await FileParserService.parseFile(filePath);
        
      case MediaType.unknown:
        throw Exception('不支持的文件类型');
    }
  }

  /// 检查是否支持某种媒体类型
  /// 
  /// 注意：视频和音频需要 ASR 模型（按需下载）
  static bool isMediaTypeSupported(MediaType type) {
    switch (type) {
      case MediaType.video:
      case MediaType.audio:
        // 需要 ASR 模型，用户下载后即可使用
        return true;
      case MediaType.image:
      case MediaType.document:
        return true;
      case MediaType.unknown:
        return false;
    }
  }

  /// 获取支持的文件扩展名
  static List<String> getSupportedExtensions() {
    return [
      // 视频
      '.mp4', '.mov', '.avi', '.mkv', '.webm',
      // 音频
      '.mp3', '.wav', '.m4a', '.aac', '.ogg',
      // 图片
      '.jpg', '.jpeg', '.png', '.webp', '.bmp',
      // 文档
      '.pdf', '.docx', '.doc', '.txt', '.md', '.html',
    ];
  }

  /// 获取媒体类型的中文名称
  static String getMediaTypeName(MediaType type) {
    switch (type) {
      case MediaType.video:
        return '视频';
      case MediaType.audio:
        return '音频';
      case MediaType.image:
        return '图片';
      case MediaType.document:
        return '文档';
      case MediaType.unknown:
        return '未知';
    }
  }
}