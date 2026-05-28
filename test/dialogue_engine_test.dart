import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mj_nexus/core/engines/model_inference_engine.dart';
import 'package:mj_nexus/core/services/context_compressor_service.dart';
import 'package:mj_nexus/core/services/mcp_service_manager.dart';
import 'package:mj_nexus/features/session/domain/dialogue_engine.dart';
import 'package:mj_nexus/features/session/domain/session_manager.dart';
import 'package:mj_nexus/features/session/data/repositories/message_repository.dart';

class MockModelInferenceEngine extends Mock implements ModelInferenceEngine {}

class MockSessionManager extends Mock implements SessionManager {}

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late MockModelInferenceEngine mockModelEngine;
  late MockSessionManager mockSessionManager;
  late MockMessageRepository mockMessageRepository;

  setUp(() {
    mockModelEngine = MockModelInferenceEngine();
    mockSessionManager = MockSessionManager();
    mockMessageRepository = MockMessageRepository();
  });

  group('DialogueEngine 构造函数', () {
    test('使用mock参数构造不抛出异常', () {
      expect(
        () => DialogueEngine(
          modelEngine: mockModelEngine,
          sessionManager: mockSessionManager,
          messageRepository: mockMessageRepository,
        ),
        returnsNormally,
      );
    });

    test('compressionStream不为null', () {
      final engine = DialogueEngine(
        modelEngine: mockModelEngine,
        sessionManager: mockSessionManager,
        messageRepository: mockMessageRepository,
      );

      expect(engine.compressionStream, isNotNull);
    });

    test('使用MCPToolCallNotifier构造', () {
      final notifier = MCPToolCallNotifier();
      final engine = DialogueEngine(
        modelEngine: mockModelEngine,
        sessionManager: mockSessionManager,
        messageRepository: mockMessageRepository,
        mcpNotifier: notifier,
      );

      expect(engine, isNotNull);
      expect(engine.compressionStream, isNotNull);
    });
  });

  group('MCP 通知', () {
    test('notifyMcpToolCall不抛出异常', () {
      final engine = DialogueEngine(
        modelEngine: mockModelEngine,
        sessionManager: mockSessionManager,
        messageRepository: mockMessageRepository,
      );

      final toolCall = MCPToolCall(
        id: 'test-id',
        serverId: 'test-server',
        serverName: '测试服务器',
        toolName: 'test-tool',
        arguments: {'key': 'value'},
        timestamp: DateTime.now(),
      );

      expect(
        () => engine.notifyMcpToolCall(toolCall),
        returnsNormally,
      );
    });

    test('notifyMcpToolCall触发监听器', () {
      final notifier = MCPToolCallNotifier();
      final engine = DialogueEngine(
        modelEngine: mockModelEngine,
        sessionManager: mockSessionManager,
        messageRepository: mockMessageRepository,
        mcpNotifier: notifier,
      );

      bool listenerCalled = false;
      notifier.addListener((call) {
        listenerCalled = true;
      });

      final toolCall = MCPToolCall(
        id: 'test-id-2',
        serverId: 'test-server',
        serverName: '测试服务器',
        toolName: 'test-tool',
        arguments: {'key': 'value'},
        timestamp: DateTime.now(),
      );

      engine.notifyMcpToolCall(toolCall);
      expect(listenerCalled, isTrue);
    });
  });

  group('DialogueEngine 状态', () {
    test('getSearchModeName返回正确名称', () {
      expect(DialogueEngine.getSearchModeName(WebSearchMode.tavily), 'Tavily');
      expect(DialogueEngine.getSearchModeName(WebSearchMode.duckduckgo), 'DuckDuckGo');
      expect(DialogueEngine.getSearchModeName(WebSearchMode.wikipedia), 'Wikipedia');
    });
  });

  group('CompressionEvent', () {
    test('message格式正确', () {
      final event = CompressionEvent(
        originalCount: 100,
        compressedCount: 20,
        strategy: CompressionStrategy.hybrid,
      );

      expect(event.message, contains('100'));
      expect(event.message, contains('20'));
      expect(event.message, contains('80%')); // 100-20=80, 80/100=80%
    });

    test('getter返回正确值', () {
      final event = CompressionEvent(
        originalCount: 50,
        compressedCount: 25,
        strategy: CompressionStrategy.hybrid,
      );

      expect(event.originalCount, 50);
      expect(event.compressedCount, 25);
      expect(event.strategy, CompressionStrategy.hybrid);
    });
  });
}
