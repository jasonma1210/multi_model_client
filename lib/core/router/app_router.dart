import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../features/settings/presentation/pages/voice_clone_page.dart';
import '../../features/settings/presentation/pages/director_template_editor_page.dart';
import '../../features/settings/presentation/pages/proxy_status_page.dart';
import '../../features/settings/presentation/pages/knowledge_base_management_page.dart';
import '../../features/settings/presentation/pages/knowledge_base_detail_page.dart';
import '../../features/settings/presentation/pages/storage_paths_page.dart';
import '../../features/settings/presentation/pages/log_list_page.dart';
import '../../features/settings/presentation/pages/plugin_management_page.dart';
import '../../features/settings/presentation/pages/manual_page.dart';
import '../../features/spirit/presentation/pages/spirit_gallery_page.dart';
import '../../features/spirit/presentation/pages/spirit_create_page.dart';
import '../../features/spirit/presentation/pages/spirit_chat_page.dart';
import '../../features/spirit/presentation/pages/spirit_voice_chat_page.dart';
import '../../features/spirit/presentation/pages/spirit_detail_page.dart';
// v0.42.0 新增
import '../../features/research/presentation/pages/research_input_page.dart';
import '../../features/project/presentation/pages/project_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 主页（首页）—— 所有子路由嵌套在 '/' 下，确保 back 手势行为正确
      GoRoute(
        path: '/',
        builder: (context, state) => const SessionListPage(),
        routes: [
          GoRoute(
            path: 'session/:id',
            builder: (context, state) {
              final sessionId = state.pathParameters['id']!;
              return SessionDetailPage(sessionId: sessionId);
            },
          ),
          GoRoute(
            path: 'folders',
            builder: (context, state) => const FolderManagePage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'models',
                builder: (context, state) => const ModelManagementPage(),
              ),
              GoRoute(
                path: 'skills',
                builder: (context, state) => const SkillMarketPage(),
                routes: [
                  GoRoute(
                    path: 'editor',
                    builder: (context, state) => const SkillEditorPage(),
                  ),
                ],
              ),
              GoRoute(
                path: 'memory',
                builder: (context, state) => const MemorySettingsPage(),
              ),
              GoRoute(
                path: 'voice',
                builder: (context, state) => const VoiceSettingsPage(),
              ),
              GoRoute(
                path: 'voice/clone',
                builder: (context, state) => VoiceClonePage(
                  provider: state.uri.queryParameters['provider'] ?? 'mimo',
                ),
              ),
              GoRoute(
                path: 'voice/director-templates',
                builder: (context, state) => const MyDirectorTemplatesPage(),
              ),
              GoRoute(
                path: 'proxy',
                builder: (context, state) => const ProxyStatusPage(),
              ),
              GoRoute(
                path: 'knowledge',
                builder: (context, state) => const KnowledgeBaseManagementPage(),
              ),
              GoRoute(
                path: 'knowledge/:id',
                builder: (context, state) {
                  final kbId = state.pathParameters['id']!;
                  return KnowledgeBaseDetailPage(knowledgeBaseId: kbId);
                },
              ),
              GoRoute(
                path: 'storage',
                builder: (context, state) => const StoragePathsPage(),
              ),
              GoRoute(
                path: 'logs',
                builder: (context, state) => const LogListPage(),
              ),
              GoRoute(
                path: 'plugins',
                builder: (context, state) => const PluginManagementPage(),
              ),
              GoRoute(
                path: 'manual',
                builder: (context, state) => const ManualPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'model-market',
            builder: (context, state) => const ModelMarketPage(),
          ),
          GoRoute(
            path: 'model/:id/load',
            builder: (context, state) {
              final modelId = state.pathParameters['id']!;
              return ModelLoadPage(modelId: modelId);
            },
          ),
          GoRoute(
            path: 'downloads',
            builder: (context, state) => const DownloadsPage(),
          ),
          // 名灵回响路由
          GoRoute(
            path: 'spirit',
            builder: (context, state) => const SpiritGalleryPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const SpiritCreatePage(),
              ),
              GoRoute(
                path: 'chat/:spiritId',
                builder: (context, state) {
                  final spiritId = state.pathParameters['spiritId']!;
                  return SpiritChatPage(spiritId: spiritId);
                },
              ),
              GoRoute(
                path: 'voice-chat/:spiritId',
                builder: (context, state) {
                  final spiritId = state.pathParameters['spiritId']!;
                  final modelId = state.uri.queryParameters['modelId'] ?? '';
                  return SpiritVoiceChatPage(spiritId: spiritId, modelId: modelId);
                },
              ),
              GoRoute(
                path: 'detail/:spiritId',
                builder: (context, state) {
                  final spiritId = state.pathParameters['spiritId']!;
                  return SpiritDetailPage(spiritId: spiritId);
                },
              ),
            ],
          ),
          // v0.42.0 新增路由
          GoRoute(
            path: 'research',
            builder: (context, state) => const ResearchInputPage(),
          ),
          GoRoute(
            path: 'projects',
            builder: (context, state) => const ProjectListPage(),
          ),
        ],
      ),
    ],
  );
});