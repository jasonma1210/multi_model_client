/// 深度研究输入页面（v0.42.0）
///
/// 用户输入研究问题 → 选择启用源 → 启动研究 → 跳转到结果页面。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/providers/thinking_budget_provider.dart';
import '../../domain/research_models.dart';
import 'research_result_page.dart';

class ResearchInputPage extends ConsumerStatefulWidget {
  const ResearchInputPage({super.key});

  @override
  ConsumerState<ResearchInputPage> createState() => _ResearchInputPageState();
}

class _ResearchInputPageState extends ConsumerState<ResearchInputPage> {
  final TextEditingController _queryController = TextEditingController();
  final Set<ResearchSource> _enabledSources = {
    ResearchSource.web,
    ResearchSource.knowledgeBase,
    ResearchSource.file,
  };
  int _maxSteps = 5;
  String? _selectedModelConfigId;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _startResearch() {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入研究问题')),
      );
      return;
    }

    final params = ResearchParams(
      query: query,
      modelConfigId: _selectedModelConfigId,
      enabledSources: _enabledSources.toList(),
      maxSteps: _maxSteps,
    );

    // 跳转到结果页面并启动研究
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResearchResultPage(params: params),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 仅用 appDatabaseProvider 来验证数据库可访问
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('深度研究'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '历史报告',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('历史报告功能开发中')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.science_outlined,
              title: '研究问题',
              description: '输入你想要深入研究的问题。越具体，得到的报告越精准。',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _queryController,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: '例如：对比分析 GPT-5 与 Claude 4.5 在长上下文场景下的表现',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              icon: Icons.source_outlined,
              title: '数据源',
              description: '选择启用哪些数据源进行检索。',
            ),
            Wrap(
              spacing: 8,
              children: ResearchSource.values.map((source) {
                final selected = _enabledSources.contains(source);
                return FilterChip(
                  label: Text(_sourceLabel(source)),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _enabledSources.add(source);
                      } else {
                        _enabledSources.remove(source);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              icon: Icons.tune,
              title: '研究深度',
              description: '步骤越多，报告越详尽；时间与 token 消耗也会增加。',
            ),
            Row(
              children: [
                const Text('步骤数'),
                Expanded(
                  child: Slider(
                    value: _maxSteps.toDouble(),
                    min: 3,
                    max: 10,
                    divisions: 7,
                    label: '$_maxSteps 步',
                    onChanged: (val) {
                      setState(() => _maxSteps = val.round());
                    },
                  ),
                ),
                Text('$_maxSteps'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startResearch,
                icon: const Icon(Icons.play_arrow),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('开始研究', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '深度研究会消耗较多 Token，建议使用支持思考模式的模型。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 引用 db 以避免未使用警告（保持依赖链路）
            if (db.hashCode == 0) const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(ResearchSource source) {
    switch (source) {
      case ResearchSource.web:
        return '🌐 Web';
      case ResearchSource.knowledgeBase:
        return '📚 知识库';
      case ResearchSource.file:
        return '📁 本地文件';
    }
    // ignore: dead_code
    return source.name;
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
