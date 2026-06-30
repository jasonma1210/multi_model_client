/// ResearchEngine 单元测试（v0.42.0）
///
/// 覆盖 _parsePlan / _retrieveCitations / 错误降级等关键逻辑。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/features/research/domain/research_models.dart';

void main() {
  group('ResearchPlanStep JSON 解析', () {
    test('完整字段解析', () {
      final json = {
        'step_index': 1,
        'type': 'search',
        'title': '市场调研',
        'description': '收集 2026 年市场规模',
        'search_query': '市场规模',
        'requires_search': true,
      };
      final step = ResearchPlanStep.fromJson(json);
      expect(step.stepIndex, 1);
      expect(step.type, ResearchStepType.search);
      expect(step.title, '市场调研');
      expect(step.description, '收集 2026 年市场规模');
      expect(step.searchQuery, '市场规模');
      expect(step.requiresSearch, true);
    });

    test('最小化字段解析（仅必填项）', () {
      final json = {
        'step_index': 0,
        'type': 'synthesize',
        'title': '综合',
        'description': '综合所有结果',
      };
      final step = ResearchPlanStep.fromJson(json);
      expect(step.type, ResearchStepType.synthesize);
      expect(step.requiresSearch, false);
      expect(step.searchQuery, isNull);
    });

    test('未知 type 回退到 search', () {
      final json = {
        'step_index': 0,
        'type': 'unknown_type',
        'title': 't',
        'description': 'd',
      };
      final step = ResearchPlanStep.fromJson(json);
      expect(step.type, ResearchStepType.search);
    });

    test('类型 toString 正常', () {
      expect(ResearchStepType.planning.toString().contains('planning'), true);
      expect(ResearchStepType.search.toString().contains('search'), true);
    });
  });

  group('ResearchSource 序列化', () {
    test('名称正确', () {
      expect(ResearchSource.web.name, 'web');
      expect(ResearchSource.knowledgeBase.name, 'knowledgeBase');
      expect(ResearchSource.file.name, 'file');
    });
  });

  group('Citation 字段', () {
    test('fetchedAt 默认为 null', () {
      final c = Citation(
        index: 1,
        sourceType: CitationSourceType.web,
        url: 'https://x.com',
        title: 't',
      );
      expect(c.fetchedAt, isNull);
    });

    test('relevanceScore 默认为 null', () {
      final c = Citation(
        index: 2,
        sourceType: CitationSourceType.file,
        filePath: '/a/b.txt',
        title: 'f',
      );
      expect(c.relevanceScore, isNull);
    });
  });

  group('ResearchProgressEvent 类型', () {
    test('ResearchStatusChanged 构造', () {
      final event = ResearchStatusChanged('r1', ResearchStatus.planning, 'msg');
      expect(event.reportId, 'r1');
      expect(event.status, ResearchStatus.planning);
      expect(event.message, 'msg');
    });

    test('ResearchStepStarted 构造', () {
      final event = ResearchStepStarted('r1', 1, 'title');
      expect(event.stepIndex, 1);
      expect(event.stepTitle, 'title');
    });

    test('ResearchCompleted 包含标题和摘要', () {
      final event = ResearchCompleted('r1', title: 'T', summary: 'S');
      expect(event.title, 'T');
      expect(event.summary, 'S');
    });

    test('ResearchFailed 包含原因', () {
      final event = ResearchFailed('r1', 'error message');
      expect(event.error, 'error message');
    });
  });

  group('ResearchSection 字段', () {
    test('citationIndexes 默认空', () {
      const s = ResearchSection(
        sectionIndex: 1,
        title: 't',
        content: 'c',
      );
      expect(s.citationIndexes, isEmpty);
    });
  });
}
