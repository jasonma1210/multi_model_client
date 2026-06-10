import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// 使用说明书页面
/// 包含0基础入门指南、模型下载教程、量化模型选择建议等
class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('使用说明书'),
          centerTitle: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            // 欢迎卡片
            _WelcomeCard(),
            const SizedBox(height: 20),

            // 目录
            _TableOfContents(
              tocItems: [
                TocItem(title: '什么是本地模型？', id: 'what-is-local-model'),
                TocItem(title: '如何下载模型？', id: 'how-to-download'),
                TocItem(title: '量化模型是什么？', id: 'quantization'),
                TocItem(title: '如何选择适合自己的模型？', id: 'choose-model'),
                TocItem(title: '什么是 mmproj？', id: 'mmproj'),
                TocItem(title: '开始使用', id: 'getting-started'),
              ],
            ),
            const SizedBox(height: 24),

            // 1. 什么是本地模型
            _SectionCard(
              id: 'what-is-local-model',
              title: '什么是本地模型？',
              icon: Icons.computer_rounded,
              children: [
                Text(
                  '本地模型是指将 AI 大模型文件（如 GGUF 格式）下载到您的设备上，直接在本地运行。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _InfoBox(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  title: '本地模型的优势',
                  children: [
                    '✓ 完全离线可用，不依赖网络',
                    '✓ 数据隐私安全，对话内容不上传到服务器',
                    '✓ 一次下载永久使用，无订阅费用',
                    '✓ 可自定义系统提示词，打造专属 AI 助手',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. 如何下载模型
            _SectionCard(
              id: 'how-to-download',
              title: '如何下载模型？',
              icon: Icons.download_rounded,
              children: [
                Text(
                  '应用内置了模型市场，您可以从这里浏览和下载模型。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _StepList(
                  steps: [
                    '打开应用，进入「设置」→「模型管理」',
                    '点击「模型市场」进入模型浏览页面',
                    '在模型市场顶部搜索框输入您想要的模型名称',
                    '找到模型后，点击进入详情页，查看模型信息',
                    '点击「下载」按钮开始下载，等待下载完成',
                  ],
                ),
                const SizedBox(height: 12),
                _WarningBox(
                  icon: Icons.info_outline,
                  title: '温馨提示',
                  children: [
                    '• 模型文件通常较大（1GB~10GB），请确保有足够的存储空间',
                    '• 建议在 Wi-Fi 环境下下载，避免消耗手机流量',
                    '• 下载过程中可以切换到其他应用，下载会在后台继续进行',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. 量化模型是什么
            _SectionCard(
              id: 'quantization',
              title: '量化模型是什么？',
              icon: Icons.memory_rounded,
              children: [
                Text(
                  '量化（Quantization）是一种压缩技术，通过降低模型参数的精度来减小模型体积和内存占用。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '常见量化等级对比',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _QuantizationTable(),
                const SizedBox(height: 12),
                _InfoBox(
                  icon: Icons.lightbulb_outline,
                  color: Colors.amber,
                  title: '推荐选择',
                  children: [
                    'Q4_K_M：性价比最高，适合大多数设备',
                    'Q5_K_S：效果更好，显存占用适中',
                    'Q8_0：接近原始精度，但需要更多显存',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. 如何选择适合自己的模型
            _SectionCard(
              id: 'choose-model',
              title: '如何选择适合自己的模型？',
              icon: Icons.psychology_rounded,
              children: [
                Text('选择模型需要考虑以下几个因素：', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),

                // 按内存大小分类
                _ModelRecommendation(
                  title: '8GB 及以下内存（手机/老旧电脑）',
                  icon: Icons.smartphone_rounded,
                  color: Colors.blue,
                  recommendations: [
                    '推荐模型：Qwen2.5-3B, Phi-3-mini, Gemma-2B',
                    '推荐量化：Q4_K_M 或更高压缩',
                    '特点：启动快，响应迅速，但能力有限',
                  ],
                ),
                const SizedBox(height: 12),

                _ModelRecommendation(
                  title: '16GB 内存（大多数电脑/平板）',
                  icon: Icons.laptop_rounded,
                  color: Colors.green,
                  recommendations: [
                    '推荐模型：Qwen2.5-7B, Llama-3-8B, Mistral-7B',
                    '推荐量化：Q4_K_M',
                    '特点：平衡了效果和资源占用',
                  ],
                ),
                const SizedBox(height: 12),

                _ModelRecommendation(
                  title: '32GB 及以上内存（高端电脑/Mac）',
                  icon: Icons.desktop_mac_rounded,
                  color: Colors.purple,
                  recommendations: [
                    '推荐模型：Qwen2.5-14B, Llama-3-13B, DeepSeek-33B',
                    '推荐量化：Q5_K_S 或 Q8_0',
                    '特点：效果接近云端大模型',
                  ],
                ),
                const SizedBox(height: 12),

                _InfoBox(
                  icon: Icons.tips_and_updates_outlined,
                  color: Colors.blue,
                  title: '热门模型推荐',
                  children: [
                    '📚 知识问答：Qwen2.5、Llama-3',
                    '💻 代码生成：CodeQwen、DeepSeek-Coder',
                    '📝 文本写作：Qwen2.5、Mistral',
                    '🔍 逻辑推理：Qwen2.5-Coder、DeepSeek',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. 什么是 mmproj
            _SectionCard(
              id: 'mmproj',
              title: '什么是 mmproj？',
              icon: Icons.view_in_ar_rounded,
              children: [
                Text(
                  'mmproj（MultiModal Projector）是多模态模型的图像理解组件。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _InfoBox(
                  icon: Icons.image_outlined,
                  color: Colors.purple,
                  title: '多模态能力',
                  children: [
                    '✓ 支持上传图片，让 AI 分析图片内容',
                    '✓ 支持图片问答，询问图片中的信息',
                    '✓ 支持图文混合对话',
                  ],
                ),
                const SizedBox(height: 12),
                _WarningBox(
                  icon: Icons.info_outline,
                  title: '注意事项',
                  children: [
                    '• mmproj 是可选项，不影响文字对话功能',
                    '• 下载模型时，如果同时提供 mmproj 选项，可以一起下载',
                    '• 加载模型时，应用会询问是否启用多模态支持',
                    '• 启用多模态会占用额外内存，请根据设备情况选择',
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '哪些模型支持多模态？',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '通常模型名称中包含 "vl"（视觉语言）或 "vision" 的模型支持多模态，如：Qwen2.5-VL、Llama-3.2-Vision 等。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 6. 开始使用
            _SectionCard(
              id: 'getting-started',
              title: '开始使用',
              icon: Icons.rocket_launch_rounded,
              children: [
                Text('下载并加载模型后，您可以开始使用了：', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                _StepList(
                  steps: [
                    '在模型管理页面，点击要使用的模型',
                    '在加载页面配置参数（如有需要）',
                    '点击「保存参数」保存您的配置',
                    '点击「加载并开始对话」按钮',
                    '等待模型加载完成，进入对话界面',
                    '开始与您的本地 AI 助手对话！',
                  ],
                ),
                const SizedBox(height: 16),
                _InfoBox(
                  icon: Icons.settings_outlined,
                  color: Colors.teal,
                  title: '参数调整建议',
                  children: [
                    '温度（Temperature）：\n  0.1~0.3 适合代码/准确问答\n  0.7~1.0 适合创意写作',
                    '上下文长度：\n  根据对话长度自动管理，超长会自动压缩',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 底部提示
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '如有问题，请在应用内反馈',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 欢迎卡片
class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '欢迎使用 MJ Nexus Series',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '这是一个本地 AI 助手应用，让您在设备上运行强大的 AI 模型，保护隐私，无需网络。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 目录
class _TableOfContents extends StatelessWidget {
  final List<TocItem> tocItems;

  const _TableOfContents({required this.tocItems});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '目录',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...tocItems.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () {
                  Scrollable.ensureVisible(
                    context,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 目录项
class TocItem {
  final String title;
  final String id;

  TocItem({required this.title, required this.id});
}

/// 章节卡片
class _SectionCard extends StatelessWidget {
  final String id;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.id,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// 信息框
class _InfoBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> children;

  const _InfoBox({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 计算较深的颜色（用于文本显示）
    final darkerColor = Color.fromARGB(
      (color.a * 255).round().clamp(0, 255),
      (color.r * 0.7 * 255).round().clamp(0, 255),
      (color.g * 0.7 * 255).round().clamp(0, 255),
      (color.b * 0.7 * 255).round().clamp(0, 255),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: darkerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: darkerColor.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 警告框
class _WarningBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> children;

  const _WarningBox({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orange = Colors.orange.shade700;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade900,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 步骤列表
class _StepList extends StatelessWidget {
  final List<String> steps;

  const _StepList({required this.steps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 量化等级对比表
class _QuantizationTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = [
      ['Q2_K', '最小', '~70%', '极低', '老旧设备'],
      ['Q3_K_M', '较小', '~80%', '较低', '低端设备'],
      ['Q4_K_M', '适中', '~90%', '中等', '推荐大多数'],
      ['Q5_K_S', '较好', '~95%', '较高', '中高端设备'],
      ['Q8_0', '最好', '100%', '高', '高端设备'],
    ];

    return Table(
      border: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1.5),
      },
      children: [
        // 表头
        TableRow(
          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
          children: [
            _tableCell('量化', isHeader: true),
            _tableCell('体积', isHeader: true),
            _tableCell('精度', isHeader: true),
            _tableCell('显存', isHeader: true),
            _tableCell('推荐', isHeader: true),
          ],
        ),
        // 数据行
        ...data.map(
          (row) =>
              TableRow(children: row.map((cell) => _tableCell(cell)).toList()),
        ),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 模型推荐卡片
class _ModelRecommendation extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> recommendations;

  const _ModelRecommendation({
    required this.title,
    required this.icon,
    required this.color,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 计算较深的颜色（用于文本显示）
    final darkerColor = Color.fromARGB(
      (color.a * 255).round().clamp(0, 255),
      (color.r * 0.7 * 255).round().clamp(0, 255),
      (color.g * 0.7 * 255).round().clamp(0, 255),
      (color.b * 0.7 * 255).round().clamp(0, 255),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: darkerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recommendations.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $text',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: darkerColor.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
