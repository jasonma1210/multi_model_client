import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/network_utils.dart';

/// 网络诊断工具
class NetworkDiagnostics {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  /// 诊断结果
  static Future<DiagnosticResult> runDiagnostics() async {
    final result = DiagnosticResult();

    // 1. 检查本地网络连接
    result.hasLocalConnection = await NetworkUtils.hasConnection();

    // 2. 测试 ModelScope 连接
    result.modelScopeStatus = await _testConnection(
      'https://modelscope.cn/api/v1/models',
      'ModelScope (国内)',
    );

    // 3. 测试 HuggingFace 连接
    result.huggingFaceStatus = await _testConnection(
      'https://huggingface.co/api/models',
      'HuggingFace (官方)',
    );

    // 4. 测试 HuggingFace 镜像连接
    result.huggingFaceMirrorStatus = await _testConnection(
      'https://hf-mirror.com/api/models',
      'HuggingFace Mirror (国内镜像)',
    );

    // 5. 生成建议
    result.recommendations = _generateRecommendations(result);

    return result;
  }

  static Future<ConnectionStatus> _testConnection(
    String url,
    String name,
  ) async {
    try {
      final response = await _dio.get(url, queryParameters: {'limit': 1});

      return ConnectionStatus(
        name: name,
        url: url,
        isAccessible: true,
        responseTime: response.headers['x-response-time']?.first,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ConnectionStatus(
        name: name,
        url: url,
        isAccessible: false,
        errorMessage: NetworkUtils.handleNetworkError(e),
        errorType: e.type.toString(),
      );
    } catch (e) {
      return ConnectionStatus(
        name: name,
        url: url,
        isAccessible: false,
        errorMessage: e.toString(),
      );
    }
  }

  static List<String> _generateRecommendations(DiagnosticResult result) {
    final recommendations = <String>[];

    if (!result.hasLocalConnection) {
      recommendations.add('❌ 本地网络未连接，请检查网络设置');
      return recommendations;
    }

    recommendations.add('✅ 本地网络已连接');

    if (result.modelScopeStatus?.isAccessible ?? false) {
      recommendations.add('✅ ModelScope 可访问 - 推荐使用');
    } else {
      recommendations.add('❌ ModelScope 无法访问');
    }

    if (result.huggingFaceMirrorStatus?.isAccessible ?? false) {
      recommendations.add('✅ HuggingFace 镜像可访问 - 推荐使用');
    } else {
      recommendations.add('❌ HuggingFace 镜像无法访问');
    }

    if (result.huggingFaceStatus?.isAccessible ?? false) {
      recommendations.add('✅ HuggingFace 官方可访问');
    } else {
      recommendations.add('⚠️ HuggingFace 官方无法访问（可能需要代理）');
    }

    // 具体建议
    if (result.modelScopeStatus?.isAccessible ?? false) {
      recommendations.add('\n💡 建议：使用 ModelScope 作为主要模型源');
    } else if (result.huggingFaceMirrorStatus?.isAccessible ?? false) {
      recommendations.add('\n💡 建议：使用 HuggingFace 镜像作为主要模型源');
    } else {
      recommendations.add('\n💡 建议：');
      recommendations.add('1. 检查防火墙设置');
      recommendations.add('2. 尝试使用 VPN 或代理');
      recommendations.add('3. 检查系统网络权限设置');
      recommendations.add('4. macOS用户：确保应用有网络访问权限');
    }

    return recommendations;
  }
}

/// 连接状态
class ConnectionStatus {
  final String name;
  final String url;
  final bool isAccessible;
  final String? responseTime;
  final int? statusCode;
  final String? errorMessage;
  final String? errorType;

  ConnectionStatus({
    required this.name,
    required this.url,
    required this.isAccessible,
    this.responseTime,
    this.statusCode,
    this.errorMessage,
    this.errorType,
  });
}

/// 诊断结果
class DiagnosticResult {
  bool hasLocalConnection = false;
  ConnectionStatus? modelScopeStatus;
  ConnectionStatus? huggingFaceStatus;
  ConnectionStatus? huggingFaceMirrorStatus;
  List<String> recommendations = [];
}

/// 网络诊断页面
class NetworkDiagnosticsPage extends StatefulWidget {
  const NetworkDiagnosticsPage({super.key});

  @override
  State<NetworkDiagnosticsPage> createState() => _NetworkDiagnosticsPageState();
}

class _NetworkDiagnosticsPageState extends State<NetworkDiagnosticsPage> {
  DiagnosticResult? _result;
  bool _isRunning = false;

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _result = null;
    });

    try {
      final result = await NetworkDiagnostics.runDiagnostics();
      setState(() {
        _result = result;
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('网络诊断'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isRunning ? null : _runDiagnostics,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 运行按钮
              if (_result == null && !_isRunning)
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.network_check,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '点击下方按钮开始网络诊断',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _runDiagnostics,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('开始诊断'),
                      ),
                    ],
                  ),
                ),

              // 加载中
              if (_isRunning)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在诊断网络连接...'),
                    ],
                  ),
                ),

              // 诊断结果
              if (_result != null && !_isRunning) ...[
                _buildSectionTitle('本地网络'),
                _buildStatusCard(
                  _result!.hasLocalConnection ? '已连接' : '未连接',
                  _result!.hasLocalConnection,
                ),

                const SizedBox(height: 16),

                _buildSectionTitle('模型源连接状态'),
                if (_result!.modelScopeStatus != null)
                  _buildConnectionCard(_result!.modelScopeStatus!),
                const SizedBox(height: 8),
                if (_result!.huggingFaceMirrorStatus != null)
                  _buildConnectionCard(_result!.huggingFaceMirrorStatus!),
                const SizedBox(height: 8),
                if (_result!.huggingFaceStatus != null)
                  _buildConnectionCard(_result!.huggingFaceStatus!),

                const SizedBox(height: 16),

                _buildSectionTitle('诊断建议'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _result!.recommendations
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(r),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusCard(String status, bool isSuccess) {
    return Card(
      child: ListTile(
        leading: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
        ),
        title: Text(status),
      ),
    );
  }

  Widget _buildConnectionCard(ConnectionStatus status) {
    return Card(
      child: ListTile(
        leading: Icon(
          status.isAccessible ? Icons.check_circle : Icons.error,
          color: status.isAccessible ? Colors.green : Colors.red,
        ),
        title: Text(status.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status.isAccessible
                  ? '可访问 ${status.responseTime != null ? "(${status.responseTime})" : ""}'
                  : '无法访问',
            ),
            if (status.errorMessage != null)
              Text(
                status.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            Text(
              status.url,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: status.errorMessage != null,
      ),
    );
  }
}
