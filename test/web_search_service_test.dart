/// WebSearchService 单元测试
///
/// v0.42.0 新增：测试 Web 检索服务。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/web_search_service.dart';

void main() {
  group('WebSearchService - URL 识别', () {
    test('非 URL 短查询返回空结果', () async {
      final service = WebSearchService();
      final results = await service.searchAndFetch('hi', maxResults: 3);
      expect(results, isEmpty);
    });

    test('非 URL 普通查询返回空结果', () async {
      final service = WebSearchService();
      final results =
          await service.searchAndFetch('hello world', maxResults: 3);
      expect(results, isEmpty);
    });

    test('空字符串返回空结果', () async {
      final service = WebSearchService();
      final results = await service.searchAndFetch('', maxResults: 3);
      expect(results, isEmpty);
    });
  });

  group('WebSearchResult', () {
    test('基本字段赋值', () {
      final r = WebSearchResult(
        title: 'Test',
        url: 'https://example.com',
        snippet: 'snippet content',
        score: 0.95,
      );
      expect(r.title, 'Test');
      expect(r.url, 'https://example.com');
      expect(r.snippet, 'snippet content');
      expect(r.score, 0.95);
      expect(r.publishedAt, isNull);
    });
  });
}
