import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/skill.dart';
import '../../domain/skill_providers.dart';

/// 技能详情页面
class SkillDetailPage extends ConsumerStatefulWidget {
  final Skill skill;
  final ScrollController? scrollController;

  const SkillDetailPage({
    super.key,
    required this.skill,
    this.scrollController,
  });

  @override
  ConsumerState<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends ConsumerState<SkillDetailPage> {
  final Map<String, dynamic> _paramValues = {};
  bool _isExecuting = false;
  SkillResult? _lastResult;

  @override
  void initState() {
    super.initState();
    // 初始化参数默认值
    for (final param in widget.skill.parameters) {
      if (param.defaultValue != null) {
        _paramValues[param.name] = param.defaultValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statistics = ref.watch(skillStatisticsProvider(widget.skill.id));

    return Column(
      children: [
        // 拖动条
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingS),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // 头部
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  _getIconData(widget.skill.icon),
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.skill.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      widget.skill.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 标签
        if (widget.skill.tags != null && widget.skill.tags!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Wrap(
              spacing: AppTheme.spacingS,
              children: widget.skill.tags!
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          ),

        const Divider(height: AppTheme.spacingXL),

        // 内容
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基本信息
                _buildSection(
                  title: '基本信息',
                  children: [
                    _buildInfoRow('ID', widget.skill.id),
                    _buildInfoRow('类型', widget.skill.type.name),
                    if (widget.skill.category != null)
                      _buildInfoRow('分类', widget.skill.category!),
                    _buildInfoRow('内置', widget.skill.isBuiltin ? '是' : '否'),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // 使用统计
                _buildSection(
                  title: '使用统计',
                  children: [
                    _buildInfoRow('总调用次数', '${statistics['totalCalls']}'),
                    _buildInfoRow('成功次数', '${statistics['successCount']}'),
                    _buildInfoRow('失败次数', '${statistics['errorCount']}'),
                    _buildInfoRow(
                      '成功率',
                      '${(statistics['successRate'] * 100).toStringAsFixed(1)}%',
                    ),
                    _buildInfoRow(
                      '平均耗时',
                      '${statistics['averageDurationMs'].toStringAsFixed(0)}ms',
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // 参数说明
                if (widget.skill.parameters.isNotEmpty)
                  _buildParametersSection(),

                const SizedBox(height: AppTheme.spacingL),

                // 测试执行
                _buildTestSection(),

                const SizedBox(height: AppTheme.spacingL),

                // 调用记录
                _buildInvocationHistory(),

                const SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParametersSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '参数说明',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        ...widget.skill.parameters.map((param) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: ExpansionTile(
              title: Row(
                children: [
                  Text(
                    param.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: param.required
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      param.required ? '必需' : '可选',
                      style: TextStyle(
                        fontSize: 10,
                        color: param.required ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                param.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('类型', param.type.name),
                      if (param.defaultValue != null)
                        _buildInfoRow('默认值', '${param.defaultValue}'),
                      if (param.enumValues != null)
                        _buildInfoRow(
                          '可选值',
                          param.enumValues!.join(', '),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTestSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '测试执行',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 参数输入
                ...widget.skill.parameters.map((param) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppTheme.spacingM),
                    child: _buildParamInput(param),
                  );
                }),

                const SizedBox(height: AppTheme.spacingM),

                // 执行按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExecuting ? null : _executeSkill,
                    icon: _isExecuting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isExecuting ? '执行中...' : '执行'),
                  ),
                ),

                // 执行结果
                if (_lastResult != null) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: _lastResult!.success
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _lastResult!.success
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _lastResult!.success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              _lastResult!.success ? '执行成功' : '执行失败',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _lastResult!.success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (_lastResult!.data != null) ...[
                          const SizedBox(height: AppTheme.spacingS),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusS),
                            ),
                            child: Text(
                              const JsonEncoder.withIndent('  ')
                                  .convert(_lastResult!.data),
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                        if (_lastResult!.error != null) ...[
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            _lastResult!.error!,
                            style: TextStyle(
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParamInput(SkillParameter param) {
    final theme = Theme.of(context);

    switch (param.type) {
      case SkillParameterType.boolean:
        return SwitchListTile(
          title: Text(param.name),
          subtitle: Text(param.description),
          value: _paramValues[param.name] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _paramValues[param.name] = value;
            });
          },
        );

      case SkillParameterType.number:
        return TextField(
          decoration: InputDecoration(
            labelText: param.name,
            helperText: param.description,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _paramValues[param.name]?.toString() ??
                param.defaultValue?.toString() ??
                '',
          ),
          onChanged: (value) {
            _paramValues[param.name] =
                value.isEmpty ? null : num.tryParse(value);
          },
        );

      case SkillParameterType.array:
      case SkillParameterType.object:
        return TextField(
          decoration: InputDecoration(
            labelText: param.name,
            helperText: '${param.description} (JSON格式)',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          controller: TextEditingController(
            text: _paramValues[param.name] != null
                ? const JsonEncoder.withIndent('  ')
                    .convert(_paramValues[param.name])
                : param.defaultValue != null
                    ? const JsonEncoder.withIndent('  ')
                        .convert(param.defaultValue)
                    : '',
          ),
          onChanged: (value) {
            try {
              _paramValues[param.name] = jsonDecode(value);
            } catch (_) {
              // 忽略解析错误
            }
          },
        );

      case SkillParameterType.string:
      default:
        if (param.enumValues != null) {
          return DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              labelText: param.name,
              helperText: param.description,
              border: const OutlineInputBorder(),
            ),
            value: _paramValues[param.name] ?? param.defaultValue,
            items: param.enumValues!
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.toString()),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _paramValues[param.name] = value;
              });
            },
          );
        }

        return TextField(
          decoration: InputDecoration(
            labelText: param.name,
            helperText: param.description,
            border: const OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: _paramValues[param.name]?.toString() ??
                param.defaultValue?.toString() ??
                '',
          ),
          onChanged: (value) {
            _paramValues[param.name] = value.isEmpty ? null : value;
          },
        );
    }
  }

  Widget _buildInvocationHistory() {
    final theme = Theme.of(context);
    final history =
        ref.watch(skillInvocationHistoryProvider(widget.skill.id));

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '调用记录',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(skillDispatcherProvider)
                    .clearInvocationHistory();
                setState(() {});
              },
              child: const Text('清空'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        ...history.reversed.take(5).map((invocation) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: ListTile(
              leading: Icon(
                invocation.result.success ? Icons.check_circle : Icons.error,
                color: invocation.result.success ? Colors.green : Colors.red,
              ),
              title: Text(
                '${invocation.timestamp.hour}:${invocation.timestamp.minute.toString().padLeft(2, '0')}:${invocation.timestamp.second.toString().padLeft(2, '0')}',
              ),
              subtitle: Text('耗时: ${invocation.duration.inMilliseconds}ms'),
              trailing: invocation.result.success
                  ? null
                  : const Icon(Icons.error_outline, color: Colors.red),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _executeSkill() async {
    setState(() {
      _isExecuting = true;
      _lastResult = null;
    });

    try {
      final dispatcher = ref.read(skillDispatcherProvider);
      final result = await dispatcher.dispatch(
        widget.skill.id,
        Map<String, dynamic>.from(_paramValues),
      );

      setState(() {
        _lastResult = result;
      });
    } catch (e) {
      setState(() {
        _lastResult = SkillResult.error(e.toString());
      });
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'calculate':
        return Icons.calculate;
      case 'schedule':
        return Icons.schedule;
      case 'search':
        return Icons.search;
      case 'build':
        return Icons.build;
      default:
        return Icons.extension;
    }
  }
}
