/// 代理状态页面 - 显示本地代理服务状态和请求日志
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_proxy_service.dart';

class ProxyStatusPage extends ConsumerStatefulWidget {
  const ProxyStatusPage({super.key});

  @override
  ConsumerState<ProxyStatusPage> createState() => _ProxyStatusPageState();
}

class _ProxyStatusPageState extends ConsumerState<ProxyStatusPage> {
  @override
  void initState() {
    super.initState();
    // 监听状态变化
    localProxyService.statusStream.listen((_) {
      if (mounted) setState(() {});
    });
    localProxyService.logStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = localProxyService.status;
    final proxyUrl = localProxyService.proxyUrl;
    final logs = localProxyService.requestLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('代理服务状态'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 状态卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('代理地址', proxyUrl ?? '未启动'),
                  _buildInfoRow('目标地址', 'api.xiaomimimo.com/v1'),
                  _buildInfoRow('请求数', '${logs.length}'),
                  if (logs.isNotEmpty) ...[
                    _buildInfoRow(
                      '成功率',
                      '${_calculateSuccessRate(logs)}%',
                    ),
                    _buildInfoRow(
                      '平均耗时',
                      '${_calculateAvgDuration(logs)}ms',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: status == ProxyServiceStatus.running
                      ? null
                      : () async {
                          await localProxyService.start();
                          setState(() {});
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('启动'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: status != ProxyServiceStatus.running
                      ? null
                      : () async {
                          await localProxyService.stop();
                          setState(() {});
                        },
                  icon: const Icon(Icons.stop),
                  label: const Text('停止'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 请求日志
          Text(
            '请求日志',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (logs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    '暂无请求日志',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ...logs.reversed.take(20).map((log) => _buildLogCard(log)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLogCard(ProxyRequestLog log) {
    final isError = log.errorMessage != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isError ? Colors.red.shade50 : null,
      child: ListTile(
        leading: Icon(
          isError ? Icons.error : Icons.check_circle,
          color: isError ? Colors.red : Colors.green,
          size: 20,
        ),
        title: Text(
          '${log.method} ${log.path}',
          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
        ),
        subtitle: Text(
          isError
              ? log.errorMessage!
              : '${log.statusCode} • ${log.duration.inMilliseconds}ms',
          style: TextStyle(
            fontSize: 12,
            color: isError ? Colors.red : Colors.grey,
          ),
        ),
        trailing: Text(
          '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ),
    );
  }

  IconData _getStatusIcon(ProxyServiceStatus status) {
    return switch (status) {
      ProxyServiceStatus.stopped => Icons.stop_circle,
      ProxyServiceStatus.starting => Icons.sync,
      ProxyServiceStatus.running => Icons.check_circle,
      ProxyServiceStatus.error => Icons.error,
    };
  }

  Color _getStatusColor(ProxyServiceStatus status) {
    return switch (status) {
      ProxyServiceStatus.stopped => Colors.grey,
      ProxyServiceStatus.starting => Colors.orange,
      ProxyServiceStatus.running => Colors.green,
      ProxyServiceStatus.error => Colors.red,
    };
  }

  String _getStatusText(ProxyServiceStatus status) {
    return switch (status) {
      ProxyServiceStatus.stopped => '已停止',
      ProxyServiceStatus.starting => '启动中...',
      ProxyServiceStatus.running => '运行中',
      ProxyServiceStatus.error => '错误',
    };
  }

  int _calculateSuccessRate(List<ProxyRequestLog> logs) {
    if (logs.isEmpty) return 0;
    final successCount = logs.where((l) => l.statusCode == 200).length;
    return (successCount * 100 ~/ logs.length);
  }

  int _calculateAvgDuration(List<ProxyRequestLog> logs) {
    if (logs.isEmpty) return 0;
    final total = logs.fold<int>(
      0,
      (sum, l) => sum + l.duration.inMilliseconds,
    );
    return total ~/ logs.length;
  }
}
