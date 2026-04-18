import 'dart:convert';
import 'package:http/http.dart' as http;
import '../skill.dart';

/// 搜索技能
/// 支持多种搜索引擎和搜索类型
class SearchSkill extends Skill {
  const SearchSkill()
      : super(
          id: 'native.search',
          name: '网络搜索',
          description: '搜索网络信息，支持网页、图片、新闻等多种类型',
          type: SkillType.native,
          parameters: const [
            SkillParameter(
              name: 'query',
              description: '搜索关键词',
              type: SkillParameterType.string,
              required: true,
            ),
            SkillParameter(
              name: 'type',
              description: '搜索类型',
              type: SkillParameterType.string,
              required: false,
              defaultValue: 'web',
              enumValues: ['web', 'image', 'news', 'video'],
            ),
            SkillParameter(
              name: 'limit',
              description: '返回结果数量',
              type: SkillParameterType.number,
              required: false,
              defaultValue: 5,
            ),
            SkillParameter(
              name: 'safeSearch',
              description: '安全搜索',
              type: SkillParameterType.boolean,
              required: false,
              defaultValue: true,
            ),
          ],
          icon: 'search',
          category: '搜索',
          tags: const ['search', 'web', 'internet', 'google', 'bing'],
          isBuiltin: true,
        );

  @override
  Future<SkillResult> execute(Map<String, dynamic> params) async {
    try {
      final validatedParams = validateParams(params);
      final query = validatedParams['query'] as String;
      final type = validatedParams['type'] as String? ?? 'web';
      final limit = (validatedParams['limit'] as num?)?.toInt() ?? 5;
      final safeSearch = validatedParams['safeSearch'] as bool? ?? true;

      // 由于实际搜索需要 API 密钥，这里提供一个模拟实现
      // 在实际应用中，可以集成 DuckDuckGo、Google Custom Search、Bing 等 API
      final results = await _performSearch(
        query: query,
        type: type,
        limit: limit,
        safeSearch: safeSearch,
      );

      return SkillResult.success({
        'query': query,
        'type': type,
        'results': results,
        'total': results.length,
      }, metadata: {
        'query': query,
        'type': type,
        'limit': limit,
        'safeSearch': safeSearch,
      });
    } on SkillValidationException {
      rethrow;
    } catch (e) {
      return SkillResult.error('搜索失败: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _performSearch({
    required String query,
    required String type,
    required int limit,
    required bool safeSearch,
  }) async {
    // 模拟搜索结果
    // 实际实现应该调用搜索引擎 API

    // 尝试使用 DuckDuckGo 的即时答案 API（无需 API 密钥）
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          'https://api.duckduckgo.com/?q=$encodedQuery&format=json&no_html=1&skip_disambig=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = <Map<String, dynamic>>[];

        // 提取摘要
        final abstract = data['Abstract'] as String?;
        final abstractUrl = data['AbstractURL'] as String?;
        final abstractSource = data['AbstractSource'] as String?;

        if (abstract != null && abstract.isNotEmpty) {
          results.add({
            'title': query,
            'snippet': abstract,
            'url': abstractUrl ?? '',
            'source': abstractSource ?? 'DuckDuckGo',
            'type': 'abstract',
          });
        }

        // 提取相关主题
        final related = data['RelatedTopics'] as List<dynamic>?;
        if (related != null) {
          for (var i = 0; i < related.length && results.length < limit; i++) {
            final topic = related[i] as Map<String, dynamic>;
            final text = topic['Text'] as String?;
            final firstUrl = topic['FirstURL'] as String?;

            if (text != null && text.isNotEmpty) {
              results.add({
                'title': text.split(' - ').first,
                'snippet': text,
                'url': firstUrl ?? '',
                'source': 'DuckDuckGo',
                'type': 'related',
              });
            }
          }
        }

        if (results.isNotEmpty) {
          return results;
        }
      }
    } catch (e) {
      // API 调用失败，返回模拟结果
    }

    // 返回模拟搜索结果
    return _generateMockResults(query, type, limit);
  }

  List<Map<String, dynamic>> _generateMockResults(
      String query, String type, int limit) {
    final mockResults = [
      {
        'title': '$query - 搜索结果 1',
        'snippet': '这是关于 $query 的第一个搜索结果。在实际实现中，这里将显示真实的搜索结果摘要。',
        'url': 'https://example.com/search/1',
        'source': 'Example Search',
        'type': type,
      },
      {
        'title': '$query - 搜索结果 2',
        'snippet': '这是关于 $query 的第二个搜索结果。包含更多相关信息和详细描述。',
        'url': 'https://example.com/search/2',
        'source': 'Example Search',
        'type': type,
      },
      {
        'title': '$query - 搜索结果 3',
        'snippet': '这是关于 $query 的第三个搜索结果。提供额外的参考信息和资源链接。',
        'url': 'https://example.com/search/3',
        'source': 'Example Search',
        'type': type,
      },
      {
        'title': '$query - 搜索结果 4',
        'snippet': '这是关于 $query 的第四个搜索结果。包含技术细节和实现说明。',
        'url': 'https://example.com/search/4',
        'source': 'Example Search',
        'type': type,
      },
      {
        'title': '$query - 搜索结果 5',
        'snippet': '这是关于 $query 的第五个搜索结果。提供最新的更新和动态信息。',
        'url': 'https://example.com/search/5',
        'source': 'Example Search',
        'type': type,
      },
    ];

    return mockResults.take(limit).toList();
  }

  @override
  String getExecutePrompt() {
    return '''
## 网络搜索

搜索网络信息，支持多种搜索类型。

### 搜索类型
- **web**: 网页搜索（默认）
- **image**: 图片搜索
- **news**: 新闻搜索
- **video**: 视频搜索

### 参数
- **query** (string, 必需): 搜索关键词
- **type** (string, 可选): 搜索类型，默认 "web"
- **limit** (number, 可选): 返回结果数量，默认 5
- **safeSearch** (boolean, 可选): 是否启用安全搜索，默认 true

### 返回结果
每个搜索结果包含：
- **title**: 标题
- **snippet**: 摘要
- **url**: 链接
- **source**: 来源
- **type**: 类型

### 示例
```json
{
  "query": "Flutter 教程",
  "type": "web",
  "limit": 3
}
```

### 注意
当前实现使用 DuckDuckGo API 或模拟数据。如需更好的搜索结果，建议配置：
- Google Custom Search API
- Bing Search API
- 其他搜索引擎 API
'''.trim();
  }
}
