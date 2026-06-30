// v0.43.0 实现 A2A Agent 面板 UI
//
// 用途：在 ChatPage 工具栏/工具菜单中展示可用的 A2A Agent 列表
// 用户可选择某个 Agent 来接管当前会话
// 特性：自动刷新 AgentCard 显示技能数量

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/protocols/a2a/a2a_client.dart';
import '../providers/a2a_providers.dart';

/// A2A Agent 选择面板
class A2AAgentPanel extends ConsumerStatefulWidget {
  /// 当前选中的 Agent（高亮显示）
  final String? selectedAgent;

  /// 选中 Agent 时的回调
  final ValueChanged<String?>? onAgentSelected;

  const A2AAgentPanel({
    super.key,
    this.selectedAgent,
    this.onAgentSelected,
  });

  @override
  ConsumerState<A2AAgentPanel> createState() => _A2AAgentPanelState();
}

class _A2AAgentPanelState extends ConsumerState<A2AAgentPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(a2aAgentsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agents = ref.watch(a2aAgentsProvider);
    final settings = ref.watch(a2aSettingsProvider);
    final selected = ref.watch(selectedA2AAgentProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(Icons.psychology_outlined, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'A2A 远程 Agent',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                tooltip: '刷新',
                icon: agents.loading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                onPressed: agents.loading
                    ? null
                    : () => ref.read(a2aAgentsProvider.notifier).refresh(),
              ),
            ],
          ),
        ),

        // 错误提示
        if (agents.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              '⚠️ ${agents.error}',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),

        // Agent 列表
        if (agents.agents.isEmpty && !agents.loading)
          _buildEmpty(theme, settings.servers.length)
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: agents.agents.length,
              itemBuilder: (context, index) {
                final card = agents.agents[index];
                final isSelected = (widget.selectedAgent ?? selected) == card.name;
                return _AgentTile(
                  card: card,
                  isSelected: isSelected,
                  onTap: () {
                    final newValue = isSelected ? null : card.name;
                    ref.read(selectedA2AAgentProvider.notifier).select(newValue);
                    widget.onAgentSelected?.call(newValue);
                  },
                );
              },
            ),
          ),

        // 底部：添加服务器
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
          title: const Text('添加 A2A 服务器'),
          subtitle: Text('${settings.servers.length} 个已配置', style: const TextStyle(fontSize: 12)),
          onTap: () => _showAddServerDialog(context),
        ),
      ],
    );
  }

  Widget _buildEmpty(ThemeData theme, int serverCount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.psychology_alt_outlined,
              size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            serverCount == 0
                ? '暂未配置 A2A 服务器'
                : '正在连接 $serverCount 个 A2A 服务器...',
            style: TextStyle(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          if (serverCount == 0) ...[
            const SizedBox(height: 12),
            Text(
              'A2A 让 MJ Nexus 调用远程 Agent 完成任务',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showAddServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _AddA2AServerDialog(),
    );
  }
}

class _AgentTile extends StatelessWidget {
  final dynamic card; // AgentCard
  final bool isSelected;
  final VoidCallback onTap;

  const _AgentTile({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 0,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.secondaryContainer,
          child: Text(
            card.name.toString().substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          card.name.toString(),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.description != null)
              Text(
                card.description.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.bolt, size: 12, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  '${(card.skills as List).length} 个技能',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                ),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}

/// 添加 A2A 服务器对话框
class _AddA2AServerDialog extends ConsumerStatefulWidget {
  const _AddA2AServerDialog();

  @override
  ConsumerState<_AddA2AServerDialog> createState() => _AddA2AServerDialogState();
}

class _AddA2AServerDialogState extends ConsumerState<_AddA2AServerDialog> {
  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  bool _testing = false;
  String? _testResult;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      setState(() => _testResult = '❌ 请填写 URL');
      return;
    }
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      // 临时创建客户端测试
      // ignore: use_build_context_synchronously
      final client = A2AClientProxy(url: url, apiKey: _keyCtrl.text.trim().isEmpty ? null : _keyCtrl.text.trim());
      final card = await client.getAgentCard();
      setState(() => _testResult = '✅ 连接成功：${card.name} (${card.skills.length} skills)');
    } catch (e) {
      setState(() => _testResult = '❌ 连接失败：$e');
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    if (name.isEmpty || url.isEmpty) {
      setState(() => _testResult = '❌ 名称和 URL 必填');
      return;
    }
    final apiKey = _keyCtrl.text.trim().isEmpty ? null : _keyCtrl.text.trim();
    await ref.read(a2aSettingsProvider.notifier).addFromUrl(name, url, apiKey: apiKey);
    await ref.read(a2aAgentsProvider.notifier).refresh();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加 A2A 服务器'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例如：深度研究 Agent',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'A2A Endpoint',
                hintText: 'https://agent.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key (可选)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_testResult!, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _testing ? null : _testConnection,
          child: _testing
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('测试连接'),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}

/// A2A 客户端代理（仅用于测试连接）
class A2AClientProxy {
  final String url;
  final String? apiKey;
  A2AClientProxy({required this.url, this.apiKey});

  Future<dynamic> getAgentCard() async {
    final client = A2AClient(agentUrl: url, apiKey: apiKey);
    return client.getAgentCard();
  }
}
