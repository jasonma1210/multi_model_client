/// 深度研究 Provider（v0.42.0）
///
/// 集中管理 ResearchEngine 实例和研究状态。
///
/// 设计原则：
/// - ResearchEngine 接受 LLM Caller 函数注入，避免与具体 LLM Provider 强耦合
/// - UI 层启动研究时需要传入 LLM Caller（保证运行时上下文完整）
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/file_parser_service.dart';
import '../../../core/services/knowledge_base_service.dart';
import '../../../core/services/web_search_service.dart';
import '../../model/providers/thinking_budget_provider.dart'
    show appDatabaseProvider;
import '../domain/research_engine.dart';
import '../domain/research_models.dart';

/// LLM 调用函数签名（非流式）
typedef ResearchLlmCaller = Future<String> Function(
  String systemPrompt,
  String userPrompt,
);

/// KnowledgeBaseService Provider
final knowledgeBaseServiceProvider = Provider<KnowledgeBaseService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return KnowledgeBaseService(db);
});

/// WebSearchService Provider
final webSearchServiceProvider = Provider<WebSearchService>((ref) {
  return WebSearchService();
});

/// 当前 LLM Caller Provider（启动研究前必须 override）
final researchLlmCallerProvider = Provider<ResearchLlmCaller>((ref) {
  throw UnimplementedError('researchLlmCallerProvider 必须在启动研究前 override');
});

/// 研究引擎 Provider
final researchEngineProvider = Provider<ResearchEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final knowledgeBase = ref.watch(knowledgeBaseServiceProvider);
  final webSearch = ref.watch(webSearchServiceProvider);
  final llmCaller = ref.watch(researchLlmCallerProvider);

  return ResearchEngine(
    db: db,
    knowledgeBase: knowledgeBase,
    webSearch: webSearch,
    fileParser: FileParserService.instance,
    llmCaller: llmCaller,
  );
});

/// 当前研究报告状态（用于 UI 实时显示进度）
class ResearchReportState {
  final String? currentReportId;
  final ResearchStatus status;
  final String? statusMessage;
  final List<ResearchProgressEvent> eventLog;
  final List<Citation> allCitations;
  final int completedSteps;
  final int totalSteps;
  final String? finalTitle;
  final String? finalSummary;
  final int totalTokens;
  final String? error;

  const ResearchReportState({
    this.currentReportId,
    this.status = ResearchStatus.pending,
    this.statusMessage,
    this.eventLog = const [],
    this.allCitations = const [],
    this.completedSteps = 0,
    this.totalSteps = 0,
    this.finalTitle,
    this.finalSummary,
    this.totalTokens = 0,
    this.error,
  });

  ResearchReportState copyWith({
    String? currentReportId,
    ResearchStatus? status,
    String? statusMessage,
    List<ResearchProgressEvent>? eventLog,
    List<Citation>? allCitations,
    int? completedSteps,
    int? totalSteps,
    String? finalTitle,
    String? finalSummary,
    int? totalTokens,
    String? error,
  }) {
    return ResearchReportState(
      currentReportId: currentReportId ?? this.currentReportId,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      eventLog: eventLog ?? this.eventLog,
      allCitations: allCitations ?? this.allCitations,
      completedSteps: completedSteps ?? this.completedSteps,
      totalSteps: totalSteps ?? this.totalSteps,
      finalTitle: finalTitle ?? this.finalTitle,
      finalSummary: finalSummary ?? this.finalSummary,
      totalTokens: totalTokens ?? this.totalTokens,
      error: error,
    );
  }
}

/// 研究报告 Controller
class ResearchReportController extends StateNotifier<ResearchReportState> {
  final Ref _ref;

  ResearchReportController(this._ref) : super(const ResearchReportState());

  /// 启动新研究
  Future<void> startResearch(ResearchParams params) async {
    state = const ResearchReportState(
      status: ResearchStatus.planning,
      statusMessage: '正在启动研究...',
    );

    try {
      final engine = _ref.read(researchEngineProvider);

      // 订阅进度事件
      await for (final event in engine.research(params)) {
        _handleEvent(event);
      }
    } catch (e) {
      state = state.copyWith(
        status: ResearchStatus.failed,
        error: e.toString(),
        statusMessage: '研究失败: $e',
      );
    }
  }

  /// 重置状态
  void reset() {
    state = const ResearchReportState();
  }

  void _handleEvent(ResearchProgressEvent event) {
    if (event is ResearchStatusChanged) {
      state = state.copyWith(
        currentReportId: event.reportId,
        status: event.status,
        statusMessage: event.message,
        eventLog: [...state.eventLog, event],
      );
    } else if (event is ResearchStepStarted) {
      state = state.copyWith(
        currentReportId: event.reportId,
        status: ResearchStatus.searching,
        eventLog: [...state.eventLog, event],
        statusMessage: '执行第 ${event.stepIndex} 步: ${event.stepTitle}',
      );
    } else if (event is ResearchStepCompleted) {
      state = state.copyWith(
        currentReportId: event.reportId,
        status: ResearchStatus.analyzing,
        completedSteps: event.stepIndex,
        eventLog: [...state.eventLog, event],
        allCitations: [...state.allCitations, ...event.newCitations],
        totalTokens: state.totalTokens + event.tokensUsed,
      );
    } else if (event is ResearchCompleted) {
      state = state.copyWith(
        currentReportId: event.reportId,
        status: ResearchStatus.completed,
        finalTitle: event.title,
        finalSummary: event.summary,
        eventLog: [...state.eventLog, event],
        statusMessage: '研究完成',
      );
    } else if (event is ResearchFailed) {
      state = state.copyWith(
        currentReportId: event.reportId.isNotEmpty
            ? event.reportId
            : state.currentReportId,
        status: ResearchStatus.failed,
        error: event.error,
        eventLog: [...state.eventLog, event],
        statusMessage: '失败: ${event.error}',
      );
    }
  }
}

/// 研究报告 Provider
final researchReportProvider =
    StateNotifierProvider<ResearchReportController, ResearchReportState>(
  (ref) => ResearchReportController(ref),
);
