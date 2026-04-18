import '../storage/database.dart' show Session, Message;

abstract class ISessionManager {
  Future<Session> createSession(SessionConfig config);
  Future<void> deleteSession(String sessionId);
  Future<Session> getSession(String sessionId);
  Future<List<Session>> getAllSessions();
  Future<void> switchSession(String sessionId);
  Future<void> updateSessionConfig(String sessionId, SessionConfig config);
  Stream<SessionState> get sessionStateStream;
  SessionState get currentState;
}

class SessionConfig {
  final String name;
  final String modelId;
  final String? systemPrompt;
  final Map<String, dynamic>? inferenceParams;
  final List<String>? enabledSkills;
  final List<String>? boundKnowledgeBases;
  final bool enableGlobalMemory;
  final bool enableVideoUnderstanding;

  const SessionConfig({
    required this.name,
    required this.modelId,
    this.systemPrompt,
    this.inferenceParams,
    this.enabledSkills,
    this.boundKnowledgeBases,
    this.enableGlobalMemory = true,
    this.enableVideoUnderstanding = false,
  });
}

class SessionState {
  final Session? activeSession;
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.activeSession,
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    Session? activeSession,
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      activeSession: activeSession ?? this.activeSession,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
