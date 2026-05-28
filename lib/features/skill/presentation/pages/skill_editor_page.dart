import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Skill 编辑器页面
/// 支持创建和编辑自定义技能
class SkillEditorPage extends ConsumerStatefulWidget {
  final String? skillId; // 如果是编辑模式，传入 skillId

  const SkillEditorPage({super.key, this.skillId});

  @override
  ConsumerState<SkillEditorPage> createState() => _SkillEditorPageState();
}

class _SkillEditorPageState extends ConsumerState<SkillEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promptController = TextEditingController();
  final _implementationController = TextEditingController();

  String _selectedType = 'expert'; // expert 或 tool
  String _selectedDomain = '通用';
  String _emoji = '🤖';

  bool _isLoading = false;
  bool get _isEditMode => widget.skillId != null;

  final List<String> _domains = [
    '通用',
    '编程开发',
    '产品设计',
    '数据分析',
    '市场营销',
    '项目管理',
    '写作创作',
    '学习教育',
    '生活助手',
    '专业服务',
  ];

  final List<String> _commonEmojis = [
    '🤖',
    '👨‍💻',
    '👩‍💻',
    '🧠',
    '💡',
    '🎯',
    '📊',
    '📝',
    '🔧',
    '🚀',
    '🎨',
    '📚',
    '💼',
    '🌟',
    '⚡',
    '🔍',
    '💬',
    '🎓',
    '🏠',
    '🎮',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadSkill();
    }
  }

  void _loadSkill() {
    // TODO: 从数据库加载现有 Skill
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _promptController.dispose();
    _implementationController.dispose();
    super.dispose();
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings/skills'),
          ),
          title: Text(_isEditMode ? '编辑技能' : '创建技能'),
          actions: [
            TextButton.icon(
              onPressed: _isLoading ? null : _saveSkill,
              icon: const Icon(Icons.save),
              label: const Text('保存'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            children: [
              // 技能类型选择
              _buildSectionTitle('技能类型'),
              _buildTypeSelector(),
              const SizedBox(height: AppTheme.spacingL),

              // 基本信息
              _buildSectionTitle('基本信息'),
              _buildBasicInfoSection(),
              const SizedBox(height: AppTheme.spacingL),

              // 技能提示词
              _buildSectionTitle('技能提示词'),
              _buildPromptSection(),
              const SizedBox(height: AppTheme.spacingL),

              // 自定义实现（高级）
              _buildSectionTitle('自定义实现（高级）'),
              _buildImplementationSection(),
              const SizedBox(height: AppTheme.spacingXXL),

              // 预览
              _buildSectionTitle('预览'),
              _buildPreviewSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expert',
                  label: Text('专家技能'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment(
                  value: 'tool',
                  label: Text('工具技能'),
                  icon: Icon(Icons.build),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _selectedType = selection.first);
              },
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _selectedType == 'expert'
                  ? '专家技能：AI 扮演特定角色，提供专业建议和指导'
                  : '工具技能：执行特定任务，需要自定义实现代码',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            // Emoji 选择
            Row(
              children: [
                Text('图标', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonEmojis.map((emoji) {
                      final isSelected = emoji == _emoji;
                      return InkWell(
                        onTap: () => setState(() => _emoji = emoji),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),

            // 名称
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '技能名称',
                hintText: '例如：代码审查专家',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入技能名称';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingM),

            // 描述
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '技能描述',
                hintText: '简要描述这个技能的作用',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入技能描述';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingM),

            // 领域选择
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _selectedDomain,
              decoration: const InputDecoration(
                labelText: '所属领域',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _domains.map((domain) {
                return DropdownMenuItem(value: domain, child: Text(domain));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDomain = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('系统提示词', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '定义 AI 在使用此技能时的角色和行为方式。支持使用 {{变量}} 格式定义变量。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: '''你是一个专业的{{domain}}专家。

你的职责是：
1. ...
2. ...

请用专业但易懂的方式回答用户的问题。''',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
              maxLines: 10,
              validator: (value) {
                if (_selectedType == 'expert' &&
                    (value == null || value.isEmpty)) {
                  return '专家技能必须提供系统提示词';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Dart 实现代码（可选）',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '对于工具技能，可以提供 Dart 代码来实现具体功能。代码需要包含 execute 方法。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusS),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'skill_implementation.dart',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _showCodeTemplate,
                          icon: const Icon(Icons.content_paste, size: 16),
                          label: const Text('模板'),
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _implementationController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(AppTheme.spacingM),
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    maxLines: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isEmpty
                            ? '技能名称'
                            : _nameController.text,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _selectedDomain,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedType == 'expert'
                        ? Colors.purple.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedType == 'expert' ? '👨‍💼 专家' : '🧰 工具',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedType == 'expert'
                          ? Colors.purple
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              _descriptionController.text.isEmpty
                  ? '技能描述将显示在这里...'
                  : _descriptionController.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCodeTemplate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('代码模板'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTemplateButton('基础模板', '''// Skill 实现模板
// 参数通过 params Map 传入
// 返回 SkillResult

Future<SkillResult> execute(Map<String, dynamic> params) async {
  try {
    // 1. 获取参数
    final input = params['input'] as String?;
    
    // 2. 执行逻辑
    // TODO: 在这里实现你的逻辑
    
    // 3. 返回结果
    return SkillResult.success(
      '处理结果: \$input',
      metadata: {'status': 'completed'},
    );
  } catch (e) {
    return SkillResult.error('执行失败: \$e');
  }
}'''),
              const SizedBox(height: 8),
              _buildTemplateButton('网络请求模板', '''// 网络请求模板
import 'package:dio/dio.dart';

Future<SkillResult> execute(Map<String, dynamic> params) async {
  try {
    final dio = Dio();
    final url = params['url'] as String;
    
    final response = await dio.get(url);
    
    if (response.statusCode == 200) {
      return SkillResult.success(
        response.data,
        metadata: {'source': url},
      );
    } else {
      return SkillResult.error('请求失败: \${response.statusCode}');
    }
  } catch (e) {
    return SkillResult.error('网络错误: \$e');
  }
}'''),
              const SizedBox(height: 8),
              _buildTemplateButton('数据处理模板', '''// 数据处理模板
Future<SkillResult> execute(Map<String, dynamic> params) async {
  try {
    final data = params['data'];
    final operation = params['operation'] as String?;
    
    dynamic result;
    
    switch (operation) {
      case 'count':
        result = (data as List).length;
        break;
      case 'sum':
        result = (data as List).fold(0, (a, b) => a + b);
        break;
      default:
        result = data;
    }
    
    return SkillResult.success(
      result,
      metadata: {'operation': operation},
    );
  } catch (e) {
    return SkillResult.error('处理失败: \$e');
  }
}'''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateButton(String name, String template) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _implementationController.text = template;
          });
          Navigator.pop(context);
        },
        child: Text(name),
      ),
    );
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: 保存到数据库
      // 创建 CustomSkill 对象并保存

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('技能保存成功'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/settings/skills');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
