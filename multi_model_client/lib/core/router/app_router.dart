import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/database.dart';
import '../../features/session/presentation/pages/session_list_page.dart';
import '../../features/session/presentation/pages/session_detail_page.dart';
import '../../features/session/presentation/pages/folder_manage_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/model_management_page.dart';
import '../../features/model/presentation/pages/model_market_page.dart';
import '../../features/model/presentation/pages/model_load_page.dart';
import '../../features/model/presentation/pages/downloads_page.dart';
import '../../features/skill/presentation/pages/skill_market_page.dart';
import '../../features/skill/presentation/pages/skill_editor_page.dart';
import '../../features/settings/presentation/pages/memory_settings_page.dart';
import '../../features/settings/presentation/pages/voice_settings_page.dart';
import '../../features/settings/presentation/pages/knowledge_base_management_page.dart';
import '../../features/settings/presentation/pages/knowledge_base_detail_page.dart';
import '../../features/settings/presentation/pages/storage_paths_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // ── 主页：会话列表 ──
      GoRoute(
        path: '/',
        builder: (context, state) => const SessionListPage(),
      ),

      // ── 会话详情 ──
      GoRoute(
        path: '/session/:id',
        builder: (context, state) {
          final sessionId = state.pathParameters['id']!;
          return SessionDetailPage(sessionId: sessionId);
        },
      ),

      // ── 设置 ──
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // ── 模型管理（本地 + 远程列表）──
      GoRoute(
        path: '/settings/models',
        builder: (context, state) => const ModelManagementPage(),
      ),

      // ── 模型市场（HuggingFace + ModelScope 搜索/下载）──
      GoRoute(
        path: '/model-market',
        builder: (context, state) => const ModelMarketPage(),
      ),

      // ── 模型加载 & 参数配置（本地模型）──
      GoRoute(
        path: '/model/:id/load',
        builder: (context, state) {
          final modelId = state.pathParameters['id']!;
          return ModelLoadPage(modelId: modelId);
        },
      ),

      // ── 技能中心 ──
      GoRoute(
        path: '/settings/skills',
        builder: (context, state) => const SkillMarketPage(),
      ),

      // ── 技能编辑器 ──
      GoRoute(
        path: '/settings/skills/editor',
        builder: (context, state) {
          final skillId = state.uri.queryParameters['id'];
          return SkillEditorPage(skillId: skillId);
        },
      ),

      // ── 下载管理页面 ──
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsPage(),
      ),

      // ── 文件夹管理页面 ──
      GoRoute(
        path: '/settings/folders',
        builder: (context, state) => const FolderManagePage(),
      ),

      // ── 记忆设置页面 ──
      GoRoute(
        path: '/settings/memory',
        builder: (context, state) => const MemorySettingsPage(),
      ),

      // ── 语音设置页面 ──
      GoRoute(
        path: '/settings/voice',
        builder: (context, state) => const VoiceSettingsPage(),
      ),

      // ── 知识库管理页面 ──
      GoRoute(
        path: '/settings/knowledge',
        builder: (context, state) => const KnowledgeBaseManagementPage(),
      ),
      // ── 知识库详情页面 ──
      GoRoute(
        path: '/settings/knowledge/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return KnowledgeBaseDetailPage(knowledgeBaseId: id);
        },
      ),

      // ── 存储位置配置页面 ──
      GoRoute(
        path: '/settings/storage',
        builder: (context, state) => const StoragePathsPage(),
      ),
    ],
    errorBuilder: (context, state) => const _ErrorPage(),
  );
});

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            const Text('页面不存在'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
