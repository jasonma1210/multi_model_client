// v0.43.0 实现 A2A Riverpod Provider 层
//
// 层级：
// 1. a2aSettingsProvider：持久化 A2A 服务器配置
// 2. a2aServerConfigsProvider：所有已注册的 A2A 服务器
// 3. a2aClientManagerProvider：管理 A2AClient 实例（按 serverId 缓存）
// 4. a2aAgentsProvider：每个 A2A Server 的 Agent 列表
// 5. a2aTaskStreamProvider：当前任务的事件流
// 6. a2aSessionStateProvider：当前会话选中的 A2A Agent

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/protocols/a2a/a2a_client.dart';
import '../../../core/protocols/a2a/a2a_protocol.dart';
import '../../../core/protocols/a2a/a2a_server.dart';
import '../../../core/protocols/a2a/a2a_stream_event.dart';

/// A2A 服务器配置
@immutable
class A2AServerConfig {
  final String id;
  final String name;
  final String agentUrl;
  final String? apiKey;
  final bool enabled;
  final DateTime createdAt;

  const A2AServerConfig({
    required this.id,
    required this.name,
    required this.agentUrl,
    this.apiKey,
    this.enabled = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'agentUrl': agentUrl,
        'apiKey': apiKey,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory A2AServerConfig.fromJson(Map<String, dynamic> json) => A2AServerConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        agentUrl: json['agentUrl'] as String,
        apiKey: json['apiKey'] as String?,
        enabled: json['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  A2AServerConfig copyWith({String? name, String? agentUrl, String? apiKey, bool? enabled}) {
    return A2AServerConfig(
      id: id,
      name: name ?? this.name,
      agentUrl: agentUrl ?? this.agentUrl,
      apiKey: apiKey ?? this.apiKey,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt,
    );
  }
}

/// A2A 设置（持久化）
class A2ASettings {
  final List<A2AServerConfig> servers;

  const A2ASettings({this.servers = const []});

  Map<String, dynamic> toJson() => {
        'servers': servers.map((s) => s.toJson()).toList(),
      };

  factory A2ASettings.fromJson(Map<String, dynamic> json) => A2ASettings(
        servers: ((json['servers'] as List<dynamic>?) ?? [])
            .map((e) => A2AServerConfig.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// SharedPreferences 键
const _kA2ASettingsKey = 'a2a_settings_v1';

/// A2A 设置 Notifier（持久化到 SharedPreferences）
class A2ASettingsNotifier extends StateNotifier<A2ASettings> {
  A2ASettingsNotifier() : super(const A2ASettings()) {
    _load();
  }

  final _uuid = const Uuid();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kA2ASettingsKey);
    if (raw != null) {
      try {
        state = A2ASettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[A2ASettings] load failed: $e');
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kA2ASettingsKey, jsonEncode(state.toJson()));
  }

  Future<void> addServer(A2AServerConfig config) async {
    state = A2ASettings(servers: [...state.servers, config]);
    await _save();
  }

  Future<void> updateServer(A2AServerConfig config) async {
    state = A2ASettings(
      servers: state.servers.map((s) => s.id == config.id ? config : s).toList(),
    );
    await _save();
  }

  Future<void> removeServer(String id) async {
    state = A2ASettings(
      servers: state.servers.where((s) => s.id != id).toList(),
    );
    await _save();
  }

  /// 快捷添加：仅需 URL 和 Name
  Future<A2AServerConfig> addFromUrl(String name, String agentUrl, {String? apiKey}) async {
    final config = A2AServerConfig(
      id: _uuid.v4(),
      name: name,
      agentUrl: agentUrl,
      apiKey: apiKey,
      createdAt: DateTime.now(),
    );
    await addServer(config);
    return config;
  }
}

final a2aSettingsProvider = StateNotifierProvider<A2ASettingsNotifier, A2ASettings>(
  (ref) => A2ASettingsNotifier(),
);

/// A2A 客户端管理器（按 serverId 缓存客户端实例）
class A2AClientManager {
  final Map<String, A2AClient> _clients = {};

  A2AClient getOrCreate(A2AServerConfig config) {
    final existing = _clients[config.id];
    if (existing != null) return existing;
    final client = A2AClient(
      agentUrl: config.agentUrl,
      apiKey: config.apiKey,
    );
    _clients[config.id] = client;
    return client;
  }

  void dispose(String serverId) {
    _clients.remove(serverId);
  }
}

final a2aClientManagerProvider = Provider<A2AClientManager>(
  (ref) => A2AClientManager(),
);

/// A2A Agents：所有启用服务器的 Agent 列表
class A2AAgentsState {
  final List<AgentCard> agents;
  final Map<String, String> agentToServerMap; // agentName -> serverId
  final bool loading;
  final String? error;

  const A2AAgentsState({
    this.agents = const [],
    this.agentToServerMap = const {},
    this.loading = false,
    this.error,
  });

  A2AAgentsState copyWith({
    List<AgentCard>? agents,
    Map<String, String>? agentToServerMap,
    bool? loading,
    String? error,
  }) {
    return A2AAgentsState(
      agents: agents ?? this.agents,
      agentToServerMap: agentToServerMap ?? this.agentToServerMap,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class A2AAgentsNotifier extends StateNotifier<A2AAgentsState> {
  A2AAgentsNotifier(this._ref) : super(const A2AAgentsState());

  final Ref _ref;

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    final settings = _ref.read(a2aSettingsProvider);
    final enabledServers = settings.servers.where((s) => s.enabled).toList();

    if (enabledServers.isEmpty) {
      state = const A2AAgentsState(agents: []);
      return;
    }

    final manager = _ref.read(a2aClientManagerProvider);
    final agents = <AgentCard>[];
    final map = <String, String>{};

    for (final config in enabledServers) {
      try {
        final client = manager.getOrCreate(config);
        final card = await client.getAgentCard();
        agents.add(card);
        map[card.name] = config.id;
        debugPrint('[A2AAgents] loaded ${config.name}: ${card.skills.length} skills');
      } catch (e) {
        debugPrint('[A2AAgents] failed to load ${config.name}: $e');
      }
    }

    state = A2AAgentsState(agents: agents, agentToServerMap: map);
  }
}

final a2aAgentsProvider = StateNotifierProvider<A2AAgentsNotifier, A2AAgentsState>(
  (ref) => A2AAgentsNotifier(ref),
);

/// A2A 任务运行时状态
class A2ATaskRuntime {
  final String taskId;
  final String agentName;
  final String serverId;
  final String contextId;
  final String userMessageId;
  final List<A2AStreamEvent> events;
  final TaskState state;
  final String? accumulatedText;
  final A2AStreamSubscription? subscription;
  final DateTime createdAt;

  const A2ATaskRuntime({
    required this.taskId,
    required this.agentName,
    required this.serverId,
    required this.contextId,
    required this.userMessageId,
    this.events = const [],
    this.state = TaskState.submitted,
    this.accumulatedText,
    this.subscription,
    required this.createdAt,
  });

  A2ATaskRuntime copyWith({
    List<A2AStreamEvent>? events,
    TaskState? state,
    String? accumulatedText,
  }) {
    return A2ATaskRuntime(
      taskId: taskId,
      agentName: agentName,
      serverId: serverId,
      contextId: contextId,
      userMessageId: userMessageId,
      events: events ?? this.events,
      state: state ?? this.state,
      accumulatedText: accumulatedText ?? this.accumulatedText,
      subscription: subscription,
      createdAt: createdAt,
    );
  }
}

class A2ATaskRuntimeNotifier extends StateNotifier<A2ATaskRuntime?> {
  A2ATaskRuntimeNotifier(Ref ref) : super(null) {
    _ref = ref;
  }

  late final Ref _ref;
  A2AStreamSubscription? _sub;

  void _appendEvent(A2AStreamEvent event) {
    if (state == null) return;
    final events = [...state!.events, event];
    String? acc = state!.accumulatedText;
    TaskState newState = state!.state;

    switch (event) {
      case A2AStatusEvent(:final status):
        newState = status.state;
      case A2AMessageEvent(:final message):
        final text = message.parts.whereType<TextPart>().map((p) => p.text).join('');
        acc = (acc ?? '') + text;
      case A2AArtifactEvent():
      case A2ATaskEvent():
      case A2AEndEvent():
      case A2AUnknownEvent():
        break;
    }

    state = state!.copyWith(events: events, state: newState, accumulatedText: acc);
  }

  /// 启动 A2A 流式任务
  Future<void> startStreaming({
    required String agentName,
    required String userMessageId,
    required String contextId,
    required String text,
  }) async {
    final agents = _ref.read(a2aAgentsProvider);
    final serverId = agents.agentToServerMap[agentName];
    if (serverId == null) {
      throw Exception('Agent not found: $agentName');
    }
    final settings = _ref.read(a2aSettingsProvider);
    final config = settings.servers.firstWhere((s) => s.id == serverId);
    final manager = _ref.read(a2aClientManagerProvider);
    final client = manager.getOrCreate(config);

    final taskId = const Uuid().v4();
    state = A2ATaskRuntime(
      taskId: taskId,
      agentName: agentName,
      serverId: serverId,
      contextId: contextId,
      userMessageId: userMessageId,
      createdAt: DateTime.now(),
    );

    _sub = client.sendStreamingMessage(
      messageId: userMessageId,
      contextId: contextId,
      parts: [TextPart(text)],
    );

    // 监听事件
    _sub!.stream.listen(
      _appendEvent,
      onError: (e) {
        debugPrint('[A2ATask] error: $e');
        if (state != null) {
          state = state!.copyWith(state: TaskState.failed);
        }
      },
      onDone: () {
        debugPrint('[A2ATask] done');
        if (state != null && state!.state == TaskState.working) {
          state = state!.copyWith(state: TaskState.completed);
        }
      },
    );
  }

  /// 取消当前任务
  Future<void> cancel() async {
    await _sub?.cancel();
    if (state != null) {
      state = state!.copyWith(state: TaskState.canceled);
    }
  }

  /// 清理
  void clear() {
    _sub?.cancel();
    _sub = null;
    state = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final a2aTaskRuntimeProvider = StateNotifierProvider<A2ATaskRuntimeNotifier, A2ATaskRuntime?>(
  (ref) => A2ATaskRuntimeNotifier(ref),
);

/// 当前选中的 A2A Agent（会话级）
class SelectedA2AAgentNotifier extends StateNotifier<String?> {
  SelectedA2AAgentNotifier() : super(null);

  void select(String? agentName) {
    state = agentName;
  }
}

final selectedA2AAgentProvider = StateNotifierProvider<SelectedA2AAgentNotifier, String?>(
  (ref) => SelectedA2AAgentNotifier(),
);

/// MJ Nexus 内置 A2A Server（用于演示和测试）
final mjNexusA2AServerProvider = Provider<A2AServer>((ref) {
  return A2AServer();
});
