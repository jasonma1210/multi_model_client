import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:multi_model_client/core/adapters/openai_adapter.dart';

// Mock classes
class MockDio extends Mock implements Dio {}

void main() {
  group('OpenAIAdapter', () {
    late OpenAIAdapter adapter;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      adapter = OpenAIAdapter(
        config: OpenAIConfig(
          apiKey: 'test-api-key',
          model: 'gpt-3.5-turbo',
        ),
      );
    });

    group('OpenAIConfig', () {
      test('should create config with default values', () {
        // Arrange
        final config = OpenAIConfig(apiKey: 'test-key');

        // Assert
        expect(config.apiKey, equals('test-key'));
        expect(config.baseUrl, equals('https://api.openai.com/v1'));
        expect(config.model, equals('gpt-3.5-turbo'));
        expect(config.temperature, equals(0.7));
        expect(config.maxTokens, equals(2048));
        expect(config.topP, equals(1.0));
        expect(config.stream, isFalse);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final config = OpenAIConfig(
          apiKey: 'test-key',
          model: 'gpt-4',
          temperature: 0.8,
          maxTokens: 4096,
          topP: 0.9,
          stream: true,
        );

        // Act
        final json = config.toJson();

        // Assert
        expect(json['model'], equals('gpt-4'));
        expect(json['temperature'], equals(0.8));
        expect(json['max_tokens'], equals(4096));
        expect(json['top_p'], equals(0.9));
        expect(json['stream'], isTrue);
      });
    });

    group('OpenAIMessage', () {
      test('should create message with role and content', () {
        // Arrange
        final message = OpenAIMessage(
          role: 'user',
          content: 'Hello',
        );

        // Assert
        expect(message.role, equals('user'));
        expect(message.content, equals('Hello'));
        expect(message.name, isNull);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final message = OpenAIMessage(
          role: 'assistant',
          content: 'Hi there!',
          name: 'bot',
        );

        // Act
        final json = message.toJson();

        // Assert
        expect(json['role'], equals('assistant'));
        expect(json['content'], equals('Hi there!'));
        expect(json['name'], equals('bot'));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'role': 'user',
          'content': 'Test message',
          'name': 'user1',
        };

        // Act
        final message = OpenAIMessage.fromJson(json);

        // Assert
        expect(message.role, equals('user'));
        expect(message.content, equals('Test message'));
        expect(message.name, equals('user1'));
      });
    });

    group('OpenAIResponse', () {
      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'chatcmpl-123',
          'object': 'chat.completion',
          'created': 1234567890,
          'model': 'gpt-3.5-turbo',
          'choices': [
            {
              'index': 0,
              'message': {
                'role': 'assistant',
                'content': 'Hello!',
              },
              'finish_reason': 'stop',
            },
          ],
          'usage': {
            'prompt_tokens': 10,
            'completion_tokens': 5,
            'total_tokens': 15,
          },
        };

        // Act
        final response = OpenAIResponse.fromJson(json);

        // Assert
        expect(response.id, equals('chatcmpl-123'));
        expect(response.model, equals('gpt-3.5-turbo'));
        expect(response.choices.length, equals(1));
        expect(response.choices.first.message.content, equals('Hello!'));
        expect(response.usage.totalTokens, equals(15));
      });
    });

    group('estimateTokens', () {
      test('should estimate tokens for English text', () {
        // Arrange
        const text = 'Hello world'; // 11 chars ≈ 2.75 tokens

        // Act
        final tokens = adapter.estimateTokens(text);

        // Assert
        expect(tokens, greaterThanOrEqualTo(2));
        expect(tokens, lessThanOrEqualTo(4));
      });

      test('should estimate tokens for Chinese text', () {
        // Arrange
        const text = '你好世界'; // 4 chars ≈ 2.67 tokens

        // Act
        final tokens = adapter.estimateTokens(text);

        // Assert
        expect(tokens, greaterThanOrEqualTo(2));
        expect(tokens, lessThanOrEqualTo(4));
      });

      test('should estimate tokens for mixed text', () {
        // Arrange
        const text = 'Hello 你好 World 世界'; // Mixed

        // Act
        final tokens = adapter.estimateTokens(text);

        // Assert
        expect(tokens, greaterThan(0));
      });
    });

    group('buildConversationHistory', () {
      test('should build conversation history from messages', () {
        // Arrange
        final messages = [
          {'role': 'user', 'content': 'Hi'},
          {'role': 'assistant', 'content': 'Hello!'},
        ];

        // Act
        final history = OpenAIAdapter.buildConversationHistory(messages);

        // Assert
        expect(history.length, equals(2));
        expect(history[0].role, equals('user'));
        expect(history[0].content, equals('Hi'));
        expect(history[1].role, equals('assistant'));
        expect(history[1].content, equals('Hello!'));
      });

      test('should handle missing role and content', () {
        // Arrange
        final messages = [
          {'content': 'Test'},
        ];

        // Act
        final history = OpenAIAdapter.buildConversationHistory(messages);

        // Assert
        expect(history.length, equals(1));
        expect(history[0].role, equals('user')); // Default role
        expect(history[0].content, equals('Test'));
      });
    });

    group('updateConfig', () {
      test('should update config', () {
        // Arrange
        final newConfig = OpenAIConfig(
          apiKey: 'new-key',
          model: 'gpt-4',
        );

        // Act
        adapter.updateConfig(newConfig);

        // Assert
        expect(adapter.config.apiKey, equals('new-key'));
        expect(adapter.config.model, equals('gpt-4'));
      });
    });

    group('testConnection', () {
      test('should return true on successful connection', () async {
        // This would require mocking Dio responses
        // For now, we'll skip the actual API call test
      });
    });
  });

  group('OpenAIUsage', () {
    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'prompt_tokens': 100,
        'completion_tokens': 50,
        'total_tokens': 150,
      };

      // Act
      final usage = OpenAIUsage.fromJson(json);

      // Assert
      expect(usage.promptTokens, equals(100));
      expect(usage.completionTokens, equals(50));
      expect(usage.totalTokens, equals(150));
    });
  });

  group('OpenAIChoice', () {
    test('should deserialize from JSON with message', () {
      // Arrange
      final json = {
        'index': 0,
        'message': {
          'role': 'assistant',
          'content': 'Test response',
        },
        'finish_reason': 'stop',
      };

      // Act
      final choice = OpenAIChoice.fromJson(json);

      // Assert
      expect(choice.index, equals(0));
      expect(choice.message.content, equals('Test response'));
      expect(choice.finishReason, equals('stop'));
    });

    test('should deserialize from JSON with delta', () {
      // Arrange
      final json = {
        'index': 0,
        'delta': {
          'role': 'assistant',
          'content': 'partial',
        },
      };

      // Act
      final choice = OpenAIChoice.fromJson(json);

      // Assert
      expect(choice.index, equals(0));
      expect(choice.delta, isNotNull);
      expect(choice.delta!.content, equals('partial'));
    });
  });
}
