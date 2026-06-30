/// ResearchModels 单元测试
///
/// v0.42.0 新增：覆盖深度研究领域模型的解析与状态。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/features/research/domain/research_models.dart';

void main() {
  group('ResearchStatus', () {
    test('从字符串解析', () {
      expect(ResearchStatusX.fromString('pending'), ResearchStatus.pending);
      expect(ResearchStatusX.fromString('planning'), ResearchStatus.planning);
      expect(ResearchStatusX.fromString('completed'), ResearchStatus.completed);
      expect(ResearchStatusX.fromString('failed'), ResearchStatus.failed);
    });

    test('未知字符串回退到 pending', () {
      expect(ResearchStatusX.fromString('xxx'), ResearchStatus.pending);
    });

    test('isRunning 仅在执行阶段为 true', () {
      expect(ResearchStatus.pending.isRunning, false);
      expect(ResearchStatus.planning.isRunning, true);
      expect(ResearchStatus.searching.isRunning, true);
      expect(ResearchStatus.analyzing.isRunning, true);
      expect(ResearchStatus.synthesizing.isRunning, true);
      expect(ResearchStatus.completed.isRunning, false);
      expect(ResearchStatus.failed.isRunning, false);
    });

    test('displayName 返回中文', () {
      expect(ResearchStatus.pending.displayName, '等待开始');
      expect(ResearchStatus.completed.displayName, '已完成');
    });
  });

  group('ResearchPlanStep.fromJson', () {
    test('解析 search 类型步骤', () {
      final json = {
        'step_index': 1,
        'type': 'search',
        'title': '市场调研',
        'description': '收集市场数据',
        'search_query': '市场规模 2026',
        'requires_search': true,
      };
      final step = ResearchPlanStep.fromJson(json);
      expect(step.stepIndex, 1);
      expect(step.type, ResearchStepType.search);
      expect(step.title, '市场调研');
      expect(step.searchQuery, '市场规模 2026');
      expect(step.requiresSearch, true);
    });

    test('解析 analyze 类型步骤 - 默认为不需搜索', () {
      final json = {
        'step_index': 2,
        'type': 'analyze',
        'title': '分析数据',
        'description': '分析结果',
      };
      final step = ResearchPlanStep.fromJson(json);
      expect(step.type, ResearchStepType.analyze);
      expect(step.requiresSearch, false);
      expect(step.searchQuery, isNull);
    });
  });

  group('Citation', () {
    test('displayLocation 优先级: url > filePath > title', () {
      final c1 = Citation(
        index: 1,
        sourceType: CitationSourceType.web,
        url: 'https://example.com',
        title: 'fallback',
      );
      expect(c1.displayLocation, 'https://example.com');

      final c2 = Citation(
        index: 2,
        sourceType: CitationSourceType.file,
        filePath: '/tmp/a.pdf',
        title: 'fallback',
      );
      expect(c2.displayLocation, '/tmp/a.pdf');

      final c3 = Citation(
        index: 3,
        sourceType: CitationSourceType.knowledgeBase,
        title: 'only title',
      );
      expect(c3.displayLocation, 'only title');
    });
  });

  group('ResearchParams', () {
    test('默认值', () {
      const params = ResearchParams(query: 'test');
      expect(params.query, 'test');
      expect(params.maxSteps, 7);
      expect(params.enabledSources.length, 3);
      expect(params.preferLocal, false);
      expect(params.knowledgeBaseId, isNull);
    });

    test('自定义配置', () {
      const params = ResearchParams(
        query: 'test',
        modelConfigId: 'm1',
        maxSteps: 5,
        knowledgeBaseId: 'kb1',
      );
      expect(params.maxSteps, 5);
      expect(params.modelConfigId, 'm1');
      expect(params.knowledgeBaseId, 'kb1');
    });
  });
}
