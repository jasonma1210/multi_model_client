/// Jina Reader 服务 - LLM Studio 网页解析模块
/// 
/// 功能：
/// - 网页内容解析
/// - URL 内容提取
/// - Markdown 格式转换
/// - 多平台内容支持
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:dio/dio.dart';

/// Jina AI Reader API 服务
/// 用于解析任意 URL 的网页内容
/// API 文档: https://jina.ai/reader
class JinaReaderService {
  final Dio _dio;
  static const String _baseUrl = 'https://r.jina.ai';

  JinaReaderService({Dio? dio}) : _dio = dio ?? Dio();

  /// 解析 URL 内容
  /// [url] - 要解析的网页 URL
  /// [returnMarkdown] - 是否返回 Markdown 格式（默认 true）
  Future<JinaReaderResponse> readURL(String url, {bool returnMarkdown = true}) async {
    try {
      final encodedUrl = Uri.encodeComponent(url);
      final endpoint = returnMarkdown ? '/markdown' : '/text';
      final response = await _dio.get(
        '$_baseUrl$endpoint/$encodedUrl',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return JinaReaderResponse(
          success: true,
          content: data['content'] as String? ?? '',
          title: data['title'] as String?,
          url: data['url'] as String?,
          finalUrl: data['final_url'] as String?,
          description: data['description'] as String?,
          image: data['image'] as String?,
        );
      } else {
        return JinaReaderResponse(
          success: false,
          content: '',
          error: 'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      return JinaReaderResponse(
        success: false,
        content: '',
        error: _handleDioError(e),
      );
    } catch (e) {
      return JinaReaderResponse(
        success: false,
        content: '',
        error: '未知错误: $e',
      );
    }
  }

  /// 解析 URL 并返回纯文本
  Future<String> readText(String url) async {
    final result = await readURL(url, returnMarkdown: false);
    return result.success ? result.content : '';
  }

  /// 解析 URL 并返回 Markdown
  Future<String> readMarkdown(String url) async {
    final result = await readURL(url, returnMarkdown: true);
    return result.success ? result.content : '';
  }

  /// 处理 Dio 错误
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络';
      case DioExceptionType.sendTimeout:
        return '发送请求超时';
      case DioExceptionType.receiveTimeout:
        return '接收响应超时';
      case DioExceptionType.badResponse:
        return '服务器响应错误: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败';
      default:
        return '网络错误: ${e.message}';
    }
  }
}

/// Jina Reader API 响应
class JinaReaderResponse {
  final bool success;
  final String content;
  final String? title;
  final String? url;
  final String? finalUrl;
  final String? description;
  final String? image;
  final String? error;

  JinaReaderResponse({
    required this.success,
    required this.content,
    this.title,
    this.url,
    this.finalUrl,
    this.description,
    this.image,
    this.error,
  });
}