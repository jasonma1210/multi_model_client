import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:audio_session/audio_session.dart';

// ════════════════════════════════════════════════════════════════
// 全局录音管理器
//
// 解决的问题：
// 1. flutter_recorder 的 Recorder.instance 是全局单例
// 2. 多个页面（灵感一瞬、语音克隆）共享同一个实例
// 3. 页面 A deinit() 后 C++ 端可能还没完全释放，页面 B init() 会失败
// 4. 需要全局协调 init/deinit 调用，避免竞态条件
// ════════════════════════════════════════════════════════════════

class RecorderManager {
  static const String _tag = 'RecorderManager';

  /// 当前持有录音器的页面标识
  String? _currentHolder;

  /// 是否正在执行 init/deinit 操作（防止并发）
  bool _isTransitioning = false;

  /// 录音器是否已初始化
  bool get isInitialized => Recorder.instance.isDeviceInitialized();

  /// 当前持有者
  String? get currentHolder => _currentHolder;

  /// 获取全局单例
  static final RecorderManager _instance = RecorderManager._();
  static RecorderManager get instance => _instance;
  RecorderManager._();

  /// 初始化录音器
  ///
  /// [holder] 持有者标识（如 'inspiration', 'voice_clone'）
  /// [sampleRate] 采样率
  /// [channels] 声道
  /// [format] PCM 格式
  ///
  /// 如果录音器已被其他页面持有，会先安全释放再重新初始化
  Future<bool> init({
    required String holder,
    int sampleRate = 16000,
    RecorderChannels channels = RecorderChannels.mono,
    PCMFormat format = PCMFormat.s16le,
  }) async {
    if (_isTransitioning) {
      debugPrint('[$_tag] ⚠️ 正在执行 init/deinit 操作，等待...');
      // 等待过渡完成
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isTransitioning) break;
      }
      if (_isTransitioning) {
        debugPrint('[$_tag] ❌ 等待超时，init 失败');
        return false;
      }
    }

    _isTransitioning = true;
    try {
      // 如果当前持有者就是自己，且已初始化，直接返回
      if (_currentHolder == holder && isInitialized) {
        debugPrint('[$_tag] ✅ $holder 已持有录音器，无需重新初始化');
        return true;
      }

      // 如果已被其他页面持有，先安全释放
      if (isInitialized) {
        debugPrint('[$_tag] 🔄 录音器已被 $_currentHolder 持有，先释放...');
        await _safeDeinit();
      }

      // ★★★ 关键修复：init 之前主动 forceDeinit 一次 ★★★
      // 解决：灵感页 dispose 时 fire-and-forget 的 deinit 还在 background 跑，
      //      下次 init 进来时 isInitialized 还是 true（因为 C++ 端还在），init 失败
      // 现在：init 一进来就 force deinit 一次，再轮询等释放，再 init
      debugPrint('[$_tag] 🔄 $holder init 前先强制清理一次 C++ 端...');
      await _forceDeinit();
      // 再次确认 C++ 端真的释放了（多等一轮）
      for (int i = 0; i < 10; i++) {
        if (!isInitialized) {
          debugPrint('[$_tag] ✅ init 前确认 C++ 端已释放 (额外等待 ${i * 100}ms)');
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // ★★★ 关键修复：init 前配置 iOS AVAudioSession ★★★
      // ASR（record 包的 AudioRecorder）使用后可能把 AVAudioSession 设为 playAndRecord
      // 然后 stopRecording 时恢复为 playback。但 flutter_recorder 的 init 需要
      // AVAudioSession 为 playAndRecord 才能成功初始化录音。
      // 如果 ASR 的 AudioRecorder 还没完全释放，或者 AVAudioSession 还在 playback 状态，
      // flutter_recorder 的 init 就会失败。
      if (Platform.isIOS || Platform.isMacOS) {
        try {
          final session = await AudioSession.instance;
          await session.configure(AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
            avAudioSessionMode: AVAudioSessionMode.measurement,
          ));
          debugPrint('[$_tag] ✅ AVAudioSession 切换为 playAndRecord (flutter_recorder init)');
        } catch (e) {
          debugPrint('[$_tag] ⚠️ AVAudioSession 配置失败: $e');
        }
      }

      // 初始化
      debugPrint('[$_tag] 🔄 $holder 初始化录音器 (sampleRate=$sampleRate, format=$format)...');
      bool initSuccess = false;
      try {
        await Recorder.instance.init(
          sampleRate: sampleRate,
          channels: channels,
          format: format,
        );
        initSuccess = true;
      } catch (initError) {
        debugPrint('[$_tag] ⚠️ 首次 init 失败: $initError，等待后重试...');
        // 等待 C++ 端完全释放资源后重试
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          await Recorder.instance.init(
            sampleRate: sampleRate,
            channels: channels,
            format: format,
          );
          initSuccess = true;
        } catch (retryError) {
          debugPrint('[$_tag] ⚠️ 重试 init 也失败: $retryError');
          // 最后尝试：强制 deinit 后再 init
          await _forceDeinit();
          await Future.delayed(const Duration(milliseconds: 300));
          try {
            await Recorder.instance.init(
              sampleRate: sampleRate,
              channels: channels,
              format: format,
            );
            initSuccess = true;
          } catch (finalError) {
            debugPrint('[$_tag] ❌ 强制 deinit 后 init 仍失败: $finalError');
          }
        }
      }

      if (!initSuccess) {
        debugPrint('[$_tag] ❌ $holder 初始化录音器失败：所有重试均失败');
        _currentHolder = null;
        return false;
      }

      _currentHolder = holder;
      debugPrint('[$_tag] ✅ $holder 初始化录音器成功');
      return true;
    } catch (e) {
      debugPrint('[$_tag] ❌ $holder 初始化录音器失败: $e');
      _currentHolder = null;
      return false;
    } finally {
      _isTransitioning = false;
    }
  }

  /// 安全释放录音器
  ///
  /// [holder] 释放者标识，必须与 init 时的 holder 一致
  /// 如果 holder 不匹配，说明不是当前持有者，跳过释放
  Future<void> deinit({required String holder}) async {
    if (_isTransitioning) {
      debugPrint('[$_tag] ⚠️ 正在执行 init/deinit 操作，等待...');
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isTransitioning) break;
      }
    }

    // 只有当前持有者才能释放
    if (_currentHolder != null && _currentHolder != holder) {
      debugPrint('[$_tag] ⚠️ $holder 不是当前持有者($_currentHolder)，跳过释放');
      return;
    }

    _isTransitioning = true;
    try {
      await _safeDeinit();
      _currentHolder = null;
      debugPrint('[$_tag] ✅ $holder 释放录音器成功');

      // ★ 修复：deinit 后恢复 AVAudioSession 为 playback
      // flutter_recorder 使用的是 playAndRecord，释放后应恢复为 playback
      // 让 TTS 等播放功能正常工作
      if (Platform.isIOS || Platform.isMacOS) {
        try {
          final session = await AudioSession.instance;
          await session.configure(AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playback,
          ));
          debugPrint('[$_tag] ✅ AVAudioSession 恢复为 playback (deinit 后)');
        } catch (e) {
          debugPrint('[$_tag] ⚠️ AVAudioSession 恢复失败: $e');
        }
      }
    } catch (e) {
      debugPrint('[$_tag] ⚠️ $holder 释放录音器失败: $e');
      _currentHolder = null;
    } finally {
      _isTransitioning = false;
    }
  }

  /// 安全 deinit：先 stop 再 deinit
  Future<void> _safeDeinit() async {
    try {
      if (!isInitialized) return;

      // 先停止录音（如果正在录音）
      try {
        Recorder.instance.stopRecording();
      } catch (_) {}

      // 停止设备
      try {
        Recorder.instance.stop();
      } catch (_) {}

      // 释放
      try {
        Recorder.instance.deinit();
      } catch (_) {}

      // 等待 C++ 端完全释放资源
      await Future.delayed(const Duration(milliseconds: 200));
      // ★ 轮询等待 isInitialized 变 false，最多等 1500ms
      // 解决 voice_clone 退出后灵感一瞬录音 init 失败的问题（C++ 端释放未完成）
      for (int i = 0; i < 15; i++) {
        if (!isInitialized) {
          debugPrint('[$_tag] ✅ C++ 端已完全释放 (等待 ${i * 100 + 200}ms)');
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (isInitialized) {
        debugPrint('[$_tag] ⚠️ C++ 端释放超时，isInitialized 仍为 true');
      }
    } catch (e) {
      debugPrint('[$_tag] ⚠️ _safeDeinit 失败: $e');
    }
  }

  /// 强制 deinit：忽略所有错误
  Future<void> _forceDeinit() async {
    try {
      Recorder.instance.stopRecording();
    } catch (_) {}
    try {
      Recorder.instance.stop();
    } catch (_) {}
    try {
      if (isInitialized) {
        Recorder.instance.deinit();
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 300));
    // ★ 同样轮询等待释放完成
    for (int i = 0; i < 10; i++) {
      if (!isInitialized) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// 启动录音（start + startRecording）
  ///
  /// 调用前必须先 init
  void startRecording(String filePath) {
    if (!isInitialized) {
      throw StateError('录音器未初始化，请先调用 init()');
    }
    Recorder.instance.start();
    Recorder.instance.startRecording(completeFilePath: filePath);
    debugPrint('[$_tag] 🎙️ 开始录音: $filePath (holder=$_currentHolder)');
  }

  /// 停止录音（stopRecording + stop，不 deinit）
  ///
  /// 录音停止后仍保持初始化状态，可以再次 startRecording
  /// 如需完全释放，调用 deinit()
  void stopRecording() {
    try {
      Recorder.instance.stopRecording();
    } catch (_) {}
    try {
      Recorder.instance.stop();
    } catch (_) {}
    debugPrint('[$_tag] ⏹️ 停止录音 (holder=$_currentHolder)');
  }

  /// 暂停录音
  void pauseRecording() {
    Recorder.instance.setPauseRecording(pause: true);
  }

  /// 恢复录音
  void resumeRecording() {
    Recorder.instance.setPauseRecording(pause: false);
  }
}
