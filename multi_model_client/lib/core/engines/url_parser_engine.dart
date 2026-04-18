/// URL 解析引擎 - LLM Studio 网页内容提取模块
/// 
/// 功能：
/// - 网页内容提取
/// - 多平台 URL 解析（抖音/小红书/B站等）
/// - 智能内容摘要
/// - Markdown 格式转换
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

import '../services/jina_reader_service.dart';

/// URL解析引擎
/// 提取网页内容并生成智能总结
class URLParserEngine {
  final Dio _dio;
  final JinaReaderService _jinaReader;

  URLParserEngine({Dio? dio})
      : _dio = dio ?? Dio(),
        _jinaReader = JinaReaderService();

  /// 解析URL并提取内容
  Future<URLContent> parseURL(String url) async {
    // 验证URL格式
    if (!_isValidURL(url)) {
      throw URLParseException('Invalid URL format');
    }

    // 识别平台
    final platform = _identifyPlatform(url);

    // 根据平台选择解析策略
    switch (platform) {
      case Platform.douyin:
        return await _parseDouyin(url);
      case Platform.xiaohongshu:
        return await _parseXiaohongshu(url);
      case Platform.bilibili:
        return await _parseBilibili(url);
      case Platform.zhihu:
        return await _parseZhihu(url);
      case Platform.weibo:
        return await _parseWeibo(url);
      default:
        return await _parseGenericWeb(url);
    }
  }

  /// 验证URL格式
  bool _isValidURL(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 识别平台
  Platform _identifyPlatform(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('douyin.com') || lowerUrl.contains('iesdouyin.com')) {
      return Platform.douyin;
    } else if (lowerUrl.contains('xiaohongshu.com') || lowerUrl.contains('xhslink.com')) {
      return Platform.xiaohongshu;
    } else if (lowerUrl.contains('bilibili.com') || lowerUrl.contains('b23.tv')) {
      return Platform.bilibili;
    } else if (lowerUrl.contains('zhihu.com')) {
      return Platform.zhihu;
    } else if (lowerUrl.contains('weibo.com') || lowerUrl.contains('weibo.cn')) {
      return Platform.weibo;
    }
    return Platform.generic;
  }

  /// 解析抖音视频
  Future<URLContent> _parseDouyin(String url) async {
    try {
      // 1. 获取视频ID
      final videoId = await _extractDouyinVideoId(url);
      if (videoId == null) {
        throw URLParseException('无法提取抖音视频ID');
      }

      // 2. 请求移动端页面获取元数据
      final mobileUrl = 'https://m.douyin.com/video/$videoId';
      final response = await _dio.get(
        mobileUrl,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9',
          },
        ),
      );

      final html = response.data as String;
      final document = parse(html);

      // 3. 提取标题和描述
      String title = '';
      String description = '';
      String? author;
      int likeCount = 0;
      int commentCount = 0;

      // 尝试从 SSR 数据中提取
      final scripts = document.querySelectorAll('script');
      for (final script in scripts) {
        final text = script.text;
        if (text.contains('SSR_HYDRATED_DATA')) {
          try {
            final match = RegExp(r'SSR_HYDRATED_DATA\s*=\s*({.+?});').firstMatch(text);
            if (match != null) {
              final jsonStr = match.group(1);
              if (jsonStr != null) {
                final data = json.decode(jsonStr);
                final videoData = data['app']?['videoDetail']?['video'];
                if (videoData != null) {
                  title = videoData['desc'] ?? '';
                  description = videoData['desc'] ?? '';
                  author = videoData['author']?['nickname'];
                  likeCount = videoData['statistics']?['diggCount'] ?? 0;
                  commentCount = videoData['statistics']?['commentCount'] ?? 0;
                }
              }
            }
          } catch (e) {
            // 忽略解析错误，继续尝试其他方式
          }
        }
      }

      // 4. 尝试从 meta 标签提取
      if (title.isEmpty) {
        final titleMeta = document.querySelector('meta[property="og:title"]');
        title = titleMeta?.attributes['content'] ?? '';
      }
      if (description.isEmpty) {
        final descMeta = document.querySelector('meta[property="og:description"]');
        description = descMeta?.attributes['content'] ?? '';
      }

      return DouyinContent(
        url: url,
        platform: Platform.douyin,
        title: title.isNotEmpty ? title : '抖音视频',
        content: description,
        author: author,
        publishTime: DateTime.now(),
        videoId: videoId,
        likeCount: likeCount,
        commentCount: commentCount,
      );
    } catch (e) {
      return DouyinContent(
        url: url,
        platform: Platform.douyin,
        title: '抖音视频',
        content: '解析失败: $e',
        author: null,
        publishTime: DateTime.now(),
        videoId: '',
        likeCount: 0,
        commentCount: 0,
      );
    }
  }

  /// 提取抖音视频ID
  Future<String?> _extractDouyinVideoId(String url) async {
    try {
      // 处理短链接
      if (url.contains('v.douyin.com') || url.contains('iesdouyin.com')) {
        final response = await _dio.head(url, options: Options(followRedirects: true));
        final finalUrl = response.realUri.toString();
        return _extractVideoIdFromUrl(finalUrl);
      }
      return _extractVideoIdFromUrl(url);
    } catch (e) {
      return _extractVideoIdFromUrl(url);
    }
  }

  String? _extractVideoIdFromUrl(String url) {
    // 匹配 /video/1234567890 格式
    final match = RegExp(r'/video/(\d+)').firstMatch(url);
    if (match != null) {
      return match.group(1);
    }
    // 匹配 ?video_id=1234567890 格式
    final idMatch = RegExp(r'video_id[=:](\d+)').firstMatch(url);
    if (idMatch != null) {
      return idMatch.group(1);
    }
    return null;
  }

  /// 解析小红书笔记
  Future<URLContent> _parseXiaohongshu(String url) async {
    try {
      // 1. 处理短链接
      String targetUrl = url;
      if (url.contains('xhslink.com')) {
        final response = await _dio.head(url, options: Options(followRedirects: true));
        targetUrl = response.realUri.toString();
      }

      // 2. 提取笔记ID
      final noteId = _extractXiaohongshuNoteId(targetUrl);
      if (noteId == null) {
        throw URLParseException('无法提取小红书笔记ID');
      }

      // 3. 请求页面获取元数据
      final response = await _dio.get(
        targetUrl,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9',
          },
        ),
      );

      final html = response.data as String;
      final document = parse(html);

      // 4. 提取数据
      String title = '';
      String content = '';
      String? author;
      List<String> images = [];
      List<String> tags = [];

      // 从 SSR 数据提取
      final scripts = document.querySelectorAll('script');
      for (final script in scripts) {
        final text = script.text;
        if (text.contains('window.__INITIAL_STATE__')) {
          try {
            final match = RegExp(r'window\.__INITIAL_STATE__\s*=\s*({.+?});').firstMatch(text);
            if (match != null) {
              final jsonStr = match.group(1);
              if (jsonStr != null) {
                final data = json.decode(jsonStr);
                final note = data['note']?['noteDetailMap']?[noteId];
                if (note != null) {
                  title = note['title'] ?? '';
                  content = note['desc'] ?? '';
                  author = note['user']?['nickname'];
                  
                  // 提取图片
                  final imageList = note['imageList'] as List?;
                  if (imageList != null) {
                    images = imageList.map((img) => img['url']?.toString() ?? '').where((u) => u.isNotEmpty).toList();
                  }
                  
                  // 提取标签
                  final tagList = note['tagList'] as List?;
                  if (tagList != null) {
                    tags = tagList.map((t) => t['name']?.toString() ?? '').where((t) => t.isNotEmpty).toList();
                  }
                }
              }
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }

      // 从 meta 标签提取
      if (title.isEmpty) {
        final titleMeta = document.querySelector('meta[property="og:title"]');
        title = titleMeta?.attributes['content'] ?? '';
      }
      if (content.isEmpty) {
        final descMeta = document.querySelector('meta[property="og:description"]');
        content = descMeta?.attributes['content'] ?? '';
      }

      return XiaohongshuContent(
        url: url,
        platform: Platform.xiaohongshu,
        title: title.isNotEmpty ? title : '小红书笔记',
        content: content,
        author: author,
        publishTime: DateTime.now(),
        noteId: noteId,
        images: images,
        tags: tags,
      );
    } catch (e) {
      return XiaohongshuContent(
        url: url,
        platform: Platform.xiaohongshu,
        title: '小红书笔记',
        content: '解析失败: $e',
        author: null,
        publishTime: DateTime.now(),
        noteId: '',
        images: [],
        tags: [],
      );
    }
  }

  /// 提取小红书笔记ID
  String? _extractXiaohongshuNoteId(String url) {
    // 匹配 /explore/ 或 /discovery/item/ 后的ID
    final match = RegExp(r'/(?:explore|discovery/item)/([a-zA-Z0-9]+)').firstMatch(url);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }

  /// 解析B站视频
  Future<URLContent> _parseBilibili(String url) async {
    try {
      // 1. 处理短链接
      String targetUrl = url;
      if (url.contains('b23.tv')) {
        final response = await _dio.head(url, options: Options(followRedirects: true));
        targetUrl = response.realUri.toString();
      }

      // 2. 提取视频ID (BV号或AV号)
      final videoId = _extractBilibiliVideoId(targetUrl);
      if (videoId == null) {
        throw URLParseException('无法提取B站视频ID');
      }

      // 3. 请求视频页面
      final response = await _dio.get(
        targetUrl,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9',
            'Referer': 'https://www.bilibili.com',
          },
        ),
      );

      final html = response.data as String;
      final document = parse(html);

      // 4. 提取数据
      String title = '';
      String description = '';
      String? author;
      String? category;
      String? subtitleText;

      // 从 __INITIAL_STATE__ 提取
      final scripts = document.querySelectorAll('script');
      for (final script in scripts) {
        final text = script.text;
        if (text.contains('window.__INITIAL_STATE__')) {
          try {
            final match = RegExp(r'window\.__INITIAL_STATE__\s*=\s*({.+?});\s*</script>', dotAll: true).firstMatch(text);
            if (match != null) {
              final jsonStr = match.group(1);
              if (jsonStr != null) {
                final data = json.decode(jsonStr);
                final videoData = data['videoData'];
                if (videoData != null) {
                  title = videoData['title'] ?? '';
                  description = videoData['desc'] ?? '';
                  author = videoData['owner']?['name'];
                  category = videoData['tname'];
                }
                
                // 提取字幕
                final subtitleData = data['subtitle']?['subtitles'] as List?;
                if (subtitleData != null && subtitleData.isNotEmpty) {
                  final firstSubtitle = subtitleData.first;
                  final subtitleUrl = firstSubtitle['subtitle_url'];
                  if (subtitleUrl != null) {
                    subtitleText = await _fetchBilibiliSubtitle(subtitleUrl);
                  }
                }
              }
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }

      // 从 meta 标签提取
      if (title.isEmpty) {
        final titleMeta = document.querySelector('meta[property="og:title"]');
        title = titleMeta?.attributes['content'] ?? '';
      }
      if (description.isEmpty) {
        final descMeta = document.querySelector('meta[property="og:description"]');
        description = descMeta?.attributes['content'] ?? '';
      }

      // 组合内容
      final contentBuffer = StringBuffer();
      if (description.isNotEmpty) {
        contentBuffer.writeln(description);
      }
      if (subtitleText != null && subtitleText.isNotEmpty) {
        contentBuffer.writeln('\n\n【字幕内容】\n$subtitleText');
      }

      return BilibiliContent(
        url: url,
        platform: Platform.bilibili,
        title: title.isNotEmpty ? title : 'B站视频',
        content: contentBuffer.toString(),
        author: author,
        publishTime: DateTime.now(),
        videoId: videoId,
        category: category,
        subtitleText: subtitleText,
      );
    } catch (e) {
      return BilibiliContent(
        url: url,
        platform: Platform.bilibili,
        title: 'B站视频',
        content: '解析失败: $e',
        author: null,
        publishTime: DateTime.now(),
        videoId: '',
        category: null,
        subtitleText: null,
      );
    }
  }

  /// 提取B站视频ID
  String? _extractBilibiliVideoId(String url) {
    // 匹配 BV号
    final bvMatch = RegExp(r'BV[0-9a-zA-Z]{10}').firstMatch(url);
    if (bvMatch != null) {
      return bvMatch.group(0);
    }
    // 匹配 av号
    final avMatch = RegExp(r'av(\d+)').firstMatch(url);
    if (avMatch != null) {
      return avMatch.group(0);
    }
    return null;
  }

  /// 获取B站字幕
  Future<String?> _fetchBilibiliSubtitle(String subtitleUrl) async {
    try {
      final response = await _dio.get(subtitleUrl);
      final data = response.data;
      if (data is Map && data.containsKey('body')) {
        final body = data['body'] as List;
        final subtitles = body.map((item) => item['content']?.toString() ?? '').where((s) => s.isNotEmpty).join('\n');
        return subtitles;
      }
    } catch (e) {
      // 忽略字幕获取错误
    }
    return null;
  }

  /// 解析知乎内容
  Future<URLContent> _parseZhihu(String url) async {
    try {
      // 1. 请求页面
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9',
          },
        ),
      );

      final html = response.data as String;
      final document = parse(html);

      // 2. 提取数据
      String title = '';
      String content = '';
      String? author;
      String? contentType;
      int? voteupCount;

      // 从 initialData 提取
      final scripts = document.querySelectorAll('script');
      for (final script in scripts) {
        final text = script.text;
        if (text.contains('window.__INITIAL_STATE__')) {
          try {
            final match = RegExp(r'window\.__INITIAL_STATE__\s*=\s*({.+?});').firstMatch(text);
            if (match != null) {
              final jsonStr = match.group(1);
              if (jsonStr != null) {
                final data = json.decode(jsonStr);
                
                // 判断是文章还是回答
                if (data.containsKey('entities') && data['entities'].containsKey('articles')) {
                  // 文章
                  contentType = 'article';
                  final articles = data['entities']['articles'] as Map?;
                  if (articles != null && articles.isNotEmpty) {
                    final article = articles.values.first;
                    title = article['title'] ?? '';
                    content = article['content'] ?? '';
                    author = article['author']?['name'];
                    voteupCount = article['voteupCount'];
                  }
                } else if (data.containsKey('entities') && data['entities'].containsKey('answers')) {
                  // 回答
                  contentType = 'answer';
                  final answers = data['entities']['answers'] as Map?;
                  if (answers != null && answers.isNotEmpty) {
                    final answer = answers.values.first;
                    content = answer['content'] ?? '';
                    author = answer['author']?['name'];
                    voteupCount = answer['voteupCount'];
                    
                    // 获取问题标题
                    final questions = data['entities']['questions'] as Map?;
                    if (questions != null && questions.isNotEmpty) {
                      title = questions.values.first['title'] ?? '';
                    }
                  }
                }
              }
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }

      // 从 meta 标签提取
      if (title.isEmpty) {
        final titleMeta = document.querySelector('meta[property="og:title"]');
        title = titleMeta?.attributes['content'] ?? '';
      }
      if (content.isEmpty) {
        final descMeta = document.querySelector('meta[property="og:description"]');
        content = descMeta?.attributes['content'] ?? '';
      }

      // 清理HTML标签
      content = _stripHtmlTags(content);

      return ZhihuContent(
        url: url,
        platform: Platform.zhihu,
        title: title.isNotEmpty ? title : '知乎内容',
        content: content,
        author: author,
        publishTime: DateTime.now(),
        contentType: contentType ?? 'unknown',
        voteupCount: voteupCount ?? 0,
      );
    } catch (e) {
      return ZhihuContent(
        url: url,
        platform: Platform.zhihu,
        title: '知乎内容',
        content: '解析失败: $e',
        author: null,
        publishTime: DateTime.now(),
        contentType: 'unknown',
        voteupCount: 0,
      );
    }
  }

  /// 移除HTML标签
  String _stripHtmlTags(String html) {
    if (html.isEmpty) return '';
    final document = parse(html);
    return document.body?.text ?? html;
  }

  /// 解析微博内容
  Future<URLContent> _parseWeibo(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9',
          },
        ),
      );

      final html = response.data as String;
      final document = parse(html);

      String title = '';
      String content = '';
      String? author;

      // 从 meta 标签提取
      final titleMeta = document.querySelector('meta[property="og:title"]');
      title = titleMeta?.attributes['content'] ?? '';
      
      final descMeta = document.querySelector('meta[property="og:description"]');
      content = descMeta?.attributes['content'] ?? '';

      return URLContent(
        url: url,
        platform: Platform.weibo,
        title: title.isNotEmpty ? title : '微博内容',
        content: content,
        author: author,
        publishTime: DateTime.now(),
        extra: {'type': 'weibo'},
      );
    } catch (e) {
      return URLContent(
        url: url,
        platform: Platform.weibo,
        title: '微博内容',
        content: '解析失败: $e',
        author: null,
        publishTime: DateTime.now(),
        extra: {'type': 'weibo'},
      );
    }
  }

  /// 解析通用网页
  /// 优先使用 Jina Reader API 解析，失败则回退到原生解析
  Future<URLContent> _parseGenericWeb(String url) async {
    // 方案1：使用 Jina Reader API（推荐）
    try {
      final jinaResult = await _jinaReader.readURL(url, returnMarkdown: true);
      if (jinaResult.success && jinaResult.content.isNotEmpty) {
        return URLContent(
          url: url,
          platform: Platform.generic,
          title: jinaResult.title ?? '网页内容',
          content: jinaResult.content,
          author: null,
          publishTime: DateTime.now(),
          extra: {
            'type': 'webpage',
            'source': 'jina_reader',
            'description': jinaResult.description,
            'image': jinaResult.image,
          },
        );
      }
    } catch (e) {
      // Jina 失败，继续尝试原生解析
    }

    // 方案2：原生 HTML 解析（后备）
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9',
          },
        ),
      );

      final html = response.data as String;
      final document = parse(html);

      // 提取标题
      String title = '';
      final titleMeta = document.querySelector('meta[property="og:title"]');
      if (titleMeta != null) {
        title = titleMeta.attributes['content'] ?? '';
      }
      if (title.isEmpty) {
        final titleTag = document.querySelector('title');
        title = titleTag?.text ?? '';
      }

      // 提取描述
      String content = '';
      final descMeta = document.querySelector('meta[property="og:description"]');
      if (descMeta != null) {
        content = descMeta.attributes['content'] ?? '';
      }
      if (content.isEmpty) {
        final descTag = document.querySelector('meta[name="description"]');
        content = descTag?.attributes['content'] ?? '';
      }

      // 提取正文（简化版）
      if (content.isEmpty) {
        final article = document.querySelector('article');
        if (article != null) {
          content = article.text.trim();
        } else {
          // 尝试提取主要内容区域
          final main = document.querySelector('main');
          if (main != null) {
            content = main.text.trim();
          }
        }
        // 限制长度
        if (content.length > 1000) {
          content = '${content.substring(0, 1000)}...';
        }
      }

      return URLContent(
        url: url,
        platform: Platform.generic,
        title: title.isNotEmpty ? title : '网页内容',
        content: content,
        author: null,
        publishTime: DateTime.now(),
        extra: {'type': 'webpage', 'source': 'native'},
      );
    } catch (e) {
      return URLContent(
        url: url,
        platform: Platform.generic,
        title: '网页内容',
        content: '解析失败: $e',
        author: null,
        publishTime: DateTime.now(),
        extra: {'type': 'webpage'},
      );
    }
  }
}

/// 智能总结引擎
class SummaryEngine {
  /// 生成极简摘要
  Future<String> generateBriefSummary(String content) async {
    // TODO: 使用LLM生成极简摘要
    // 控制在100字以内
    return '这是内容的极简摘要，提取最核心的信息。';
  }

  /// 生成详细总结
  Future<String> generateDetailedSummary(String content) async {
    // TODO: 使用LLM生成详细总结
    // 包含主要观点和细节
    return '''
这是内容的详细总结：

1. 主要观点一
   - 细节说明

2. 主要观点二
   - 细节说明

3. 主要观点三
   - 细节说明
''';
  }

  /// 生成要点提炼
  Future<List<String>> generateKeyPoints(String content) async {
    // TODO: 使用LLM提取要点
    return [
      '要点1：关键信息',
      '要点2：关键信息',
      '要点3：关键信息',
    ];
  }

  /// 生成思维导图
  Future<String> generateMindMap(String content) async {
    // TODO: 使用LLM生成思维导图结构
    return '''
# 中心主题

## 分支1
- 子节点1
- 子节点2

## 分支2
- 子节点1
- 子节点2
''';
  }
}

/// URL内容模型基类
class URLContent {
  final String url;
  final Platform platform;
  final String title;
  final String content;
  final String? author;
  final DateTime? publishTime;
  final Map<String, dynamic>? extra;

  URLContent({
    required this.url,
    required this.platform,
    required this.title,
    required this.content,
    this.author,
    this.publishTime,
    this.extra,
  });

  /// 获取平台显示名称
  String get platformName {
    switch (platform) {
      case Platform.douyin:
        return '抖音';
      case Platform.xiaohongshu:
        return '小红书';
      case Platform.bilibili:
        return 'Bilibili';
      case Platform.zhihu:
        return '知乎';
      case Platform.weibo:
        return '微博';
      case Platform.generic:
        return '网页';
    }
  }
}

/// 抖音内容
class DouyinContent extends URLContent {
  final String videoId;
  final int likeCount;
  final int commentCount;

  DouyinContent({
    required super.url,
    required super.platform,
    required super.title,
    required super.content,
    super.author,
    super.publishTime,
    super.extra,
    required this.videoId,
    required this.likeCount,
    required this.commentCount,
  });
}

/// 小红书内容
class XiaohongshuContent extends URLContent {
  final String noteId;
  final List<String> images;
  final List<String> tags;

  XiaohongshuContent({
    required super.url,
    required super.platform,
    required super.title,
    required super.content,
    super.author,
    super.publishTime,
    super.extra,
    required this.noteId,
    required this.images,
    required this.tags,
  });
}

/// B站内容
class BilibiliContent extends URLContent {
  final String videoId;
  final String? category;
  final String? subtitleText;

  BilibiliContent({
    required super.url,
    required super.platform,
    required super.title,
    required super.content,
    super.author,
    super.publishTime,
    super.extra,
    required this.videoId,
    this.category,
    this.subtitleText,
  });
}

/// 知乎内容
class ZhihuContent extends URLContent {
  final String contentType; // 'article', 'answer'
  final int voteupCount;

  ZhihuContent({
    required super.url,
    required super.platform,
    required super.title,
    required super.content,
    super.author,
    super.publishTime,
    super.extra,
    required this.contentType,
    required this.voteupCount,
  });
}

/// 平台枚举
enum Platform {
  douyin,
  xiaohongshu,
  bilibili,
  zhihu,
  weibo,
  generic,
}

/// URL解析异常
class URLParseException implements Exception {
  final String message;

  URLParseException(this.message);

  @override
  String toString() => 'URLParseException: $message';
}
