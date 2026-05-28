/// 流式 TTS 服务 - 性能优化
/// 
/// 实现"边合成边播放"的流水线模式，
/// 解决长文本 TTS 首字播放延迟问题。
/// 
/// 核心优化：
/// - 双缓冲播放：合成第 N 块时播放第 N-1 块
/// - 句子级流式：检测到完整句子立即开始合成
/// - 异步队列：合成和播放并行执行
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'tts_service.dart';

/// 流式 TTS 状态
enum StreamingTTSState {
  idle,
  synthesizing,
  playing,
  paused,
  stopped,
}

/// 音频块
class AudioChunk {
  final String filePath;
  final Duration duration;
  
  AudioChunk({required this.filePath, required this.duration});
}

/// 流式 TTS 服务
class StreamingTTSService {
  static final StreamingTTSService _instance = StreamingTTSService._();
  static StreamingTTSService get instance => _instance;

  StreamingTTSService._();

  /// TTS 服务引用
  final TTSService _ttsService = TTSService();

  /// 音频播放器
  AudioPlayer? _player;

  /// 状态
  StreamingTTSState _state = StreamingTTSState.idle;
  StreamingTTSState get state => _state;

  /// 合成队列
  final Queue<_SynthesisTask> _synthesisQueue = Queue();
  
  /// 已合成待播放队列
  final Queue<AudioChunk> _playbackQueue = Queue();

  /// 当前播放的块
  AudioChunk? _currentChunk;

  /// 文本缓冲区（用于检测完整句子）
  String _textBuffer = '';

  /// 停止标志
  bool _stopRequested = false;

  /// 状态变更控制器
  final _stateController = StreamController<StreamingTTSState>.broadcast();
  Stream<StreamingTTSState> get stateStream => _stateController.stream;

  /// 进度回调
  void Function(int synthesized, int played, int total)? onProgress;

  /// 开始流式播放
  Future<void> startStreaming() async {
    _stopRequested = false;
    _state = StreamingTTSState.idle;
    _textBuffer = '';
    _synthesisQueue.clear();
    _playbackQueue.clear();
    
    _player ??= AudioPlayer();
    
    debugPrint('[StreamingTTS] 开始流式播放模式');
  }

  /// 接收流式 token（从 LLM 流式输出调用）
  void onTokenReceived(String token) {
    if (_stopRequested) return;
    
    _textBuffer += token;
    
    // 检测句子边界
    final sentenceEndIndex = _findSentenceEnd(_textBuffer);
    if (sentenceEndIndex >= 0) {
      final sentence = _textBuffer.substring(0, sentenceEndIndex + 1).trim();
      _textBuffer = _textBuffer.substring(sentenceEndIndex + 1);
      
      if (sentence.isNotEmpty) {
        _enqueueForSynthesis(sentence);
      }
    }
  }

  /// 检测句子结束位置
  int _findSentenceEnd(String text) {
    // 中文标点
    final cnPuncts = ['。', '！', '？', '；', '……', '…', '\n'];
    // 英文标点
    final enPuncts = ['.', '!', '?', ';'];
    
    int lastIndex = -1;
    for (final punct in [...cnPuncts, ...enPuncts]) {
      final index = text.lastIndexOf(punct);
      if (index > lastIndex) {
        lastIndex = index;
      }
    }
    
    return lastIndex;
  }

  /// 将文本加入合成队列
  void _enqueueForSynthesis(String text) {
    final task = _SynthesisTask(text: text);
    _synthesisQueue.add(task);
    
    debugPrint('[StreamingTTS] 加入合成队列: "${text.substring(0, text.length > 30 ? 30 : text.length)}..."');
    
    // 启动合成处理（如果未在处理）
    _processSynthesisQueue();
  }

  /// 处理合成队列
  Future<void> _processSynthesisQueue() async {
    if (_synthesisQueue.isEmpty || _stopRequested) return;
    
    _state = StreamingTTSState.synthesizing;
    _stateController.add(_state);
    
    while (_synthesisQueue.isNotEmpty && !_stopRequested) {
      final task = _synthesisQueue.removeFirst();
      
      try {
        debugPrint('[StreamingTTS] 合成: "${task.text.substring(0, task.text.length > 20 ? 20 : task.text.length)}..."');
        
        final filePath = await _ttsService.synthesize(task.text);
        
        if (filePath.isNotEmpty && !_stopRequested) {
          // 获取音频时长
          final duration = await _getAudioDuration(filePath);
          
          final chunk = AudioChunk(
            filePath: filePath,
            duration: duration,
          );
          
          _playbackQueue.add(chunk);
          
          debugPrint('[StreamingTTS] 合成完成，加入播放队列: $filePath');
          
          // 如果当前没有播放，开始播放
          if (_state != StreamingTTSState.playing) {
            _startPlayback();
          }
        }
      } catch (e) {
        debugPrint('[StreamingTTS] ❌ 合成失败: $e');
      }
    }
  }

  /// 开始播放队列中的音频
  Future<void> _startPlayback() async {
    if (_playbackQueue.isEmpty || _stopRequested) return;
    
    _state = StreamingTTSState.playing;
    _stateController.add(_state);
    
    while (_playbackQueue.isNotEmpty && !_stopRequested) {
      _currentChunk = _playbackQueue.removeFirst();
      
      try {
        debugPrint('[StreamingTTS] 播放: ${_currentChunk!.filePath}');
        
        await _player!.setFilePath(_currentChunk!.filePath);
        await _player!.play();
        
        // 等待播放完成
        await _player!.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        );
        
        debugPrint('[StreamingTTS] 播放完成');
        
        // 删除临时文件
        try {
          await File(_currentChunk!.filePath).delete();
        } catch (_) {}
        
      } catch (e) {
        debugPrint('[StreamingTTS] ❌ 播放失败: $e');
      }
    }
    
    // 队列播放完毕
    if (!_stopRequested) {
      _state = StreamingTTSState.idle;
      _stateController.add(_state);
    }
  }

  /// 获取音频时长
  Future<Duration> _getAudioDuration(String filePath) async {
    try {
      final tempPlayer = AudioPlayer();
      await tempPlayer.setFilePath(filePath);
      final duration = tempPlayer.duration ?? Duration.zero;
      await tempPlayer.dispose();
      return duration;
    } catch (_) {
      return Duration.zero;
    }
  }

  /// 流式输出结束（刷新缓冲区）
  Future<void> finish() async {
    // 处理缓冲区中剩余的文本
    if (_textBuffer.trim().isNotEmpty) {
      _enqueueForSynthesis(_textBuffer.trim());
      _textBuffer = '';
    }
    
    debugPrint('[StreamingTTS] 流式输出结束，等待队列播放完毕');
  }

  /// 停止播放
  Future<void> stop() async {
    _stopRequested = true;
    
    await _player?.stop();
    
    // 清理队列
    _synthesisQueue.clear();
    _playbackQueue.clear();
    
    // 清理临时文件
    for (final chunk in _playbackQueue) {
      try {
        await File(chunk.filePath).delete();
      } catch (_) {}
    }
    
    _state = StreamingTTSState.stopped;
    _stateController.add(_state);
    
    debugPrint('[StreamingTTS] 已停止');
  }

  /// 暂停播放
  Future<void> pause() async {
    await _player?.pause();
    _state = StreamingTTSState.paused;
    _stateController.add(_state);
  }

  /// 恢复播放
  Future<void> resume() async {
    await _player?.play();
    _state = StreamingTTSState.playing;
    _stateController.add(_state);
  }

  /// 释放资源
  Future<void> dispose() async {
    await stop();
    await _player?.dispose();
    _player = null;
    await _stateController.close();
  }
}

/// 合成任务
class _SynthesisTask {
  final String text;
  
  _SynthesisTask({required this.text});
}
