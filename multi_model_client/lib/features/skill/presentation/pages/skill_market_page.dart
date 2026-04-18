import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/skill.dart';
import '../../domain/skill_providers.dart';

/// 技能市场页面
class SkillMarketPage extends ConsumerStatefulWidget {
  const SkillMarketPage({super.key});

  @override
  ConsumerState<SkillMarketPage> createState() => _SkillMarketPageState();
}

class _SkillMarketPageState extends ConsumerState<SkillMarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skills = ref.watch(allSkillsProvider);

    // 搜索过滤
    final filteredSkills = _searchQuery.isEmpty
        ? skills
        : ref.read(skillSearchProvider(_searchQuery));

    // 分类
    final toolSkills = filteredSkills.where((s) => s.type == SkillType.native).toList();
    final expertSkills = filteredSkills.where((s) => s.type == SkillType.expert).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Text('技能中心', style: theme.textTheme.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/settings/skills/editor'),
            tooltip: '创建自定义技能',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '🧰 工具技能 (${toolSkills.length})'),
            Tab(text: '👨‍💼 专家技能 (${expertSkills.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索技能或专家...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // 技能列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildToolSkillsTab(toolSkills, theme),
                _buildExpertSkillsTab(expertSkills, theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/settings/skills/editor'),
        icon: const Icon(Icons.add),
        label: const Text('创建技能'),
      ),
    );
  }

  /// 工具技能 Tab
  Widget _buildToolSkillsTab(List<Skill> skills, ThemeData theme) {
    if (skills.isEmpty) {
      return _buildEmptyState('暂无匹配的工具技能', Icons.build_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return _ToolSkillCard(
          skill: skill,
          theme: theme,
          onTap: () => _showSkillDetail(skill),
        );
      },
    );
  }

  /// 专家技能 Tab - 按领域分组
  Widget _buildExpertSkillsTab(List<Skill> skills, ThemeData theme) {
    if (skills.isEmpty) {
      return _buildEmptyState('暂无匹配的专家技能', Icons.person_outline);
    }

    // 按领域分组
    final domainGroups = <String, List<Skill>>{};
    for (final skill in skills) {
      final domain = skill.domain ?? skill.category ?? '其他';
      domainGroups.putIfAbsent(domain, () => []).add(skill);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      itemCount: domainGroups.length,
      itemBuilder: (context, index) {
        final entry = domainGroups.entries.elementAt(index);
        return _ExpertDomainSection(
          domain: entry.key,
          experts: entry.value,
          theme: theme,
          onExpertTap: _showSkillDetail,
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppTheme.spacingM),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  void _showSkillDetail(Skill skill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _SkillDetailSheet(
          skill: skill,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// 工具技能卡片
class _ToolSkillCard extends StatelessWidget {
  final Skill skill;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ToolSkillCard({required this.skill, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconData(skill.icon),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(skill.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      skill.description,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'calculate': return Icons.calculate;
      case 'schedule': return Icons.schedule;
      case 'search': return Icons.search;
      default: return Icons.extension;
    }
  }
}

/// 专家领域分组
class _ExpertDomainSection extends StatelessWidget {
  final String domain;
  final List<Skill> experts;
  final ThemeData theme;
  final Function(Skill) onExpertTap;

  const _ExpertDomainSection({
    required this.domain,
    required this.experts,
    required this.theme,
    required this.onExpertTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            domain,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: experts.map((expert) => _ExpertChip(
            expert: expert,
            theme: theme,
            onTap: () => onExpertTap(expert),
          )).toList(),
        ),
        const Divider(height: 24),
      ],
    );
  }
}

/// 专家技能 Chip
class _ExpertChip extends StatelessWidget {
  final Skill expert;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ExpertChip({required this.expert, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(expert.emoji ?? '👤', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              expert.name,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// 技能详情弹窗
class _SkillDetailSheet extends StatelessWidget {
  final Skill skill;
  final ScrollController scrollController;

  const _SkillDetailSheet({required this.skill, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpert = skill.type == SkillType.expert;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // 拖拽指示器
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // 图标和名称
        Row(
          children: [
            if (isExpert)
              Text(skill.emoji ?? '👤', style: const TextStyle(fontSize: 40))
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.extension, color: theme.colorScheme.onPrimaryContainer, size: 28),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isExpert ? Colors.purple.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isExpert ? '👨‍💼 专家' : '🧰 工具',
                      style: TextStyle(fontSize: 12, color: isExpert ? Colors.purple : Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 描述
        Text(skill.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        // 领域
        if (skill.domain != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('领域: ${skill.domain}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
          ),
        ],
        // 专家提示词预览
        if (isExpert && skill.expertPrompt != null) ...[
          const SizedBox(height: 20),
          Text('专家能力描述', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              skill.expertPrompt!,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
        // 工具参数
        if (!isExpert && skill.parameters.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('参数说明', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...skill.parameters.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text('${p.name}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(' (${p.type.name}${p.required ? ", 必需" : ""}): ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Expanded(child: Text(p.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
              ],
            ),
          )),
        ],
        // 标签
        if (skill.tags != null && skill.tags!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            children: skill.tags!.map((tag) => Chip(
              label: Text(tag, style: const TextStyle(fontSize: 11)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }
}
