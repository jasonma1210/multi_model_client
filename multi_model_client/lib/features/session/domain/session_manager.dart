import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/interfaces/session_interface.dart';
import '../../../core/storage/database.dart' show Session, Message;
import '../data/repositories/session_repository.dart';
import '../data/repositories/message_repository.dart';

class SessionManager implements ISessionManager {
  final SessionRepository _sessionRepository;
  final MessageRepository _messageRepository;

  final _sessionStateController = StreamController<SessionState>.broadcast();
  SessionState _currentState = const SessionState();

  SessionManager({
    required SessionRepository sessionRepository,
    required MessageRepository messageRepository,
  })  : _sessionRepository = sessionRepository,
        _messageRepository = messageRepository;

  @override
  Stream<SessionState> get sessionStateStream => _sessionStateController.stream;

  @override
  SessionState get currentState => _currentState;

  @override
  Future<Session> createSession(SessionConfig config) async {
    _updateState(_currentState.copyWith(isLoading: true));

    try {
      // Create session in database
      final session = await _sessionRepository.createSession(
        name: config.name,
        modelId: config.modelId,
        systemPrompt: config.systemPrompt,
        inferenceParams: config.inferenceParams,
      );

      // Load initial messages
      final messages = await _messageRepository.getSessionMessages(session.id);

      final newState = SessionState(
        activeSession: session,
        messages: messages,
        isLoading: false,
      );

      _updateState(newState);

      return session;
    } catch (e) {
      _updateState(SessionState(
        isLoading: false,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Delete session and all related data
      await _sessionRepository.deleteSession(sessionId);

      // If this was the active session, clear it
      if (_currentState.activeSession?.id == sessionId) {
        _updateState(const SessionState());
      } else {
        // 发送状态更新，通知监听者会话列表已更改
        _updateState(_currentState.copyWith(
          isLoading: false,
          error: null,
        ));
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }

  /// 清空会话消息
  Future<void> clearMessages(String sessionId) async {
    try {
      await _messageRepository.deleteSessionMessages(sessionId);
      // 如果是当前活跃会话，刷新状态
      if (_currentState.activeSession?.id == sessionId) {
        _updateState(_currentState.copyWith(
          messages: [],
          isLoading: false,
        ));
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }

  @override
  Future<Session> getSession(String sessionId) async {
    final session = await _sessionRepository.getSession(sessionId);
    if (session == null) {
      throw StateError('Session $sessionId not found');
    }
    return session;
  }

  @override
  Future<List<Session>> getAllSessions() async {
    return await _sessionRepository.getAllSessions();
  }

  @override
  Future<void> switchSession(String sessionId) async {
    _updateState(_currentState.copyWith(isLoading: true));

    try {
      // Load the session
      final session = await getSession(sessionId);

      // Load session messages
      final messages = await _messageRepository.getSessionMessages(sessionId);

      // Update state with new active session
      _updateState(SessionState(
        activeSession: session,
        messages: messages,
        isLoading: false,
      ));
    } catch (e) {
      _updateState(SessionState(
        isLoading: false,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  @override
  Future<void> updateSessionConfig(String sessionId, SessionConfig config) async {
    try {
      await _sessionRepository.updateSession(
        id: sessionId,
        name: config.name,
        modelId: config.modelId,
        systemPrompt: config.systemPrompt,
        inferenceParams: config.inferenceParams,
      );

      // Reload if this is the active session
      if (_currentState.activeSession?.id == sessionId) {
        await switchSession(sessionId);
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }

  /// 更新会话（通用方法）
  Future<void> updateSession(String sessionId, {
    String? name,
    String? modelId,
    String? folderId,
    String? systemPrompt,
    Map<String, dynamic>? inferenceParams,
    bool? isPinned,
    bool? isArchived,
    bool? enableVoiceOutput,
    String? enabledSkill,
    String? enabledKnowledgeBaseId,
  }) async {
    try {
      await _sessionRepository.updateSession(
        id: sessionId,
        name: name,
        modelId: modelId,
        folderId: folderId,
        systemPrompt: systemPrompt,
        inferenceParams: inferenceParams,
        isPinned: isPinned,
        isArchived: isArchived,
        enableVoiceOutput: enableVoiceOutput,
        enabledSkill: enabledSkill,
        enabledKnowledgeBaseId: enabledKnowledgeBaseId,
      );

      // Reload if this is the active session
      if (_currentState.activeSession?.id == sessionId) {
        await switchSession(sessionId);
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }

  /// 更新会话的 MCP 服务器列表
  Future<void> updateEnabledMcpServers(String sessionId, List<String> enabledServerIds) async {
    try {
      await _sessionRepository.updateEnabledMcpServers(sessionId, enabledServerIds);

      // Reload if this is the active session
      if (_currentState.activeSession?.id == sessionId) {
        await switchSession(sessionId);
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }

  /// 更新会话的语音播报设置
  Future<void> updateSessionVoiceOutput(String sessionId, bool enableVoiceOutput) async {
    try {
      await _sessionRepository.updateSession(
        id: sessionId,
        enableVoiceOutput: enableVoiceOutput,
      );

      // Reload if this is the active session
      if (_currentState.activeSession?.id == sessionId) {
        await switchSession(sessionId);
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }
  
  /// 更新会话的技能
  Future<void> updateEnabledSkill(String sessionId, String? skillId) async {
    try {
      await _sessionRepository.updateEnabledSkill(sessionId, skillId);

      // Reload if this is the active session
      if (_currentState.activeSession?.id == sessionId) {
        await switchSession(sessionId);
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }

  /// 更新会话的知识库关联
  Future<void> updateSessionKnowledgeBase(String sessionId, String? knowledgeBaseId) async {
    try {
      await _sessionRepository.updateSession(
        id: sessionId,
        enabledKnowledgeBaseId: knowledgeBaseId,
      );

      // Reload if this is the active session
      if (_currentState.activeSession?.id == sessionId) {
        await switchSession(sessionId);
      }
    } catch (e) {
      _updateState(SessionState(error: e.toString()));
      rethrow;
    }
  }

  // Add message to active session
  Future<void> addMessage(String role, String content) async {
    if (_currentState.activeSession == null) {
      throw StateError('No active session');
    }

    final message = await _messageRepository.createMessage(
      sessionId: _currentState.activeSession!.id,
      role: role,
      content: content,
    );

    _updateState(_currentState.copyWith(
      messages: [..._currentState.messages, message],
    ));
  }

  // Get messages for active session
  Future<List<Message>> getMessages() async {
    if (_currentState.activeSession == null) {
      return [];
    }

    return await _messageRepository.getSessionMessages(
      _currentState.activeSession!.id,
    );
  }

  /// 刷新当前会话的消息列表（不重置 isLoading 状态，避免 UI 闪烁）
  /// 在 AI 回复写入数据库后调用此方法，确保消息列表显示最新内容
  Future<void> refreshCurrentSession() async {
    if (_currentState.activeSession == null) return;
    try {
      final messages = await _messageRepository.getSessionMessages(
        _currentState.activeSession!.id,
      );
      _updateState(_currentState.copyWith(
        messages: messages,
        isLoading: false,
      ));
    } catch (e) {
      // 刷新失败时静默忽略，不影响已有状态
      debugPrint('refreshCurrentSession failed: $e');
    }
  }

  // Clear session context
  Future<void> clearContext(String sessionId) async {
    await _messageRepository.deleteSessionMessages(sessionId);

    if (_currentState.activeSession?.id == sessionId) {
      _updateState(_currentState.copyWith(messages: []));
    }
  }

  /// 搜索会话（按名称模糊匹配）
  Future<List<Session>> searchSessions(String query) async {
    return await _sessionRepository.searchSessions(query);
  }

  /// 重命名会话
  Future<void> renameSession(String sessionId, String newName) async {
    await _sessionRepository.renameSession(sessionId, newName);
    
    // 如果是当前活跃会话，刷新状态
    if (_currentState.activeSession?.id == sessionId) {
      await switchSession(sessionId);
    }
  }

  void _updateState(SessionState newState) {
    _currentState = newState;
    _sessionStateController.add(newState);
  }

  void dispose() {
    _sessionStateController.close();
  }
}

// Riverpod Provider
final sessionManagerProvider = Provider<SessionManager>((ref) {
  final manager = SessionManager(
    sessionRepository: SessionRepository(),
    messageRepository: MessageRepository(),
  );

  ref.onDispose(() => manager.dispose());

  return manager;
});

// ─── StateNotifier 包装器 ───────────────────────────────────────────────────
// 把 SessionManager 的 stream 桥接到 Riverpod StateNotifier，
// 这样 Riverpod 会持有最新状态，新订阅者立刻拿到缓存值，不再 loading / error。
class _SessionStateNotifier extends StateNotifier<SessionState> {
  final SessionManager _manager;
  StreamSubscription<SessionState>? _sub;

  _SessionStateNotifier(this._manager) : super(_manager.currentState) {
    _sub = _manager.sessionStateStream.listen((s) => state = s);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final sessionStateProvider =
    StateNotifierProvider<_SessionStateNotifier, SessionState>((ref) {
  final manager = ref.watch(sessionManagerProvider);
  return _SessionStateNotifier(manager);
});
