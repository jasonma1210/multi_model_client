/// GitHub 插件仓库服务
/// 
/// 从 GitHub 搜索和获取 LLM Studio 插件
/// 支持：
/// - 搜索插件仓库
/// - 获取插件清单（plugin.json）
/// - 获取插件版本信息
/// - 下载插件包
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/plugin_manifest.dart';

/// GitHub 插件仓库配置
class GitHubPluginConfig {
  /// GitHub API 基础地址
  static const String apiBase = 'https://api.github.com';
  
  /// LLM Studio 官方插件库组织名
  static const String officialOrg = 'llm-studio-plugins';
  
  /// 插件清单文件名
  static const String manifestFile = 'plugin.json';
  
  /// 插件包文件名
  static const String packageFile = 'plugin.zip';
  
  /// 搜索主题标签
  static const String searchTopic = 'llm-studio-plugin';
}

/// GitHub 仓库信息
class GitHubRepository {
  final String name;
  final String fullName;
  final String description;
  final String? homepage;
  final String defaultBranch;
  final int stars;
  final int forks;
  final DateTime? updatedAt;
  final List<String> topics;
  final String? ownerAvatarUrl;
  
  const GitHubRepository({
    required this.name,
    required this.fullName,
    required this.description,
    this.homepage,
    required this.defaultBranch,
    this.stars = 0,
    this.forks = 0,
    this.updatedAt,
    this.topics = const [],
    this.ownerAvatarUrl,
  });
  
  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      homepage: json['homepage'] as String?,
      defaultBranch: json['default_branch'] as String? ?? 'main',
      stars: json['stargazers_count'] as int? ?? 0,
      forks: json['forks_count'] as int? ?? 0,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      ownerAvatarUrl: json['owner']?['avatar_url'] as String?,
    );
  }
  
  /// 获取仓库 URL
  String get url => 'https://github.com/$fullName';
  
  /// 获取原始内容 URL
  String getRawUrl(String path) {
    return 'https://raw.githubusercontent.com/$fullName/$defaultBranch/$path';
  }
}

/// 插件搜索结果
class PluginSearchResult {
  final List<PluginManifest> plugins;
  final int totalCount;
  final bool hasMore;
  final String? nextPageToken;
  
  const PluginSearchResult({
    required this.plugins,
    required this.totalCount,
    this.hasMore = false,
    this.nextPageToken,
  });
}

/// GitHub 插件仓库服务
class GitHubPluginRegistry {
  final http.Client _httpClient;
  final String? _accessToken;
  
  GitHubPluginRegistry({
    http.Client? httpClient,
    String? accessToken,
  }) : _httpClient = httpClient ?? http.Client(),
       _accessToken = accessToken;
  
  /// 搜索插件
  Future<PluginSearchResult> searchPlugins({
    String? query,
    String? category,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // 构建搜索查询
      final searchQuery = StringBuffer();
      searchQuery.write('topic:${GitHubPluginConfig.searchTopic}');
      if (query != null && query.isNotEmpty) {
        searchQuery.write(' $query');
      }
      if (category != null && category.isNotEmpty) {
        searchQuery.write(' $category');
      }
      
      final url = Uri.parse(
        '${GitHubPluginConfig.apiBase}/search/repositories'
        '?q=${Uri.encodeComponent(searchQuery.toString())}'
        '&sort=stars&order=desc'
        '&page=$page&per_page=$perPage',
      );
      
      final response = await _makeRequest(url);
      
      if (response.statusCode != 200) {
        throw PluginRegistryException('搜索失败: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      final totalCount = data['total_count'] as int? ?? 0;
      
      // 获取每个仓库的插件清单
      final plugins = <PluginManifest>[];
      for (final item in items) {
        final repo = GitHubRepository.fromJson(item as Map<String, dynamic>);
        try {
          final manifest = await _fetchManifest(repo);
          if (manifest != null) {
            plugins.add(manifest);
          }
        } catch (e) {
          debugPrint('[GitHubPluginRegistry] 获取清单失败 ${repo.fullName}: $e');
        }
      }
      
      return PluginSearchResult(
        plugins: plugins,
        totalCount: totalCount,
        hasMore: plugins.length < totalCount,
        nextPageToken: (page * perPage < totalCount) ? (page + 1).toString() : null,
      );
    } catch (e) {
      if (e is PluginRegistryException) rethrow;
      throw PluginRegistryException('搜索插件失败: $e');
    }
  }
  
  /// 获取官方推荐插件
  Future<List<PluginManifest>> getFeaturedPlugins() async {
    try {
      final url = Uri.parse(
        '${GitHubPluginConfig.apiBase}/orgs/${GitHubPluginConfig.officialOrg}/repos'
        '?sort=stars&order=desc&per_page=10',
      );
      
      final response = await _makeRequest(url);
      
      if (response.statusCode != 200) {
        throw PluginRegistryException('获取推荐插件失败: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body) as List<dynamic>;
      final plugins = <PluginManifest>[];
      
      for (final item in data) {
        final repo = GitHubRepository.fromJson(item as Map<String, dynamic>);
        try {
          final manifest = await _fetchManifest(repo);
          if (manifest != null) {
            plugins.add(manifest);
          }
        } catch (e) {
          debugPrint('[GitHubPluginRegistry] 获取清单失败 ${repo.fullName}: $e');
        }
      }
      
      return plugins;
    } catch (e) {
      if (e is PluginRegistryException) rethrow;
      throw PluginRegistryException('获取推荐插件失败: $e');
    }
  }
  
  /// 获取指定插件的清单
  Future<PluginManifest?> getPlugin(String repoFullName) async {
    try {
      final repoUrl = Uri.parse('${GitHubPluginConfig.apiBase}/repos/$repoFullName');
      final repoResponse = await _makeRequest(repoUrl);
      
      if (repoResponse.statusCode != 200) {
        throw PluginRegistryException('获取仓库信息失败: ${repoResponse.statusCode}');
      }
      
      final repo = GitHubRepository.fromJson(
        jsonDecode(repoResponse.body) as Map<String, dynamic>,
      );
      
      return await _fetchManifest(repo);
    } catch (e) {
      if (e is PluginRegistryException) rethrow;
      throw PluginRegistryException('获取插件失败: $e');
    }
  }
  
  /// 获取插件版本列表
  Future<List<PluginVersion>> getPluginVersions(String repoFullName) async {
    try {
      final url = Uri.parse(
        '${GitHubPluginConfig.apiBase}/repos/$repoFullName/releases',
      );
      
      final response = await _makeRequest(url);
      
      if (response.statusCode != 200) {
        throw PluginRegistryException('获取版本列表失败: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => PluginVersion.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is PluginRegistryException) rethrow;
      throw PluginRegistryException('获取版本列表失败: $e');
    }
  }
  
  /// 获取插件下载 URL
  Future<String> getPluginDownloadUrl(String repoFullName, {String? version}) async {
    if (version != null) {
      return 'https://github.com/$repoFullName/archive/refs/tags/v$version.zip';
    }
    return 'https://github.com/$repoFullName/archive/refs/heads/main.zip';
  }
  
  /// 从仓库获取插件清单
  Future<PluginManifest?> _fetchManifest(GitHubRepository repo) async {
    try {
      final manifestUrl = repo.getRawUrl(GitHubPluginConfig.manifestFile);
      final response = await _httpClient.get(
        Uri.parse(manifestUrl),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        return null;
      }
      
      final manifest = PluginManifest.fromJsonString(response.body);
      
      // 补充仓库信息
      return manifest.copyWith(
        repository: repo.url,
      );
    } catch (e) {
      debugPrint('[GitHubPluginRegistry] 解析清单失败: $e');
      return null;
    }
  }
  
  /// 发送 HTTP 请求
  Future<http.Response> _makeRequest(Uri url) async {
    return await _httpClient.get(
      url,
      headers: _getHeaders(),
    ).timeout(const Duration(seconds: 15));
  }
  
  /// 获取请求头
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'LLM-Studio/1.0',
    };
    
    final token = _accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}

/// 插件版本信息
class PluginVersion {
  final String tagName;
  final String name;
  final String? body;
  final DateTime? publishedAt;
  final String downloadUrl;
  final bool isPrerelease;
  
  const PluginVersion({
    required this.tagName,
    required this.name,
    this.body,
    this.publishedAt,
    required this.downloadUrl,
    this.isPrerelease = false,
  });
  
  factory PluginVersion.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as List<dynamic>? ?? [];
    String? downloadUrl;
    
    for (final asset in assets) {
      final assetMap = asset as Map<String, dynamic>;
      final assetName = assetMap['name'] as String? ?? '';
      if (assetName.contains('plugin') && assetName.endsWith('.zip')) {
        downloadUrl = assetMap['browser_download_url'] as String?;
        break;
      }
    }
    
    return PluginVersion(
      tagName: json['tag_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      body: json['body'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      downloadUrl: downloadUrl ?? '',
      isPrerelease: json['prerelease'] as bool? ?? false,
    );
  }
  
  /// 获取版本号（去掉 v 前缀）
  String get version {
    if (tagName.startsWith('v')) {
      return tagName.substring(1);
    }
    return tagName;
  }
}

/// 插件仓库异常
class PluginRegistryException implements Exception {
  final String message;
  
  const PluginRegistryException(this.message);
  
  @override
  String toString() => 'PluginRegistryException: $message';
}