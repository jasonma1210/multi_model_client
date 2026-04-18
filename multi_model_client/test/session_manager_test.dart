import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:multi_model_client/features/session/domain/session_manager.dart';
import 'package:multi_model_client/features/session/data/repositories/session_repository.dart';
import 'package:multi_model_client/features/session/data/repositories/message_repository.dart';
import 'package:multi_model_client/core/storage/database.dart';
import 'package:multi_model_client/core/interfaces/session_interface.dart';

// Mock classes
class MockSessionRepository extends Mock implements SessionRepository {}

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  group('SessionManager', () {
    late SessionManager sessionManager;
    late MockSessionRepository mockSessionRepository;
    late MockMessageRepository mockMessageRepository;

    setUp(() {
      mockSessionRepository = MockSessionRepository();
      mockMessageRepository = MockMessageRepository();
      sessionManager = SessionManager(
        sessionRepository: mockSessionRepository,
        messageRepository: mockMessageRepository,
      );
    });

    tearDown(() {
      sessionManager.dispose();
    });

    group('createSession', () {
      test('should create session successfully', () async {
        // Arrange
        final config = SessionConfig(
          name: 'Test Session',
          modelId: 'test-model',
          systemPrompt: 'You are a helpful assistant',
          inferenceParams: {},
        );

        final expectedSession = Session(
          id: 'session-1',
          name: config.name,
          modelId: config.modelId,
          systemPrompt: config.systemPrompt,
          inferenceParams: config.inferenceParams != null
              ? '{"params": ${config.inferenceParams}}'
              : null,
          isPinned: false,
          isArchived: false,
          enableGlobalMemory: true,
          enableVideoUnderstanding: false,
          enableWebSearch: false,
          enableVoiceInput: false,
          enableVoiceOutput: false,
          enableCamera: false,
          enableFileUpload: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockSessionRepository.createSession(
              name: config.name,
              modelId: config.modelId,
              systemPrompt: config.systemPrompt,
              inferenceParams: config.inferenceParams,
            )).thenAnswer((_) async => expectedSession);

        when(() => mockMessageRepository.getSessionMessages(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await sessionManager.createSession(config);

        // Assert
        expect(result.id, equals('session-1'));
        expect(result.name, equals('Test Session'));
        expect(result.modelId, equals('test-model'));

        verify(() => mockSessionRepository.createSession(
              name: config.name,
              modelId: config.modelId,
              systemPrompt: config.systemPrompt,
              inferenceParams: config.inferenceParams,
            )).called(1);

        // Verify state was updated
        expect(sessionManager.currentState.activeSession?.id, equals('session-1'));
        expect(sessionManager.currentState.isLoading, isFalse);
      });

      test('should handle creation error', () async {
        // Arrange
        final config = SessionConfig(
          name: 'Test Session',
          modelId: 'test-model',
        );

        when(() => mockSessionRepository.createSession(
              name: any(named: 'name'),
              modelId: any(named: 'modelId'),
              systemPrompt: any(named: 'systemPrompt'),
              inferenceParams: any(named: 'inferenceParams'),
            )).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => sessionManager.createSession(config),
          throwsException,
        );

        expect(sessionManager.currentState.isLoading, isFalse);
        expect(sessionManager.currentState.error, isNotNull);
      });
    });

    group('switchSession', () {
      test('should switch to existing session', () async {
        // Arrange
        final sessionId = 'session-1';
        final session = Session(
          id: sessionId,
          name: 'Test Session',
          modelId: 'test-model',
          isPinned: false,
          isArchived: false,
          enableGlobalMemory: true,
          enableVideoUnderstanding: false,
          enableWebSearch: false,
          enableVoiceInput: false,
          enableVoiceOutput: false,
          enableCamera: false,
          enableFileUpload: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final List<Message> messages = [
          Message(
            id: 'msg-1',
            sessionId: sessionId,
            role: 'user',
            content: 'Hello',
            type: 'text',
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockSessionRepository.getSession(sessionId))
            .thenAnswer((_) async => session);

        when(() => mockMessageRepository.getSessionMessages(sessionId))
            .thenAnswer((_) async => messages);

        // Act
        await sessionManager.switchSession(sessionId);

        // Assert
        expect(sessionManager.currentState.activeSession?.id, equals(sessionId));
        expect(sessionManager.currentState.messages.length, equals(1));
        expect(sessionManager.currentState.isLoading, isFalse);

        verify(() => mockSessionRepository.getSession(sessionId)).called(1);
        verify(() => mockMessageRepository.getSessionMessages(sessionId)).called(1);
      });

      test('should throw error for non-existent session', () async {
        // Arrange
        final sessionId = 'non-existent';

        when(() => mockSessionRepository.getSession(sessionId))
            .thenAnswer((_) async => null);

        // Act & Assert
        await expectLater(
          () => sessionManager.switchSession(sessionId),
          throwsA(isA<StateError>()),
        );

        // Verify error state after exception
        await Future.delayed(Duration(milliseconds: 100)); // Wait for state update
        expect(sessionManager.currentState.isLoading, isFalse);
        expect(sessionManager.currentState.error, isNotNull);
      });
    });

    group('deleteSession', () {
      test('should delete session successfully', () async {
        // Arrange
        final sessionId = 'session-1';

        // First create and activate a session
        final session = Session(
          id: sessionId,
          name: 'Test',
          modelId: 'model-1',
          isPinned: false,
          isArchived: false,
          enableGlobalMemory: true,
          enableVideoUnderstanding: false,
          enableWebSearch: false,
          enableVoiceInput: false,
          enableVoiceOutput: false,
          enableCamera: false,
          enableFileUpload: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockSessionRepository.createSession(
              name: any(named: 'name'),
              modelId: any(named: 'modelId'),
              systemPrompt: any(named: 'systemPrompt'),
              inferenceParams: any(named: 'inferenceParams'),
            )).thenAnswer((_) async => session);

        when(() => mockMessageRepository.getSessionMessages(any()))
            .thenAnswer((_) async => []);

        await sessionManager.createSession(SessionConfig(
          name: 'Test',
          modelId: 'model-1',
        ));

        // Now delete it
        when(() => mockSessionRepository.deleteSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await sessionManager.deleteSession(sessionId);

        // Assert
        expect(sessionManager.currentState.activeSession, isNull);

        verify(() => mockSessionRepository.deleteSession(sessionId)).called(1);
      });

      test('should handle deletion error', () async {
        // Arrange
        final sessionId = 'session-1';

        when(() => mockSessionRepository.deleteSession(sessionId))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => sessionManager.deleteSession(sessionId),
          throwsException,
        );

        expect(sessionManager.currentState.error, isNotNull);
      });
    });

    group('updateSessionConfig', () {
      test('should update session config', () async {
        // Arrange
        final sessionId = 'session-1';
        final oldSession = Session(
          id: sessionId,
          name: 'Old Name',
          modelId: 'old-model',
          isPinned: false,
          isArchived: false,
          enableGlobalMemory: true,
          enableVideoUnderstanding: false,
          enableWebSearch: false,
          enableVoiceInput: false,
          enableVoiceOutput: false,
          enableCamera: false,
          enableFileUpload: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final newConfig = SessionConfig(
          name: 'New Name',
          modelId: 'new-model',
          systemPrompt: 'New prompt',
        );

        // Setup initial session
        when(() => mockSessionRepository.getSession(sessionId))
            .thenAnswer((_) async => oldSession);

        when(() => mockMessageRepository.getSessionMessages(any()))
            .thenAnswer((_) async => []);

        await sessionManager.switchSession(sessionId);

        // Setup update
        when(() => mockSessionRepository.updateSession(
              id: sessionId,
              name: newConfig.name,
              modelId: newConfig.modelId,
              systemPrompt: newConfig.systemPrompt,
              inferenceParams: newConfig.inferenceParams,
            )).thenAnswer((_) async {});

        // Act
        await sessionManager.updateSessionConfig(sessionId, newConfig);

        // Assert
        verify(() => mockSessionRepository.updateSession(
              id: sessionId,
              name: newConfig.name,
              modelId: newConfig.modelId,
              systemPrompt: newConfig.systemPrompt,
              inferenceParams: newConfig.inferenceParams,
            )).called(1);
      });
    });

    group('getAllSessions', () {
      test('should return all sessions', () async {
        // Arrange
        final sessions = [
          Session(
            id: 'session-1',
            name: 'Session 1',
            modelId: 'model-1',
            isPinned: false,
            isArchived: false,
            enableGlobalMemory: true,
            enableVideoUnderstanding: false,
            enableWebSearch: false,
            enableVoiceInput: false,
            enableVoiceOutput: false,
            enableCamera: false,
            enableFileUpload: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Session(
            id: 'session-2',
            name: 'Session 2',
            modelId: 'model-2',
            isPinned: false,
            isArchived: false,
            enableGlobalMemory: true,
            enableVideoUnderstanding: false,
            enableWebSearch: false,
            enableVoiceInput: false,
            enableVoiceOutput: false,
            enableCamera: false,
            enableFileUpload: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockSessionRepository.getAllSessions())
            .thenAnswer((_) async => sessions);

        // Act
        final result = await sessionManager.getAllSessions();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].name, equals('Session 1'));
        expect(result[1].name, equals('Session 2'));

        verify(() => mockSessionRepository.getAllSessions()).called(1);
      });
    });

    group('addMessage', () {
      test('should add message to active session', () async {
        // Arrange
        final session = Session(
          id: 'session-1',
          name: 'Test',
          modelId: 'model-1',
          isPinned: false,
          isArchived: false,
          enableGlobalMemory: true,
          enableVideoUnderstanding: false,
          enableWebSearch: false,
          enableVoiceInput: false,
          enableVoiceOutput: false,
          enableCamera: false,
          enableFileUpload: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup active session
        when(() => mockSessionRepository.createSession(
              name: any(named: 'name'),
              modelId: any(named: 'modelId'),
              systemPrompt: any(named: 'systemPrompt'),
              inferenceParams: any(named: 'inferenceParams'),
            )).thenAnswer((_) async => session);

        when(() => mockMessageRepository.getSessionMessages(any()))
            .thenAnswer((_) async => []);

        await sessionManager.createSession(SessionConfig(
          name: 'Test',
          modelId: 'model-1',
        ));

        // Setup message creation
        final message = Message(
          id: 'msg-1',
          sessionId: 'session-1',
          role: 'user',
          content: 'Test message',
          type: 'text',
          createdAt: DateTime.now(),
        );

        when(() => mockMessageRepository.createMessage(
              sessionId: 'session-1',
              role: 'user',
              content: 'Test message',
            )).thenAnswer((_) async => message);

        // Act
        await sessionManager.addMessage('user', 'Test message');

        // Assert
        expect(sessionManager.currentState.messages.length, equals(1));
        expect(sessionManager.currentState.messages[0].content, equals('Test message'));

        verify(() => mockMessageRepository.createMessage(
              sessionId: 'session-1',
              role: 'user',
              content: 'Test message',
            )).called(1);
      });

      test('should throw error when no active session', () async {
        // Act & Assert
        expect(
          () => sessionManager.addMessage('user', 'Test'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('clearContext', () {
      test('should clear all messages for session', () async {
        // Arrange
        final sessionId = 'session-1';

        when(() => mockMessageRepository.deleteSessionMessages(sessionId))
            .thenAnswer((_) async {});

        // Act
        await sessionManager.clearContext(sessionId);

        // Assert
        verify(() => mockMessageRepository.deleteSessionMessages(sessionId))
            .called(1);
      });
    });

    group('state management', () {
      test('should emit state changes through stream', () async {
        // Arrange
        final completer = Completer<void>();
        final states = <SessionState>[];

        final subscription = sessionManager.sessionStateStream.listen(
          (state) {
            states.add(state);
            if (!state.isLoading && state.activeSession != null) {
              completer.complete();
            }
          },
        );

        final config = SessionConfig(
          name: 'Test',
          modelId: 'model-1',
        );

        final session = Session(
          id: 'session-1',
          name: 'Test',
          modelId: 'model-1',
          isPinned: false,
          isArchived: false,
          enableGlobalMemory: true,
          enableVideoUnderstanding: false,
          enableWebSearch: false,
          enableVoiceInput: false,
          enableVoiceOutput: false,
          enableCamera: false,
          enableFileUpload: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockSessionRepository.createSession(
              name: any(named: 'name'),
              modelId: any(named: 'modelId'),
              systemPrompt: any(named: 'systemPrompt'),
              inferenceParams: any(named: 'inferenceParams'),
            )).thenAnswer((_) async => session);

        when(() => mockMessageRepository.getSessionMessages(any()))
            .thenAnswer((_) async => []);

        // Act
        await sessionManager.createSession(config);
        await completer.future.timeout(Duration(seconds: 1));

        // Assert
        expect(states.length, greaterThanOrEqualTo(1));
        expect(states.last.isLoading, isFalse);
        expect(states.last.activeSession?.id, equals('session-1'));

        await subscription.cancel();
      });
    });
  });
}
