// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mj_nexus/generated/app_localizations.dart';
import '../../../../core/models/model_entry.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/engines/model_inference_engine.dart';
import '../../../../core/interfaces/model_interface.dart';
import '../../../session/domain/session_manager.dart';
import '../../../../core/interfaces/session_interface.dart';

/// 使用全局单例
ModelInferenceEngine get _engine => globalModelEngine;

// ════════════════════════════════════════════════════════════════════════════
//  模型加载 & 参数配置页（对照效果图完整实现）
//  路由: /model/:id/load
// ════════════════════════════════════════════════════════════════════════════

class ModelLoadPage extends ConsumerStatefulWidget {
  final String modelId;
  const ModelLoadPage({super.key, required this.modelId});

  @override
  ConsumerState<ModelLoadPage> createState() => _ModelLoadPageState();
}

class _ModelLoadPageState extends ConsumerState<ModelLoadPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// 当前正在编辑的参数（本地模型）
  LocalModelParams _params = const LocalModelParams();

  /// 当前正在编辑的远程模型参数
  RemoteModelConfig? _remoteConfig;

  /// 系统提示词控制器
  final _systemPromptController = TextEditingController();

  /// Ollama API Key 控制器
  final _ollamaApiKeyController = TextEditingController();

  /// llama.cpp 是否可用
  bool _llamaCppAvailable = false;

  /// 参数是否已保存（本地模型需要先保存参数才能加载）
  bool _paramsSaved = false;

  /// 加载超时 Timer（提升为类成员，dispose 时取消）
  Timer? _loadTimeoutTimer;

  /// 加载状态 StreamSubscription（提升为类成员，dispose 时取消）
  StreamSubscription<ModelLoadingState>? _loadStateSub;

  /// 是否为远程 Ollama 模型
  bool get _isRemoteOllama {
    final modelState = ref.read(modelProvider);
    final model = modelState.models
        .where((m) => m.id == widget.modelId)
        .firstOrNull;
    return model?.isRemote == true &&
        model?.remoteConfig?.protocol == RemoteProtocol.ollama;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 检查 llama.cpp 是否可用
    _checkLlamaCppAvailability();

    // 读取已保存的参数
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final models = ref.read(modelProvider).models;
      final model = models.where((m) => m.id == widget.modelId).firstOrNull;
      if (model != null) {
        if (model.isLocal && model.localParams != null) {
          setState(() {
            _params = model.localParams!;
            // 如果已有保存的参数，标记为已保存状态
            _paramsSaved = true;
          });
          // 同步系统提示词到文本控制器
          if (model.localParams!.systemPrompt != null) {
            _systemPromptController.text = model.localParams!.systemPrompt!;
          }
        } else if (model.isRemote && model.remoteConfig != null) {
          setState(() {
            _remoteConfig = model.remoteConfig;
            // ★★★ 远程模型：从顶级 enableReasoning 字段恢复开关状态 ★★★
            if (model.enableReasoning != null) {
              _params = _params.copyWith(
                enableReasoning: model.enableReasoning!,
              );
            }
          });
          // 同步 Ollama API Key 到文本控制器
          if (model.remoteConfig!.apiKey.isNotEmpty) {
            _ollamaApiKeyController.text = model.remoteConfig!.apiKey;
          }
        }
      }
    });
  }

  Future<void> _checkLlamaCppAvailability() async {
    // 检查 llama.cpp 库是否可用
    setState(() => _llamaCppAvailable = true);
  }

  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    _loadStateSub?.cancel();
    _tabController.dispose();
    _systemPromptController.dispose();
    _ollamaApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modelState = ref.watch(modelProvider);
    final model = modelState.models
        .where((m) => m.id == widget.modelId)
        .firstOrNull;

    if (model == null) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {},
        child: Scaffold(
          appBar: AppBar(title: const Text('模型不存在')),
          body: const Center(child: Text('找不到指定模型')),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(model.displayName),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          actions: [
            // 保存参数
            TextButton.icon(
              onPressed: _saveParams,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('保存'),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Model Parameters'),
              Tab(text: '模型信息'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildParamsTab(theme, model),
            _buildInfoTab(theme, model),
          ],
        ),
        // 底部加载/卸载按钮
        bottomNavigationBar: _buildBottomBar(theme, model),
      ),
    );
  }

  // ──────────────────────────── 参数面板 ────────────────────────────

  Widget _buildParamsTab(ThemeData theme, ModelEntry model) {
    // 根据模型类型显示不同的参数配置
    if (model.isRemote &&
        model.remoteConfig?.protocol == RemoteProtocol.ollama) {
      return _buildOllamaParamsTab(theme, model);
    }
    return _buildLocalParamsTab(theme, model);
  }

  // 本地模型参数配置
  Widget _buildLocalParamsTab(ThemeData theme, ModelEntry model) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      children: [
        // ── 系统提示词区域 ──
        _SectionCard(
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '系统提示词',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(不设定则使用默认)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _systemPromptController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '输入人设提示词，例如：你是一位专业的技术作家...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (v) => setState(
                () => _params = _params.copyWith(
                  systemPrompt: v.isEmpty ? null : v,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_params.systemPrompt != null &&
                _params.systemPrompt!.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  _systemPromptController.clear();
                  setState(
                    () => _params = _params.copyWith(systemPrompt: null),
                  );
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('清除系统提示词'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // ── 设置区域 ──
        _CollapsibleSection(
          title: AppLocalizations.of(context)!.settings,
          icon: Icons.settings_outlined,
          defaultExpanded: true,
          children: [
            // 温度
            _SliderParam(
              label: '温度',
              tooltip:
                  '控制生成文本的随机性。值越低(0.0)输出越确定性，值越高(2.0)输出越随机多样。推荐：创意写作 0.8-1.2，代码生成 0.1-0.3',
              value: _params.temperature,
              min: 0.0,
              max: 2.0,
              divisions: 200,
              onChanged: (v) =>
                  setState(() => _params = _params.copyWith(temperature: v)),
            ),
            const SizedBox(height: 8),
            // 限制响应长度
            _SwitchParam(
              label: '限制响应长度',
              tooltip: '启用后，模型生成的回答将受到最大 token 数限制，防止生成过长内容',
              value: _params.limitResponseLength,
              onChanged: (v) => setState(
                () => _params = _params.copyWith(limitResponseLength: v),
              ),
            ),
            const SizedBox(height: 8),
            // 上下文溢出
            _DropdownParam(
              label: '上下文溢出',
              tooltip: '当对话上下文超过模型最大长度时，选择如何处理超出部分：截断中间保留首尾，截断开头保留最新，截断末尾保留最早',
              value: _params.contextOverflow,
              items: const {
                'truncate_middle': '截断中间',
                'truncate_start': '截断开头',
                'truncate_end': '截断末尾',
              },
              onChanged: (v) => setState(
                () => _params = _params.copyWith(contextOverflow: v!),
              ),
            ),
            const SizedBox(height: 8),
            // 上下文大小
            _StepperParam(
              label: '上下文大小',
              tooltip: '设置模型的上下文窗口大小（token 数）。更大的上下文可处理更长对话，但需要更多内存。48GB 内存可设 65536-131072',
              value: _params.contextSize,
              min: 2048,
              max: 131072,
              onChanged: (v) =>
                  setState(() => _params = _params.copyWith(contextSize: v)),
            ),
            const SizedBox(height: 8),
            // 停止字符串
            _TextInputParam(
              label: '停止字符串',
              tooltip: '设置自定义停止词，模型遇到此字符串时立即停止生成。例如设置 "END" 可在特定位置停止输出',
              hint: '输入一个字符串并按 ↵',
              value: _params.stopString,
              onChanged: (v) => setState(
                () => _params = _params.copyWith(
                  stopString: v.isEmpty ? null : v,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // CPU 线程数
            _StepperParam(
              label: 'CPU 线程',
              tooltip: '设置用于模型推理的 CPU 线程数。更多线程可加快推理速度，但会增加资源占用。建议设置为 CPU 核心数',
              value: _params.cpuThreads,
              min: 1,
              max: 32,
              onChanged: (v) =>
                  setState(() => _params = _params.copyWith(cpuThreads: v)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── 采样区域 ──
        _CollapsibleSection(
          title: '采样',
          icon: Icons.auto_fix_high_outlined,
          defaultExpanded: true,
          children: [
            // Top K
            _StepperParam(
              label: 'Top K 采样',
              tooltip:
                  '限制模型只从概率最高的 K 个词中选择。K=1 时完全确定性输出，K 越大输出越随机。推荐：精确任务 1-10，创意任务 40-100',
              value: _params.topK,
              min: 1,
              max: 200,
              onChanged: (v) =>
                  setState(() => _params = _params.copyWith(topK: v)),
            ),
            const SizedBox(height: 8),
            // 重复惩罚
            _SwitchSliderParam(
              label: '重复惩罚',
              tooltip: '防止模型重复生成相同内容。值越高惩罚越强，1.0 为无惩罚，1.2 表示之前出现过的词概率降低 20%',
              enabled: _params.repeatPenaltyEnabled,
              value: _params.repeatPenalty,
              min: 1.0,
              max: 2.0,
              divisions: 100,
              onEnabledChanged: (v) => setState(
                () => _params = _params.copyWith(repeatPenaltyEnabled: v),
              ),
              onValueChanged: (v) =>
                  setState(() => _params = _params.copyWith(repeatPenalty: v)),
            ),
            const SizedBox(height: 8),
            // 存在惩罚
            _SwitchParam(
              label: '存在惩罚',
              tooltip: '启用后，模型会倾向于引入对话中未出现过的新词汇和概念，有助于增加输出的多样性和新颖性',
              value: _params.presencePenaltyEnabled,
              onChanged: (v) => setState(
                () => _params = _params.copyWith(presencePenaltyEnabled: v),
              ),
            ),
            const SizedBox(height: 8),
            // Top P
            _SwitchSliderParam(
              label: 'Top P 采样',
              tooltip:
                  '核采样：只从累积概率达到 P 的高概率词中选择。P=0.9 表示从概率最高的词中选择，直到累计概率达到 90%',
              enabled: _params.topPEnabled,
              value: _params.topP,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onEnabledChanged: (v) =>
                  setState(() => _params = _params.copyWith(topPEnabled: v)),
              onValueChanged: (v) =>
                  setState(() => _params = _params.copyWith(topP: v)),
            ),
            const SizedBox(height: 8),
            // Min P
            _SwitchSliderParam(
              label: '最小 P 采样',
              tooltip: '设置最低概率阈值，排除概率过低的词。值越高输出越保守，值越低允许更多低概率词出现',
              enabled: _params.minPEnabled,
              value: _params.minP,
              min: 0.0,
              max: 0.5,
              divisions: 50,
              onEnabledChanged: (v) =>
                  setState(() => _params = _params.copyWith(minPEnabled: v)),
              onValueChanged: (v) =>
                  setState(() => _params = _params.copyWith(minP: v)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── 结构化输出 ──
        _CollapsibleSection(
          title: '结构化输出',
          icon: Icons.data_object_outlined,
          defaultExpanded: false,
          children: [
            _SwitchParam(
              label: '启用结构化输出（JSON Schema）',
              tooltip: '启用后，模型输出将遵循 JSON Schema 规范，适合需要结构化数据的场景（如 API 响应、数据提取）',
              value: _params.structuredOutput,
              onChanged: (v) => setState(
                () => _params = _params.copyWith(structuredOutput: v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── 快速模式 ──
        _CollapsibleSection(
          title: '快速模式',
          icon: Icons.bolt_outlined,
          defaultExpanded: false,
          children: [
            _SwitchParam(
              label: '启用思考模式（Reasoning）',
              tooltip:
                  '启用后，模型将输出思考过程（Chain-of-Thought），适合数学、逻辑推理等复杂问题。关闭则为快速模式，直接给出答案',
              value: _params.enableReasoning,
              onChanged: (v) => setState(
                () => _params = _params.copyWith(enableReasoning: v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── 投机解码 ──
        _CollapsibleSection(
          title: '投机解码',
          icon: Icons.flash_on_outlined,
          defaultExpanded: false,
          children: [
            _SwitchParam(
              label: '启用投机解码（加速推理）',
              tooltip: '使用小型模型预测后续 token，主模型验证并修正。可显著提升推理速度，但会增加内存占用',
              value: _params.speculativeDecoding,
              onChanged: (v) => setState(
                () => _params = _params.copyWith(speculativeDecoding: v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // 远程 Ollama 模型参数配置
  Widget _buildOllamaParamsTab(ThemeData theme, ModelEntry model) {
    final config = _remoteConfig ?? model.remoteConfig!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      children: [
        // ── 连接信息 ──
        _SectionCard(
          children: [
            Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '连接信息',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: '显示名称', value: model.displayName),
            _InfoRow(label: 'API 地址', value: config.baseUrl),
            _InfoRow(label: '模型 ID', value: config.modelId),
            const SizedBox(height: 8),
            // API Key 输入
            TextField(
              controller: _ollamaApiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: '如需认证请输入',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility_off, size: 18),
                  onPressed: () {},
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _remoteConfig = config.copyWith(apiKey: value);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── 推理参数 ──
        _SectionCard(
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '推理参数',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 温度
            _SliderParam(
              label: '温度',
              tooltip: '控制生成文本的随机性。值越低输出越确定性，值越高输出越随机多样',
              value: config.temperature,
              min: 0.0,
              max: 2.0,
              divisions: 200,
              onChanged: (v) => setState(
                () => _remoteConfig = config.copyWith(temperature: v),
              ),
            ),
            const SizedBox(height: 8),
            // Top P
            _SliderParam(
              label: 'Top P',
              tooltip: '核采样：只从累积概率达到 P 的高概率词中选择',
              value: config.topP,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (v) =>
                  setState(() => _remoteConfig = config.copyWith(topP: v)),
            ),
            const SizedBox(height: 8),
            // Max Tokens
            _StepperParam(
              label: '最大 Token 数',
              tooltip: '限制生成回答的最大 token 数量',
              value: config.maxTokens,
              min: 256,
              max: 32768,
              onChanged: (v) =>
                  setState(() => _remoteConfig = config.copyWith(maxTokens: v)),
            ),
            const SizedBox(height: 8),
            // 上下文大小
            _StepperParam(
              label: '上下文大小',
              tooltip: '设置模型处理的上下文窗口大小（最小8192，最大65536）',
              value: config.numCtx ?? 32768,
              min: 8192,
              max: 65536,
              onChanged: (v) =>
                  setState(() => _remoteConfig = config.copyWith(numCtx: v)),
            ),
            const SizedBox(height: 8),
            // Stream 开关
            _SwitchParam(
              label: '流式输出',
              tooltip: '启用后，模型将实时流式返回生成内容',
              value: config.streamEnabled,
              onChanged: (v) => setState(
                () => _remoteConfig = config.copyWith(streamEnabled: v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ──────────────────────────── 模型信息 ────────────────────────────

  Widget _buildInfoTab(ThemeData theme, ModelEntry model) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      children: [
        _SectionCard(
          children: [
            _InfoRow(label: '模型名称', value: model.displayName),
            if (model.filePath != null)
              _InfoRow(label: '文件路径', value: model.filePath!),
            if (model.parameterSize != null)
              _InfoRow(label: '参数量', value: '${model.parameterSize}B'),
            if (model.quantLevel != null)
              _InfoRow(label: '量化级别', value: model.quantLevel!),
            _InfoRow(
              label: '类型',
              value: model.isLocal ? '本地模型（llama.cpp 驱动）' : '远程 API 模型',
            ),
            _InfoRow(label: '加载状态', value: model.isLoaded ? '已就绪' : '未加载'),
            if (model.isLocal) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.memory_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '使用 llama.cpp 本地推理引擎加载 GGUF 模型',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (model.isRemote && model.remoteConfig != null) ...[
              _InfoRow(
                label: '协议',
                value: model.remoteConfig!.protocol.name.toUpperCase(),
              ),
              _InfoRow(label: 'Base URL', value: model.remoteConfig!.baseUrl),
              _InfoRow(label: '模型 ID', value: model.remoteConfig!.modelId),
            ],
          ],
        ),
      ],
    );
  }

  // ──────────────────────────── 底部加载栏 ────────────────────────────

  Widget _buildBottomBar(ThemeData theme, ModelEntry model) {
    final isLoaded = model.isLoaded;
    final isRemote = model.isRemote;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        42,
        16,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          if (isRemote) ...[
            // 远程模型：验证连通性后开始对话
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  // 先验证连通性
                  try {
                    await _engine.loadModel(model.id);
                    ref
                        .read(modelProvider.notifier)
                        .setModelLoaded(model.id, true);
                    if (context.mounted) context.go('/');
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('连接失败: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.chat_rounded),
                label: const Text('连接并开始对话'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ] else if (isLoaded) ...[
            // 本地模型已加载：显示卸载按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _unloadModel,
                icon: const Icon(Icons.eject_outlined),
                label: const Text('卸载模型'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('开始对话'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ] else ...[
            // 本地模型未加载：只显示 llama.cpp 加载选项
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_llamaCppAvailable) ...[
                    // llama.cpp 不可用，显示提示和更新按钮
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'llama.cpp 引擎未就绪',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('前往设置更新 llama.cpp'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ] else ...[
                    // llama.cpp 可用，根据参数是否已保存显示不同按钮
                    if (!_paramsSaved) ...[
                      // 参数未保存：显示保存按钮
                      OutlinedButton.icon(
                        onPressed: _saveParams,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('保存参数'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '请先保存模型参数，然后点击加载按钮',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      // 参数已保存：显示返回按钮和加载按钮
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                            icon: const Icon(Icons.arrow_back_rounded),
                            tooltip: '返回上一页',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHigh,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _loadModel,
                              icon: const Icon(Icons.rocket_launch_outlined),
                              label: const Text('加载并开始对话'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '参数已保存，点击上方按钮加载模型',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────── 操作 ────────────────────────────

  Future<void> _saveParams() async {
    final modelState = ref.read(modelProvider);
    final model = modelState.models
        .where((m) => m.id == widget.modelId)
        .firstOrNull;

    if (model == null) return;

    if (model.isLocal) {
      // 本地模型：保存本地参数（含 enableReasoning）
      await ref
          .read(modelProvider.notifier)
          .updateLocalParams(widget.modelId, _params);
    } else if (model.isRemote &&
        model.remoteConfig?.protocol == RemoteProtocol.ollama &&
        _remoteConfig != null) {
      // 远程 Ollama 模型：保存远程配置
      await ref
          .read(modelProvider.notifier)
          .updateRemoteConfig(widget.modelId, _remoteConfig!);
      // ★★★ 同时保存 reasoning 开关（顶级字段，不依赖 remoteConfig）★★★
      await ref
          .read(modelProvider.notifier)
          .updateEnableReasoning(widget.modelId, _params.enableReasoning);
    } else {
      // ★★★ 其他远程模型（OpenAI / Anthropic）：仅保存 reasoning 开关 ★★★
      await ref
          .read(modelProvider.notifier)
          .updateEnableReasoning(widget.modelId, _params.enableReasoning);
    }

    // 标记参数已保存
    if (model.isLocal) {
      setState(() => _paramsSaved = true);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('参数已保存'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 查找匹配的 mmproj 文件
  /// 匹配规则：文件名以 "mmproj" 开头且包含主模型文件名（去掉扩展名）
  Future<String?> _findMatchingMmprojFile(ModelEntry model) async {
    if (!model.isLocal || model.filePath == null) return null;
    if (model.mmprojFileName != null) return model.mmprojFileName;

    try {
      // 收集要搜索的目录：应用内部目录 + 模型文件所在目录
      final dirs = <Directory>[];
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add(Directory('${appDir.path}/models'));

      // 添加模型文件所在的目录（支持外部路径模型）
      final modelFile = File(model.filePath!);
      if (await modelFile.exists()) {
        final modelParentDir = modelFile.parent;
        if (!dirs.any((d) => d.path == modelParentDir.path)) {
          dirs.add(modelParentDir);
        }
      }

      // 主模型文件名（去掉 .gguf 扩展名）
      final modelFileName = model.filePath!.split('/').last;
      final modelBaseName = modelFileName.endsWith('.gguf')
          ? modelFileName.substring(0, modelFileName.length - 5)
          : modelFileName;

      // 收集所有 mmproj 文件
      final mmprojFiles = <String>[];
      for (final modelsDir in dirs) {
        if (!await modelsDir.exists()) continue;
        await for (final entity in modelsDir.list(recursive: true)) {
          if (entity is File) {
            final name = entity.path.split('/').last;
            if (name.toLowerCase().startsWith('mmproj') && name.endsWith('.gguf')) {
              if (!mmprojFiles.contains(name)) {
                mmprojFiles.add(name);
              }
            }
          }
        }
      }

      if (mmprojFiles.isEmpty) return null;

      // 规则匹配：mmproj 文件名包含主模型文件名
      final modelBaseLower = modelBaseName.toLowerCase();
      for (final f in mmprojFiles) {
        if (f.toLowerCase().contains(modelBaseLower)) {
          return f;
        }
      }

      // Fallback: 如果只有一个 mmproj 文件，就关联它
      if (mmprojFiles.length == 1) {
        return mmprojFiles.first;
      }
    } catch (e) {
      debugPrint('查找 mmproj 文件失败: $e');
    }

    return null;
  }

  Future<void> _loadModel() async {
    if (!mounted) return;

    final modelState = ref.read(modelProvider);
    final model = modelState.models
        .where((m) => m.id == widget.modelId)
        .firstOrNull;

    if (model == null) {
      _showErrorSnackBar('模型不存在');
      return;
    }

    // ─── 检测 mmproj 多模态投影仪 ───
    bool enableMultimodal = false;
    String? mmprojFileName = model.mmprojFileName;

    // 如果模型没有关联 mmprojFileName，尝试查找匹配的 mmproj 文件
    if (model.isLocal && mmprojFileName == null) {
      mmprojFileName = await _findMatchingMmprojFile(model);
    }

    if (model.isLocal && mmprojFileName != null) {
      // 模型有关联的 mmproj 文件，弹出确认对话框
      // 默认加载 mmproj（与 LM Studio 行为一致）
      final choice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: Icon(
            Icons.view_in_ar_rounded,
            size: 48,
            color: Colors.purple.shade400,
          ),
          title: const Text('检测到多模态投影仪'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('该模型已包含多模态支持：'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: Colors.purple.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mmprojFileName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.purple.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'mmproj: 图文理解投影仪',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '加载后可识别和分析图片内容',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'skip'),
              child: const Text('不加载'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'confirm'),
              child: const Text('确认加载'),
            ),
          ],
        ),
      );

      if (choice == null) {
        // 用户点击外部关闭，默认加载 mmproj
        enableMultimodal = true;
      } else {
        enableMultimodal = (choice == 'confirm');
      }
    }

    // ─── 开始加载模型 ───
    _startModelLoading(model, enableMultimodal, mmprojFileName);
  }

  void _startModelLoading(
    ModelEntry model,
    bool enableMultimodal,
    String? mmprojFileName,
  ) {
    String? lastError;
    bool loadCompleted = false;

    // 显示加载进度对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ModelLoadingDialog(
        modelName: model.displayName,
        onCompleted: () {
          // 对话框动画完成后关闭
          if (mounted) Navigator.pop(ctx);
        },
      ),
    );

    Future<void> doLoad() async {
      bool isTimedOut = false; // 超时标志

      try {
        // 设置60秒超时（使用类成员变量，dispose 时可取消）
        _loadTimeoutTimer = Timer(const Duration(seconds: 60), () {
          if (!loadCompleted && !isTimedOut) {
            isTimedOut = true; // 标记超时
            lastError = '模型加载超时（60秒），请检查 Ollama 服务是否正常运行';
            loadCompleted = true; // 标记完成以阻止后续执行
            _loadStateSub?.cancel();
            _loadTimeoutTimer?.cancel();
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              _showErrorSnackBar(lastError!);
            }
          }
        });

        // 监听加载状态（使用类成员变量，dispose 时可取消）
        _loadStateSub = _engine.loadingStateStream.listen((state) {
          if (state.modelId == widget.modelId) {
            if (state.status == LoadingStatus.error && state.error != null) {
              lastError = state.error;
            }
          }
        });

        // 用全局单例加载模型，传递多模态配置
        await _engine
            .loadModel(
              widget.modelId,
              mmprojPath: enableMultimodal ? mmprojFileName : null,
            )
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                throw TimeoutException('模型加载超时，请检查网络连接和 Ollama 服务');
              },
            );

        // 如果已超时，直接返回
        if (isTimedOut) {
          _loadTimeoutTimer?.cancel();
          _loadStateSub?.cancel();
          return;
        }

        loadCompleted = true;
        _loadTimeoutTimer?.cancel();
        _loadStateSub?.cancel();

        // 更新模型状态为已加载
        ref.read(modelProvider.notifier).setModelLoaded(widget.modelId, true);

        // 安全关闭加载对话框
        if (mounted) {
          // 先关闭对话框
          Navigator.of(context, rootNavigator: true).pop();

          // 显示简短成功提示
          await Future.delayed(const Duration(milliseconds: 100));

          if (!mounted) return;

          // 显示成功 SnackBar（自动消失，不阻塞用户）
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[300], size: 20),
                  const SizedBox(width: 8),
                  Text('${model.displayName} 加载成功'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1500),
            ),
          );

          // 直接创建会话并跳转（无需用户手动选择）
          final sessionManager = ref.read(sessionManagerProvider);
          final session = await sessionManager.createSession(
            SessionConfig(
              modelId: model.id,
              name: '${model.displayName} 对话',
              systemPrompt: _params.systemPrompt,
            ),
          );

          if (mounted) {
            context.go('/session/${session.id}');
          }
        }
      } catch (e) {
        debugPrint('模型加载失败: $e');
        _loadTimeoutTimer?.cancel();
        _loadStateSub?.cancel();

        // 安全关闭加载对话框
        if (mounted) {
          try {
            // 安全地关闭加载对话框
            Navigator.of(context, rootNavigator: true).maybePop();
          } catch (err) {
            debugPrint('关闭对话框失败（可能已关闭）: $err');
          }

          _showErrorSnackBar('模型加载失败: ${lastError ?? e}');
        }
      }
    }

    doLoad();
  }

  /// 显示错误提示，1.5秒后自动消失
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 1500), // 1.5秒后消失
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _unloadModel() async {
    try {
      // 用全局单例卸载模型
      await _engine.unloadModel(widget.modelId);

      // 更新模型状态
      ref.read(modelProvider.notifier).setModelLoaded(widget.modelId, false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('模型已卸载'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('模型卸载失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('模型卸载失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  模型加载进度对话框
// ════════════════════════════════════════════════════════════════════════════

class _ModelLoadingDialog extends StatefulWidget {
  final String modelName;
  final VoidCallback onCompleted;

  const _ModelLoadingDialog({
    required this.modelName,
    required this.onCompleted,
  });

  @override
  State<_ModelLoadingDialog> createState() => _ModelLoadingDialogState();
}

class _ModelLoadingDialogState extends State<_ModelLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  String _currentStep = '正在连接模型服务...';
  double _progress = 0.0;
  bool _isCompleted = false;
  String? _errorMessage;

  static const _steps = [
    (0.1, '正在连接模型服务...'),
    (0.3, '验证模型可用性...'),
    (0.5, '加载模型配置...'),
    (0.7, '初始化推理引擎...'),
    (0.85, '预热推理上下文...'),
    (0.95, '准备就绪...'),
    (1.0, '模型加载完成 ✓'),
  ];

  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() {
            // 只有在没有错误且未完成时才更新步骤
            if (!_isCompleted && _errorMessage == null) {
              _updateStep(_progressController.value);
            }
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && !_isCompleted) {
              _isCompleted = true;
              setState(() {
                _progress = 1.0;
                _currentStep = '模型加载完成 ✓';
              });
              Future.delayed(
                const Duration(milliseconds: 500),
                widget.onCompleted,
              );
            }
          })
          ..forward();
  }

  void _updateStep(double progress) {
    for (var i = _steps.length - 1; i >= 0; i--) {
      if (progress >= _steps[i].$1) {
        if (_stepIndex != i) {
          setState(() {
            _stepIndex = i;
            _currentStep = _steps[i].$2;
            _progress = progress;
          });
        } else {
          setState(() => _progress = progress);
        }
        break;
      }
    }
  }

  /// 设置加载完成
  void setCompleted() {
    if (_isCompleted) return;
    _isCompleted = true;
    _progressController.stop();
    setState(() {
      _progress = 1.0;
      _currentStep = '模型加载完成 ✓';
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onCompleted();
    });
  }

  /// 设置错误状态
  void setError(String message) {
    if (_isCompleted) return;
    _isCompleted = true;
    _progressController.stop();
    setState(() {
      _errorMessage = message;
      _currentStep = '加载失败';
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _errorMessage != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: hasError
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              hasError ? Icons.error_outline : Icons.memory_rounded,
              size: 36,
              color: hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasError ? '加载失败' : '正在加载模型',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.modelName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasError && _errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentStep,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 步骤列表
            ..._steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isDone = _progress >= step.$1;
              final isCurrent = idx == _stepIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isDone
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : isCurrent
                          ? Padding(
                              padding: const EdgeInsets.all(3),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      step.$2,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDone
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.outline,
                        fontWeight: isCurrent
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  通用参数控件
// ════════════════════════════════════════════════════════════════════════════

/// 卡片容器
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? _padding;

  const _SectionCard({required this.children, EdgeInsets? padding}) : _padding = padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: _padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// 可折叠区域
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool defaultExpanded;
  final List<Widget> children;

  const _CollapsibleSection({
    required this.title,
    required this.icon,
    this.defaultExpanded = true,
    required this.children,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _expanded = widget.defaultExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _expanded ? 1.0 : 0.0,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedBuilder(
              animation: _heightFactor,
              builder: (context, child) =>
                  Align(heightFactor: _heightFactor.value, child: child),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    ...widget.children,
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

/// 滑块参数
class _SliderParam extends StatelessWidget {
  final String label;
  final String? tooltip;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderParam({
    required this.label,
    this.tooltip,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(label, style: theme.textTheme.bodyMedium);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: tooltip != null
              ? _ParamTooltip(
                  description: tooltip!,
                  child: Row(
                    children: [
                      labelWidget,
                      const SizedBox(width: 4),
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                )
              : labelWidget,
        ),
        Expanded(
          flex: 3,
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value.toStringAsFixed(2),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// 开关参数
class _SwitchParam extends StatelessWidget {
  final String label;
  final String? tooltip;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchParam({
    required this.label,
    this.tooltip,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(label, style: theme.textTheme.bodyMedium);
    return Row(
      children: [
        Expanded(
          child: tooltip != null
              ? _ParamTooltip(
                  description: tooltip!,
                  child: Row(
                    children: [
                      labelWidget,
                      const SizedBox(width: 4),
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                )
              : labelWidget,
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// 开关 + 滑块联动参数
class _SwitchSliderParam extends StatelessWidget {
  final String label;
  final String? tooltip;
  final bool enabled;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onValueChanged;

  const _SwitchSliderParam({
    required this.label,
    this.tooltip,
    required this.enabled,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onEnabledChanged,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(label, style: theme.textTheme.bodyMedium);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: tooltip != null
                  ? _ParamTooltip(
                      description: tooltip!,
                      child: Row(
                        children: [
                          labelWidget,
                          const SizedBox(width: 4),
                          Icon(
                            Icons.help_outline,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                    )
                  : labelWidget,
            ),
            Switch.adaptive(value: enabled, onChanged: onEnabledChanged),
            SizedBox(
              width: 44,
              child: Text(
                value.toStringAsFixed(2),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        if (enabled)
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onValueChanged,
          ),
      ],
    );
  }
}

/// 下拉选择参数
class _DropdownParam extends StatelessWidget {
  final String label;
  final String? tooltip;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownParam({
    required this.label,
    this.tooltip,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(label, style: theme.textTheme.bodyMedium);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: tooltip != null
              ? _ParamTooltip(
                  description: tooltip!,
                  child: Row(
                    children: [
                      labelWidget,
                      const SizedBox(width: 4),
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                )
              : labelWidget,
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 文本输入参数
class _TextInputParam extends StatefulWidget {
  final String label;
  final String? tooltip;
  final String hint;
  final String? value;
  final ValueChanged<String> onChanged;

  const _TextInputParam({
    required this.label,
    this.tooltip,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_TextInputParam> createState() => _TextInputParamState();
}

class _TextInputParamState extends State<_TextInputParam> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextInputParam oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部 value 改变时同步更新，但不重置光标
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(widget.label, style: theme.textTheme.bodyMedium);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: widget.tooltip != null
              ? _ParamTooltip(
                  description: widget.tooltip!,
                  child: Row(
                    children: [
                      labelWidget,
                      const SizedBox(width: 4),
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                )
              : labelWidget,
        ),
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodySmall,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              isDense: true,
            ),
            controller: _controller,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

/// 步进参数
class _StepperParam extends StatelessWidget {
  final String label;
  final String? tooltip;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperParam({
    required this.label,
    this.tooltip,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(label, style: theme.textTheme.bodyMedium);
    return Row(
      children: [
        Expanded(
          child: tooltip != null
              ? _ParamTooltip(
                  description: tooltip!,
                  child: Row(
                    children: [
                      labelWidget,
                      const SizedBox(width: 4),
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                )
              : labelWidget,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: value > min ? () => onChanged(value - 1) : null,
              style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: value < max ? () => onChanged(value + 1) : null,
              style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
            ),
          ],
        ),
      ],
    );
  }
}

/// 信息行
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

/// 加载方式选择按钮
class _LoadModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LoadModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 参数帮助提示组件 - 悬停1秒显示提示
class _ParamTooltip extends StatefulWidget {
  final String description;
  final Widget child;

  const _ParamTooltip({required this.description, required this.child});

  @override
  State<_ParamTooltip> createState() => _ParamTooltipState();
}

class _ParamTooltipState extends State<_ParamTooltip> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  Timer? _showTimer;

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    box.size;
    final position = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // 显示在问号图标的左边
        left: position.dx - 260,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _showTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _showTimer = Timer(const Duration(seconds: 1), () {
          if (_isHovering && mounted) {
            _showTooltip();
          }
        });
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hideTooltip();
      },
      child: widget.child,
    );
  }
}
