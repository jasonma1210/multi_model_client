/// ASR 输入服务 - LLM Studio 语音输入模块
/// 
/// 功能：
/// - 微信风格语音录入（按住说话，松开识别）
/// - 实时音量反馈
/// - 上滑取消录制
/// - 识别结果回调
/// 
/// @author JianMa
/// @version 1.0.0
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
class AsrInputService {
  final AudioRecorder _recorder = AudioRecorder();
  final ASRService _asrService;

  /// 麦克风权限状态
  bool _hasPermission = false;

  /// 是否正在录音
  bool _isRecording = false;

  /// 录音文件路径
  String? _recordingPath;

  /// 音量监听流控制器（0.0 ~ 1.0）
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();

  /// 识别结果流
  final StreamController<String> _resultController =
      StreamController<String>.broadcast();

  /// 错误流
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  /// 当前音量（0.0 ~ 1.0）
  double _currentAmplitude = 0.0;

  Timer? _amplitudeTimer;

  AsrInputService(this._asrService);

  /// 音量流（实时音量 0.0~1.0）
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// 识别结果流
  Stream<String> get resultStream => _resultController.stream;

  /// 错误流
  Stream<String> get errorStream => _errorController.stream;

  /// 是否正在录音
  bool get isRecording => _isRecording;

  /// 检查麦克风权限
  Future<bool> checkPermission() async {
    _hasPermission = await _recorder.hasPermission();
    return _hasPermission;
  }

  /// 开始录音（按住说话时调用）
  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      // 检查权限
      _hasPermission = await _recorder.hasPermission();
      if (!_hasPermission) {
        _errorController.add('麦克风权限被拒绝，请在系统设置中开启');
        return;
      }

      // 生成录音文件路径（根据平台用对应扩展名）
      final dir = await getTemporaryDirectory();
      final isWav = Platform.isIOS || Platform.isMacOS;
      final ext = isWav ? 'wav' : 'm4a';
      _recordingPath =
          '${dir.path}/asr_recording_${DateTime.now().millisecondsSinceEpoch}.$ext';

      // 开始录音（macOS/iOS 用 WAV 格式，Android 用 AAC）
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
      _currentAmplitude = 0.0;

      // 启动音量轮询（每 100ms 更新一次）
      _amplitudeTimer?.cancel();
      _amplitudeTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _updateAmplitude(),
      );
    } catch (e) {
      _errorController.add('录音启动失败: $e');
      _isRecording = false;
    }
  }

  /// 更新音量
  Future<void> _updateAmplitude() async {
    if (!_isRecording) return;
    try {
      final amp = await _recorder.getAmplitude();
      // amp.current 是分贝值，范围大约 -160 ~ 0
      // 转换为 0.0 ~ 1.0
      final normalized = _normalizeAmplitude(amp.current);
      _currentAmplitude = normalized;
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
    if (!_isRecording) return null;

    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;

    try {
      await _recorder.stop();
    } catch (e) {
      debugPrint('[AsrInputService] stop error: $e');
    }

    _isRecording = false;
    _amplitudeController.add(0.0);

    // 如果是取消，不识别
    if (cancelled) return null;
    if (_recordingPath == null) return null;

    // 检查录音文件是否存在且有内容
    final file = File(_recordingPath!);
    if (!await file.exists()) {
      _errorController.add('录音文件丢失: $_recordingPath');
      debugPrint('[AsrInputService] 录音文件不存在: $_recordingPath');
      return null;
    }

    final length = await file.length();
    debugPrint('[AsrInputService] 录音文件大小: $length bytes, path: $_recordingPath');
    if (length < 1000) {
      // 录音太短，可能是误触，忽略
      debugPrint('[AsrInputService] 录音太短 ($length bytes)，忽略');
      await _cleanupRecording();
      return null;
    }

    // 发送识别
    try {
      debugPrint('[AsrInputService] 开始识别录音文件...');
      final text = await _asrService.recognizeFile(_recordingPath!);
      debugPrint('[AsrInputService] 识别结果: "$text"');
      await _cleanupRecording();
      if (text != null && text.trim().isNotEmpty) {
        _resultController.add(text.trim());
        return text.trim();
      }
      debugPrint('[AsrInputService] 识别结果为空');
      return null;
    } catch (e) {
      debugPrint('[AsrInputService] 识别失败: $e');
      await _cleanupRecording();
      _errorController.add('语音识别失败: $e');
      return null;
    }
  }

  /// 清理录音文件
  Future<void> _cleanupRecording() async {
    if (_recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      _recordingPath = null;
    }
  }

  /// 释放资源
  void dispose() {
    _amplitudeTimer?.cancel();
    _recorder.dispose();
    _amplitudeController.close();
    _resultController.close();
    _errorController.close();
  }
}
