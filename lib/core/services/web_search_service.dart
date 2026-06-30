/// Web 搜索服务（v0.42.0 新增）
///
/// 深度研究功能需要的网页搜索能力。
/// Jina Reader 仅支持 URL 内容抓取（r.jina.ai），不提供搜索 API。
/// 本服务提供轻量级 Web 搜索抽象，后续可对接：
/// - DuckDuckGo HTML
/// - Google Custom Search
/// - Bing Search API
/// - SerpAPI
library;

import 'package:dio/dio.dart';
import 'app_logger.dart';

/// 搜索结果
class WebSearchResult {
  final String title;
  final String url;
  final String snippet;
  final double? score;
  final DateTime? publishedAt;

  const WebSearchResult({
    required this.title,
    required this.url,
    required this.snippet,
    this.score,
    this.publishedAt,
  });
}

/// Web 搜索服务
class WebSearchService {
  final Dio _dio;

  WebSearchService({Dio? dio}) : _dio = dio ?? Dio();

  /// 搜索并获取（v0.42.0）
  ///
  /// 注意：当前为最小可用实现 - 后续可替换为生产级搜索引擎。
  /// 实际策略：
  /// 1. 检查 query 是否为 URL（直接抓取）
  /// 2. 否则返回空列表（需要外部搜索引擎 API）
  Future<List<WebSearchResult>> searchAndFetch(
    String query, {
    int maxResults = 5,
  }) async {
    try {
      // 策略 1: query 本身就是 URL
      if (_isUrl(query)) {
        return await _fetchSingleUrl(query);
      }

      // 策略 2: 多 URL 列表（逗号或换行分隔）
      final urls = _extractUrls(query);
      if (urls.isNotEmpty) {
        return await _fetchMultipleUrls(urls.take(maxResults).toList());
      }

      // 策略 3: 真正的关键词搜索 - 当前未实现
      logWarning('WebSearchService', '关键词搜索功能尚未实现，需要接入搜索引擎 API');
      return const [];
    } catch (e) {
      logError('WebSearchService', 'searchAndFetch 失败: $e');
      return const [];
    }
  }

  /// 抓取单个 URL
  Future<List<WebSearchResult>> _fetchSingleUrl(String url) async {
    try {
      final response = await _dio.get<String>(
        'https://r.jina.ai/${Uri.encodeComponent(url)}',
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Accept': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return [
          WebSearchResult(
            title: url,
            url: url,
            snippet: _truncate(response.data!, 1500),
            score: 1.0,
            publishedAt: DateTime.now(),
          ),
        ];
      }
      return const [];
    } catch (e) {
      logWarning('WebSearchService', '抓取 $url 失败: $e');
      return const [];
    }
  }

  /// 抓取多个 URL
  Future<List<WebSearchResult>> _fetchMultipleUrls(List<String> urls) async {
    final results = <WebSearchResult>[];
    for (var i = 0; i < urls.length; i++) {
      final url = urls[i].trim();
      if (url.isEmpty) continue;
      final fetched = await _fetchSingleUrl(url);
      results.addAll(fetched);
    }
    return results;
  }

  /// 判断是否为 URL
  bool _isUrl(String s) {
    final trimmed = s.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  /// 从文本中提取 URL 列表
  List<String> _extractUrls(String text) {
    final urlRegExp = RegExp(
      r'https?://[^\s,;，。；、\n]+',
      caseSensitive: false,
    );
    return urlRegExp.allMatches(text).map((m) => m.group(0)!).toList();
  }

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}...';
  }
}
