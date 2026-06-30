/// 深度研究报告查看页面（v0.42.0）
///
/// 展示研究进度、引用、最终报告。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../domain/research_models.dart';
import '../../providers/research_provider.dart';

class ResearchResultPage extends ConsumerStatefulWidget {
  final ResearchParams params;

  const ResearchResultPage({required this.params, super.key});

  @override
  ConsumerState<ResearchResultPage> createState() => _ResearchResultPageState();
}

class _ResearchResultPageState extends ConsumerState<ResearchResultPage> {
  @override
  void initState() {
    super.initState();
    // 启动研究
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(researchReportProvider.notifier).startResearch(widget.params);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(researchReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('研究报告'),
        actions: [
          if (state.status == ResearchStatus.completed)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(researchReportProvider.notifier).reset();
                ref
                    .read(researchReportProvider.notifier)
                    .startResearch(widget.params);
              },
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ResearchReportState state) {
    if (state.status == ResearchStatus.pending && state.eventLog.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ResearchStatus.failed && state.eventLog.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('研究失败: ${state.error ?? "未知错误"}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(researchReportProvider.notifier).startResearch(widget.params);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildProgressHeader(state),
        const Divider(height: 1),
        Expanded(
          child: state.status == ResearchStatus.completed
              ? _buildCompletedView(state)
              : _buildRunningView(state),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(ResearchReportState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusIcon(status: state.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.status.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (state.statusMessage != null)
                      Text(
                        state.statusMessage!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (state.totalSteps > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: state.totalSteps > 0
                  ? state.completedSteps / state.totalSteps
                  : null,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            const SizedBox(height: 4),
            Text(
              '进度: ${state.completedSteps} / ${state.totalSteps} 步 · 累计 ${state.totalTokens} tokens · ${state.allCitations.length} 个引用',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRunningView(ResearchReportState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.allCitations.isNotEmpty) ...[
          const _SectionTitle('已检索到的引用'),
          const SizedBox(height: 8),
          ...state.allCitations.map(_buildCitationCard),
          const SizedBox(height: 24),
        ],
        if (state.eventLog.isNotEmpty) ...[
          const _SectionTitle('执行日志'),
          const SizedBox(height: 8),
          ...state.eventLog.reversed.take(20).map(_buildEventLog),
        ],
      ],
    );
  }

  Widget _buildCompletedView(ResearchReportState state) {
    final title = state.finalTitle ?? widget.params.query;
    final summary = state.finalSummary ?? '（暂无摘要）';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.summarize, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '摘要',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(summary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (state.allCitations.isNotEmpty) ...[
          _SectionTitle('所有引用（${state.allCitations.length}）'),
          const SizedBox(height: 8),
          ...state.allCitations.map(_buildCitationCard),
        ],
      ],
    );
  }

  Widget _buildCitationCard(Citation citation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _sourceColor(citation.sourceType),
          child: Text(
            '[${citation.index}]',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        title: Text(
          citation.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          citation.snippet ?? citation.displayLocation,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          citation.sourceType.displayName,
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildEventLog(ResearchProgressEvent event) {
    String text;
    IconData icon = Icons.info_outline;
    Color color = Colors.blue;

    if (event is ResearchStatusChanged) {
      text = '${event.status.displayName}: ${event.message ?? ""}';
      icon = Icons.flag;
    } else if (event is ResearchStepStarted) {
      text = '开始第 ${event.stepIndex} 步: ${event.stepTitle}';
      icon = Icons.play_arrow;
      color = Colors.green;
    } else if (event is ResearchStepCompleted) {
      text = '完成第 ${event.stepIndex} 步 (${event.tokensUsed} tokens, ${event.newCitations.length} 引用)';
      icon = Icons.check;
      color = Colors.teal;
    } else if (event is ResearchFailed) {
      text = '失败: ${event.error}';
      icon = Icons.error;
      color = Colors.red;
    } else {
      text = event.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Color _sourceColor(CitationSourceType type) {
    switch (type) {
      case CitationSourceType.web:
        return Colors.blue;
      case CitationSourceType.knowledgeBase:
        return Colors.purple;
      case CitationSourceType.file:
        return Colors.orange;
      case CitationSourceType.rss:
        return Colors.green;
    }
    // ignore: dead_code
    return Colors.grey;
  }
}

class _StatusIcon extends StatelessWidget {
  final ResearchStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status.isRunning) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (status == ResearchStatus.completed) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 28);
    }
    if (status == ResearchStatus.failed) {
      return const Icon(Icons.error, color: Colors.red, size: 28);
    }
    return const Icon(Icons.science, size: 28);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

/// 完整报告页面（用于最终查看）
class ResearchFullReportPage extends ConsumerWidget {
  final String reportId;
  const ResearchFullReportPage({required this.reportId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('完整报告')),
      body: Markdown(
        data: '# 报告\n\n详细内容...',
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
