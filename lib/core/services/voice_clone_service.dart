// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'local_proxy_service.dart';

/// 克隆音色状态
enum CloneVoiceStatus {
  pending, // 等待处理
  processing, // 正在克隆处理
  completed, // 克隆完成
  failed, // 克隆失败
}

/// 克隆音色数据模型
class ClonedVoice {
  final String id;
  final String name;
  final String referenceAudioPath;
  final DateTime createdAt;
  final CloneVoiceStatus status;
  final String? errorMessage;

  ClonedVoice({
    required this.id,
    required this.name,
    required this.referenceAudioPath,
    required this.createdAt,
    this.status = CloneVoiceStatus.completed,
    this.errorMessage,
  });

  bool get isReady => status == CloneVoiceStatus.completed;
  bool get isProcessing => status == CloneVoiceStatus.processing;
  bool get isFailed => status == CloneVoiceStatus.failed;

  ClonedVoice copyWith({
    String? id,
    String? name,
    String? referenceAudioPath,
    DateTime? createdAt,
    CloneVoiceStatus? status,
    String? errorMessage,
  }) {
    return ClonedVoice(
      id: id ?? this.id,
      name: name ?? this.name,
      referenceAudioPath: referenceAudioPath ?? this.referenceAudioPath,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'referenceAudioPath': referenceAudioPath,
        'createdAt': createdAt.toIso8601String(),
        'status': status.index,
        'errorMessage': errorMessage,
      };

  factory ClonedVoice.fromJson(Map<String, dynamic> json) => ClonedVoice(
        id: json['id'] as String,
        name: json['name'] as String,
        referenceAudioPath: json['referenceAudioPath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: CloneVoiceStatus
            .values[json['status'] as int? ?? CloneVoiceStatus.completed.index],
        errorMessage: json['errorMessage'] as String?,
      );
}

/// 克隆任务进度通知
class CloneTaskProgress {
  final String taskId;
  final CloneVoiceStatus status;
  final String? message;
  final double? progress; // 0.0 ~ 1.0

  const CloneTaskProgress({
    required this.taskId,
    required this.status,
    this.message,
    this.progress,
  });
}

/// 语音克隆服务 - 管理克隆音色的持久化、异步克隆处理和参考音频文件存储
class VoiceCloneService {
  static const String _tag = 'VoiceCloneService';
  static const String _clonedVoicesKey = 'cloned_voices';
  static const String _mimoApiKeyKey = 'mimo_api_key';
  static const String _mimoBaseUrlKey = 'mimo_base_url';
  static const String _defaultBaseUrl = 'https://api.xiaomimimo.com/v1';

  // 进度回调列表
  final List<void Function(CloneTaskProgress)> _progressCallbacks = [];

  /// 注册进度回调
  void addProgressCallback(void Function(CloneTaskProgress) callback) {
    _progressCallbacks.add(callback);
  }

  /// 移除进度回调
  void removeProgressCallback(void Function(CloneTaskProgress) callback) {
    _progressCallbacks.remove(callback);
  }

  void _notifyProgress(CloneTaskProgress progress) {
    for (final cb in _progressCallbacks) {
      cb(progress);
    }
  }

  /// 获取所有克隆音色
  Future<List<ClonedVoice>> getClonedVoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final voicesJson = prefs.getString(_clonedVoicesKey);
      if (voicesJson == null || voicesJson.isEmpty) return [];
      final List<dynamic> voicesList = jsonDecode(voicesJson);
      return voicesList
          .map((e) => ClonedVoice.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[$_tag] Failed to load cloned voices: $e');
      return [];
    }
  }

  /// 添加克隆音色
  Future<void> addClonedVoice(ClonedVoice voice) async {
    final voices = await getClonedVoices();
    voices.add(voice);
    final jsonStr = jsonEncode(voices.map((e) => e.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clonedVoicesKey, jsonStr);
    debugPrint('[$_tag] Added cloned voice: ${voice.name}');
  }

  /// 更新克隆音色状态
  Future<void> updateClonedVoice(ClonedVoice voice) async {
    final voices = await getClonedVoices();
    final idx = voices.indexWhere((v) => v.id == voice.id);
    if (idx >= 0) {
      voices[idx] = voice;
    }
    final jsonStr = jsonEncode(voices.map((e) => e.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clonedVoicesKey, jsonStr);
    debugPrint('[$_tag] Updated cloned voice: ${voice.name}, status: ${voice.status}');
  }

  /// 删除克隆音色
  Future<void> deleteClonedVoice(String id) async {
    final voices = await getClonedVoices();
    final target = voices.firstWhere((v) => v.id == id,
        orElse: () => throw Exception('Voice not found: $id'));
    final audioFile = File(target.referenceAudioPath);
    if (await audioFile.exists()) await audioFile.delete();
    voices.removeWhere((v) => v.id == id);
    final jsonStr = jsonEncode(voices.map((e) => e.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clonedVoicesKey, jsonStr);
  }

  /// 保存参考音频文件，返回保存后的文件路径
  Future<String> saveReferenceAudio(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cloneDir = Directory('${appDir.path}/voice_clones');
    if (!await cloneDir.exists()) await cloneDir.create(recursive: true);
    final ext = sourcePath.toLowerCase().split('.').last;
    final dest =
        '${cloneDir.path}/ref_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(sourcePath).copy(dest);
    return dest;
  }

  /// 验证参考音频文件
  Future<(bool, String?)> validateReferenceAudio(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return (false, '音频文件不存在');
    final size = await file.length();
    if (size > 10 * 1024 * 1024) return (false, '音频文件超过 10MB 限制');
    final ext = filePath.toLowerCase().split('.').last;
    if (ext != 'mp3' && ext != 'wav' && ext != 'm4a') {
      return (false, '仅支持 mp3、wav 或 m4a 格式');
    }
    return (true, null);
  }

  /// 异步提交克隆任务
  ///
  /// 流程：
  /// 1. 保存参考音频
  /// 2. 创建 pending 状态的克隆音色记录
  /// 3. 异步调用 MiMo API 进行测试合成验证
  /// 4. 成功后更新状态为 completed，失败则标记 failed
  Future<ClonedVoice> submitCloneTask({
    required String audioPath,
    required String voiceName,
  }) async {
    // 1. 验证音频
    final (isValid, errorMsg) = await validateReferenceAudio(audioPath);
    if (!isValid) {
      throw Exception(errorMsg ?? '音频验证失败');
    }

    // 2. 保存参考音频
    final savedPath = await saveReferenceAudio(audioPath);

    // 3. 创建克隆音色记录（processing 状态）
    final clonedVoice = ClonedVoice(
      id: 'clone_${DateTime.now().millisecondsSinceEpoch}',
      name: voiceName,
      referenceAudioPath: savedPath,
      createdAt: DateTime.now(),
      status: CloneVoiceStatus.processing,
    );

    await addClonedVoice(clonedVoice);

    _notifyProgress(CloneTaskProgress(
      taskId: clonedVoice.id,
      status: CloneVoiceStatus.processing,
      message: '正在上传音频并处理克隆...',
      progress: 0.1,
    ));

    // 4. 异步执行克隆验证（不 await，在后台执行）
    _executeCloneVerification(clonedVoice);

    return clonedVoice;
  }

  /// 后台执行克隆验证 - 调用 MiMo API 发送测试文本验证克隆效果
  Future<void> _executeCloneVerification(ClonedVoice voice) async {
    try {
      _notifyProgress(CloneTaskProgress(
        taskId: voice.id,
        status: CloneVoiceStatus.processing,
        message: '正在上传参考音频至服务器...',
        progress: 0.3,
      ));

      // 读取 API Key
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString(_mimoApiKeyKey);
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('MiMo API Key 未配置，请在设置中配置');
      }

      // 读取自定义 Base URL（支持代理/镜像）
      final customBaseUrl = prefs.getString(_mimoBaseUrlKey);
      final useLocalProxy = prefs.getBool('use_local_proxy') ?? false;
      
      String baseUrl;
      if (useLocalProxy && localProxyService.status == ProxyServiceStatus.running) {
        // 使用本地代理
        baseUrl = localProxyService.proxyUrl ?? _defaultBaseUrl;
        debugPrint('[$_tag] Using local proxy: $baseUrl');
      } else if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
        baseUrl = customBaseUrl;
      } else {
        baseUrl = _defaultBaseUrl;
      }
      final apiUrl = '$baseUrl/chat/completions';

      // 读取参考音频并编码
      final audioFile = File(voice.referenceAudioPath);
      if (!await audioFile.exists()) {
        throw Exception('参考音频文件不存在');
      }

      final audioBytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(audioBytes);

      if (base64Audio.length > 10 * 1024 * 1024) {
        throw Exception('音频文件过大（最大 10MB）');
      }

      // voice 字段必须是 DataURL 格式: data:{MIME_TYPE};base64,$BASE64_AUDIO
      // MIME 类型必须与实际音频格式匹配：audio/wav 或 audio/mpeg
      final ext = voice.referenceAudioPath.toLowerCase().split('.').last;
      final mimeType = (ext == 'mp3' || ext == 'mpeg') ? 'audio/mpeg' : 'audio/wav';
      final voiceData = 'data:$mimeType;base64,$base64Audio';

      debugPrint('[$_tag] Clone request: url=$apiUrl, audioSize=${audioBytes.length} bytes');

      _notifyProgress(CloneTaskProgress(
        taskId: voice.id,
        status: CloneVoiceStatus.processing,
        message: '正在远程克隆处理中...',
        progress: 0.5,
      ));

      // 调用 MiMo API 进行测试合成（支持重试）
      // 参考实现: VoiceClone 模式下，user 消息可选（仅在有风格指令时添加），assistant 消息为合成文本
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 120);

      final response = await _postWithRetry(dio, apiUrl, apiKey, {
        'model': 'mimo-v2.5-tts-voiceclone',
        'messages': [
          {
            'role': 'assistant',
            'content': '你好，这是语音克隆测试。',
          },
        ],
        'audio': {
          'format': 'wav',
          'voice': voiceData,
        },
      });

      _notifyProgress(CloneTaskProgress(
        taskId: voice.id,
        status: CloneVoiceStatus.processing,
        message: '正在接收克隆结果...',
        progress: 0.8,
      ));

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;

        if (choices != null && choices.isNotEmpty) {
          // 克隆验证成功 - 保存测试音频
          final message = choices[0]['message'] as Map<String, dynamic>?;
          final audio = message?['audio'] as Map<String, dynamic>?;
          final base64Data = audio?['data'] as String?;

          if (base64Data != null && base64Data.isNotEmpty) {
            final resultAudioBytes = base64Decode(base64Data);
            final appDir = await getApplicationDocumentsDirectory();
            final testAudioPath =
                '${appDir.path}/voice_clones/test_${voice.id}.wav';
            await File(testAudioPath).writeAsBytes(resultAudioBytes);
            debugPrint('[$_tag] Clone test audio saved: $testAudioPath');
          }

          // 更新状态为完成
          final updatedVoice = voice.copyWith(
            status: CloneVoiceStatus.completed,
          );
          await updateClonedVoice(updatedVoice);

          _notifyProgress(CloneTaskProgress(
            taskId: voice.id,
            status: CloneVoiceStatus.completed,
            message: '语音克隆 "${voice.name}" 完成!',
            progress: 1.0,
          ));
        } else {
          throw Exception('服务器返回数据为空');
        }
      } else {
        throw Exception(
            '服务器返回错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errMsg = _handleDioError(e);
      debugPrint('[$_tag] Clone DioException: type=${e.type}, message=${e.message}');
      final updatedVoice = voice.copyWith(
        status: CloneVoiceStatus.failed,
        errorMessage: errMsg,
      );
      await updateClonedVoice(updatedVoice);

      _notifyProgress(CloneTaskProgress(
        taskId: voice.id,
        status: CloneVoiceStatus.failed,
        message: '克隆失败: $errMsg',
      ));
    } catch (e) {
      debugPrint('[$_tag] Clone error: $e');
      final updatedVoice = voice.copyWith(
        status: CloneVoiceStatus.failed,
        errorMessage: e.toString(),
      );
      await updateClonedVoice(updatedVoice);

      _notifyProgress(CloneTaskProgress(
        taskId: voice.id,
        status: CloneVoiceStatus.failed,
        message: '克隆失败: $e',
      ));
    }
  }

  /// 带重试的 POST 请求（网络超时/连接错误自动重试 2 次）
  Future<Response<dynamic>> _postWithRetry(
    Dio dio,
    String url,
    String apiKey,
    Map<String, dynamic> body, {
    int maxRetries = 2,
  }) async {
    DioException? lastError;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          debugPrint('[$_tag] Retry attempt $attempt/$maxRetries...');
          await Future.delayed(Duration(seconds: attempt * 2));
        }
        return await dio.post(
          url,
          data: body,
          options: Options(
            headers: {
              'api-key': apiKey,
              'Content-Type': 'application/json',
            },
            responseType: ResponseType.json,
          ),
        );
      } on DioException catch (e) {
        lastError = e;
        // 只在可重试的错误类型时重试
        if (!_shouldRetry(e) || attempt == maxRetries) rethrow;
      }
    }
    throw lastError!;
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  /// 友好的错误信息映射
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络或稍后重试';
      case DioExceptionType.sendTimeout:
        return '发送超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        return '接收超时，服务器响应过慢，请稍后重试';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return 'API Key 无效或已过期，请在设置中重新配置';
        }
        return '服务器错误 ($statusCode)';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        final msg = e.message ?? '';
        if (msg.contains('SocketException') ||
            msg.contains('Failed host lookup') ||
            msg.contains('resolve')) {
          return 'DNS 解析失败，无法连接 api.xiaomimimo.com。请检查网络，或在设置中配置自定义 MiMo API 地址';
        }
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.unknown:
        final msg = e.error?.toString() ?? '';
        if (msg.contains('SocketException') ||
            msg.contains('Failed host lookup')) {
          return 'DNS 解析失败，请检查网络连接或尝试切换网络';
        }
        return '网络错误: ${e.message}';
      default:
        return '网络错误: ${e.type.name}';
    }
  }

  /// 重试失败的克隆任务
  Future<void> retryClone(ClonedVoice voice) async {
    if (!voice.isFailed) return;

    final updatedVoice = voice.copyWith(
      status: CloneVoiceStatus.processing,
      errorMessage: null,
    );
    await updateClonedVoice(updatedVoice);

    _notifyProgress(CloneTaskProgress(
      taskId: voice.id,
      status: CloneVoiceStatus.processing,
      message: '正在重试克隆...',
      progress: 0.1,
    ));

    _executeCloneVerification(updatedVoice);
  }
}

/// Riverpod Provider
final voiceCloneServiceProvider = Provider<VoiceCloneService>((ref) {
  return VoiceCloneService();
});

/// 克隆任务进度 Stream Provider
final cloneProgressProvider = StreamProvider<CloneTaskProgress>((ref) {
  final service = ref.read(voiceCloneServiceProvider);
  return Stream.multi((controller) {
    void callback(CloneTaskProgress progress) {
      controller.add(progress);
    }

    service.addProgressCallback(callback);

    controller.onCancel = () {
      service.removeProgressCallback(callback);
    };
  });
});

/// 克隆音色列表 Provider（自动刷新）
final clonedVoicesProvider = StreamProvider<List<ClonedVoice>>((ref) {
  // 初始加载
  final service = ref.read(voiceCloneServiceProvider);

  return Stream.multi((controller) async {
    // 发送初始数据
    final initialVoices = await service.getClonedVoices();
    controller.add(initialVoices);

    // 监听进度变化时刷新
    void callback(CloneTaskProgress progress) async {
      if (progress.status == CloneVoiceStatus.completed ||
          progress.status == CloneVoiceStatus.failed) {
        final voices = await service.getClonedVoices();
        controller.add(voices);
      }
    }

    service.addProgressCallback(callback);

    controller.onCancel = () {
      service.removeProgressCallback(callback);
    };
  });
});
