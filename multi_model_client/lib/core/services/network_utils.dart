import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络配置
class NetworkConfig {
  /// 代理设置
  static String? proxyUrl;

  /// 超时配置
  static const int connectTimeout = 15000; // 15秒
  static const int receiveTimeout = 30000; // 30秒
  static const int sendTimeout = 30000;    // 30秒

  /// 重试配置
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1秒

  /// User Agent
  static const String userAgent = 'MultiModelClient/1.0.0';
}

/// 网络工具类
class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();

  /// 检查网络连接
  static Future<bool> hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      // 如果无法检查连接状态，假设有网络
      return true;
    }
  }

  /// 创建配置好的Dio实例
  static Dio createDio({
    String? baseUrl,
    Map<String, dynamic>? headers,
    bool enableProxy = false,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: Duration(milliseconds: NetworkConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: NetworkConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: NetworkConfig.sendTimeout),
      headers: {
        'User-Agent': NetworkConfig.userAgent,
        ...?headers,
      },
    ));

    // 配置代理
    if (enableProxy && NetworkConfig.proxyUrl != null) {
      // 注意：Dio的代理配置需要通过系统代理或自定义HttpClientAdapter
      // 这里只是示例，实际配置可能需要使用其他包
    }

    // 添加拦截器
    dio.interceptors.addAll([
      // 日志拦截器
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
      ),

      // 重试拦截器
      RetryInterceptor(
        dio: dio,
        retries: NetworkConfig.maxRetries,
        retryDelays: List.generate(
          NetworkConfig.maxRetries,
          (i) => Duration(milliseconds: NetworkConfig.retryDelay * (i + 1)),
        ),
      ),
    ]);

    return dio;
  }

  /// 处理网络错误
  static String handleNetworkError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络设置';
        case DioExceptionType.sendTimeout:
          return '发送超时，请重试';
        case DioExceptionType.receiveTimeout:
          return '接收超时，请重试';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            return '访问被拒绝，请检查认证信息';
          } else if (statusCode == 404) {
            return '请求的资源不存在';
          } else if (statusCode == 429) {
            return '请求过于频繁，请稍后再试';
          } else if (statusCode != null && statusCode >= 500) {
            return '服务器错误 ($statusCode)，请稍后再试';
          }
          return '请求失败 ($statusCode)';
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.connectionError:
          if (error.message?.contains('Operation not permitted') ?? false) {
            return '网络访问被系统阻止，请检查应用权限设置';
          } else if (error.message?.contains('Connection refused') ?? false) {
            return '无法连接到服务器';
          } else if (error.message?.contains('Connection failed') ?? false) {
            return '连接失败，请检查网络设置或尝试使用代理';
          }
          return '网络连接错误，请检查网络设置';
        case DioExceptionType.unknown:
          if (error.error?.toString().contains('SocketException') ?? false) {
            return '网络连接异常，请检查网络设置或防火墙配置';
          }
          return '未知错误: ${error.message}';
        default:
          return '请求失败: ${error.message}';
      }
    }

    return '发生错误: $error';
  }

  /// 判断是否需要代理
  static bool needsProxy(String url) {
    // 判断是否是需要代理才能访问的网站
    final needsProxyDomains = [
      'huggingface.co',
      'github.com',
      'raw.githubusercontent.com',
    ];

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    return needsProxyDomains.any((domain) => uri.host.contains(domain));
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    List<Duration>? retryDelays,
  }) : retryDelays = retryDelays ??
           List.generate(retries, (i) => Duration(seconds: i + 1));

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 只重试特定的错误类型
    if (_shouldRetry(err) && err.requestOptions.extra['_retryCount'] == null) {
      final retryCount = 0;

      for (var i = retryCount; i < retries; i++) {
        try {
          // 等待一段时间再重试
          await Future.delayed(retryDelays[i]);

          // 标记重试次数
          err.requestOptions.extra['_retryCount'] = i + 1;

          // 重新发送请求
          final response = await dio.fetch(err.requestOptions);

          // 成功则返回响应
          return handler.resolve(response);
        } catch (e) {
          // 继续下一次重试
          if (i == retries - 1) {
            // 最后一次重试也失败了，返回错误
            return handler.next(err);
          }
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // 连接超时、发送超时、接收超时、连接错误时重试
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.type == DioExceptionType.badResponse &&
            err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
