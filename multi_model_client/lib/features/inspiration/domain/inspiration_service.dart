/// 灵感一瞬服务 - 语音录制、转录、总结、思维导图
/// 
/// 功能流程：
/// 1. 录音控制（开始/暂停/播放/停止）
/// 2. ASR 语音转文本（异步）
/// 3. 一键总结
/// 4. 多段合并总结
/// 5. 生成思维导图
/// 6. 导出功能
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/asr_service.dart';
import '../../../core/services/document_generation_service.dart';

/// 录音段落
class AudioSegment {
  final String id;
  final String filePath;
  final Duration duration;
  final String? transcription;
  final DateTime createdAt;

  AudioSegment({
    required this.id,
    required this.filePath,
    required this.duration,
    this.transcription,
    required this.createdAt,
  });

  AudioSegment copyWith({
    String? transcription,
  }) {
    return AudioSegment(
      id: id,
      filePath: filePath,
      duration: duration,
      transcription: transcription ?? this.transcription,
      createdAt: createdAt,
    );
  }
}

/// 灵感会话
class InspirationSession {
  final String id;
  final DateTime createdAt;
  final List<AudioSegment> segments;
  final String? summary;
  final Map<String, dynamic>? mindMap;

  InspirationSession({
    required this.id,
    required this.createdAt,
    this.segments = const [],
    this.summary,
    this.mindMap,
  });

  InspirationSession copyWith({
    List<AudioSegment>? segments,
    String? summary,
    Map<String, dynamic>? mindMap,
  }) {
    return InspirationSession(
      id: id,
      createdAt: createdAt,
      segments: segments ?? this.segments,
      summary: summary ?? this.summary,
      mindMap: mindMap ?? this.mindMap,
    );
  }
}

/// 录音状态
enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

/// 转录状态
enum TranscriptionState {
  idle,
  processing,
  completed,
  failed,
}

/// 灵感一瞬服务
class InspirationService extends StateNotifier<InspirationSession> {
  final ASRService _asrService;
  final DocumentGenerationService _docService;

  InspirationService({
    required ASRService asrService,
    required DocumentGenerationService docService,
  })  : _asrService = asrService,
        _docService = docService,
        super(InspirationSession(
          id: const Uuid().v4(),
          createdAt: DateTime.now(),
        ));

  /// 录音状态
  RecordingState _recordingState = RecordingState.idle;
  RecordingState get recordingState => _recordingState;

  /// 转录状态
  TranscriptionState _transcriptionState = TranscriptionState.idle;
  TranscriptionState get transcriptionState => _transcriptionState;

  /// 状态变更控制器
  final _stateController = StreamController<InspirationState>.broadcast();
  Stream<InspirationState> get stateStream => _stateController.stream;

  /// 开始录音
  Future<void> startRecording() async {
    _recordingState = RecordingState.recording;
    _notifyState();
    debugPrint('[Inspiration] 开始录音');
  }

  /// 暂停录音
  Future<void> pauseRecording() async {
    _recordingState = RecordingState.paused;
    _notifyState();
    debugPrint('[Inspiration] 暂停录音');
  }

  /// 恢复录音
  Future<void> resumeRecording() async {
    _recordingState = RecordingState.recording;
    _notifyState();
    debugPrint('[Inspiration] 恢复录音');
  }

  /// 停止录音并添加段落
  Future<void> stopRecording(String filePath, Duration duration) async {
    _recordingState = RecordingState.stopped;
    
    final segment = AudioSegment(
      id: const Uuid().v4(),
      filePath: filePath,
      duration: duration,
      createdAt: DateTime.now(),
    );
    
    state = state.copyWith(
      segments: [...state.segments, segment],
    );
    
    _notifyState();
    debugPrint('[Inspiration] 停止录音，添加段落: ${segment.id}');
  }

  /// 转录单个段落
  Future<String> transcribeSegment(String segmentId) async {
    final segment = state.segments.firstWhere((s) => s.id == segmentId);
    
    _transcriptionState = TranscriptionState.processing;
    _notifyState();
    
    try {
      final transcription = await _asrService.recognizeFile(segment.filePath);
      
      // 更新段落的转录文本
      final updatedSegments = state.segments.map((s) {
        if (s.id == segmentId) {
          return s.copyWith(transcription: transcription);
        }
        return s;
      }).toList();
      
      state = state.copyWith(segments: updatedSegments);
      
      _transcriptionState = TranscriptionState.completed;
      _notifyState();
      
      debugPrint('[Inspiration] 转录完成: $segmentId');
      return transcription;
    } catch (e) {
      _transcriptionState = TranscriptionState.failed;
      _notifyState();
      debugPrint('[Inspiration] 转录失败: $e');
      rethrow;
    }
  }

  /// 转录所有段落
  Future<void> transcribeAll() async {
    for (final segment in state.segments) {
      if (segment.transcription == null) {
        await transcribeSegment(segment.id);
      }
    }
  }

  /// 获取所有转录文本
  String getAllTranscriptions() {
    return state.segments
        .where((s) => s.transcription != null)
        .map((s) => s.transcription!)
        .join('\n\n');
  }

  /// 一键总结
  Future<String> generateSummary() async {
    final allText = getAllTranscriptions();
    if (allText.isEmpty) {
      throw Exception('没有可总结的转录文本');
    }
    
    // 简单总结实现（实际应调用 LLM）
    final lines = allText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final summary = StringBuffer();
    
    summary.writeln('## 总结');
    summary.writeln();
    
    for (var i = 0; i < lines.length && i < 10; i++) {
      summary.writeln('- ${lines[i]}');
    }
    
    state = state.copyWith(summary: summary.toString());
    _notifyState();
    
    debugPrint('[Inspiration] 总结生成完成');
    return summary.toString();
  }

  /// 生成思维导图
  Future<Map<String, dynamic>> generateMindMap() async {
    final allText = getAllTranscriptions();
    if (allText.isEmpty) {
      throw Exception('没有可生成思维导图的转录文本');
    }
    
    final mindMap = _docService.generateMindMapFromText(allText);
    
    state = state.copyWith(mindMap: mindMap);
    _notifyState();
    
    debugPrint('[Inspiration] 思维导图生成完成');
    return mindMap;
  }

  /// 导出总结
  Future<DocumentResult> exportSummary() async {
    if (state.summary == null) {
      await generateSummary();
    }
    
    return _docService.generateMarkdown(
      title: '灵感总结_${state.id}',
      content: state.summary!,
    );
  }

  /// 导出思维导图
  Future<DocumentResult> exportMindMap() async {
    if (state.mindMap == null) {
      await generateMindMap();
    }
    
    return _docService.generateXMind(
      title: '灵感导图_${state.id}',
      mindMapData: state.mindMap!,
    );
  }

  /// 创建新的灵感会话
  void newSession() {
    state = InspirationSession(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _notifyState();
  }

  /// 清除当前会话
  void clearSession() {
    state = InspirationSession(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
    );
    _notifyState();
  }

  void _notifyState() {
    _stateController.add(InspirationState(
      recordingState: _recordingState,
      transcriptionState: _transcriptionState,
      session: state,
    ));
  }

  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }
}

/// 灵感状态
class InspirationState {
  final RecordingState recordingState;
  final TranscriptionState transcriptionState;
  final InspirationSession session;

  InspirationState({
    required this.recordingState,
    required this.transcriptionState,
    required this.session,
  });
}

/// Riverpod Providers
final inspirationServiceProvider = StateNotifierProvider<InspirationService, InspirationSession>((ref) {
  return InspirationService(
    asrService: ASRService(),
    docService: DocumentGenerationService.instance,
  );
});
