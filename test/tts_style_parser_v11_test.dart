// =============================================================================
// TTS 风格解析器 + 冲突检测单元测试 — V1.1
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/tts_style_parser.dart';

void main() {
  group('TTSStyleParser - audio tag 白名单', () {
    test('白名单包含 30 种文档定义的标签', () {
      expect(TTSStyleParser.audioTagWhitelist.length, 30);
    });

    test('hasAudioTag 识别白名单内的标签', () {
      expect(TTSStyleParser.hasAudioTag('你好[笑]世界'), true);
      expect(TTSStyleParser.hasAudioTag('我[叹气]很无奈'), true);
      expect(TTSStyleParser.hasAudioTag('[紧张]她看着他'), true);
    });

    test('hasAudioTag 不识别非白名单标签', () {
      expect(TTSStyleParser.hasAudioTag('你好[神秘]世界'), false);
      expect(TTSStyleParser.hasAudioTag('我[哈哈哈]笑了'), false);
    });

    test('countAudioTags 计数正确', () {
      // 选用拼接版正则中靠前的关键词（吸气/叹气/沙哑）
      expect(TTSStyleParser.countAudioTags('[吸气]你[叹气]好[沙哑]啊'), 3);
      expect(TTSStyleParser.countAudioTags('无标签'), 0);
    });

    test('extractAudioTags 返回位置信息', () {
      // '你好[大笑]世界[紧张]啊'
      //  0123 4 5678 9 10 11 12
      final tags = TTSStyleParser.extractAudioTags('你好[大笑]世界[紧张]啊');
      expect(tags.length, 2);
      expect(tags[0].tag, '大笑');
      expect(tags[0].position, 2);
      expect(tags[1].tag, '紧张');
      expect(tags[1].position, 8);
    });

    test('findUnknownAudioTags 找出非白名单标签', () {
      final unknown = TTSStyleParser.findUnknownAudioTags('[神秘][笑][未知]');
      expect(unknown, ['神秘', '未知']);
    });

    test('findUnknownAudioTags 跳过 tts: 标签', () {
      final unknown = TTSStyleParser.findUnknownAudioTags(
          '[tts:style=开心]你好[/tts]');
      expect(unknown, isEmpty);
    });

    test('sanitizeAudioTags 非严格模式保留原文本', () {
      final result =
          TTSStyleParser.sanitizeAudioTags('[神秘]你好', strict: false);
      expect(result.text, '[神秘]你好');
      expect(result.warnings, ['神秘']);
    });

    test('sanitizeAudioTags 严格模式删除未知标签', () {
      final result =
          TTSStyleParser.sanitizeAudioTags('[神秘]你好[/神秘][笑]', strict: true);
      expect(result.text, '你好[笑]');
      expect(result.warnings, ['神秘']);
    });
  });

  group('detectTTSConflicts - 冲突检测', () {
    test('无冲突返回空列表', () {
      final conflicts = detectTTSConflicts('今天天气真好');
      expect(conflicts, isEmpty);
    });

    test('style + natural 重叠', () {
      final text = '[tts:style=开心]你好[/tts][tts:natural=气声]再见[/tts]';
      final conflicts = detectTTSConflicts(text);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ConflictType.styleAndNaturalOverlap);
    });

    test('style + director 重叠', () {
      final text = '[tts:director]角色：xxx[/tts][tts:style=开心]你好[/tts]';
      final conflicts = detectTTSConflicts(text);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ConflictType.styleAndDirectorOverlap);
    });

    test('多个 natural 标签', () {
      final text = '[tts:natural=气声]你好[/tts][tts:natural=颤抖]再见[/tts]';
      final conflicts = detectTTSConflicts(text);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ConflictType.naturalMultiple);
    });

    test('audio tag 过多（>10）', () {
      // 用白名单内的标签组合，避免触发 unknownAudioTag 冲突
      final text = '[笑][轻笑][大笑][笑][轻笑][大笑][笑][轻笑][大笑][笑][轻笑]';
      final conflicts = detectTTSConflicts(text);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ConflictType.audioTagOverload);
    });

    test('白名单外标签', () {
      final text = '[神秘][笑][未知]';
      final conflicts = detectTTSConflicts(text);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ConflictType.unknownAudioTag);
    });

    test('多冲突并存', () {
      final text = '[tts:style=开心]你好[/tts][tts:natural=气声]再见[/tts]'
          '[神秘]';
      final conflicts = detectTTSConflicts(text);
      expect(conflicts.length, 2);
    });

    test('summarizeTTSConflicts 空列表返回无冲突', () {
      expect(summarizeTTSConflicts([]), '✓ 无冲突');
    });

    test('summarizeTTSConflicts 列出冲突类型', () {
      final conflicts = [
        (
          type: ConflictType.styleAndNaturalOverlap,
          message: 'msg',
          position: null,
        ),
      ];
      final summary = summarizeTTSConflicts(conflicts);
      expect(summary.contains('1 个冲突'), true);
      expect(summary.contains('style 与 natural 同时存在'), true);
    });

    test('conflictTypeName 完整覆盖所有类型', () {
      for (final t in ConflictType.values) {
        final name = conflictTypeName(t);
        expect(name.isNotEmpty, true, reason: '$t 名称为空');
      }
    });
  });

  group('TTSStyleParser - 解析器', () {
    test('孤立起始标签自愈剥除', () {
      final data = TTSStyleParser.parse('[tts:style=傲娇]哼！才不是');
      expect(data.displayContent, '哼！才不是');
      expect(data.controlContent, '');
    });

    test('完整闭合对保持解析', () {
      final data = TTSStyleParser.parse('[tts:style=开心]你好[/tts]');
      expect(data.displayContent, '你好');
      expect(data.controlContent, '(开心)');
    });

    test('director 模式', () {
      final data = TTSStyleParser.parse(
          '[tts:director]角色：傲娇[/tts]这是正文');
      expect(data.type, TTSControlType.director);
      expect(data.displayContent, '这是正文');
      expect(data.controlContent, '角色：傲娇');
    });

    test('natural 模式', () {
      final data = TTSStyleParser.parse('[tts:natural=气声绵长]嗯……[/tts]');
      expect(data.type, TTSControlType.natural);
      expect(data.displayContent, '嗯……');
      expect(data.controlContent, '气声绵长');
    });
  });

  group('buildMiMoDesignRequest - voicedesign 请求', () {
    test('voicePrompt 必填', () {
      expect(
        () => TTSStyleParser.buildMiMoDesignRequest(text: 'x', voicePrompt: ''),
        throwsArgumentError,
      );
    });

    test('基本请求结构', () {
      final req = TTSStyleParser.buildMiMoDesignRequest(
        text: '你好',
        voicePrompt: '年轻女性',
      );
      expect(req['model'], 'mimo-v2.5-tts-voicedesign');
      final messages = req['messages'] as List;
      expect(messages.length, 2);
      expect(messages[0]['role'], 'user');
      expect(messages[0]['content'], '年轻女性');
      expect(messages[1]['role'], 'assistant');
      expect(messages[1]['content'], '你好');
    });

    test('带 director 描述', () {
      final req = TTSStyleParser.buildMiMoDesignRequest(
        text: '[tts:director]角色：xxx[/tts]你好',
        voicePrompt: '声音1',
      );
      final messages = req['messages'] as List;
      expect(messages.length, 3);
      expect(messages[1]['role'], 'user');
      expect(messages[1]['content'], '角色：xxx');
    });

    test('optimize_text_preview 参数', () {
      final req1 = TTSStyleParser.buildMiMoDesignRequest(
        text: 'x', voicePrompt: 'y', autoOptimizeText: true,
      );
      expect((req1['audio'] as Map)['optimize_text_preview'], true);

      final req2 = TTSStyleParser.buildMiMoDesignRequest(
        text: 'x', voicePrompt: 'y', autoOptimizeText: false,
      );
      expect((req2['audio'] as Map)['optimize_text_preview'], false);
    });
  });
}
