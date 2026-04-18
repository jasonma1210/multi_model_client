import 'package:flutter_test/flutter_test.dart';
import 'package:multi_model_client/core/adapters/anthropic_adapter.dart';

void main() {
  group('AnthropicAdapter', () {
    late AnthropicAdapter adapter;

    setUp(() {
      adapter = AnthropicAdapter(
        config: AnthropicConfig(
          apiKey: 'test-api-key',
          model: 'claude-3-5-sonnet-20241022',
        ),
      );
    });

    group('AnthropicConfig', () {
      test('should create config with default values', () {
        // Arrange
        final config = AnthropicConfig(apiKey: 'test-key');

        // Assert
        expect(config.apiKey, equals('test-key'));
        expect(config.baseUrl, equals('https://api.anthropic.com/v1'));
        expect(config.model, equals('claude-3-5-sonnet-20241022'));
        expect(config.maxTokens, equals(4096));
        expect(config.temperature, isNull);
        expect(config.topP, isNull);
        expect(config.stream, isFalse);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final config = AnthropicConfig(
          apiKey: 'test-key',
          model: 'claude-3-opus-20240229',
          maxTokens: 8192,
          temperature: 0.8,
          topP: 0.9,
          topK: 50,
          stream: true,
        );

        // Act
        final json = config.toJson();

        // Assert
        expect(json['model'], equals('claude-3-opus-20240229'));
        expect(json['max_tokens'], equals(8192));
        expect(json['temperature'], equals(0.8));
        expect(json['top_p'], equals(0.9));
        expect(json['top_k'], equals(50));
        expect(json['stream'], isTrue);
      });

      test('should omit null values from JSON', () {
        // Arrange
        final config = AnthropicConfig(
          apiKey: 'test-key',
          maxTokens: 4096,
        );

        // Act
        final json = config.toJson();

        // Assert
        expect(json.containsKey('temperature'), isFalse);
        expect(json.containsKey('top_p'), isFalse);
        expect(json.containsKey('top_k'), isFalse);
      });
    });

    group('AnthropicMessage', () {
      test('should create message with role and content', () {
        // Arrange
        final message = AnthropicMessage(
          role: 'user',
          content: 'Hello',
        );

        // Assert
        expect(message.role, equals('user'));
        expect(message.content, equals('Hello'));
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final message = AnthropicMessage(
          role: 'assistant',
          content: 'Hi there!',
        );

        // Act
        final json = message.toJson();

        // Assert
        expect(json['role'], equals('assistant'));
        expect(json['content'], equals('Hi there!'));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'role': 'user',
          'content': 'Test message',
        };

        // Act
        final message = AnthropicMessage.fromJson(json);

        // Assert
        expect(message.role, equals('user'));
        expect(message.content, equals('Test message'));
      });
    });

    group('AnthropicResponse', () {
      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'msg_123',
          'type': 'message',
          'role': 'assistant',
          'content': [
            {
              'type': 'text',
              'text': 'Hello! How can I help you?',
            },
          ],
          'model': 'claude-3-5-sonnet-20241022',
          'usage': {
            'input_tokens': 20,
            'output_tokens': 15,
          },
          'stop_reason': 'end_turn',
        };

        // Act
        final response = AnthropicResponse.fromJson(json);

        // Assert
        expect(response.id, equals('msg_123'));
        expect(response.role, equals('assistant'));
        expect(response.model, equals('claude-3-5-sonnet-20241022'));
        expect(response.content.length, equals(1));
        expect(response.usage.inputTokens, equals(20));
        expect(response.usage.outputTokens, equals(15));
        expect(response.stopReason, equals('end_turn'));
      });

      test('should extract text from content', () {
        // Arrange
        final json = {
          'id': 'msg_123',
          'type': 'message',
          'role': 'assistant',
          'content': [
            {
              'type': 'text',
              'text': 'First paragraph',
            },
            {
              'type': 'text',
              'text': 'Second paragraph',
            },
          ],
          'model': 'claude-3-5-sonnet-20241022',
          'usage': {
            'input_tokens': 10,
            'output_tokens': 20,
          },
        };

        // Act
        final response = AnthropicResponse.fromJson(json);

        // Assert
        expect(response.text, equals('First paragraph\nSecond paragraph'));
      });
    });

    group('AnthropicContent', () {
      test('should deserialize text content', () {
        // Arrange
        final json = {
          'type': 'text',
          'text': 'Test content',
        };

        // Act
        final content = AnthropicContent.fromJson(json);

        // Assert
        expect(content.type, equals('text'));
        expect(content.text, equals('Test content'));
        expect(content.thinking, isNull);
      });

      test('should deserialize thinking content', () {
        // Arrange
        final json = {
          'type': 'thinking',
          'thinking': 'Let me think...',
        };

        // Act
        final content = AnthropicContent.fromJson(json);

        // Assert
        expect(content.type, equals('thinking'));
        expect(content.thinking, equals('Let me think...'));
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final content = AnthropicContent(
          type: 'text',
          text: 'Test',
        );

        // Act
        final json = content.toJson();

        // Assert
        expect(json['type'], equals('text'));
        expect(json['text'], equals('Test'));
      });
    });

    group('AnthropicUsage', () {
      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'input_tokens': 100,
          'output_tokens': 50,
        };

        // Act
        final usage = AnthropicUsage.fromJson(json);

        // Assert
        expect(usage.inputTokens, equals(100));
        expect(usage.outputTokens, equals(50));
      });
    });

    group('AnthropicStreamEvent', () {
      test('should deserialize content_block_delta event', () {
        // Arrange
        final json = {
          'type': 'content_block_delta',
          'index': 0,
          'delta': {
            'type': 'text_delta',
            'text': 'Hello',
          },
        };

        // Act
        final event = AnthropicStreamEvent.fromJson(json);

        // Assert
        expect(event.type, equals('content_block_delta'));
        expect(event.index, equals(0));
        expect(event.delta, isNotNull);
        expect(event.delta!.text, equals('Hello'));
      });

      test('should deserialize message_stop event', () {
        // Arrange
        final json = {
          'type': 'message_stop',
        };

        // Act
        final event = AnthropicStreamEvent.fromJson(json);

        // Assert
        expect(event.type, equals('message_stop'));
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
    });

    group('buildConversationHistory', () {
      test('should build conversation history from messages', () {
        // Arrange
        final messages = [
          {'role': 'user', 'content': 'Hi'},
          {'role': 'assistant', 'content': 'Hello!'},
        ];

        // Act
        final history = AnthropicAdapter.buildConversationHistory(messages);

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
        final history = AnthropicAdapter.buildConversationHistory(messages);

        // Assert
        expect(history.length, equals(1));
        expect(history[0].role, equals('user')); // Default role
        expect(history[0].content, equals('Test'));
      });
    });

    group('updateConfig', () {
      test('should update config', () {
        // Arrange
        final newConfig = AnthropicConfig(
          apiKey: 'new-key',
          model: 'claude-3-opus-20240229',
        );

        // Act
        adapter.updateConfig(newConfig);

        // Assert
        expect(adapter.config.apiKey, equals('new-key'));
        expect(adapter.config.model, equals('claude-3-opus-20240229'));
      });
    });
  });
}
