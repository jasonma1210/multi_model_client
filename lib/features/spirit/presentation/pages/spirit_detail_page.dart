// ignore_for_file: use_build_context_synchronously
/// 名灵回响 - 名灵 Skill 详情页面
///
/// 展示蒸馏完成的名灵角色的完整 Skill 描述信息
/// 包含：身份卡、心智模型、决策启发式、表达DNA、价值观等
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/spirit_repository.dart';
import '../../domain/spirit_persona.dart';

class SpiritDetailPage extends ConsumerStatefulWidget {
  final String spiritId;

  const SpiritDetailPage({super.key, required this.spiritId});

  @override
  ConsumerState<SpiritDetailPage> createState() => _SpiritDetailPageState();
}

class _SpiritDetailPageState extends ConsumerState<SpiritDetailPage> {
  SpiritPersona? _persona;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPersona();
  }

  Future<void> _loadPersona() async {
    final repo = ref.read(spiritRepositoryProvider);
    final persona = await repo.getPersonaById(widget.spiritId);
    if (mounted) {
      setState(() {
        _persona = persona;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('名灵详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_persona == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('名灵详情')),
        body: const Center(child: Text('名灵角色不存在')),
      );
    }

    final persona = _persona!;
    final prompt = persona.distilledPrompt ?? '暂无蒸馏内容';

    return Scaffold(
      appBar: AppBar(
        title: Text('${persona.avatarEmoji} ${persona.nickname}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息卡片
            _buildInfoCard(theme, persona),
            const SizedBox(height: 16),

            // 蒸馏内容
            _buildPromptSection(theme, prompt, persona),
          ],
        ),
      ),
    );
  }

  /// 基本信息卡片
  Widget _buildInfoCard(ThemeData theme, SpiritPersona persona) {
    final statusColor = persona.isReady
        ? Colors.green
        : persona.isProcessing
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(persona.avatarEmoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.nickname,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          persona.domain,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    persona.statusText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (persona.description != null) ...[
              const SizedBox(height: 12),
              Text(
                persona.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (persona.clonedVoiceId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.record_voice_over, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '已克隆音色',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
            if (persona.searchSources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '搜索来源: ${persona.searchSources.length} 个',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 蒸馏内容展示（解析 Markdown 格式的 system prompt）
  Widget _buildPromptSection(ThemeData theme, String prompt, SpiritPersona persona) {
    // 按 Markdown 标题分割内容
    final sections = _parsePromptSections(prompt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '蒸馏内容',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sections.isEmpty)
          // 无结构化内容，直接显示原始文本
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                prompt,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...sections.map((section) => _buildSectionCard(theme, section)),
      ],
    );
  }

  /// 解析 prompt 为结构化段落
  List<_PromptSection> _parsePromptSections(String prompt) {
    final sections = <_PromptSection>[];
    final lines = prompt.split('\n');
    _PromptSection? currentSection;

    for (final line in lines) {
      // 检测 Markdown 标题
      if (line.startsWith('## ')) {
        if (currentSection != null) {
          sections.add(currentSection);
        }
        currentSection = _PromptSection(
          title: line.substring(3).trim(),
          level: 2,
          content: '',
        );
      } else if (line.startsWith('### ')) {
        if (currentSection != null) {
          sections.add(currentSection);
        }
        currentSection = _PromptSection(
          title: line.substring(4).trim(),
          level: 3,
          content: '',
        );
      } else if (currentSection != null) {
        currentSection = _PromptSection(
          title: currentSection.title,
          level: currentSection.level,
          content: currentSection.content.isEmpty
              ? line
              : '${currentSection.content}\n$line',
        );
      }
    }
    if (currentSection != null) {
      sections.add(currentSection);
    }

    return sections;
  }

  /// 构建段落卡片
  Widget _buildSectionCard(ThemeData theme, _PromptSection section) {
    final isLevel2 = section.level == 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isLevel2 ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isLevel2
              ? BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))
              : BorderSide.none,
        ),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isLevel2,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            title: Row(
              children: [
                Icon(
                  _getSectionIcon(section.title),
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: (isLevel2
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.bodyMedium)
                        ?.copyWith(
                      fontWeight: isLevel2 ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  section.content.trim(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据段落标题返回图标
  IconData _getSectionIcon(String title) {
    if (title.contains('角色扮演') || title.contains('规则')) {
      return Icons.theater_comedy;
    } else if (title.contains('身份') || title.contains('我是谁')) {
      return Icons.badge;
    } else if (title.contains('心智模型') || title.contains('模型')) {
      return Icons.psychology;
    } else if (title.contains('决策') || title.contains('启发')) {
      return Icons.lightbulb;
    } else if (title.contains('表达') || title.contains('DNA')) {
      return Icons.record_voice_over;
    } else if (title.contains('价值') || title.contains('反模式')) {
      return Icons.favorite;
    } else if (title.contains('诚实') || title.contains('边界') || title.contains('局限')) {
      return Icons.shield;
    } else if (title.contains('黑名单')) {
      return Icons.block;
    } else if (title.contains('起点') || title.contains('背景')) {
      return Icons.history;
    } else if (title.contains('现在') || title.contains('动态')) {
      return Icons.update;
    }
    return Icons.article;
  }
}

/// prompt 段落数据
class _PromptSection {
  final String title;
  final int level;
  final String content;

  const _PromptSection({
    required this.title,
    required this.level,
    required this.content,
  });
}
