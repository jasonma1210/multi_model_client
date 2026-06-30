/// 深度研究引擎
///
/// v0.42.0 新增：自动多源研究引擎。
/// 流程：用户问题 → LLM 拆解步骤 → 多源检索 → LLM 分析 → 综合报告。
///
/// 设计参考：
/// - OpenAI Deep Research
/// - Anthropic Claude Research
/// - Google Gemini Deep Research
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/app_logger.dart';
import '../../../core/services/knowledge_base_service.dart';
import '../../../core/services/file_parser_service.dart';
import '../../../core/services/web_search_service.dart';
// v0.42.0: 通过别名避免与领域模型类名冲突
import '../../../core/storage/database.dart' as db;
import '../../../core/templates/prompt_scenarios.dart' as scenarios;
import 'research_models.dart';

/// 研究引擎结果
@immutable
class ResearchResult {
  final String reportId;
  final List<ResearchStepResult> steps;
  final List<Citation> allCitations;
  final List<ResearchSection> sections;
  final String? finalTitle;
  final String? finalSummary;
  final int totalTokens;

  const ResearchResult({
    required this.reportId,
    required this.steps,
    required this.allCitations,
    required this.sections,
    this.finalTitle,
    this.finalSummary,
    required this.totalTokens,
  });
}

/// 单个研究步骤的结果
@immutable
class ResearchStepResult {
  final int stepIndex;
  final String title;
  final String content;
  final List<Citation> citations;
  final int tokensUsed;
  final int? durationMs;

  const ResearchStepResult({
    required this.stepIndex,
    required this.title,
    required this.content,
    this.citations = const [],
    required this.tokensUsed,
    this.durationMs,
  });
}

/// 深度研究引擎
class ResearchEngine {
  final db.AppDatabase _db;
  final WebSearchService _webSearch;
  final KnowledgeBaseService _knowledgeBase;
  final FileParserService _fileParser;
  final Future<String> Function(String systemPrompt, String userPrompt)
      _llmCaller;

  ResearchEngine({
    required db.AppDatabase db,
    required KnowledgeBaseService knowledgeBase,
    WebSearchService? webSearch,
    FileParserService? fileParser,
    required Future<String> Function(String, String) llmCaller,
  })  : _db = db,
        _webSearch = webSearch ?? WebSearchService(),
        _knowledgeBase = knowledgeBase,
        _fileParser = fileParser ?? FileParserService.instance,
        _llmCaller = llmCaller;

  /// 执行研究，返回流式进度事件
  Stream<ResearchProgressEvent> research(ResearchParams params) async* {
    final reportId = const Uuid().v4();
    final controller = StreamController<ResearchProgressEvent>();

    // 异步执行
    unawaited(_executeResearch(reportId, params, controller));

    // 流式 yield
    yield* controller.stream;
  }

  /// 内部执行
  Future<void> _executeResearch(
    String reportId,
    ResearchParams params,
    StreamController<ResearchProgressEvent> controller,
  ) async {
    try {
      // 1. 创建报告记录
      await _db.createResearchReport(db.ResearchReportsCompanion.insert(
        id: reportId,
        sessionId: const Value(null),
        query: params.query,
        title: '研究: ${params.query.substring(0, params.query.length.clamp(0, 50))}',
        status: Value(ResearchStatus.pending.name),
        totalSteps: const Value(0),
        completedSteps: const Value(0),
        totalTokens: const Value(0),
        modelConfigId: Value(params.modelConfigId),
        enabledSources: Value(
          jsonEncode(params.enabledSources.map((e) => e.name).toList()),
        ),
        createdAt: DateTime.now(),
      ));

      controller.add(
        ResearchStatusChanged(reportId, ResearchStatus.planning, '正在规划研究步骤...'),
      );
      await _updateReportStatus(reportId, ResearchStatus.planning);

      // 2. 调用 LLM 拆解研究计划
      final planJson = await _llmCaller(
        scenarios.PromptTemplates.researchPlanning,
        jsonEncode({
          'query': params.query,
          'enabled_sources': params.enabledSources.map((e) => e.name).join(', '),
        }),
      );

      final plan = _parsePlan(planJson);
      if (plan.isEmpty) {
        controller.add(const ResearchFailed('', '研究计划拆解失败'));
        return;
      }

      // 限制步骤数
      final limitedPlan = plan.take(params.maxSteps).toList();
      await _db.updateResearchReport(
        reportId,
        db.ResearchReportsCompanion(
          totalSteps: Value(limitedPlan.length),
          status: Value(ResearchStatus.searching.name),
        ),
      );
      controller.add(
        ResearchStatusChanged(reportId, ResearchStatus.searching, '共 ${limitedPlan.length} 步研究计划'),
      );

      // 3. 逐步执行
      int totalTokens = 0;
      final allCitations = <Citation>[];
      final allSections = <ResearchSection>[];

      for (var i = 0; i < limitedPlan.length; i++) {
        final planStep = limitedPlan[i];
        final stepStartTime = DateTime.now();
        final stepId = const Uuid().v4();

        // 保存步骤记录
        await _db.createResearchStep(db.ResearchStepsCompanion.insert(
          id: stepId,
          reportId: reportId,
          stepIndex: i + 1,
          type: planStep.type.name,
          title: planStep.title,
          description: Value(planStep.description),
          searchQuery: Value(planStep.searchQuery),
          status: const Value('running'),
          startedAt: Value(stepStartTime),
        ));

        controller.add(
          ResearchStepStarted(reportId, i + 1, planStep.title),
        );

        try {
          // 多源检索
          final stepCitations = await _retrieveCitations(
            planStep,
            params.enabledSources,
            params.knowledgeBaseId,
          );

          // LLM 分析
          final citationsText = stepCitations
              .map((c) => '[${c.index}] ${c.snippet ?? c.title}')
              .join('\n\n');

          final analysisText = await _llmCaller(
            scenarios.PromptTemplates.researchAnalysis,
            jsonEncode({
              'step_title': planStep.title,
              'step_description': planStep.description,
              'search_query': planStep.searchQuery ?? '',
              'citations': citationsText,
            }),
          );

          final stepDuration = DateTime.now().difference(stepStartTime).inMilliseconds;
          final stepTokens = analysisText.length ~/ 4; // 粗略估算

          // 累计引用
          allCitations.addAll(stepCitations);

          // 保存章节
          allSections.add(ResearchSection(
            sectionIndex: i + 1,
            title: planStep.title,
            content: analysisText,
            citationIndexes: stepCitations.map((c) => c.index).toList(),
          ));

          // 累计 tokens
          totalTokens += stepTokens;

          // 更新步骤状态
          await _db.updateResearchStep(
            stepId,
            db.ResearchStepsCompanion(
              status: const Value('completed'),
              outputData: Value(jsonEncode({
                'analysis': analysisText,
                'citations_count': stepCitations.length,
              })),
              tokensUsed: Value(stepTokens),
              completedAt: Value(DateTime.now()),
              durationMs: Value(stepDuration),
            ),
          );

          // 更新报告进度
          await _db.updateResearchReport(
            reportId,
            db.ResearchReportsCompanion(
              completedSteps: Value(i + 1),
              totalTokens: Value(totalTokens),
            ),
          );

          controller.add(
            ResearchStepCompleted(
              reportId,
              i + 1,
              newCitations: stepCitations,
              tokensUsed: stepTokens,
            ),
          );
        } catch (e) {
          logError('ResearchEngine', '步骤 ${i + 1} 失败: $e');
          await _db.updateResearchStep(
            stepId,
            db.ResearchStepsCompanion(
              status: const Value('failed'),
              errorMessage: Value(e.toString()),
              completedAt: Value(DateTime.now()),
            ),
          );
          controller.add(ResearchFailed(reportId, e.toString(), i + 1));
          // 单步失败不中断整体研究
        }
      }

      // 4. 综合生成最终报告
      controller.add(
        ResearchStatusChanged(reportId, ResearchStatus.synthesizing, '正在综合所有研究结果...'),
      );
      await _updateReportStatus(reportId, ResearchStatus.synthesizing);

      try {
        final sectionsText = allSections
            .map((s) =>
                '## ${s.title}\n${s.content}\n引用: [${s.citationIndexes.join(',')}]')
            .join('\n\n');
        final citationsText = allCitations
            .map((c) => '[${c.index}] ${c.title} - ${c.url ?? c.filePath ?? ''}')
            .join('\n');

        final synthesisText = await _llmCaller(
          scenarios.PromptTemplates.researchSynthesize,
          jsonEncode({
            'query': params.query,
            'sections': sectionsText,
            'citations': citationsText,
          }),
        );

        // 提取标题和摘要
        final titleMatch = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(synthesisText);
        final title = titleMatch?.group(1) ?? params.query;
        final summaryMatch = RegExp(
          r'##\s+摘要\s*\n+(.+?)(?=\n##|\n#|$)',
          multiLine: true,
          dotAll: true,
        ).firstMatch(synthesisText);
        final summary = summaryMatch?.group(1)?.trim() ?? '';

        totalTokens += synthesisText.length ~/ 4;

        // 更新报告
        await _db.updateResearchReport(
          reportId,
          db.ResearchReportsCompanion(
            status: const Value('completed'),
            title: Value(title),
            summary: Value(summary),
            totalTokens: Value(totalTokens),
            completedAt: Value(DateTime.now()),
          ),
        );

        // 持久化引用
        if (allCitations.isNotEmpty) {
          final citationRecords = allCitations
              .map((c) => db.ResearchCitationsCompanion.insert(
                    id: const Uuid().v4(),
                    reportId: reportId,
                    citationIndex: c.index,
                    sourceType: c.sourceType.name,
                    url: Value(c.url),
                    filePath: Value(c.filePath),
                    title: c.title,
                    snippet: Value(c.snippet),
                    relevanceScore: Value(c.relevanceScore),
                    fetchedAt: Value(c.fetchedAt ?? DateTime.now()),
                  ))
              .toList();
          await _db.createResearchCitations(citationRecords);
        }

        // 持久化章节
        if (allSections.isNotEmpty) {
          final sectionRecords = allSections
              .map((s) => db.ResearchSectionsCompanion.insert(
                    id: const Uuid().v4(),
                    reportId: reportId,
                    sectionIndex: s.sectionIndex,
                    title: s.title,
                    content: s.content,
                    citationIds: Value(jsonEncode(s.citationIndexes)),
                    createdAt: DateTime.now(),
                  ))
              .toList();
          await _db.createResearchSections(sectionRecords);
        }

        controller.add(ResearchCompleted(reportId, title: title, summary: summary));
      } catch (e) {
        logError('ResearchEngine', '综合报告失败: $e');
        await _db.updateResearchReport(
          reportId,
          db.ResearchReportsCompanion(
            status: const Value('failed'),
            completedAt: Value(DateTime.now()),
          ),
        );
        controller.add(ResearchFailed(reportId, '综合报告失败: $e'));
      }
    } catch (e, st) {
      logError('ResearchEngine', '研究失败: $e\n$st');
      try {
        await _db.updateResearchReport(
          reportId,
          db.ResearchReportsCompanion(
            status: const Value('failed'),
            completedAt: Value(DateTime.now()),
          ),
        );
      } catch (_) {}
      controller.add(ResearchFailed(reportId, e.toString()));
    } finally {
      await controller.close();
    }
  }

  /// 解析 LLM 输出的研究计划
  List<ResearchPlanStep> _parsePlan(String llmResponse) {
    try {
      // 尝试提取 JSON
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(llmResponse);
      if (jsonMatch == null) return [];
      final planJson = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      final steps = planJson['steps'] as List<dynamic>?;
      if (steps == null) return [];

      return steps
          .map((s) => ResearchPlanStep.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('ResearchEngine', '解析研究计划失败: $e');
      return [];
    }
  }

  /// 多源检索
  Future<List<Citation>> _retrieveCitations(
    ResearchPlanStep step,
    List<ResearchSource> enabledSources,
    String? knowledgeBaseId,
  ) async {
    final citations = <Citation>[];
    var index = 1;

    if (!step.requiresSearch) {
      return citations;
    }

    final query = step.searchQuery ?? step.title;

    for (final source in enabledSources) {
      try {
        switch (source) {
          case ResearchSource.web:
            if (query.length > 3) {
              final searchResults = await _webSearch.searchAndFetch(
                query,
                maxResults: 3,
              );
              for (final r in searchResults) {
                citations.add(Citation(
                  index: index++,
                  sourceType: CitationSourceType.web,
                  url: r.url,
                  title: r.title,
                  snippet: r.snippet,
                  relevanceScore: r.score,
                  fetchedAt: r.publishedAt ?? DateTime.now(),
                ));
              }
            }
            break;

          case ResearchSource.knowledgeBase:
            if (knowledgeBaseId == null || knowledgeBaseId.isEmpty) break;
            final kbResults = await _knowledgeBase.searchKnowledgeBase(
              knowledgeBaseId,
              query,
              limit: 3,
            );
            for (final r in kbResults) {
              citations.add(Citation(
                index: index++,
                sourceType: CitationSourceType.knowledgeBase,
                filePath: 'knowledge_chunk_${r.chunkId}',
                title: '知识库分块',
                snippet: r.content.length > 500
                    ? '${r.content.substring(0, 500)}...'
                    : r.content,
                relevanceScore: r.rank,
                fetchedAt: DateTime.now(),
              ));
            }
            break;

          case ResearchSource.file:
            final files = await _fileParser.listRecentFiles(limit: 3);
            for (final f in files) {
              citations.add(Citation(
                index: index++,
                sourceType: CitationSourceType.file,
                filePath: f.path,
                title: f.name,
                snippet: null,
                relevanceScore: null,
                fetchedAt: f.modifiedAt,
              ));
            }
            break;
        }
      } catch (e) {
        logWarning('ResearchEngine', '${source.name} 检索失败: $e');
      }
    }

    return citations;
  }

  /// 更新报告状态
  Future<void> _updateReportStatus(String reportId, ResearchStatus status) async {
    await _db.updateResearchReport(
      reportId,
      db.ResearchReportsCompanion(status: Value(status.name)),
    );
  }
}
