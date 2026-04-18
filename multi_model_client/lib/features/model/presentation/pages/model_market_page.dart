import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/providers/model_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/services/model_download_manager.dart' hide DownloadProgress;
import '../../../../core/services/model_download/download_task_manager.dart';
import '../../../../core/services/hardware_compatibility_checker.dart';
import '../../../../core/services/model_download/huggingface_api.dart';
import '../../../../core/services/model_download/modelscope_api.dart' show ModelFile;
import '../../../../core/engines/model_inference_engine.dart';
import '../../../../core/interfaces/session_interface.dart';
import '../../../../features/session/domain/session_manager.dart';

// ════════════════════════════════════════════════════════════════════════════
//  模型市场页（HuggingFace 搜索/详情/下载）
//  路由: /model-market
// ════════════════════════════════════════════════════════════════════════════

class ModelMarketPage extends ConsumerStatefulWidget {
  const ModelMarketPage({super.key});

  @override
  ConsumerState<ModelMarketPage> createState() => _ModelMarketPageState();
}

class _ModelMarketPageState extends ConsumerState<ModelMarketPage> {
  final _searchController = TextEditingController();
  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  late final HuggingFaceApi _hfApi;
  late final HardwareCompatibilityChecker _hardwareChecker;
  late final DownloadTaskManager _taskManager;
  HardwareInfo? _hardwareInfo;

  List<ModelInfo> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  /// 当前正在下载的模型进度 modelId -> DownloadProgress
  final Map<String, DownloadProgress> _downloadProgress = {};

  // 精选推荐模型（手动维护）
  final _featuredHF = const [
    _FeaturedModel(
      id: 'bartowski/Qwen2.5-7B-Instruct-GGUF',
      name: 'Qwen2.5 7B Instruct',
      author: 'Qwen / bartowski',
      params: '7B',
      quantLevel: 'Q4_K_M',
      description: '通义千问 2.5 7B 指令微调版，中英双语，GGUF 量化',
      minRam: 6,
      minStorage: 5,
    ),
    _FeaturedModel(
      id: 'bartowski/Llama-3.2-3B-Instruct-GGUF',
      name: 'Llama 3.2 3B Instruct',
      author: 'Meta / bartowski',
      params: '3B',
      quantLevel: 'Q4_K_M',
      description: 'Meta 最新轻量级指令模型，移动端友好',
      minRam: 3,
      minStorage: 2,
    ),
    _FeaturedModel(
      id: 'bartowski/Mistral-7B-Instruct-v0.3-GGUF',
      name: 'Mistral 7B Instruct v0.3',
      author: 'Mistral / bartowski',
      params: '7B',
      quantLevel: 'Q4_K_M',
      description: '高性能英文推理模型，速度快，质量好',
      minRam: 6,
      minStorage: 5,
    ),
    _FeaturedModel(
      id: 'bartowski/gemma-2-9b-it-GGUF',
      name: 'Gemma 2 9B IT',
      author: 'Google / bartowski',
      params: '9B',
      quantLevel: 'Q4_K_M',
      description: 'Google Gemma 2 指令微调版，多任务表现优秀',
      minRam: 8,
      minStorage: 6,
    ),
  ];

  final _featuredMS = const [
    _FeaturedModel(
      id: 'Qwen/Qwen2.5-7B-Instruct-GGUF',
      name: 'Qwen2.5 7B Instruct GGUF',
      author: 'Qwen',
      params: '7B',
      quantLevel: 'Q4_K_M',
      description: '官方通义千问 2.5 GGUF 版本，国内下载速度快',
      minRam: 6,
      minStorage: 5,
    ),
    _FeaturedModel(
      id: 'LLM-Research/Meta-Llama-3.1-8B-Instruct-GGUF',
      name: 'Llama 3.1 8B Instruct',
      author: 'LLM-Research',
      params: '8B',
      quantLevel: 'Q4_K_M',
      description: 'Meta Llama 3.1 8B 指令版 GGUF',
      minRam: 7,
      minStorage: 5,
    ),
    _FeaturedModel(
      id: 'BAAI/bge-small-zh-v1.5-gguf',
      name: 'BGE Small ZH v1.5',
      author: 'BAAI',
      params: '0.3B',
      quantLevel: 'Q8_0',
      description: '中文向量嵌入模型，RAG 场景适用',
      minRam: 1,
      minStorage: 1,
    ),
    _FeaturedModel(
      id: 'internlm/internlm2_5-7b-chat-gguf',
      name: 'InternLM 2.5 7B Chat',
      author: 'Shanghai AI Lab',
      params: '7B',
      quantLevel: 'Q4_K_M',
      description: '书生浦语 2.5 7B 对话版，中英双语强',
      minRam: 6,
      minStorage: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _hfApi = HuggingFaceApi(_dio);
    _hardwareChecker = HardwareCompatibilityChecker();
    _taskManager = DownloadTaskManager(_dio);
    _loadHardwareInfo();
    _loadDownloadProgress();
  }

  Future<void> _loadHardwareInfo() async {
    _hardwareInfo = await _hardwareChecker.getHardwareInfo();
    if (mounted) setState(() {});
  }

  /// 加载下载进度
  Future<void> _loadDownloadProgress() async {
    // 监听下载任务管理器进度
    _taskManager.progressNotifier.addListener(_onDownloadProgress);
    // 加载已有任务
    final tasks = await _taskManager.getAllTasks();
    for (final task in tasks) {
      if (task.status == 'downloading' || task.status == 'pending') {
        // 重新开始监听进度
        final progress = _taskManager.progressNotifier.value[task.id];
        if (progress != null && mounted) {
          setState(() {
            _downloadProgress[task.modelId] = DownloadProgress(
              taskId: task.id,
              modelId: task.modelId,
              totalBytes: progress.totalBytes,
              downloadedBytes: progress.downloadedBytes,
              progress: progress.progress,
              status: progress.status,
            );
          });
        }
      }
    }
  }

  void _onDownloadProgress() {
    if (!mounted) return;
    final progressMap = _taskManager.progressNotifier.value;
    setState(() {
      for (final entry in progressMap.entries) {
        final taskId = entry.key;
        final progress = entry.value;
        // 通过 taskId 查找 modelId
        _downloadProgress[progress.modelId] = DownloadProgress(
          taskId: taskId,
          modelId: progress.modelId,
          totalBytes: progress.totalBytes,
          downloadedBytes: progress.downloadedBytes,
          progress: progress.progress,
          status: progress.status,
        );
      }
    });
  }

  @override
  void dispose() {
    _taskManager.progressNotifier.removeListener(_onDownloadProgress);
    _searchController.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('模型市场'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // 下载管理按钮
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: '下载管理',
            onPressed: () => context.push('/downloads'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          _buildSearchBar(theme),
          // 内容区
          Expanded(
            child: _buildContent(theme, ModelSource.huggingFace),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'e.g. llama, qwen, mistral, gemma...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: _isLoading ? null : () => _search(_searchController.text),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ModelSource source) {
    if (_error != null) {
      return _buildError(theme);
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isNotEmpty) {
      return _buildSearchResults(theme);
    }

    // 精选推荐 - 只保留 HuggingFace
    return _buildFeatured(theme, _featuredHF, source);
  }

  Widget _buildFeatured(
      ThemeData theme, List<_FeaturedModel> featured, ModelSource source) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('精选推荐', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  source == ModelSource.huggingFace
                      ? '适合本地部署的 GGUF 量化模型'
                      : '国内下载速度快，中文能力强的模型',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FeaturedModelCard(
                  featured: featured[i],
                  downloadProgress: _downloadProgress[featured[i].id],
                  onDetail: () => _showModelDetail(context, featured[i].id, source),
                  onDownload: () => _downloadFeatured(context, featured[i], source),
                ),
              ),
              childCount: featured.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final model = _searchResults[i];
        return _SearchResultCard(
          model: model,
          downloadProgress: _downloadProgress[model.id],
          hardwareInfo: _hardwareInfo,
          onDetail: () => _showModelDetailFromInfo(context, model),
          onDownload: () => _downloadModel(context, model),
        );
      },
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('搜索失败', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => setState(() => _error = null),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── 搜索 ────────────────────────────

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 只搜索 HuggingFace
      final results = await _hfApi.searchModels(
        query: query,
        limit: 30,
        filter: 'gguf', // 只搜 gguf 格式
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ──────────────────────────── 下载 ────────────────────────────

  Future<void> _downloadFeatured(
      BuildContext context, _FeaturedModel featured, ModelSource source) async {
    final modelInfo = ModelInfo(
      id: featured.id,
      name: featured.name,
      description: featured.description,
      author: featured.author,
      source: ModelSource.huggingFace,
      downloadUrl: _hfApi.getDownloadUrl(featured.id, '${featured.name}-${featured.quantLevel}.gguf'),
      minRamGB: featured.minRam,
      minStorageGB: featured.minStorage,
      parameterSize: int.tryParse(featured.params.replaceAll('B', '')) ?? 0,
      isQuantized: true,
      quantizationMethod: featured.quantLevel,
    );

    await _downloadModel(context, modelInfo);
  }

  Future<void> _downloadModel(BuildContext context, ModelInfo model) async {
    debugPrint('开始下载流程: ${model.name}, URL: ${model.downloadUrl}');
    
    // 显示下载确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DownloadConfirmDialog(model: model),
    );

    debugPrint('用户确认下载: $confirmed, context.mounted: ${context.mounted}');
    
    if (confirmed != true) {
      debugPrint('用户取消下载或对话框关闭');
      return;
    }
    
    if (!context.mounted) {
      debugPrint('context 未挂载，无法继续');
      return;
    }

    // 使用 DownloadTaskManager 开始下载
    try {
      // 获取下载目录（支持自定义路径）
      final settingsService = SettingsService();
      await settingsService.initialize();
      final downloadDir = await settingsService.getEffectiveDownloadPath();
      
      // 修复：移除 model.id 中的 .gguf 后缀作为目录名，避免路径重复
      final modelDirName = model.id.replaceAll('/', '_').replaceAll(RegExp(r'\.gguf$', caseSensitive: false), '');
      final modelDir = '$downloadDir/$modelDirName';
      final fileName = model.downloadUrl.split('/').last;
      final savePath = '$modelDir/$fileName';
      
      debugPrint('[ModelMarket] 下载路径: $savePath');

      // 创建下载任务
      final task = await _taskManager.createTask(
        modelId: model.id,
        url: model.downloadUrl,
        savePath: savePath,
        source: 'huggingface',
        quantLevel: model.quantizationMethod,
        metadata: {
          'name': model.name,
          'author': model.author,
          'description': model.description,
          'parameterSize': model.parameterSize,
        },
      );

      // 更新 UI 显示下载进度
      setState(() {
        _downloadProgress[model.id] = DownloadProgress(
          taskId: task.id,
          modelId: model.id,
          status: DownloadStatus.downloading,
          progress: 0.0,
          downloadedBytes: 0,
          totalBytes: 0,
        );
      });

      // 开始下载 - 使用 try-catch 包装以捕获异常
      try {
        await _taskManager.startDownload(task.id, onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress[model.id] = DownloadProgress(
                taskId: progress.taskId,
                modelId: progress.modelId,
                status: progress.status,
                progress: progress.progress,
                downloadedBytes: progress.downloadedBytes,
                totalBytes: progress.totalBytes,
              );
            });

            // 下载完成后处理
            if (progress.status == DownloadStatus.completed) {
              _onDownloadCompleted(context, model, savePath);
            } else if (progress.status == DownloadStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('下载失败: ${progress.error ?? "未知错误"}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
      } catch (e) {
        // 下载启动失败
        if (context.mounted) {
          setState(() {
            _downloadProgress[model.id] = DownloadProgress(
              taskId: task.id,
              modelId: model.id,
              status: DownloadStatus.error,
              progress: 0.0,
              downloadedBytes: 0,
              totalBytes: 0,
              error: e.toString(),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('下载启动失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建下载任务失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  HardwareCompatibilityChecker _createHardwareChecker() {
    return HardwareCompatibilityChecker();
  }

  void _onDownloadCompleted(BuildContext context, ModelInfo model, String filePath) async {

    // 添加到本地模型列表
    final addedModel = await ref.read(modelProvider.notifier).addLocalModel(
      displayName: model.name,
      filePath: filePath,
      parameterSize: model.parameterSize > 0 ? model.parameterSize : null,
      quantLevel: model.quantizationMethod,
      description: model.description,
    );

    if (!context.mounted) return;

    // 根据模型类型判断加载环境
    final modelType = _detectModelType(model);
    final loadingMessage = _getLoadingMessage(modelType);

    // 显示下载完成并询问是否立即加载
    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
            const SizedBox(width: 10),
            const Text('下载完成'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.name, style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('模型已成功下载到本地。', style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.memory_rounded, size: 20, color: Theme.of(ctx).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loadingMessage,
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('稍后加载'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('立即加载'),
          ),
        ],
      ),
    );

    if (shouldLoad == true && context.mounted) {
      // 自动加载模型到推理引擎
      try {
        // 显示加载中提示
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('正在加载模型...'),
              ],
            ),
          ),
        );

        // 加载模型到推理引擎
        await globalModelEngine.loadModel(addedModel.id);

        // 更新模型状态为已加载
        ref.read(modelProvider.notifier).setModelLoaded(addedModel.id, true);

        // 关闭加载对话框
        if (context.mounted) {
          Navigator.pop(context);
        }

        // 显示成功提示并询问是否开始对话
        if (context.mounted) {
          final shouldChat = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
                  const SizedBox(width: 10),
                  const Text('模型加载成功'),
                ],
              ),
              content: Text('${model.name} 已加载完成，可以开始对话了。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('稍后再说'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('开始对话'),
                ),
              ],
            ),
          );

          if (shouldChat == true && context.mounted) {
            // 创建新会话并开始对话
            final sessionManager = ref.read(sessionManagerProvider);
            final session = await sessionManager.createSession(
              SessionConfig(modelId: addedModel.id, name: '${model.name} 对话'),
            );
            if (context.mounted) {
              context.go('/session/${session.id}');
            }
          }
        }
      } catch (e) {
        // 关闭加载对话框
        if (context.mounted) {
          Navigator.pop(context);
        }
        
        debugPrint('模型加载失败: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('模型加载失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (context.mounted) {
      // 显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('${model.name} 已添加到模型列表')),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  context.go('/settings/models');
                },
                child: const Text('查看', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 根据模型信息检测模型类型
  String _detectModelType(ModelInfo model) {
    final name = model.name.toLowerCase();
    final tags = model.tags.join(' ').toLowerCase();

    // 检测是否为中文模型
    if (name.contains('qwen') || name.contains('文心') || name.contains('通义') ||
        name.contains('glm') || name.contains('chatglm') || name.contains('internlm')) {
      return '中文优化';
    }

    // 检测是否为代码模型
    if (name.contains('code') || name.contains('coder') || tags.contains('code')) {
      return '代码生成';
    }

    // 检测是否为数学/推理模型
    if (name.contains('math') || name.contains('reasoning') || name.contains('r1') ||
        name.contains('deepseek')) {
      return '数学推理';
    }

    // 默认通用模型
    return '通用对话';
  }

  /// 获取加载提示信息
  String _getLoadingMessage(String modelType) {
    switch (modelType) {
      case '中文优化':
        return '将使用中文语言模型配置加载 (CPU + 8线程)';
      case '代码生成':
        return '将使用代码模型配置加载 (CPU + 4线程, 4096上下文)';
      case '数学推理':
        return '将使用推理模型配置加载 (CPU + 8线程, 8192上下文)';
      default:
        return '将使用默认配置加载模型 (CPU + 6线程)';
    }
  }

  // ──────────────────────────── 详情 ────────────────────────────

  Future<void> _showModelDetail(
      BuildContext context, String modelId, ModelSource source) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ModelDetailSheet(
        modelId: modelId,
        hfApi: _hfApi,
        dio: _dio,
        onDownloadFile: (modelInfo) {
          // 使用原始 context 而不是 builder 的 ctx
          _downloadModel(context, modelInfo);
        },
      ),
    );
  }

  Future<void> _showModelDetailFromInfo(
      BuildContext context, ModelInfo model) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ModelDetailSheet(
        modelId: model.id,
        hfApi: _hfApi,
        dio: _dio,
        onDownloadFile: (modelInfo) => _downloadModel(context, modelInfo),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  精选模型卡片
// ════════════════════════════════════════════════════════════════════════════

class _FeaturedModelCard extends StatelessWidget {
  final _FeaturedModel featured;
  final DownloadProgress? downloadProgress;
  final VoidCallback onDetail;
  final VoidCallback onDownload;

  const _FeaturedModelCard({
    required this.featured,
    this.downloadProgress,
    required this.onDetail,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = downloadProgress;
    final isDownloading = progress?.status == DownloadStatus.downloading;
    final isDone = progress?.status == DownloadStatus.completed;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onDetail,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 图标
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.memory_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featured.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          featured.author,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 操作按钮 - 点击卡片进入详情页下载
                  if (isDone)
                    Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 28)
                  else if (isDownloading)
                    SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(
                        value: progress!.progress,
                        strokeWidth: 3,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                featured.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Tag(featured.params, color: const Color(0xFF6366F1)),
                  const SizedBox(width: 6),
                  _Tag(featured.quantLevel, color: const Color(0xFF0EA5E9)),
                  const SizedBox(width: 6),
                  _Tag('≥ ${featured.minRam}GB RAM', color: Colors.orange.shade700),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 18,
                      color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
              // 下载进度
              if (isDownloading) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress!.progress,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.downloadedMB} / ${progress.totalMB}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  搜索结果卡片
// ════════════════════════════════════════════════════════════════════════════

class _SearchResultCard extends StatelessWidget {
  final ModelInfo model;
  final DownloadProgress? downloadProgress;
  final VoidCallback onDetail;
  final VoidCallback onDownload;
  final HardwareInfo? hardwareInfo;

  const _SearchResultCard({
    required this.model,
    this.downloadProgress,
    required this.onDetail,
    required this.onDownload,
    this.hardwareInfo,
  });

  /// 检查模型是否兼容当前硬件
  bool get _isCompatible {
    if (hardwareInfo == null) return true;
    // 检查内存需求
    if (model.minRamGB > hardwareInfo!.totalRamGB) return false;
    // 检查存储需求
    if (model.minStorageGB > hardwareInfo!.availableStorageGB) return false;
    return true;
  }

  /// 获取不兼容的原因
  List<String> get _incompatibleReasons {
    final reasons = <String>[];
    if (hardwareInfo == null) return reasons;
    if (model.minRamGB > hardwareInfo!.totalRamGB) {
      reasons.add('需要 ${model.minRamGB}GB 内存（当前 ${hardwareInfo!.totalRamGB}GB）');
    }
    if (model.minStorageGB > hardwareInfo!.availableStorageGB) {
      reasons.add('需要 ${model.minStorageGB}GB 存储（当前 ${hardwareInfo!.availableStorageGB}GB 可用）');
    }
    return reasons;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = downloadProgress;
    final isDownloading = progress?.status == DownloadStatus.downloading;
    final isDone = progress?.status == DownloadStatus.completed;
    final isCompatible = _isCompatible;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onDetail,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 硬件兼容性图标
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isCompatible 
                          ? theme.colorScheme.primaryContainer
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompatible ? Icons.smart_toy_outlined : Icons.warning_amber_rounded,
                      color: isCompatible ? theme.colorScheme.primary : Colors.orange.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          model.author,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDone)
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 26)
                  else if (isDownloading)
                    SizedBox(
                      width: 26, height: 26,
                      child: CircularProgressIndicator(
                        value: progress!.progress, strokeWidth: 3),
                    )
                  else
                    Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
              // 不兼容警告
              if (!isCompatible) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '超过当前配置: ${_incompatibleReasons.join(", ")}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.orange.shade800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (model.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  model.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: [
                  if (model.parameterSize > 0) _Tag('${model.parameterSize}B', color: const Color(0xFF6366F1)),
                  if (model.isQuantized) _Tag(model.quantizationMethod ?? 'GGUF', color: const Color(0xFF0EA5E9)),
                  _Tag('≥${model.minRamGB}GB', color: Colors.orange.shade700),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_rounded, size: 12, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('${_formatCount(model.downloads)}',
                          style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
              if (isDownloading) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress!.progress, borderRadius: BorderRadius.circular(4)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  模型详情 Bottom Sheet（文件列表 + 下载）
// ════════════════════════════════════════════════════════════════════════════

class _ModelDetailSheet extends StatefulWidget {
  final String modelId;
  final HuggingFaceApi hfApi;
  final Dio dio;
  final Function(ModelInfo) onDownloadFile;

  const _ModelDetailSheet({
    required this.modelId,
    required this.hfApi,
    required this.dio,
    required this.onDownloadFile,
  });

  @override
  State<_ModelDetailSheet> createState() => _ModelDetailSheetState();
}

class _ModelDetailSheetState extends State<_ModelDetailSheet> {
  ModelInfo? _model;
  List<ModelFile> _files = [];
  bool _isLoading = true;
  String? _error;
  String? _readme;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      // 只获取 HuggingFace 模型信息
      final model = await widget.hfApi.getModel(widget.modelId);
      final files = await widget.hfApi.getModelFiles(widget.modelId);
      final readme = await widget.hfApi.getModelReadme(widget.modelId);
      if (mounted) {
        setState(() {
          _model = model;
          _files = files.where((f) => f.isGguf).toList();
          _readme = readme;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, controller) {
        return Column(
          children: [
            // 拖动把手
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text('加载失败'),
                      Text(_error!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // 模型头部信息
                    if (_model != null) _buildModelHeader(theme, _model!),
                    const SizedBox(height: 20),
                    // GGUF 文件列表
                    if (_files.isNotEmpty) ...[
                      Text(
                        'GGUF 文件 (${_files.length})',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ..._files.map((f) => _buildFileRow(theme, f)),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text('未找到 GGUF 量化文件，此模型可能不支持本地部署'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // README
                    if (_readme != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        '模型简介',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _readme!.length > 800
                            ? '${_readme!.substring(0, 800)}...'
                            : _readme!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModelHeader(ThemeData theme, ModelInfo model) {
    return Row(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.memory_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                model.author,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileRow(ThemeData theme, ModelFile file) {
    final sizeGB = file.size > 0 ? (file.size / 1024 / 1024 / 1024).toStringAsFixed(1) : '?';
    final quantLevel = _extractQuantLevel(file.path);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // 只使用 HuggingFace
            final downloadUrl = widget.hfApi.getDownloadUrl(widget.modelId, file.path);

            // 先关闭 BottomSheet，再触发下载
            Navigator.pop(context);
            
            // 等待一帧确保 BottomSheet 关闭
            await Future.delayed(const Duration(milliseconds: 100));
            
            widget.onDownloadFile(ModelInfo(
              id: '${widget.modelId}/${file.path}',
              name: '${_model?.name ?? widget.modelId} ($quantLevel)',
              description: _model?.description ?? '',
              author: _model?.author ?? '',
              source: ModelSource.huggingFace,
              downloadUrl: downloadUrl,
              minRamGB: _estimateRamForQuant(quantLevel),
              minStorageGB: file.size > 0 ? (file.size / 1024 / 1024 / 1024).ceil() : 4,
              parameterSize: _model?.parameterSize ?? 0,
              isQuantized: true,
              quantizationMethod: quantLevel,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined, size: 20, color: Color(0xFF6366F1)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.path.split('/').last,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (quantLevel.isNotEmpty)
                        Row(
                          children: [
                            _Tag(quantLevel, color: const Color(0xFF0EA5E9)),
                            const SizedBox(width: 6),
                            Text(
                              '$sizeGB GB',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(Icons.download_rounded, size: 20, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _extractQuantLevel(String path) {
    final levels = ['Q8_0', 'Q6_K', 'Q5_K_M', 'Q5_K_S', 'Q4_K_M', 'Q4_K_S', 'Q3_K_M', 'Q2_K', 'IQ4_XS'];
    for (final level in levels) {
      if (path.toUpperCase().contains(level)) return level;
    }
    return 'GGUF';
  }

  int _estimateRamForQuant(String quantLevel) {
    if (quantLevel.contains('Q2')) return 3;
    if (quantLevel.contains('Q3')) return 4;
    if (quantLevel.contains('Q4')) return 5;
    if (quantLevel.contains('Q5')) return 6;
    if (quantLevel.contains('Q6')) return 7;
    if (quantLevel.contains('Q8')) return 9;
    return 6;
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  下载确认对话框
// ════════════════════════════════════════════════════════════════════════════

class _DownloadConfirmDialog extends StatefulWidget {
  final ModelInfo model;
  const _DownloadConfirmDialog({required this.model});

  @override
  State<_DownloadConfirmDialog> createState() => _DownloadConfirmDialogState();
}

class _DownloadConfirmDialogState extends State<_DownloadConfirmDialog> {
  bool _isChecking = true;
  CompatibilityResult? _compatibilityResult;
  HardwareInfo? _hardwareInfo;

  @override
  void initState() {
    super.initState();
    _checkCompatibility();
  }

  Future<void> _checkCompatibility() async {
    final checker = HardwareCompatibilityChecker();
    try {
      final hardware = await checker.getHardwareInfo();
      final result = await checker.checkModelCompatibility(
        minRamGB: widget.model.minRamGB,
        minStorageGB: widget.model.minStorageGB,
      );
      if (mounted) {
        setState(() {
          _hardwareInfo = hardware;
          _compatibilityResult = result;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompatible = _compatibilityResult?.isCompatible ?? true;
    final hasWarnings = (_compatibilityResult?.warnings ?? []).isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(isCompatible ? Icons.download_rounded : Icons.warning_rounded,
              color: isCompatible ? theme.colorScheme.primary : theme.colorScheme.error),
          const SizedBox(width: 10),
          Text(isCompatible ? '下载模型' : '⚠️ 设备兼容性问题'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.model.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.model.author, style: theme.textTheme.bodySmall),
            const Divider(height: 20),
            if (_isChecking)
              const Center(child: Column(children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(height: 12), Text('正在检测设备兼容性...')]))
            else ...[
              if (_hardwareInfo != null) ...[
                _InfoItem('可用内存', '${_hardwareInfo!.availableRamGB} GB'),
                _InfoItem('可用存储', '${_hardwareInfo!.availableStorageGB} GB'),
                const SizedBox(height: 8),
              ],
              _InfoItem('存储需求', '约 ${widget.model.minStorageGB} GB'),
              _InfoItem('内存需求', '≥ ${widget.model.minRamGB} GB'),
              if (widget.model.parameterSize > 0) _InfoItem('参数量', '${widget.model.parameterSize}B'),
              if (widget.model.quantizationMethod != null) _InfoItem('量化格式', widget.model.quantizationMethod!),
              if (!isCompatible) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error), const SizedBox(width: 8), Text('设备不满足最低要求', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.error))]),
                    const SizedBox(height: 8),
                    ...(_compatibilityResult?.reasons ?? []).map((r) => Padding(padding: const EdgeInsets.only(left: 26, top: 2), child: Text('• $r', style: TextStyle(fontSize: 12, color: theme.colorScheme.error)))),
                    const SizedBox(height: 8),
                    Text('强行下载可能导致模型无法加载或运行缓慢。', style: TextStyle(fontSize: 12, color: theme.colorScheme.onErrorContainer)),
                  ]),
                ),
              ],
              if (isCompatible && hasWarnings) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade200)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade700), const SizedBox(width: 8), Text('温馨提示', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700))]),
                    const SizedBox(height: 8),
                    ...(_compatibilityResult?.warnings ?? []).map((w) => Padding(padding: const EdgeInsets.only(left: 26, top: 2), child: Text('• $w', style: const TextStyle(fontSize: 12)))),
                  ]),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary), const SizedBox(width: 8), Expanded(child: Text(isCompatible ? '下载完成后将自动注册到本地模型，您可以在模型管理中查看和加载。' : '仍可尝试下载，但可能无法正常使用。', style: const TextStyle(fontSize: 12)))]),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
        FilledButton(onPressed: () => Navigator.pop(context, true), style: isCompatible ? null : FilledButton.styleFrom(backgroundColor: Colors.orange), child: Text(isCompatible ? '开始下载' : '仍要下载')),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
          ),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  辅助组件
// ════════════════════════════════════════════════════════════════════════════

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _HFLogo extends StatelessWidget {
  const _HFLogo();

  @override
  Widget build(BuildContext context) {
    return const Text('🤗', style: TextStyle(fontSize: 16));
  }
}

/// 数据类
class _FeaturedModel {
  final String id;
  final String name;
  final String author;
  final String params;
  final String quantLevel;
  final String description;
  final int minRam;
  /// 磁盘存储空间需求（GB）
  final int minStorage;

  const _FeaturedModel({
    required this.id,
    required this.name,
    required this.author,
    required this.params,
    required this.quantLevel,
    required this.description,
    required this.minRam,
    required this.minStorage,
  });
}