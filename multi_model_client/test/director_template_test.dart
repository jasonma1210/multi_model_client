// =============================================================================
// 导演模板库单元测试 — V1.0
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/tts_director_template.dart';

void main() {
  group('DirectorTemplate 数据类', () {
    test('创建基本模板', () {
      const t = DirectorTemplate(
        id: 'test1',
        name: '测试模板',
        category: '自定义',
        role: '测试角色',
        scene: '测试场景',
        direction: '测试指导',
      );
      expect(t.id, 'test1');
      expect(t.name, '测试模板');
      expect(t.isPreset, false);
    });

    test('composed 拼接正确（角色/场景/指导）', () {
      const t = DirectorTemplate(
        id: 't',
        name: 'n',
        category: 'c',
        role: '我是角色',
        scene: '我是场景',
        direction: '我是指导',
      );
      final expected = '角色：我是角色\n场景：我是场景\n指导：我是指导';
      expect(t.composed, expected);
    });

    test('composed 跳过空字段', () {
      const t = DirectorTemplate(
        id: 't',
        name: 'n',
        category: 'c',
        role: '',
        scene: '我有场景',
        direction: '',
      );
      expect(t.composed, '场景：我有场景');
    });

    test('toJson / fromJson 往返一致', () {
      const original = DirectorTemplate(
        id: 't1',
        name: '测试',
        category: '情色系',
        role: 'r',
        scene: 's',
        direction: 'd',
        isPreset: false,
      );
      final json = original.toJson();
      final restored = DirectorTemplate.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.category, original.category);
      expect(restored.role, original.role);
      expect(restored.scene, original.scene);
      expect(restored.direction, original.direction);
      expect(restored.isPreset, original.isPreset);
    });

    test('copyWith 正确替换字段', () {
      const original = DirectorTemplate(
        id: 't1',
        name: '原始',
        category: 'c',
        role: 'r',
        scene: 's',
        direction: 'd',
      );
      final updated = original.copyWith(name: '修改后');
      expect(updated.name, '修改后');
      expect(updated.id, original.id);
      expect(updated.role, original.role);
    });
  });

  group('DirectorTemplatePresets 预置', () {
    test('共 25 套预置', () {
      expect(DirectorTemplatePresets.all.length, 25);
    });

    test('按 4 个分类组织', () {
      final groups = DirectorTemplatePresets.groupedByCategory;
      expect(groups.keys.toSet(),
          {'基础人设', '复杂情绪', '情色系', '特殊场景'});
      expect(groups['基础人设']?.length, 7);
      expect(groups['复杂情绪']?.length, 9);
      expect(groups['情色系']?.length, 7);
      expect(groups['特殊场景']?.length, 2);
    });

    test('情色系包含 7 套预设（诱惑/呢喃/亲密/娇喘/耳语/暧昧/痴情）', () {
      final group = DirectorTemplatePresets.groupedByCategory['情色系']!;
      final ids = group.map((t) => t.id).toSet();
      expect(ids, {
        'seductive',
        'whisper',
        'intimate',
        'panting',
        'earWhisper',
        'ambiguous',
        'infatuated',
      });
    });

    test('复杂情绪覆盖 9 种情绪（愤怒/悲伤/喜悦/恐惧/惊讶/厌恶/纠结/崩溃/嫉妒）', () {
      final group = DirectorTemplatePresets.groupedByCategory['复杂情绪']!;
      final ids = group.map((t) => t.id).toSet();
      expect(ids, {
        'anger',
        'sadness',
        'joy',
        'fear',
        'surprise',
        'disgust',
        'conflicted',
        'breakdown',
        'jealousy',
      });
    });

    test('基础人设覆盖 7 套（傲娇/御姐/病娇/萝莉/猫娘/女王/羞怯少女）', () {
      final group = DirectorTemplatePresets.groupedByCategory['基础人设']!;
      final ids = group.map((t) => t.id).toSet();
      expect(ids, {
        'tsundere',
        'mature_sister',
        'yandere',
        'loli',
        'nekomimi',
        'queen',
        'shy_girl',
      });
    });

    test('特殊场景覆盖 反派/热血', () {
      final group = DirectorTemplatePresets.groupedByCategory['特殊场景']!;
      final ids = group.map((t) => t.id).toSet();
      expect(ids, {'villain', 'hot_blooded'});
    });

    test('所有预置 ID 唯一', () {
      final ids = DirectorTemplatePresets.all.map((t) => t.id).toList();
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, ids.length,
          reason: '存在重复 ID（共 ${ids.length} 个，独立 ${uniqueIds.length} 个）');
    });

    test('findById 找到正确模板', () {
      final t = DirectorTemplatePresets.findById('tsundere');
      expect(t, isNotNull);
      expect(t!.name, '傲娇');
    });

    test('findById 找不到返回 null', () {
      final t = DirectorTemplatePresets.findById('not_exist');
      expect(t, isNull);
    });

    test('每个预置的 isPreset=true', () {
      for (final t in DirectorTemplatePresets.all) {
        expect(t.isPreset, true, reason: '${t.id} 应为预置');
      }
    });

    test('每个预置都包含完整三段', () {
      for (final t in DirectorTemplatePresets.all) {
        expect(t.role.isNotEmpty, true, reason: '${t.id} 角色为空');
        expect(t.scene.isNotEmpty, true, reason: '${t.id} 场景为空');
        expect(t.direction.isNotEmpty, true, reason: '${t.id} 指导为空');
      }
    });

    test('每个情色系模板的语气描述不含露骨内容', () {
      // ★ 情色系聚焦"声音/气息/温度"的情感表达，禁止性行为/生殖器等露骨词
      final inappropriate = RegExp(
          r'(性交|做爱|操|肏|插入|阴茎|阴道|乳头|高潮|自慰|口交|肛交|舔阴|阴蒂|乳房|臀部)');
      for (final t in DirectorTemplatePresets.groupedByCategory['情色系']!) {
        final allText = '${t.role} ${t.scene} ${t.direction}';
        expect(inappropriate.hasMatch(allText), false,
            reason: '${t.id} 包含不恰当内容');
      }
    });

    test('情色系每条模板都强调情感/温度/气息，不描述具体动作', () {
      // 检查每条情色系模板都包含"声音/情感/温度"等正向关键词
      final positiveKeywords = RegExp(
          r'(声音|情感|情绪|气息|温度|亲密|暧昧|心|呼吸|温柔|依赖|撒娇|依赖)');
      for (final t in DirectorTemplatePresets.groupedByCategory['情色系']!) {
        final allText = '${t.role} ${t.scene} ${t.direction}';
        expect(positiveKeywords.hasMatch(allText), true,
            reason: '${t.id} 应包含正向情感关键词');
      }
    });

    test('每个模板的 direction 都包含可量化的语音参数', () {
      // 验证模板的专业性：必须包含语速/气息/共鸣点/音色中的至少 3 项
      for (final t in DirectorTemplatePresets.all) {
        final dir = t.direction;
        int score = 0;
        if (RegExp(r'语速|每分钟').hasMatch(dir)) score++;
        if (RegExp(r'气息|呼吸|换气').hasMatch(dir)) score++;
        if (RegExp(r'共鸣|胸腔|喉部|口腔|鼻腔').hasMatch(dir)) score++;
        if (RegExp(r'音色|沙哑|明亮|低沉|清脆').hasMatch(dir)) score++;
        if (RegExp(r'句尾|句中|停顿|咬字').hasMatch(dir)) score++;
        expect(score >= 3, true,
            reason: '${t.id} 的指导至少应包含语速/气息/共鸣/音色/停顿中 3 项，'
                '当前命中 $score 项');
      }
    });
  });

  group('DirectorTemplateLibrary 持久化', () {
    test('空 JSON 返回预置', () {
      final result = DirectorTemplateLibrary.loadAll(customTemplatesJson: null);
      expect(result.length, DirectorTemplatePresets.all.length);
    });

    test('有效 JSON 解析', () {
      const custom = DirectorTemplate(
        id: 'custom1',
        name: '我的模板',
        category: '自定义',
        role: 'r',
        scene: 's',
        direction: 'd',
        isPreset: false,
      );
      final json = DirectorTemplateLibrary.encodeCustomTemplates([custom]);
      final loaded = DirectorTemplateLibrary.loadAll(customTemplatesJson: json);
      expect(loaded.length, DirectorTemplatePresets.all.length + 1);
      expect(loaded.last.id, 'custom1');
    });

    test('损坏的 JSON 降级为仅预置', () {
      final result =
          DirectorTemplateLibrary.loadAll(customTemplatesJson: 'not-json{');
      expect(result.length, DirectorTemplatePresets.all.length);
    });

    test('extractCustom 只保留非预置', () {
      final all = [
        ...DirectorTemplatePresets.all,
        const DirectorTemplate(
          id: 'c1',
          name: 'c',
          category: '自定义',
          role: '',
          scene: '',
          direction: '',
          isPreset: false,
        ),
      ];
      final customs = DirectorTemplateLibrary.extractCustom(all);
      expect(customs.length, 1);
      expect(customs.first.id, 'c1');
    });
  });
}
