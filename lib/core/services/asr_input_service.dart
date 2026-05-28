/// ASR 输入服务 - LLM Studio 语音输入模块
/// 
/// 功能：
/// - 微信风格语音录入（按住说话，松开识别）
/// - 实时音量反馈
/// - 上滑取消录制
/// - 识别结果回调
/// - 支持系统语音识别（实时流式）和录音文件识别
/// 
/// @author JianMa
/// @version 1.1.0
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'asr_service.dart';

/// 微信风格 ASR 语音录入服务
/// - 按住说话，松开识别
/// - 实时音量反馈
/// - 上滑取消
/// - 识别结果回调
/// - 支持系统语音识别（实时流式）和录音文件识别
class AsrInputService {
  final AudioRecorder _recorder = AudioRecorder();
  
  /// 动态 ASR 服务（每次开始录音时根据设置动态创建）
  ASRService? _dynamicAsrService;
  
  /// 获取当前 ASR 服务（优先使用动态服务，如果没有则抛出异常）
  ASRService get _asrService {
    // 优先使用动态服务
    final dynamicService = _dynamicAsrService;
    if (dynamicService != null) {
      return dynamicService;
    }
    // 如果没有动态服务，使用备用服务
    final fallbackService = _fallbackAsrService;
    if (fallbackService != null) {
      return fallbackService;
    }
    // 如果也没有备用服务，创建一个默认的 Sherpa 服务
    debugPrint('[AsrInputService] 警告：没有 ASR 服务，创建一个默认的 Sherpa 服务');
    _dynamicAsrService = ASRService(
      provider: ASRProvider.sherpa,
      sherpaModelId: 'sensevoice-int8',
    );
    return _dynamicAsrService!;
  }
  
  /// 备用 ASR 服务（如果动态服务为 null）
  final ASRService? _fallbackAsrService;

  /// 是否使用系统语音识别（实时识别模式）
  bool get _isSystemAsr {
    final provider = _asrService.provider;
    debugPrint('[AsrInputService] _isSystemAsr 检查: provider = $provider, 是否为 system: ${provider == ASRProvider.system}');
    return provider == ASRProvider.system;
  }

  /// Sherpa 模式需要 WAV 格式（Sherpa 只支持 WAV/PCM 输入）
  /// 系统模式支持 AAC/m4a
  bool get _needsWavFormat {
    final provider = _asrService.provider;
    return provider == ASRProvider.sherpa;
  }

  /// 系统语音识别是否正在运行
  bool _isSystemAsrRunning = false;

  /// 系统语音识别结果流订阅
  StreamSubscription<String>? _systemAsrSubscription;

  /// 最近一次系统语音识别文本（用于停止时作为最终结果）
  String _lastSystemAsrText = '';

  /// 麦克风权限状态
  bool _hasPermission = false;

  /// 是否正在录音/识别
  bool _isRecording = false;

  /// 录音文件路径
  String? _recordingPath;

  /// 音量监听流控制器（0.0 ~ 1.0）
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();

  /// 识别结果流（最终结果）
  final StreamController<String> _resultController =
      StreamController<String>.broadcast();

  /// 中间结果流（实时识别中的部分结果，用于浮窗气泡）
  final StreamController<String> _intermediateTextController =
      StreamController<String>.broadcast();

  /// 错误流
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  Timer? _amplitudeTimer;

  /// 构造函数 - 接受可选的备用 ASR 服务
  AsrInputService([ASRService? fallbackAsrService]) : _fallbackAsrService = fallbackAsrService;

  /// 动态创建 ASR 服务（根据当前设置）
  /// [asrProvider] - ASR 提供商 ('system', 'sherpa', 'openai')
  /// [sherpaModelId] - Sherpa 模型 ID（仅当 asrProvider 为 'sherpa' 时使用）
  void createAsrService(String asrProvider, {String? sherpaModelId}) {
    debugPrint('[AsrInputService] createAsrService: asrProvider=$asrProvider, sherpaModelId=$sherpaModelId');
    
    ASRProvider provider;
    String? apiKey;
    String? modelId;
    
    switch (asrProvider) {
      case 'system':
        provider = ASRProvider.system;
        break;
      case 'openai':
        provider = ASRProvider.openai;
        // 需要 API Key，这里暂时设为 null，实际应该从设置中获取
        break;
      case 'sherpa':
      default:
        provider = ASRProvider.sherpa;
        modelId = sherpaModelId ?? 'sensevoice-int8';
        break;
    }
    
    _dynamicAsrService = ASRService(
      provider: provider,
      apiKey: apiKey,
      sherpaModelId: modelId,
    );
    
    debugPrint('[AsrInputService] 已创建新的 ASR 服务: provider=${_dynamicAsrService!.provider}');
  }

  /// 音量流（实时音量 0.0~1.0）
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// 识别结果流（最终结果）
  Stream<String> get resultStream => _resultController.stream;

  /// 中间结果流（实时识别中的部分结果，用于浮窗气泡）
  Stream<String> get intermediateTextStream => _intermediateTextController.stream;

  /// 错误流
  Stream<String> get errorStream => _errorController.stream;

  /// 是否正在录音/识别
  bool get isRecording => _isRecording;

  /// 检查麦克风权限
  Future<bool> checkPermission() async {
    _hasPermission = await _recorder.hasPermission();
    return _hasPermission;
  }

  /// 开始录音或系统语音识别（按住说话时调用）
  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      // 检查权限
      _hasPermission = await _recorder.hasPermission();
      if (!_hasPermission) {
        _errorController.add('麦克风权限被拒绝，请在系统设置中开启');
        return;
      }

      if (_isSystemAsr) {
        // ===== 系统语音识别模式（实时流式识别）=====
        await _startSystemAsr();
      } else {
        // ===== 录音文件模式（Sherpa/OpenAI）=====
        await _startRecordingFile();
      }
    } catch (e) {
      _errorController.add('录音启动失败: $e');
      _isRecording = false;
    }
  }

  /// 启动系统语音实时识别
  /// 【修复】当系统语音识别不可用时，自动切换到 Sherpa 本地识别
  Future<void> _startSystemAsr() async {
    try {
      debugPrint('[AsrInputService] 🚀 启动系统语音实时识别...');
      debugPrint('[AsrInputService] 当前 ASR provider: ${_asrService.provider}');
      
      // 重置最近识别文本
      _lastSystemAsrText = '';
      
      // 使用系统语音的实时识别方法
      final stream = _asrService.recognizeWithSystem(
        onResult: (text) {
          debugPrint('[AsrInputService] 系统语音识别结果: $text');
          if (text.trim().isNotEmpty) {
            _lastSystemAsrText = text.trim();
            // 实时结果 → 浮窗气泡实时更新
            _intermediateTextController.add(text.trim());
          }
        },
        onDone: () {
          debugPrint('[AsrInputService] 系统语音识别完成');
          _isSystemAsrRunning = false;
          // 识别完成时，将最后的结果作为最终结果发送
          if (_lastSystemAsrText.isNotEmpty) {
            _resultController.add(_lastSystemAsrText);
          }
        },
        onError: (error) {
          debugPrint('[AsrInputService] 系统语音识别错误: $error');
          // 【修复】系统语音识别失败时，自动切换到 Sherpa 本地识别
          _handleSystemAsrError(error);
        },
      );
      
      // 监听识别结果（转发到中间结果流用于浮窗气泡）
      _systemAsrSubscription = stream.listen(
        (text) {
          if (text.trim().isNotEmpty) {
            _lastSystemAsrText = text.trim();
            _intermediateTextController.add(text.trim());
          }
        },
        onError: (e) {
          debugPrint('[AsrInputService] 系统语音识别Stream错误: $e');
          // 【修复】系统语音识别失败时，自动切换到 Sherpa 本地识别
          _handleSystemAsrError(e.toString());
        },
        onDone: () {
          _isSystemAsrRunning = false;
          // stream 结束时，确保最终结果已发送
          if (_lastSystemAsrText.isNotEmpty) {
            _resultController.add(_lastSystemAsrText);
          }
        },
      );
      
      _isRecording = true;
      _isSystemAsrRunning = true;
      
      // 系统语音识别没有音量反馈，发一个默认值
      _amplitudeController.add(0.5);
      
      // 启动一个定时器来模拟音量波动（可选）
      _amplitudeTimer?.cancel();
      _amplitudeTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) {
          if (_isSystemAsrRunning) {
            // 模拟随机音量
            final fakeAmp = 0.3 + (DateTime.now().millisecond % 50) / 100;
            _amplitudeController.add(fakeAmp);
          }
        },
      );
      
      debugPrint('[AsrInputService] 系统语音识别已启动');
    } catch (e) {
      debugPrint('[AsrInputService] 启动系统语音识别失败: $e');
      // 【修复】系统语音识别失败时，自动切换到 Sherpa 本地识别
      await _handleSystemAsrError(e.toString());
    }
  }
  
  /// 防止 _handleSystemAsrError 被重复调用的标志
  bool _isHandlingSystemAsrError = false;

  /// 【修复】处理系统语音识别错误，自动切换到 Sherpa 本地识别
  Future<void> _handleSystemAsrError(String error) async {
    // 防止重复调用（stream onError 和 catch block 可能同时触发）
    if (_isHandlingSystemAsrError) {
      debugPrint('[AsrInputService] _handleSystemAsrError 正在处理中，跳过重复调用');
      return;
    }
    _isHandlingSystemAsrError = true;
    
    _isSystemAsrRunning = false;
    
    // ★ 修复：先取消系统语音识别订阅，避免悬挂回调
    _systemAsrSubscription?.cancel();
    _systemAsrSubscription = null;
    
    // 检测是否是"不可用"错误
    final isUnavailable = error.toLowerCase().contains('not available') ||
                          error.toLowerCase().contains('unavailable') ||
                          error.toLowerCase().contains('不可用');
    
    if (isUnavailable) {
      debugPrint('[AsrInputService] ⚠️ 系统语音识别不可用，自动切换到 Sherpa 本地识别');
      _errorController.add('系统语音识别不可用，正在切换到本地识别...');
      
      // 延迟一下，让用户看到提示
      await Future.delayed(const Duration(milliseconds: 500));
      
      // ★ 修复：延迟期间用户可能已松手（stopRecording 已被调用），此时不应再开始录音
      if (!_isRecording) {
        debugPrint('[AsrInputService] 延迟期间录音已被停止，跳过 Sherpa 切换');
        _isHandlingSystemAsrError = false;
        return;
      }
      
      // 切换到 Sherpa 本地识别
      try {
        // ★ 修复：先停止旧的系统语音识别（在切换服务前调用）
        // 此时 _asrService 还是旧的 system 服务
        try {
          _asrService.stopSystemSpeech();
        } catch (_) {
          // ignore: 可能已经是 sherpa 服务了
        }
        
        // 创建 Sherpa ASR 服务
        createAsrService('sherpa', sherpaModelId: 'sensevoice-int8');
        
        // ★ 修复：预热 Sherpa 模型，确认模型可用后再录音
        try {
          await _asrService.initSherpa();
          debugPrint('[AsrInputService] Sherpa 模型初始化成功');
        } catch (modelError) {
          debugPrint('[AsrInputService] ❌ Sherpa 模型初始化失败: $modelError');
          _errorController.add('语音识别模型不可用: $modelError\n请先在设置中下载语音识别模型');
          _isRecording = false;
          _isHandlingSystemAsrError = false;
          return;
        }
        
        // 开始录音文件模式
        await _startRecordingFile();
        
        debugPrint('[AsrInputService] ✅ 已切换到 Sherpa 本地识别');
      } catch (e) {
        debugPrint('[AsrInputService] ❌ 切换到 Sherpa 失败: $e');
        _errorController.add('本地语音识别失败: $e\n请先在设置中下载语音识别模型');
        _isRecording = false;
      }
    } else {
      _errorController.add('语音识别失败: $error');
      _isRecording = false;
    }
    
    _isHandlingSystemAsrError = false;
  }

  /// 启动录音文件模式
  /// 【修复】Sherpa 模式强制使用 WAV 格式，因为 Sherpa 只支持 WAV/PCM 输入
  Future<void> _startRecordingFile() async {
    // ★ 修复：确保系统 ASR 订阅已取消（防止从系统 ASR 降级时悬挂）
    _systemAsrSubscription?.cancel();
    _systemAsrSubscription = null;
    _isSystemAsrRunning = false;
    
    // 生成录音文件路径
    // 【修复】Sherpa 模式必须用 WAV，系统/OpenAI 模式用 m4a（AAC 编码更小）
    final dir = await getTemporaryDirectory();
    final isWav = _needsWavFormat || Platform.isIOS || Platform.isMacOS;
    final ext = isWav ? 'wav' : 'm4a';
    _recordingPath =
        '${dir.path}/asr_recording_${DateTime.now().millisecondsSinceEpoch}.$ext';

    debugPrint('[AsrInputService] 开始录音: $_recordingPath (WAV=$isWav, Sherpa=$_needsWavFormat, provider=${_asrService.provider})');

    // 选择编码器：WAV 用 PCM 编码，其他用 AAC
    final encoder = isWav ? AudioEncoder.wav : AudioEncoder.aacLc;
    await _recorder.start(
      RecordConfig(
        encoder: encoder,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _recordingPath!,
    );

    _isRecording = true;

    // 启动音量轮询（每 100ms 更新一次）
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _updateAmplitude(),
    );
  }

  /// 更新音量
  Future<void> _updateAmplitude() async {
    if (!_isRecording || _isSystemAsr) return;
    try {
      final amp = await _recorder.getAmplitude();
      // amp.current 是分贝值，范围大约 -160 ~ 0
      // 转换为 0.0 ~ 1.0
      final normalized = _normalizeAmplitude(amp.current);
      _amplitudeController.add(normalized);
    } catch (e) {
      debugPrint('[AsrInputService] getAmplitude error: $e');
    }
  }

  /// 将分贝值 (-160~0) 归一化到 (0.0~1.0)
  double _normalizeAmplitude(double db) {
    // db 是负数，0 是最大值，-160 是静音
    if (db <= -160) return 0.0;
    if (db >= 0) return 1.0;
    // 映射到 0.0 ~ 1.0
    return (db + 160) / 160;
  }

  /// 停止录音并开始识别（松开说话时调用）
  /// 返回 null 表示识别失败或无内容
  Future<String?> stopRecording({bool cancelled = false}) async {
    if (!_isRecording) {
      debugPrint('[AsrInputService] stopRecording: 未在录音中，跳过');
      return null;
    }

    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;

    final provider = _asrService.provider;
    debugPrint('[AsrInputService] stopRecording: provider=$provider, cancelled=$cancelled, _isSystemAsr=$_isSystemAsr');

    if (_isSystemAsr) {
      // ===== 系统语音识别模式 =====
      debugPrint('[AsrInputService] stopRecording: 走系统语音识别停止流程');
      await _stopSystemAsr(cancelled: cancelled);
    } else {
      // ===== 录音文件模式 =====
      debugPrint('[AsrInputService] stopRecording: 走录音文件识别流程');
      await _stopRecordingFile(cancelled: cancelled);
    }

    _isRecording = false;
    _amplitudeController.add(0.0);
    return null; // 结果通过 resultStream 返回
  }

  /// 停止系统语音识别
  Future<void> _stopSystemAsr({bool cancelled = false}) async {
    _isSystemAsrRunning = false;
    
    // 取消订阅
    if (_systemAsrSubscription != null) {
      await _systemAsrSubscription?.cancel();
      _systemAsrSubscription = null;
    }
    
    // 停止系统语音识别
    _asrService.stopSystemSpeech();
    
    debugPrint('[AsrInputService] 系统语音识别已停止');
  }

  /// 停止录音文件识别
  Future<String?> _stopRecordingFile({bool cancelled = false}) async {
    // ★ 优化：先记住路径，然后并行执行 stop 和文件检查
    final path = _recordingPath;
    
    try {
      await _recorder.stop();
    } catch (e) {
      debugPrint('[AsrInputService] stop error: $e');
    }

    // 如果是取消，不识别
    if (cancelled) return null;
    if (path == null) return null;

    // 检查录音文件是否存在且有内容
    final file = File(path);
    if (!await file.exists()) {
      _errorController.add('录音文件丢失: $path');
      debugPrint('[AsrInputService] 录音文件不存在: $path');
      return null;
    }

    final length = await file.length();
    debugPrint('[AsrInputService] 录音文件大小: $length bytes, path: $path');
    if (length < 1000) {
      // 录音太短，可能是误触，忽略
      debugPrint('[AsrInputService] 录音太短 ($length bytes)，忽略');
      _cleanupRecordingAsync();
      return null;
    }

    // ★ 优化：立即开始识别，不等清理完成
    // 发送识别
    try {
      final provider = _asrService.provider;
      debugPrint('[AsrInputService] 开始识别录音文件... (provider=$provider)');
      
      // ★ 修复：对于 Sherpa 模型，先确保模型已初始化
      if (provider == ASRProvider.sherpa) {
        debugPrint('[AsrInputService] Sherpa 模式：检查模型初始化状态...');
        try {
          await _asrService.initSherpa();
          debugPrint('[AsrInputService] Sherpa 模型初始化确认完成');
        } catch (initError) {
          debugPrint('[AsrInputService] ❌ Sherpa 模型初始化失败: $initError');
          _errorController.add('语音识别模型初始化失败: $initError\n请在设置中下载语音识别模型');
          _cleanupRecordingAsync();
          return null;
        }
      }
      
      final text = await _asrService.recognizeFile(path);
      debugPrint('[AsrInputService] 识别结果: "${text.length > 50 ? '${text.substring(0, 50)}...' : text}"');
      // ★ 优化：异步清理，不阻塞结果返回
      _cleanupRecordingAsync();
      if (text.trim().isNotEmpty) {
        _resultController.add(text.trim());
        return text.trim();
      }
      debugPrint('[AsrInputService] 识别结果为空');
      return null;
    } catch (e) {
      debugPrint('[AsrInputService] 识别失败: $e');
      _cleanupRecordingAsync();
      _errorController.add('语音识别失败: $e');
      return null;
    }
  }

  /// 清理录音文件（同步等待）
  Future<void> _cleanupRecording() async {
    if (_recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // ignore: non-critical error
      }
      _recordingPath = null;
    }
  }

  /// 异步清理录音文件（不阻塞调用方，fire-and-forget）
  void _cleanupRecordingAsync() {
    final path = _recordingPath;
    _recordingPath = null;
    if (path != null) {
      Future.microtask(() async {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // ignore: non-critical error
        }
      });
    }
  }

  /// 预热 ASR 模型（在用户按下说话前预先初始化 Sherpa 模型，减少首次识别延迟）
  /// 建议在会话页面 initState 或 VoiceDialog 初始化时调用
  Future<void> warmUp() async {
    try {
      final provider = _asrService.provider;
      debugPrint('[AsrInputService] 预热 ASR 模型: provider=$provider');
      
      if (provider == ASRProvider.sherpa) {
        // Sherpa 模型预热：触发 OfflineRecognizer 创建（不执行识别）
        await _asrService.initSherpa();
        debugPrint('[AsrInputService] Sherpa ASR 模型预热完成');
      } else if (provider == ASRProvider.system) {
        // 系统 ASR：标记为需要预热（在首次使用时会自动初始化）
        debugPrint('[AsrInputService] 系统 ASR 模式，跳过预热（首次使用时自动初始化）');
      }
    } catch (e) {
      // ★ 修复：输出更详细的失败信息，帮助诊断
      debugPrint('[AsrInputService] ⚠️ ASR 预热失败（非致命，首次录音时会重试）: $e');
      debugPrint('[AsrInputService] 提示：如果是 Sherpa 模型，请确认已在设置中下载语音识别模型');
    }
  }

  /// 释放资源
  void dispose() {
    _amplitudeTimer?.cancel();
    _recorder.dispose();
    _systemAsrSubscription?.cancel();
    _amplitudeController.close();
    _resultController.close();
    _intermediateTextController.close();
    _errorController.close();
  }
}