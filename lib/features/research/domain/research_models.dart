/// 深度研究数据模型
///
/// v0.42.0 新增：研究报告、步骤、引用、章节的数据模型。
/// 设计参考：GPT-5 Deep Research、Claude Research、Gemini Deep Research 公开 API。
library;

import 'package:flutter/foundation.dart';

/// 研究状态
enum ResearchStatus {
  /// 等待开始
  pending,

  /// 规划中（拆解步骤）
  planning,

  /// 检索中
  searching,

  /// 分析中
  analyzing,

  /// 综合报告
  synthesizing,

  /// 已完成
  completed,

  /// 失败
  failed,
}

extension ResearchStatusX on ResearchStatus {
  String get name {
    switch (this) {
      case ResearchStatus.pending:
        return 'pending';
      case ResearchStatus.planning:
        return 'planning';
      case ResearchStatus.searching:
        return 'searching';
      case ResearchStatus.analyzing:
        return 'analyzing';
      case ResearchStatus.synthesizing:
        return 'synthesizing';
      case ResearchStatus.completed:
        return 'completed';
      case ResearchStatus.failed:
        return 'failed';
    }
  }

  String get displayName {
    switch (this) {
      case ResearchStatus.pending:
        return '等待开始';
      case ResearchStatus.planning:
        return '规划研究中';
      case ResearchStatus.searching:
        return '检索信息中';
      case ResearchStatus.analyzing:
        return '分析信息中';
      case ResearchStatus.synthesizing:
        return '生成报告中';
      case ResearchStatus.completed:
        return '已完成';
      case ResearchStatus.failed:
        return '失败';
    }
  }

  bool get isRunning =>
      this == ResearchStatus.planning ||
      this == ResearchStatus.searching ||
      this == ResearchStatus.analyzing ||
      this == ResearchStatus.synthesizing;

  static ResearchStatus fromString(String value) {
    for (final s in ResearchStatus.values) {
      if (s.name == value) return s;
    }
    return ResearchStatus.pending;
  }
}

/// 研究步骤类型
enum ResearchStepType {
  /// 规划（拆解任务）
  planning,

  /// 检索
  search,

  /// 分析
  analyze,

  /// 综合
  synthesize,
}

extension ResearchStepTypeX on ResearchStepType {
  String get name {
    return toString().split('.').last;
  }

  String get displayName {
    switch (this) {
      case ResearchStepType.planning:
        return '规划';
      case ResearchStepType.search:
        return '检索';
      case ResearchStepType.analyze:
        return '分析';
      case ResearchStepType.synthesize:
        return '综合';
    }
  }

  static ResearchStepType fromString(String value) {
    for (final t in ResearchStepType.values) {
      if (t.name == value) return t;
    }
    return ResearchStepType.search;
  }
}

/// 步骤状态
enum StepStatus {
  pending,
  running,
  completed,
  failed,
}

extension StepStatusX on StepStatus {
  String get name {
    return toString().split('.').last;
  }

  static StepStatus fromString(String value) {
    for (final s in StepStatus.values) {
      if (s.name == value) return s;
    }
    return StepStatus.pending;
  }
}

/// 引用来源类型
enum CitationSourceType {
  /// Web 网页
  web,

  /// 本地文件
  file,

  /// 知识库
  knowledgeBase,

  /// RSS 订阅
  rss,
}

extension CitationSourceTypeX on CitationSourceType {
  String get name {
    return toString().split('.').last;
  }

  String get displayName {
    switch (this) {
      case CitationSourceType.web:
        return '网页';
      case CitationSourceType.file:
        return '文件';
      case CitationSourceType.knowledgeBase:
        return '知识库';
      case CitationSourceType.rss:
        return 'RSS';
    }
  }

  static CitationSourceType fromString(String value) {
    for (final t in CitationSourceType.values) {
      if (t.name == value) return t;
    }
    return CitationSourceType.web;
  }
}

/// 启用的检索源
enum ResearchSource {
  web,
  knowledgeBase,
  file,
}

extension ResearchSourceX on ResearchSource {
  String get name {
    return toString().split('.').last;
  }
}

/// 研究规划步骤
@immutable
class ResearchPlanStep {
  final int stepIndex;
  final ResearchStepType type;
  final String title;
  final String description;
  final String? searchQuery;
  final bool requiresSearch;

  const ResearchPlanStep({
    required this.stepIndex,
    required this.type,
    required this.title,
    required this.description,
    this.searchQuery,
    this.requiresSearch = false,
  });

  factory ResearchPlanStep.fromJson(Map<String, dynamic> json) {
    return ResearchPlanStep(
      stepIndex: json['step_index'] as int,
      type: ResearchStepTypeX.fromString(json['type'] as String? ?? 'search'),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      searchQuery: json['search_query'] as String?,
      requiresSearch: json['requires_search'] as bool? ?? false,
    );
  }
}

/// 引用条目
@immutable
class Citation {
  final int index;
  final CitationSourceType sourceType;
  final String? url;
  final String? filePath;
  final String title;
  final String? snippet;
  final double? relevanceScore;
  final DateTime? fetchedAt;

  const Citation({
    required this.index,
    required this.sourceType,
    this.url,
    this.filePath,
    required this.title,
    this.snippet,
    this.relevanceScore,
    this.fetchedAt,
  });

  String get displayLocation {
    if (url != null) return url!;
    if (filePath != null) return filePath!;
    return title;
  }
}

/// 报告章节
@immutable
class ResearchSection {
  final int sectionIndex;
  final String title;
  final String content;
  final List<int> citationIndexes;

  const ResearchSection({
    required this.sectionIndex,
    required this.title,
    required this.content,
    this.citationIndexes = const [],
  });
}

/// 研究进度事件（流式）
sealed class ResearchProgressEvent {
  final String reportId;
  const ResearchProgressEvent(this.reportId);
}

/// 状态变更
class ResearchStatusChanged extends ResearchProgressEvent {
  final ResearchStatus status;
  final String? message;
  const ResearchStatusChanged(super.reportId, this.status, [this.message]);
}

/// 步骤开始
class ResearchStepStarted extends ResearchProgressEvent {
  final int stepIndex;
  final String stepTitle;
  const ResearchStepStarted(
    super.reportId,
    this.stepIndex,
    this.stepTitle,
  );
}

/// 步骤进度
class ResearchStepProgress extends ResearchProgressEvent {
  final int stepIndex;
  final String message;
  const ResearchStepProgress(super.reportId, this.stepIndex, this.message);
}

/// 步骤完成
class ResearchStepCompleted extends ResearchProgressEvent {
  final int stepIndex;
  final List<Citation> newCitations;
  final int tokensUsed;
  const ResearchStepCompleted(
    super.reportId,
    this.stepIndex, {
    required this.newCitations,
    required this.tokensUsed,
  });
}

/// 报告完成
class ResearchCompleted extends ResearchProgressEvent {
  final String title;
  final String summary;
  const ResearchCompleted(super.reportId, {
    required this.title,
    required this.summary,
  });
}

/// 报告失败
class ResearchFailed extends ResearchProgressEvent {
  final String error;
  final int? stepIndex;
  const ResearchFailed(super.reportId, this.error, [this.stepIndex]);
}

/// 研究执行参数
@immutable
class ResearchParams {
  /// 研究问题
  final String query;

  /// 使用的模型配置 ID
  final String? modelConfigId;

  /// 启用的检索源
  final List<ResearchSource> enabledSources;

  /// 最大步骤数
  final int maxSteps;

  /// 是否限制为本地优先
  final bool preferLocal;

  /// 关联的知识库 ID（用于知识库检索）
  final String? knowledgeBaseId;

  const ResearchParams({
    required this.query,
    this.modelConfigId,
    this.enabledSources = const [
      ResearchSource.web,
      ResearchSource.knowledgeBase,
      ResearchSource.file,
    ],
    this.maxSteps = 7,
    this.preferLocal = false,
    this.knowledgeBaseId,
  });
}
