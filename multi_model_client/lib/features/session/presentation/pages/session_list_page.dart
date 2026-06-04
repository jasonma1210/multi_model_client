// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

import '../../../../core/interfaces/session_interface.dart';
import '../../../../core/models/model_entry.dart';
import '../../../../core/models/persona.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/storage/database.dart' show Session, Folder;
import '../../../../core/theme/app_theme.dart';
import 'package:mj_nexus/generated/app_localizations.dart';
import '../../../../core/services/model_download/download_task_manager.dart';
import '../../../../core/engines/model_inference_engine.dart';
import '../../domain/session_manager.dart';
import '../../domain/folder_service.dart';
import '../../domain/export_service.dart';
import '../../../inspiration/presentation/pages/inspiration_page.dart';

/// 预定义的随机颜色列表（用于会话图标）
final List<List<Color>> _avatarGradients = [
  [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // 紫蓝
  [const Color(0xFFEC4899), const Color(0xFFF43F5E)], // 粉红
  [const Color(0xFF14B8A6), const Color(0xFF0D9488)], // 青绿
  [const Color(0xFFF59E0B), const Color(0xFFD97706)], // 橙色
  [const Color(0xFF3B82F6), const Color(0xFF2563EB)], // 蓝色
  [const Color(0xFF10B981), const Color(0xFF059669)], // 绿色
  [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], // 紫色
  [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // 青色
  [const Color(0xFFF97316), const Color(0xFFEA580C)], // 深橙
  [const Color(0xFF84CC16), const Color(0xFF65A30D)], // 柠檬绿
  [const Color(0xFFA855F7), const Color(0xFF9333EA)], // 深紫
  [const Color(0xFFEF4444), const Color(0xFFDC2626)], // 红色
];

/// 根据会话 ID 生成稳定的随机颜色
List<Color> _getSessionColors(String sessionId) {
  final hash = sessionId.hashCode.abs();
  return _avatarGradients[hash % _avatarGradients.length];
}

class SessionListPage extends ConsumerStatefulWidget {
  const SessionListPage({super.key});

  @override
  ConsumerState<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends ConsumerState<SessionListPage>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _emptyStateController;
  final FolderService _folderService = FolderService();
  final SessionExportService _exportService = SessionExportService();
  List<Folder> _folders = [];
  String? _selectedFolderId;

  // 侧边栏覆盖层状态（竖屏模式）
  bool _sidebarOpen = false;

  // 用状态变量持有 Future，保证刷新时 FutureBuilder 能感知到变化
  Future<List<Session>>? _sessionListFuture;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _emptyStateController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _loadFolders();
    // ★ 首次进入时从 DB 加载会话列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSessionList();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ★ 关键修复：每次路由变化时强制刷新会话列表
    // 解决从会话详情返回后 FutureBuilder 缓存旧数据的问题
    // 添加小延迟确保数据库写入已完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _refreshSessionList();
        });
      }
    });
  }

  /// 强制刷新会话列表（FutureBuilder 会感知到 future 实例变化）
  void _refreshSessionList() {
    if (!mounted) return;
    final sessionManager = ref.read(sessionManagerProvider);
    setState(() {
      _sessionListFuture = _getSessions(sessionManager);
    });
  }

  /// 导航到灵感一瞬页面
  void _navigateToInspiration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InspirationPage(),
      ),
    );
  }

  Future<void> _loadFolders() async {
    try {
      final folders = await _folderService.getAllFolders();
      if (mounted) {
        setState(() => _folders = folders);
      }
    } catch (e) {
      debugPrint('加载文件夹失败: $e');
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _emptyStateController.dispose();
    super.dispose();
  }

  /// 显示退出确认对话框
  Future<bool?> _showExitConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出应用'),
        content: const Text('确定要退出 LLM Studio 吗？\n\n退出前会释放当前加载的模型，下次进入将自动重新加载。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  /// 判断是否为竖屏/小屏模式
  bool get _isPortraitMode => MediaQuery.of(context).size.width <= 768;

  @override
  Widget build(BuildContext context) {
    final sessionManager = ref.watch(sessionManagerProvider);
    // sessionStateProvider 现在是 StateNotifierProvider，直接返回 SessionState
    ref.watch(sessionStateProvider); // 监听状态变化以触发重建（如会话被删除等）
    // ★ 关键修复：监听 sessionStateProvider 变化，自动刷新会话列表
    // 解决从模型加载页创建会话后返回首页列表不更新的问题
    ref.listen<SessionState>(sessionStateProvider, (previous, next) {
      if (previous != next) {
        debugPrint('[SessionListPage] sessionStateProvider 变化，刷新列表');
        // 延迟到下一帧刷新，避免在 build 期间 setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refreshSessionList();
        });
      }
    });

    // ★★★ 修复：监听模型下载完成事件，触发 UI 重建 ★★★
    // 问题：模型下载完成后回到会话列表时，由于没有订阅 modelProvider，
    // UI 不会自动重建，导致 _handleAddSession 仍用旧 modelState，
    // 进而误判为"无模型"并跳转到模型下载页面
    final modelState = ref.watch(modelProvider);
    final theme = Theme.of(context);
    final isPortrait = _isPortraitMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // 首页返回：弹窗确认退出
        final shouldExit = await _showExitConfirmDialog();
        if (shouldExit == true && context.mounted) {
          // 释放模型：获取当前加载的模型并卸载
          final modelState = ref.read(modelProvider);
          final loadedModel = modelState.loadedModel;
          if (loadedModel != null) {
            await globalModelEngine.unloadModel(loadedModel.id);
          }
          if (context.mounted) {
            // 退出应用
            exit(0);
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _navigateToInspiration(context),
            tooltip: '灵感一瞬',
            child: const Icon(Icons.lightbulb_outline),
          ),
        ),
        body: Stack(children: [
          Row(
            children: [
              // Sidebar（大屏：宽度 > 768）
              if (!isPortrait)
                Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    border: Border(
                      right: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: _buildSidebar(context),
                ),
              // 主内容：直接走 FutureBuilder，不依赖 sessionsAsync
              Expanded(
                child: _buildSessionContent(context, sessionManager, showHamburger: isPortrait),
              ),
            ],
          ),
          // 竖屏模式：侧边栏覆盖层（2/3 宽度）
          if (_sidebarOpen)
            _buildSidebarOverlay(context, theme),
        ],
      ),
    ),
  );
}

  /// 构建竖屏模式的侧边栏覆盖层（带动画）
  Widget _buildSidebarOverlay(BuildContext context, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final overlayWidth = screenWidth * 2 / 3; // 2/3 宽度
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: _sidebarOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => setState(() => _sidebarOpen = false),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          width: screenWidth,
          height: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {}, // 点击侧边栏内容不关闭
              child: AnimatedSlide(
                offset: _sidebarOpen ? Offset.zero : const Offset(-0.3, 0),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: overlayWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    border: Border(
                      right: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                        blurRadius: 24,
                        offset: const Offset(4, 0),
                      ),
                    ],
                  ),
                  child: _buildSidebarContent(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 侧边栏内容（带关闭按钮，用于覆盖层）
  Widget _buildSidebarContent(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // 关闭按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo 图片
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/mj_nexus_logo.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 如果图片加载失败，显示默认图标
                    return Icon(
                      Icons.hub_rounded,
                      size: 28,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MJ Nexus',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('多模型 AI 助手',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _sidebarOpen = false),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text('多模型 AI 助手',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  )),
            ],
          ),
        ),
        const Divider(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _NavItem(icon: Icons.chat_outlined, label: l10n.sessions, isActive: true,
                    onTap: () {
                      setState(() => _sidebarOpen = false);
                    }),
                _NavItem(icon: Icons.smart_toy_outlined, label: l10n.models, isActive: false,
                    onTap: () {
                      setState(() => _sidebarOpen = false);
                      context.go('/settings/models');
                    }),
                _NavItem(icon: Icons.psychology_outlined, label: l10n.knowledge, isActive: false,
                    onTap: () {
                      setState(() => _sidebarOpen = false);
                      context.go('/settings/knowledge');
                    }),
                const SizedBox(height: 8),
                // 灵感一瞬入口
                _NavItem(icon: Icons.lightbulb_outline, label: '灵感一瞬', isActive: false,
                    onTap: () {
                      setState(() => _sidebarOpen = false);
                      _navigateToInspiration(context);
                    }),
                const SizedBox(height: 16),
                // 下载管理入口（带角标显示下载中数量）
                _DownloadNavItem(
                  onTap: () {
                    setState(() => _sidebarOpen = false);
                    context.push('/downloads');
                  },
                ),
                const SizedBox(height: 8),
                _NavItem(icon: Icons.settings_outlined, label: l10n.settings, isActive: false,
                    onTap: () {
                      setState(() => _sidebarOpen = false);
                      context.go('/settings');
                    }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 获取当前显示的会话列表
  Future<List<Session>> _getSessions(SessionManager sessionManager) async {
    if (_showArchived) {
      return await _folderService.getArchivedSessions();
    } else if (_selectedFolderId != null) {
      return await _folderService.getSessionsByFolder(_selectedFolderId!);
    } else {
      return await sessionManager.getAllSessions();
    }
  }

  Widget _buildSessionContent(BuildContext context, SessionManager sessionManager, {bool showHamburger = false}) {
    // ★ 修复：始终使用最新的 future，避免 ??= 导致的缓存旧数据问题
    // _refreshSessionList() 已通过 setState 设置了新的 future 实例
    final future = _sessionListFuture;
    if (future == null) {
      // 尚未加载，显示空状态（_refreshSessionList 会在 initState/didChangeDependencies 中触发）
      return _buildEmptyOrSkeleton(context, showHamburger: showHamburger);
    }
    return FutureBuilder<List<Session>>(
      future: future,
      builder: (context, snapshot) {
        // 仍在加载时显示骨架，但注意：初次进入无会话应立即展示空状态
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 乐观显示：如果没有缓存就当无会话处理，体验更流畅
          return _buildEmptyOrSkeleton(context, showHamburger: showHamburger);
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error!);
        }

        final sessions = snapshot.data ?? [];

        if (sessions.isEmpty) {
          return _buildEmptyState(context, showHamburger: showHamburger);
        }

        return _buildSessionList(context, sessions, showHamburger: showHamburger);
      },
    );
  }

  /// 正在加载时：无历史 session 则直接显示空状态（不转圈）
  Widget _buildEmptyOrSkeleton(BuildContext context, {bool showHamburger = false}) {
    // 非首次加载时才显示骨架
    return _buildEmptyState(context, showHamburger: showHamburger);
  }

  // ────────────────────────── 会话列表 ──────────────────────────

  Widget _buildSessionList(BuildContext context, List<Session> sessions, {bool showHamburger = false}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          // 竖屏模式：汉堡按钮在标题左边，间距5px
          leading: showHamburger
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => setState(() => _sidebarOpen = true),
                  tooltip: '打开菜单',
                )
              : null,
          // 标题与左侧按钮间距5px
          titleSpacing: showHamburger ? 5.0 : null,
          title: Text(
            _showArchived ? '归档会话' : (_selectedFolderId != null ? _getFolderName(_selectedFolderId!) : l10n.sessions),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          actions: [
            // P0 优化：添加模型市场快捷入口
            IconButton(
              icon: const Icon(Icons.storefront_outlined),
              tooltip: '模型市场',
              onPressed: () => context.push('/model-market'),
            ),
            // P0 优化：添加下载管理快捷入口（带红色数字角标）
            _DownloadButtonWithBadge(
              onPressed: () => context.push('/downloads'),
            ),
            const SizedBox(width: 4),
            // ✅ 核心需求：右上角「+」按钮
            if (!_showArchived)
              _AddSessionButton(onTap: () => _handleAddSession(context)),
            const SizedBox(width: 4),
          ],
        ),
        // 文件夹筛选栏
        if (!_showArchived && _folders.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildFolderFilterBar(theme),
          ),
          SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final session = sessions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SessionCard(
                    session: session,
                    folders: _folders,
                    onTap: () => context.go('/session/${session.id}'),
                    onDelete: () => _deleteSession(session.id),
                    onPin: () => _togglePinSession(session),
                    onArchive: () => _toggleArchiveSession(session),
                    onMoveToFolder: () => _showMoveToFolderDialog(session),
                    onExport: () => _showExportDialog(session),
                    onRename: () => _showRenameDialog(session),
                  ),
                );
              },
              childCount: sessions.length,
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────── 空状态 ──────────────────────────

  Widget _buildEmptyState(BuildContext context, {bool showHamburger = false}) {
    final theme = Theme.of(context);

    return Scaffold(
      // 空状态页面自己有 AppBar，右上角显示「+」
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        // 竖屏模式：汉堡按钮在标题左边，间距5px
        leading: showHamburger
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => setState(() => _sidebarOpen = true),
                tooltip: '打开菜单',
              )
            : null,
        // 标题与左侧按钮间距5px
        titleSpacing: showHamburger ? 5.0 : null,
        title: showHamburger
            ? Text(
                _showArchived ? '归档会话' : (_selectedFolderId != null ? _getFolderName(_selectedFolderId!) : AppLocalizations.of(context)!.sessions),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              )
            : null,
        actions: [
          // P0 优化：添加模型市场快捷入口
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: '模型市场',
            onPressed: () => context.push('/model-market'),
          ),
          // P0 优化：添加下载管理快捷入口（带红色数字角标）
          _DownloadButtonWithBadge(
            onPressed: () => context.push('/downloads'),
          ),
          const SizedBox(width: 4),
          _AddSessionButton(onTap: () => _handleAddSession(context)),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: FadeTransition(
          opacity: _emptyStateController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _emptyStateController,
              curve: Curves.easeOutCubic,
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图标
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '还没有会话',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '点击右上角「+」创建第一个会话\n选择模型，开始对话吧',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // CTA 按钮
                  FilledButton.icon(
                    onPressed: () => _handleAddSession(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('创建会话'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────── 错误状态 ──────────────────────────

  Widget _buildErrorState(Object error) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          _AddSessionButton(onTap: () => _handleAddSession(context)),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 56,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('加载失败', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.invalidate(sessionManagerProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────── 侧边栏 ──────────────────────────

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              // Logo 图片
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/mj_nexus_logo.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 如果图片加载失败，显示默认图标
                    return Icon(
                      Icons.hub_rounded,
                      size: 28,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MJ Nexus',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('多模型 AI 助手',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      )),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 24),
        _NavItem(icon: Icons.chat_outlined, label: l10n.sessions, isActive: true,
            onTap: () {}),
        _NavItem(icon: Icons.smart_toy_outlined, label: l10n.models, isActive: false,
            onTap: () => context.go('/settings/models')),
        _NavItem(icon: Icons.psychology_outlined, label: l10n.knowledge, isActive: false,
            onTap: () => context.go('/settings/knowledge')),
        const SizedBox(height: 8),
        // 灵感一瞬入口
        _NavItem(icon: Icons.lightbulb_outline, label: '灵感一瞬', isActive: false,
            onTap: () => _navigateToInspiration(context)),
        const Spacer(),
        const Divider(height: 1),
        // 下载管理入口（带角标显示下载中数量）
        _DownloadNavItem(
          onTap: () => context.push('/downloads'),
        ),
        const SizedBox(height: 8),
        _NavItem(icon: Icons.settings_outlined, label: l10n.settings, isActive: false,
            onTap: () => context.go('/settings')),
        const SizedBox(height: 12),
      ],
    );
  }

  // ────────────────────────── 核心：点击「+」的处理逻辑 ──────────────────────────

  Future<void> _handleAddSession(BuildContext context) async {
    // 检查是否有可用模型
    final modelState = ref.read(modelProvider);

    if (modelState.isEmpty) {
      // 没有模型 → 直接跳转到模型市场（无需弹窗确认）
      if (context.mounted) {
        context.go('/model-market');
      }
      return;
    }

    // 有模型 → 显示创建会话对话框
    if (context.mounted) {
      await _showCreateSessionSheet(context);
    }
  }

  Future<void> _showCreateSessionSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CreateSessionSheet(
        onCreated: (name, modelId, systemPrompt) => _createSession(context, name, modelId, systemPrompt),
      ),
    );
  }

  Future<void> _createSession(BuildContext context, String name, String modelId, String? systemPrompt) async {
    try {
      final sessionManager = ref.read(sessionManagerProvider);
      final session = await sessionManager.createSession(
        SessionConfig(name: name, modelId: modelId, systemPrompt: systemPrompt),
      );

      // ★ 修复：创建会话后立即刷新列表（通过 setState 确保 FutureBuilder 使用新 future）
      // 导航到会话详情页后，返回时 didChangeDependencies 会再次触发刷新
      _refreshSessionList();

      // 检查模型是否已加载/可用，给出提示
      final modelState = ref.read(modelProvider);
      final model = modelState.models.where((m) => m.id == modelId).firstOrNull;

      // ✅ 修复：检查模型是否可用（本地模型需已加载，远程模型直接可用）
      bool modelAvailable = false;
      String? warningMessage;

      if (model != null) {
        if (model.isRemote) {
          // 远程模型始终可用
          modelAvailable = true;
        } else if (model.isLocal && model.isLoaded) {
          // 本地模型已加载，可用
          modelAvailable = true;
        } else if (model.isLocal && !model.isLoaded) {
          // 本地模型未加载，提示用户
          modelAvailable = false;
          warningMessage = '本地模型 ${model.displayName} 尚未加载，请先在模型页面加载模型';
        }
      }

      // 如果模型不可用，显示 Toast（3秒后自动消失）
      if (!modelAvailable && warningMessage != null && context.mounted) {
        // ✅ 关键修复：不在 SnackBarAction.onPressed 里使用 context.go()
        // 因为 SnackBar 弹出后，原始 context 可能已经 deactivated（页面跳转到会话详情后）
        // 解决方法：先跳转会话页，SnackBar 仅作提示，不带跳转按钮
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(warningMessage),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }

      if (context.mounted) {
        context.go('/session/${session.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('创建失败：$e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ));
      }
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      final sessionManager = ref.read(sessionManagerProvider);
      await sessionManager.deleteSession(sessionId);
      
      // 刷新会话列表（强制 FutureBuilder 使用新 Future）
      _refreshSessionList();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('会话已删除'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('删除失败：$e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  /// 切换会话置顶状态
  Future<void> _togglePinSession(Session session) async {
    try {
      await _folderService.togglePinSession(session.id, !session.isPinned);
      _refreshSessionList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(session.isPinned ? '已取消置顶' : '已置顶'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败：$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 切换会话归档状态
  Future<void> _toggleArchiveSession(Session session) async {
    try {
      await _folderService.toggleArchiveSession(session.id, !session.isArchived);
      _refreshSessionList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(session.isArchived ? '已取消归档' : '已归档'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败：$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 显示移动到文件夹对话框
  Future<void> _showMoveToFolderDialog(Session session) async {
    final folders = await _folderService.getAllFolders();
    if (!mounted) return;

    final selectedFolderId = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移动到文件夹'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // 未分类选项
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: const Text('未分类'),
                selected: session.folderId == null,
                onTap: () => Navigator.pop(ctx, null),
              ),
              const Divider(),
              // 文件夹列表
              ...folders.map((folder) => ListTile(
                leading: Icon(
                  Icons.folder_outlined,
                  color: _parseColor(folder.color),
                ),
                title: Text(folder.name),
                selected: session.folderId == folder.id,
                onTap: () => Navigator.pop(ctx, folder.id),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (selectedFolderId != session.folderId) {
      try {
        await _folderService.moveSessionToFolder(session.id, selectedFolderId);
        _refreshSessionList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已移动'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('移动失败：$e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// 显示导出对话框
  Future<void> _showExportDialog(Session session) async {
    final format = await showDialog<ExportFormat>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导出会话'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Markdown'),
              subtitle: const Text('.md 格式'),
              onTap: () => Navigator.pop(ctx, ExportFormat.markdown),
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet_outlined),
              title: const Text('纯文本'),
              subtitle: const Text('.txt 格式'),
              onTap: () => Navigator.pop(ctx, ExportFormat.text),
            ),
            ListTile(
              leading: const Icon(Icons.code_outlined),
              title: const Text('JSON'),
              subtitle: const Text('结构化数据'),
              onTap: () => Navigator.pop(ctx, ExportFormat.json),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (format != null) {
      try {
        final file = await _exportService.exportToFile(session, format: format);
        if (mounted) {
          // 询问是否分享
          final shouldShare = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('导出成功'),
              content: Text('文件已保存到：${file.path}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('关闭'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('分享'),
                ),
              ],
            ),
          );

          if (shouldShare == true) {
            await _exportService.shareSessionFile(session, format: format);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导出失败：$e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// 获取文件夹名称
  String _getFolderName(String folderId) {
    final folder = _folders.firstWhere(
      (f) => f.id == folderId,
      orElse: () => Folder(
        id: folderId,
        name: '未知文件夹',
        color: '#007AFF',
        icon: 'folder',
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return folder.name;
  }

  /// 解析颜色
  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  /// 显示搜索对话框
  Future<void> _showSearchDialog(BuildContext context) async {
    final sessionManager = ref.read(sessionManagerProvider);
    final l10n = AppLocalizations.of(context)!;
    String searchQuery = '';
    List<Session> searchResults = [];
    bool isSearching = false;

    // 防抖计时器
    Timer? debounceTimer;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) {
          // 执行搜索的函数（带防抖）
          void performSearch(String query) {
            // 取消之前的计时器
            debounceTimer?.cancel();

            if (query.isEmpty) {
              setState(() {
                searchResults = [];
                isSearching = false;
              });
              return;
            }

            // 防抖：延迟 300ms 后执行搜索
            debounceTimer = Timer(const Duration(milliseconds: 300), () async {
              setState(() => isSearching = true);
              try {
                final results = await sessionManager.searchSessions(query);
                if (mounted) {
                  setState(() {
                    searchResults = results;
                    isSearching = false;
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    searchResults = [];
                    isSearching = false;
                  });
                }
              }
            });
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: const BoxConstraints(maxHeight: 500),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.searchSessions,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '输入会话名称搜索...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      performSearch(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // 搜索结果区域
                  if (searchQuery.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        '输入关键词搜索会话',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else if (isSearching)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (searchResults.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        '未找到匹配的会话',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemExtent: 60,
                        itemBuilder: (listContext, i) {
                          final session = searchResults[i];
                          final colors = _getSessionColors(session.id);
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                session.name.isNotEmpty ? session.name[0].toUpperCase() : 'S',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(session.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(formatTime(session.createdAt)),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              context.go('/session/${session.id}');
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 显示重命名对话框
  Future<void> _showRenameDialog(Session session) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: session.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rename),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: '会话名称',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != session.name) {
      try {
        final sessionManager = ref.read(sessionManagerProvider);
        await sessionManager.renameSession(session.id, newName);
        _refreshSessionList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已重命名为: $newName'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('重命名失败: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// 构建文件夹筛选栏
  Widget _buildFolderFilterBar(ThemeData theme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 全部
          _FolderFilterChip(
            label: '全部',
            isSelected: _selectedFolderId == null,
            onTap: () {
              setState(() {
                _selectedFolderId = null;
                _sessionListFuture = null;
              });
            },
          ),
          const SizedBox(width: 8),
          // 文件夹列表
          ..._folders.map((folder) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FolderFilterChip(
              label: folder.name,
              isSelected: _selectedFolderId == folder.id,
              color: _parseColor(folder.color),
              onTap: () {
                setState(() {
                  _selectedFolderId = folder.id;
                  _sessionListFuture = null;
                });
              },
            ),
          )),
          // 归档
          _FolderFilterChip(
            label: '归档',
            isSelected: _showArchived,
            icon: Icons.archive_outlined,
            onTap: () {
              setState(() {
                _showArchived = !_showArchived;
                if (_showArchived) _selectedFolderId = null;
                _sessionListFuture = null;
              });
            },
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  右上角「+」按钮组件（带动效）
// ════════════════════════════════════════════════════════════

class _AddSessionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSessionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Material(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              Icons.add_rounded,
              color: theme.colorScheme.onPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  创建会话 Bottom Sheet
// ════════════════════════════════════════════════════════════

class _CreateSessionSheet extends ConsumerStatefulWidget {
  final Future<void> Function(String name, String modelId, String? systemPrompt) onCreated;

  const _CreateSessionSheet({required this.onCreated});

  @override
  ConsumerState<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends ConsumerState<_CreateSessionSheet> {
  final _nameController = TextEditingController(text: '新会话');
  final _customPromptController = TextEditingController();
  String? _selectedModelId;
  String? _selectedPersonaId;
  bool _isCreating = false;
  bool _showCustomPrompt = false;

  @override
  void initState() {
    super.initState();
    // 默认选中第一个可用模型
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final models = ref.read(availableModelsProvider);
      if (models.isNotEmpty && _selectedModelId == null) {
        setState(() => _selectedModelId = models.first.id);
      }
    });
  }

  String? get _currentSystemPrompt {
    if (_selectedPersonaId == null || _selectedPersonaId == 'none') {
      return null;
    }
    if (_selectedPersonaId == 'custom') {
      return _customPromptController.text.trim().isEmpty
          ? null
          : _customPromptController.text.trim();
    }
    final persona = PersonaTemplates.getById(_selectedPersonaId!);
    return persona?.systemPrompt;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final models = ref.watch(availableModelsProvider);

    // ★ 修复：使用 SingleChildScrollView 包裹内容，避免 BottomSheet 高度受限时
    //   Column 整体溢出导致 "RenderFlex overflowed by N pixels" 错误。
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖动把手
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('创建会话', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),

            // 会话名称
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '会话名称',
                hintText: '输入会话名称...',
                prefixIcon: const Icon(Icons.chat_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // 模型选择
            Text('选择模型', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),

            if (models.isEmpty)
              // 无模型提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '暂无可用模型，请先添加模型',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/settings/models');
                      },
                      child: const Text('去添加'),
                    ),
                  ],
                ),
              )
            else
              // 模型列表（最大 35% 屏幕高度，可滚动）
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: models.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final model = models[i];
                    final isSelected = _selectedModelId == model.id;
                    return _ModelSelectTile(
                      model: model,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedModelId = model.id),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // 角色人设选择
            Text('选择角色', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),

            // 角色选项（横向滚动）
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: PersonaTemplates.templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final persona = PersonaTemplates.templates[i];
                  final isSelected = _selectedPersonaId == persona.id;
                  return _PersonaChip(
                    persona: persona,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedPersonaId = persona.id;
                        _showCustomPrompt = persona.id == 'custom';
                      });
                    },
                  );
                },
              ),
            ),

            // 自定义提示词输入框
            if (_showCustomPrompt) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customPromptController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: '自定义系统提示词',
                  hintText: '输入你想要的 AI 角色设定...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 创建按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (models.isEmpty || _selectedModelId == null || _isCreating)
                    ? null
                    : _handleCreate,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('创建会话', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedModelId == null) return;

    // 先锁定按钮防止重复点击
    setState(() => _isCreating = true);

    // 保存必要数据和回调引用，避免 pop 后访问 widget/context
    final modelId = _selectedModelId!;
    final systemPrompt = _currentSystemPrompt;
    final onCreated = widget.onCreated;

    // 先关闭 bottom sheet（此后 widget 已销毁，不可再调用 setState）
    if (mounted) Navigator.pop(context);

    // 在 bottom sheet 外部执行异步创建（onCreated 内部自行管理状态）
    await onCreated(name, modelId, systemPrompt);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }
}

// ════════════════════════════════════════════════════════════
//  角色选择 Chip
// ════════════════════════════════════════════════════════════

class _PersonaChip extends StatelessWidget {
  final Persona persona;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonaChip({
    required this.persona,
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                persona.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                persona.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  模型选择 Tile
// ════════════════════════════════════════════════════════════

class _ModelSelectTile extends StatelessWidget {
  final ModelEntry model;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelSelectTile({
    required this.model,
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // 模型图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _modelColor(model.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _modelIcon(model.type),
                  color: _modelColor(model.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _modelSubtitle(model),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _modelIcon(ModelType type) {
    switch (type) {
      case ModelType.local:
        return Icons.storage_rounded;
      case ModelType.remote:
        return Icons.cloud_outlined;
      case ModelType.ollama:
        return Icons.memory_rounded;
    }
  }

  Color _modelColor(ModelType type) {
    switch (type) {
      case ModelType.local:
        return const Color(0xFF6366F1);
      case ModelType.remote:
        return const Color(0xFF0EA5E9);
      case ModelType.ollama:
        return const Color(0xFF10B981);
    }
  }

  String _modelSubtitle(ModelEntry model) {
    if (model.isLocal) {
      final parts = <String>[];
      if (model.parameterSize != null) parts.add('${model.parameterSize}B');
      if (model.quantLevel != null) parts.add(model.quantLevel!);
      parts.add('本地模型');
      return parts.join(' · ');
    }
    final config = model.remoteConfig;
    if (config == null) return '远程模型';
    switch (config.protocol) {
      case RemoteProtocol.openai:
        return 'OpenAI · ${config.modelId}';
      case RemoteProtocol.anthropic:
        return 'Anthropic · ${config.modelId}';
      case RemoteProtocol.ollama:
        return 'Ollama · ${config.modelId}';
    }
  }
}

// ════════════════════════════════════════════════════════════
//  会话卡片（优化版）
// ════════════════════════════════════════════════════════════

class _SessionCard extends ConsumerWidget {
  final Session session;
  final List<Folder> folders;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onMoveToFolder;
  final VoidCallback onExport;
  final VoidCallback onRename;

  const _SessionCard({
    required this.session,
    required this.folders,
    required this.onTap,
    required this.onDelete,
    required this.onPin,
    required this.onArchive,
    required this.onMoveToFolder,
    required this.onExport,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // 解析模型名：查找 modelId 对应的 displayName，降级显示「未知模型」
    final models = ref.watch(availableModelsProvider);
    final modelName = models
        .where((m) => m.id == session.modelId)
        .map((m) => m.displayName)
        .firstOrNull ?? '未知模型';

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 头像 - 随机颜色
              Builder(builder: (context) {
                final colors = _getSessionColors(session.id);
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      session.name.isNotEmpty ? session.name[0].toUpperCase() : 'S',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.smart_toy_outlined, size: 13,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            modelName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(session.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // 置顶标记
              if (session.isPinned)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: ListTile(
                      leading: Icon(session.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded),
                      title: Text(session.isPinned ? '取消置顶' : '置顶'),
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: ListTile(
                      leading: Icon(session.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                      title: Text(session.isArchived ? '取消归档' : '归档'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'move',
                    child: ListTile(leading: Icon(Icons.folder_outlined), title: Text('移动到文件夹'), dense: true),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('重命名'), dense: true),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(leading: Icon(Icons.share_outlined), title: Text('导出'), dense: true),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('删除', style: TextStyle(color: Colors.red)),
                      dense: true,
                    ),
                  ),
                ],
                onSelected: (v) {
                  switch (v) {
                    case 'pin':
                      onPin();
                      break;
                    case 'archive':
                      onArchive();
                      break;
                    case 'move':
                      onMoveToFolder();
                      break;
                    case 'export':
                      onExport();
                      break;
                    case 'rename':
                      onRename();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return formatTime(dt);
  }
}

/// 格式化时间显示
String formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
  if (diff.inDays < 1) return '${diff.inHours} 小时前';
  if (diff.inDays < 7) return '${diff.inDays} 天前';
  return DateFormat('M月d日').format(dt);
}

// ════════════════════════════════════════════════════════════
//  文件夹筛选 Chip
// ════════════════════════════════════════════════════════════

class _FolderFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final IconData? icon;
  final VoidCallback onTap;

  const _FolderFilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Material(
      color: isSelected ? chipColor : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  侧边栏导航项
// ════════════════════════════════════════════════════════════

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentPrimary.withValues(alpha: isDark ? 0.12 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: isActive
              ? Border.all(
                  color: AppTheme.accentPrimary.withValues(alpha: isDark ? 0.2 : 0.15),
                  width: 0.5,
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isActive
                        ? AppTheme.accentPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? (isDark ? AppTheme.accentPrimary : AppTheme.accentHover)
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 下载管理导航项（带角标显示下载中数量）
class _DownloadNavItem extends StatefulWidget {
  final VoidCallback onTap;

  const _DownloadNavItem({required this.onTap});

  @override
  State<_DownloadNavItem> createState() => _DownloadNavItemState();
}

class _DownloadNavItemState extends State<_DownloadNavItem> {
  int _downloadingCount = 0;

  @override
  void initState() {
    super.initState();
    // 监听下载进度
    DownloadTaskManager.instance.progressNotifier.addListener(_updateCount);
    _updateCount();
  }

  @override
  void dispose() {
    DownloadTaskManager.instance.progressNotifier.removeListener(_updateCount);
    super.dispose();
  }

  void _updateCount() {
    if (!mounted) return;
    final progressMap = DownloadTaskManager.instance.progressNotifier.value;
    final count = progressMap.values
        .where((p) => p.status == DownloadStatus.downloading)
        .length;
    if (count != _downloadingCount) {
      setState(() => _downloadingCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // 下载图标 + 角标
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    if (_downloadingCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$_downloadingCount',
                            style: TextStyle(
                              color: theme.colorScheme.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.downloadManager,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  下载按钮角标组件
// ════════════════════════════════════════════════════════════════════════════

/// 带红色数字角标的下载按钮
class _DownloadButtonWithBadge extends ConsumerWidget {
  final VoidCallback onPressed;
  const _DownloadButtonWithBadge({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadCount = ref.watch(downloadingCountProvider);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.download_outlined),
          tooltip: AppLocalizations.of(context)!.downloadManager,
          onPressed: onPressed,
        ),
        // 红色数字角标
        if (downloadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                downloadCount > 99 ? '99+' : '$downloadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
