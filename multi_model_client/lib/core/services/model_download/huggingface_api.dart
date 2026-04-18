import 'package:dio/dio.dart';
import '../model_download_manager.dart';
import '../network_utils.dart';
import 'modelscope_api.dart' show ModelFile;

/// HuggingFace API客户端（改进版）
class HuggingFaceApi {
  final Dio _dio;
  final String baseUrl = 'https://huggingface.co/api';

  // 备用镜像站点
  static const List<String> _mirrorUrls = [
    'https://hf-mirror.com/api',  // 中国镜像
    'https://huggingface.co/api',  // 官方站点
  ];

  int _currentMirrorIndex = 0;

  HuggingFaceApi(this._dio);

  /// 切换到下一个镜像
  void _switchToNextMirror() {
    _currentMirrorIndex = (_currentMirrorIndex + 1) % _mirrorUrls.length;
  }

  /// 获取当前基础URL
  String get currentBaseUrl => _mirrorUrls[_currentMirrorIndex];

  /// 搜索模型
  Future<List<ModelInfo>> searchModels({
    required String query,
    int limit = 20,
    String? filter,
    String? author,
  }) async {
    Exception? lastError;

    // 尝试所有镜像
    for (var i = 0; i < _mirrorUrls.length; i++) {
      try {
        final url = '${_mirrorUrls[_currentMirrorIndex]}/models';

        final response = await _dio.get(
          url,
          queryParameters: {
            'search': query,
            'limit': limit,
            if (filter != null) 'filter': filter,
            if (author != null) 'author': author,
          },
        );

        final models = response.data as List<dynamic>;
        return models
            .map((m) => ModelInfo.fromHuggingFace(m as Map<String, dynamic>))
            .toList();
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());

        // 如果是网络错误，切换到下一个镜像
        if (e is DioException &&
            (e.type == DioExceptionType.connectionError ||
             e.type == DioExceptionType.connectionTimeout)) {
          _switchToNextMirror();
          continue;
        }

        // 其他错误直接抛出
        rethrow;
      }
    }

    // 所有镜像都失败了
    throw lastError ?? Exception('所有镜像站点都无法访问');
  }

  /// 获取模型详情
  Future<ModelInfo?> getModel(String modelId) async {
    for (var i = 0; i < _mirrorUrls.length; i++) {
      try {
        final url = '${_mirrorUrls[_currentMirrorIndex]}/models/$modelId';
        final response = await _dio.get(url);
        return ModelInfo.fromHuggingFace(response.data as Map<String, dynamic>);
      } catch (e) {
        if (e is DioException &&
            (e.type == DioExceptionType.connectionError ||
             e.type == DioExceptionType.connectionTimeout)) {
          _switchToNextMirror();
          continue;
        }

        // 404错误直接返回null
        if (e is DioException && e.response?.statusCode == 404) {
          return null;
        }

        rethrow;
      }
    }

    return null;
  }

  /// 获取模型文件列表
  Future<List<ModelFile>> getModelFiles(String modelId, {String revision = 'main'}) async {
    for (var i = 0; i < _mirrorUrls.length; i++) {
      try {
        final url = '${_mirrorUrls[_currentMirrorIndex]}/models/$modelId/tree/$revision';
        final response = await _dio.get(url);

        final files = response.data as List<dynamic>;
        return files
            .map((f) => ModelFile.fromJson(f as Map<String, dynamic>, ModelSource.huggingFace))
            .toList();
      } catch (e) {
        if (e is DioException &&
            (e.type == DioExceptionType.connectionError ||
             e.type == DioExceptionType.connectionTimeout)) {
          _switchToNextMirror();
          continue;
        }

        return [];
      }
    }

    return [];
  }

  /// 获取下载链接
  String getDownloadUrl(String modelId, String filePath, {String revision = 'main'}) {
    // 使用镜像站点的下载链接
    final mirrorBase = _currentMirrorIndex == 0
        ? 'https://hf-mirror.com'
        : 'https://huggingface.co';
    return '$mirrorBase/$modelId/resolve/$revision/$filePath';
  }

  /// 获取模型README
  Future<String?> getModelReadme(String modelId, {String revision = 'main'}) async {
    for (var i = 0; i < _mirrorUrls.length; i++) {
      try {
        final mirrorBase = _currentMirrorIndex == 0
            ? 'https://hf-mirror.com'
            : 'https://huggingface.co';
        final url = '$mirrorBase/$modelId/raw/$revision/README.md';
        final response = await _dio.get(url);
        return response.data as String;
      } catch (e) {
        if (e is DioException &&
            (e.type == DioExceptionType.connectionError ||
             e.type == DioExceptionType.connectionTimeout)) {
          _switchToNextMirror();
          continue;
        }

        return null;
      }
    }

    return null;
  }

  /// 获取模型配置信息
  Future<Map<String, dynamic>?> getModelConfig(String modelId, {String revision = 'main'}) async {
    try {
      final url = getDownloadUrl(modelId, 'config.json', revision: revision);
      final response = await _dio.get(url);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 获取模型词表
  Future<Map<String, dynamic>?> getModelTokenizer(String modelId, {String revision = 'main'}) async {
    try {
      final url = getDownloadUrl(modelId, 'tokenizer.json', revision: revision);
      final response = await _dio.get(url);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
