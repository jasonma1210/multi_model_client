/// 回归测试：验证实时语音文本不再重复
///
/// 背景：
///   DialogueEngine.streamResponse() 会先逐 token yield (isComplete: false)，
///   最后再 yield 一次完整内容 (isComplete: true)。
///   消费者必须正确区分这两种 yield，否则会重复累加内容。
///
/// 这个测试模拟实时语音页面的 _processWithLLM 消费者逻辑，
/// 验证最终的 fullResponse 不会重复。
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/interfaces/dialogue_interface.dart';

void main() {
  group('实时语音文本不重复测试', () {
    test('逐 token 流 + isComplete 完整内容不导致重复', () async {
      // ──────── 模拟 LLM 流式输出 ────────
      Stream<DialogueResponse> mockStream() async* {
        // 逐 token 输出
        for (final token in ['你', '好', '，', '世界', '！']) {
          yield DialogueResponse(content: token, isComplete: false);
          await Future.delayed(const Duration(milliseconds: 1));
        }
        // 最后 yield 一次完整内容（标记 isComplete: true）
        yield DialogueResponse(content: '你好，世界！', isComplete: true);
      }

      // ──────── 模拟修复后的消费者逻辑 ────────
      String fullResponse = '';
      final messages = <String>[];

      await for (final chunk in mockStream()) {
        // ★ 关键修复：遇到 isComplete 为 true 时停止累加
        if (chunk.isComplete) {
          break;
        }
        fullResponse += chunk.content;
      }
      messages.add(fullResponse);

      // ──────── 验证 ────────
      expect(fullResponse, '你好，世界！', reason: 'fullResponse 应该是单次完整文本');
      expect(messages.length, 1);
      expect(messages.first, '你好，世界！');
    });

    test('对照：旧逻辑（不做 isComplete 判断）会导致重复', () async {
      Stream<DialogueResponse> mockStream() async* {
        for (final token in ['你', '好', '，', '世界', '！']) {
          yield DialogueResponse(content: token, isComplete: false);
        }
        yield DialogueResponse(content: '你好，世界！', isComplete: true);
      }

      // 旧逻辑：无条件累加
      String fullResponse = '';
      await for (final chunk in mockStream()) {
        fullResponse += chunk.content;
      }

      // 验证重复（确认修复前的 bug 现象）
      expect(
        fullResponse,
        '你好，世界！你好，世界！',
        reason: '旧逻辑确实会重复（旧 bug 表现）',
      );
    });

    test('空响应（仅 isComplete: true 但 content 为空）不应误判', () async {
      Stream<DialogueResponse> mockStream() async* {
        // 某些边界场景：只有结束标记，没有内容
        yield DialogueResponse(content: '', isComplete: true);
      }

      String fullResponse = '';
      await for (final chunk in mockStream()) {
        if (chunk.isComplete) break;
        fullResponse += chunk.content;
      }

      expect(fullResponse, isEmpty);
    });

    test('多 token + 中间 yield isComplete（异常场景）只取第一个结束标记前', () async {
      Stream<DialogueResponse> mockStream() async* {
        yield DialogueResponse(content: 'Hello', isComplete: false);
        yield DialogueResponse(content: ' World', isComplete: false);
        yield DialogueResponse(content: 'Hello World', isComplete: true);
      }

      String fullResponse = '';
      await for (final chunk in mockStream()) {
        if (chunk.isComplete) break;
        fullResponse += chunk.content;
      }

      expect(fullResponse, 'Hello World');
      expect(fullResponse.length, 11);
    });

    test('长文本流（100 tokens）累加结果应与完整内容完全一致', () async {
      final tokens = List.generate(100, (i) => 't$i');
      final fullExpected = tokens.join('');

      Stream<DialogueResponse> mockStream() async* {
        for (final t in tokens) {
          yield DialogueResponse(content: t, isComplete: false);
        }
        yield DialogueResponse(content: fullExpected, isComplete: true);
      }

      String fullResponse = '';
      await for (final chunk in mockStream()) {
        if (chunk.isComplete) break;
        fullResponse += chunk.content;
      }

      expect(fullResponse, fullExpected);
      expect(fullResponse.length, fullExpected.length);
    });
  });
}
