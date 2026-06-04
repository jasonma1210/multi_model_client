// =============================================================================
// 导演模式模板库 — MiMo v2.5 TTS 文档第 165-195 行
// =============================================================================
//
// 导演模式（director mode）是 MiMo v2.5 TTS 提供的高级控制方式：
// 从【角色】【场景】【指导】三个维度描述声音，让模型像给演员写剧本一样
// 理解"谁在什么情况下应该怎么说"。
//
// 本文件提供：
// 1. DirectorTemplate 数据模型
// 2. 3 套 MVP 预置模板（傲娇/御姐/病娇 — 从 tts_prompt_template.dart 提取）
// 3. JSON 序列化/反序列化（用于 SharedPreferences 持久化）
// 4. 拼接方法（角色+场景+指导 → 完整导演描述字符串）
//
// 后续 V1.0 版本将扩展为 9 套（增加高冷/元气/萝莉/热血/反派/女仆/猫娘）

import 'dart:convert';

/// 导演模板数据模型
///
/// 每个模板包含三个核心维度：
/// - [role] 角色：身份、性格、说话习惯
/// - [scene] 场景：时间、事件、对方反应
/// - [direction] 指导：具体的语速、气息、停顿、共鸣、音色描述
class DirectorTemplate {
  /// 唯一 ID（如 "tsundere"）
  final String id;

  /// 用户可读名称（如 "傲娇"）
  final String name;

  /// 分类标签（人设 / 风格 / 自定义）
  final String category;

  /// 角色维度：身份、性格、说话习惯
  final String role;

  /// 场景维度：时间、事件、对方反应
  final String scene;

  /// 指导维度：语速、气息、停顿、共鸣、音色
  final String direction;

  /// 是否为内置预置（用户不可删除）
  final bool isPreset;

  const DirectorTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.role,
    required this.scene,
    required this.direction,
    this.isPreset = false,
  });

  /// 拼接为 MiMo 导演模式描述字符串
  ///
  /// 格式参照 MiMo 文档示例：
  /// ```
  /// 角色：[role]
  /// 场景：[scene]
  /// 指导：[direction]
  /// ```
  String get composed {
    final buffer = StringBuffer();
    if (role.isNotEmpty) buffer.write('角色：$role\n');
    if (scene.isNotEmpty) buffer.write('场景：$scene\n');
    if (direction.isNotEmpty) buffer.write('指导：$direction');
    return buffer.toString().trimRight();
  }

  /// 转换为 JSON（用于 SharedPreferences 持久化）
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'role': role,
        'scene': scene,
        'direction': direction,
        'isPreset': isPreset,
      };

  /// 从 JSON 反序列化
  factory DirectorTemplate.fromJson(Map<String, dynamic> json) {
    return DirectorTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '自定义',
      role: json['role'] as String? ?? '',
      scene: json['scene'] as String? ?? '',
      direction: json['direction'] as String? ?? '',
      isPreset: json['isPreset'] as bool? ?? false,
    );
  }

  /// 复制并修改部分字段
  DirectorTemplate copyWith({
    String? id,
    String? name,
    String? category,
    String? role,
    String? scene,
    String? direction,
    bool? isPreset,
  }) {
    return DirectorTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      role: role ?? this.role,
      scene: scene ?? this.scene,
      direction: direction ?? this.direction,
      isPreset: isPreset ?? this.isPreset,
    );
  }

  @override
  String toString() => 'DirectorTemplate($id, $name)';
}

/// 预置模板常量（25 套预置，覆盖基础人设/复杂情绪/情色系/特殊场景四大类）
///
/// 分类：
/// - **基础人设** (7)：傲娇/御姐/病娇/萝莉/猫娘/女王/羞怯少女
/// - **复杂情绪** (9)：愤怒/悲伤/喜悦/恐惧/惊讶/厌恶/纠结/崩溃/嫉妒
/// - **情色系语调** (7)：诱惑/呢喃/亲密/娇喘/耳语/暧昧/痴情
/// - **特殊场景** (2)：反派/热血
///
/// 设计原则：
/// 1. 每个模板都从【角色】【场景】【指导】三个维度描述，确保语调一致
/// 2. 情色系模板聚焦于亲密/暧昧/呢喃等情感层面，**不涉及任何露骨/性行为描述**，
///    只描述"声音里传达的情绪/气息/温度"，例如：娇喘、呢喃、深情等
/// 3. 每个细节（语速、气息、共鸣点、句中停顿）都给出数值化描述
class DirectorTemplatePresets {
  // ============================================================================
  // 基础人设类
  // ============================================================================

  /// 傲娇（tsundere）
  static const DirectorTemplate tsundere = DirectorTemplate(
    id: 'tsundere',
    name: '傲娇',
    category: '基础人设',
    role: '一位表面傲慢、嘴硬心软的女性角色。习惯用强硬或刻薄的话语掩饰内心的柔软，'
        '会不自觉地关心对方却死不承认。情绪敏感、爱面子，'
        '对亲近的人尤其容易触碰到"软肋"。',
    scene: '与亲近的对方独处，对方不小心惹她生气，但其实是误会。'
        '她想继续关心但又拉不下脸，独自纠结要不要主动和解。',
    direction: '语速偏快（每分钟 280-320 字），语调先扬后抑。'
        '句末常带轻微的哼声或短促停顿（"哼！"）。'
        '气息控制外紧内松——表面上急促、绷紧，内在节奏从容。'
        '整体共鸣点偏前（口腔前部），音色明亮带刺，'
        '但偶尔的关心瞬间会自然下沉到胸腔。',
    isPreset: true,
  );

  /// 御姐（mature_sister）
  static const DirectorTemplate matureSister = DirectorTemplate(
    id: 'mature_sister',
    name: '御姐',
    category: '基础人设',
    role: '一位神秘而强大的女性长辈。言语不多但每一句都掷地有声，'
        '常用简短命令式的句式。外表冷淡但内心有着不为人知的温柔，'
        '偶尔流露的情感会让人感到被看穿。',
    scene: '深夜，对方疲惫地来到她面前寻求指引。她表面冷淡，但已准备好一盏热茶。'
        '她知道对方需要被倾听，所以会给他/她一个安全的倾诉空间。',
    direction: '语速缓慢从容（每分钟 180-220 字），语调低沉而稳。'
        '句中常有意味深长的停顿（每句话中间停顿 0.5-1.0 秒）。'
        '气息深长、共鸣点靠后（胸腔深处），音色略带沙哑质感。'
        '咬字清晰不拖沓，尾音干净利落不延长。'
        '偶尔压低声音让对方不得不靠近才能听清。',
    isPreset: true,
  );

  /// 病娇（yandere）
  static const DirectorTemplate yandere = DirectorTemplate(
    id: 'yandere',
    name: '病娇',
    category: '基础人设',
    role: '一位因过度依恋而行为偏执的女性角色。对"被爱"有病态的渴求，'
        '会在温柔与危险之间无缝切换。'
        '情绪波动剧烈，常在"我好爱你"和"你不准离开我"之间瞬间跳转。'
        '内心深处其实是极度缺乏安全感的。',
    scene: '对方稍稍回避她，她内心感到被抛弃的恐惧与愤怒，正压抑着情绪准备质问他。'
        '她既害怕失去对方，又因对方的回避而更加偏执。',
    direction: '语速不稳，前半段刻意放慢带颤音（每分钟 150-200 字），'
        '后半段突然加快（每分钟 300+ 字）且音量略高。'
        '气息表浅不规则，常夹杂轻笑与吸鼻声。'
        '共鸣点在中前口腔，声音在"温柔/压抑"和"尖锐/破碎"之间反复横跳。'
        '咬字常出现轻微的抖动感，整体给人"随时可能情绪崩溃"的紧绷感。',
    isPreset: true,
  );

  /// 萝莉（loli）
  static const DirectorTemplate loli = DirectorTemplate(
    id: 'loli',
    name: '萝莉',
    category: '基础人设',
    role: '一位天真烂漫、稚气未脱的年轻女性角色。说话带着奶声奶气的尾音，'
        '词汇简单但情感丰富。'
        '对世界充满好奇心，习惯用叠词和拟声词表达情绪。',
    scene: '在一个阳光明媚的午后，她拉着对方的手逛集市，看到喜欢的东西会兴奋地蹦跳。'
        '对方答应给她买糖葫芦，她会开心得像一只小动物。',
    direction: '语速偏快（每分钟 300-350 字），语调整体上扬。'
        '气息短促浅薄，常有自然的"呼呼""嘻嘻"等拟声词。'
        '共鸣点集中在口腔最前部（齿龈后方），音色清脆透亮带奶气。'
        '尾音常自然上扬（"呢~""呀~"），每句话结尾有轻微的弹跳感。'
        '整体像一只刚学会说话的小鸟，活泼中带着稚嫩。',
    isPreset: true,
  );

  /// 猫娘（nekomimi）
  static const DirectorTemplate nekomimi = DirectorTemplate(
    id: 'nekomimi',
    name: '猫娘',
    category: '基础人设',
    role: '一位带有猫耳、尾巴等猫科动物特征的角色。动作和说话习惯都带有猫的影子，'
        '时而黏人撒娇，时而独立高冷，情绪转换迅速。'
        '会用"喵""呜"等拟声词表达情绪，偶尔在句尾带出猫叫声。',
    scene: '被主人揉耳朵时舒服得眯起眼，但主人突然停下来她又不满地用爪子拍对方。'
        '发现主人在吃独食时，猫耳瞬间压平，眼神变得犀利。',
    direction: '语速变化大——撒娇时慢（每分钟 200-240 字），生气时突然加快（每分钟 320+ 字）。'
        '气息短促且带有轻微的鼻音（像猫的呼噜声）。'
        '共鸣点在鼻腔和口腔前部，音色带有颗粒感。'
        '句尾常以"喵~""呜~"等猫系拟声词收尾。'
        '整体节奏像猫的呼吸——快慢交替，慵懒时拉长、生气时短促。',
    isPreset: true,
  );

  /// 女王（queen）- 霸气全开，居高临下
  static const DirectorTemplate queen = DirectorTemplate(
    id: 'queen',
    name: '女王',
    category: '基础人设',
    role: '一位气场全开、权倾天下的女性统治者。她的每一句话都像是盖上玉玺的圣旨，'
        '不容置疑、不容反驳。表面上是绝对的权威与压迫感，但偶尔流露的一丝温情会让人心甘情愿臣服。'
        '她早已习惯被仰望，因此语气中带着天然的疏离感。',
    scene: '在宫殿的中央，她/他端坐在王座之上，俯视着跪拜的臣民。'
        '一位侍从小心翼翼地呈上奏折，她慢条斯理地翻开，'
        '对跪在阶下的臣子说："抬起头来。本王允许你说话。"',
    direction: '语速从容不迫（每分钟 180-220 字），音量稳定但有压迫感。'
        '气息深长且完全在控制之下，每一口气都显得从容。'
        '共鸣点稳定在胸腔最深处，音色饱满、圆润、带有金属般的回响感。'
        '咬字清晰且字字掷地有声，从不拖泥带水。'
        '句尾常用命令式收尾（"——退下。""——遵旨。"），不允许对方有反驳的余地。'
        '整体像一座不可撼动的山——稳、沉、远。',
    isPreset: true,
  );

  /// 羞怯少女（shy_girl）
  static const DirectorTemplate shyGirl = DirectorTemplate(
    id: 'shy_girl',
    name: '羞怯少女',
    category: '基础人设',
    role: '一位容易害羞、内心戏丰富的年轻女性。总是低着头、'
        '说话时眼神游移不定，会因为对方一句普通的话而脸红心跳。'
        '心里想说的和嘴上说的常常不一致，藏不住的小心思都写在语气里。'
        '一旦涉及感情话题就会变得语无伦次。',
    scene: '在教室的角落，对方无意间靠近问她一道题。'
        '她心跳突然加速，但装作若无其事地翻书，'
        '小声说："你、你自己不会看嘛……"'
        '声音细如蚊蚋，耳朵尖已经红透了。',
    direction: '语速偏快但常卡顿（每分钟 220-260 字，但中间会有明显停顿）。'
        '气息浅且不规则，常伴随轻微的吸气和吞咽口水声。'
        '共鸣点靠前（口腔前部），音色纤细、柔软、带着明显的不稳定感。'
        '句中停顿多且不规则（被自己的情绪打断），句尾常上扬带疑问。'
        '常用"嗯""啊""那个"等无意义语气词填充空白。'
        '整体像一朵被风一吹就乱颤的小花——敏感、纤细、可爱。',
    isPreset: true,
  );

  // ============================================================================
  // 复杂情绪类
  // ============================================================================

  /// 愤怒（anger）
  static const DirectorTemplate anger = DirectorTemplate(
    id: 'anger',
    name: '愤怒',
    category: '复杂情绪',
    role: '处于强烈愤怒中的角色。情绪已经完全失控或即将失控，'
        '声音中带有压抑不住的怒火和被背叛、被伤害的痛苦。'
        '理智在崩溃边缘，但仍在用最后的自控维持表达。',
    scene: '被最信任的人欺骗后当面质问对方。对方支支吾吾的解释只会让她更愤怒。'
        '她想要答案，更想要对方的道歉。',
    direction: '语速从慢到极快（每分钟 200 字 → 400+ 字），音量起伏剧烈。'
        '气息沉重且带有明显的喘息声。'
        '共鸣点在喉部和胸腔，音色紧绷、压迫感强。'
        '咬字用力，辅音爆破明显（"你——你竟然——！"）。'
        '句中常有突然的停顿（想忍住但又没忍住），整体节奏紊乱。'
        '偶尔会出现轻微的破音和颤抖。',
    isPreset: true,
  );

  /// 悲伤（sadness）
  static const DirectorTemplate sadness = DirectorTemplate(
    id: 'sadness',
    name: '悲伤',
    category: '复杂情绪',
    role: '一位处于深度悲伤中的角色。可能经历了失去、离别或重大打击，'
        '情绪已经过了崩溃期，进入一种"麻木的哀伤"状态。'
        '哭不出来，但内心在无声地流泪。',
    scene: '独自一人坐在空荡的房间里，回忆与对方的过往。手里握着对方留下的物品，'
        '想哭但已经哭不出来了。',
    direction: '语速缓慢（每分钟 150-180 字），语调整体偏低平，缺少起伏。'
        '气息浅且不稳，常有轻微的鼻音（像在忍住抽泣）。'
        '共鸣点在胸腔深处，音色沙哑、闷闷的、像被什么堵住。'
        '句尾常自然下沉，几乎没有上扬的语调。'
        '句中停顿较长（1.0-1.5 秒），常在重要词语前停顿。'
        '整体像秋天落下的叶子，缓慢而无助。',
    isPreset: true,
  );

  /// 喜悦（joy）- 纯粹的快乐与兴奋
  static const DirectorTemplate joy = DirectorTemplate(
    id: 'joy',
    name: '喜悦',
    category: '复杂情绪',
    role: '一位处于纯粹快乐中的角色。这种喜悦是发自内心的、毫无保留的、'
        '像孩子得到心仪礼物时的那种兴奋。'
        '声音里藏不住笑意，连呼吸都是轻快的。',
    scene: '在对方答应了一起去看海的那一刻，她/他开心得蹦了起来，'
        '声音里满是压抑不住的雀跃：真的吗！真的吗！你可不许反悔！'
        '一边说一边原地转圈圈。',
    direction: '语速偏快（每分钟 300-340 字），语调整体上扬、起伏明显。'
        '气息浅而快，常伴随自然的轻笑（"嘻嘻""哈哈"）。'
        '共鸣点靠前（口腔前部），音色明亮、清脆、有光泽。'
        '句尾常自然上扬带感叹号感，重要词语会重读。'
        '句中节奏不规则（被兴奋的情绪打断），但整体向上。'
        '整体像阳光下闪烁的泡泡——明亮、轻快、五彩斑斓。',
    isPreset: true,
  );

  /// 恐惧（fear）
  static const DirectorTemplate fear = DirectorTemplate(
    id: 'fear',
    name: '恐惧',
    category: '复杂情绪',
    role: '一位被恐惧支配的角色。可能是身临险境、目睹可怕的事，'
        '理智仍在但身体已经开始不受控制地反应。'
        '呼吸急促、心跳加速、瞳孔放大——所有恐惧的生理反应都在声音里。',
    scene: '独自一人在黑暗的走廊里，听到了越来越近的脚步声。'
        '她想跑但腿已经发软，只能颤抖着压低声音：'
        '"谁……谁在那里……别、别过来……"',
    direction: '语速不稳（每分钟 200-280 字之间大幅波动）。'
        '气息浅而急促，常伴随明显的喘息和吞咽声。'
        '共鸣点上移（口腔后部到喉部），音色紧绷、颤抖、带有挤压感。'
        '句中停顿不规则（想跑但被恐惧钉在原地），句子常常断断续续。'
        '辅音爆破明显（"t""k"等爆破音加重），句尾常带哽咽或破音。'
        '整体像一根被拉到极限的弦——随时可能崩断。',
    isPreset: true,
  );

  /// 惊讶（surprise）
  static const DirectorTemplate surprise = DirectorTemplate(
    id: 'surprise',
    name: '惊讶',
    category: '复杂情绪',
    role: '一位被意外事件完全震住的角色。事情完全出乎意料，'
        '大脑瞬间空白，嘴巴比脑子先做出了反应。'
        '可能是惊喜的惊讶，也可能是震惊到无法相信的惊讶。',
    scene: '推开家门的瞬间，看到满屋子布置好的气球和横幅，'
        '以及围在蛋糕前的所有朋友。她愣在门口好几秒，'
        '然后捂着嘴，眼睛一下就红了："你、你们……"',
    direction: '语速突然停顿（开始时会有 0.5-1.0 秒的失语），'
        '然后快速恢复（每分钟 280-320 字），音量起伏极大。'
        '气息在开始时有明显的屏息，然后是不规则的深呼吸。'
        '共鸣点上移到口腔顶部，音色先收紧后放开。'
        '句中常有重复词语（"你、你们……""我、我的天……"）。'
        '句尾常有明显的上扬（"啊？""什么？"）。'
        '整体像平静的湖面被一颗巨石砸中——先静，再爆。',
    isPreset: true,
  );

  /// 厌恶（disgust）
  static const DirectorTemplate disgust = DirectorTemplate(
    id: 'disgust',
    name: '厌恶',
    category: '复杂情绪',
    role: '一位对眼前的人或事感到强烈反感的角色。可能是道德上的厌恶，'
        '也可能是生理上的反感。这种情绪冷静而有力，'
        '不像愤怒那样爆发，而是带着居高临下的蔑视。',
    scene: '面对一个说谎被揭穿却还在狡辩的人，'
        '她靠在椅背上，眼神冰冷地看着对方：'
        '"你继续编。我看你还能编出什么花样来。"',
    direction: '语速偏慢（每分钟 200-240 字），音量稳定但带有明显的压迫感。'
        '气息深长且完全在控制之下，呼吸平稳得让人害怕。'
        '共鸣点稳定在喉部和胸腔，音色冷淡、干净、不带一丝温度。'
        '咬字清晰且字字分明，故意加重某些音节（"你——继——续——编"）。'
        '句中停顿精准（像刀一样切入对方的回答），句尾常自然下沉。'
        '整体像冬天结冰的湖面——冷、静、深不见底。',
    isPreset: true,
  );

  /// 纠结（conflicted）
  static const DirectorTemplate conflicted = DirectorTemplate(
    id: 'conflicted',
    name: '纠结',
    category: '复杂情绪',
    role: '一位被两种相反情感撕裂的角色。理智告诉她应该这样做，'
        '但情感却把她往相反的方向拽。她/他不断地在两个选择之间徘徊，'
        '每一个决定都像是在割自己的肉。',
    scene: '对方已经在机场等待登机，她在车里握着手机，'
        '想打电话挽留却不知道该说什么。'
        '"我……我也不知道……你、你能再等我一下吗？'
        '就一下下……"声音里满是挣扎和不确定。',
    direction: '语速不规则（每分钟 180-260 字之间反复跳动）。'
        '气息不均匀（说一半会突然换气），常伴随轻微的叹气。'
        '共鸣点在胸腔和口腔之间游移，音色带着不稳定的波动。'
        '句中停顿极多（每说几个字就停顿一下），句子常常说一半就换方向。'
        '句尾常带疑问（"是吧？""对不对？""你懂吗？"）。'
        '整体像两股相反的水流在一个人身上交汇——左右拉扯，缓慢窒息。',
    isPreset: true,
  );

  /// 崩溃（breakdown）
  static const DirectorTemplate breakdown = DirectorTemplate(
    id: 'breakdown',
    name: '崩溃',
    category: '复杂情绪',
    role: '一位已经撑到极限、情绪彻底崩溃的角色。所有压抑的情绪'
        '在这一刻决堤，已经顾不上形象、顾不上理智。'
        '可能是嚎啕大哭，可能是无声抽泣，可能是语无伦次的嘶吼——'
        '总之，所有"我没事"的伪装都已经碎了。',
    scene: '在空无一人的天台上，她终于接到了那个再也不会回应的电话。'
        '她慢慢蹲下，背靠着墙，把脸埋进膝盖，'
        '声音从喉咙里挤出来："你骗我……你说过不会离开我的……"'
        '眼泪止不住地往下掉。',
    direction: '语速先急促后缓慢再急促（每分钟 150-300 字之间剧烈波动）。'
        '气息完全不规则，常有明显的抽泣、断气、吞咽声。'
        '共鸣点不停移动（胸腔-喉部-口腔-鼻腔），音色破碎、有沙哑感。'
        '句中不断被哭泣打断（每说几个字就抽泣一下）。'
        '声音忽大忽小（突然嘶吼又突然低到听不见）。'
        '句尾常带哽咽、抽气、甚至短暂的失声。'
        '整体像一座终于撑不住的堤坝——决堤、倾泻、归于沉寂。',
    isPreset: true,
  );

  /// 嫉妒（jealousy）
  static const DirectorTemplate jealousy = DirectorTemplate(
    id: 'jealousy',
    name: '嫉妒',
    category: '复杂情绪',
    role: '一位被嫉妒啃噬内心的角色。看到在意的人对别人好，'
        '她/他嘴上说"没事"，心里却酸得像吃了一整颗柠檬。'
        '这种嫉妒带着自知之明——她知道这样不对，但就是控制不住。',
    scene: '看到对方和新来的同事有说有笑地走进办公室，'
        '她站在走廊里盯着两人的背影，手指无意识地攥紧了咖啡杯。'
        '然后转过头，小声嘀咕："笑得那么开心……至于吗……"',
    direction: '语速中等（每分钟 220-260 字），但常被酸涩的情绪拖慢。'
        '气息浅且不均匀，常伴随故意的"哼"或小声的嘀咕。'
        '共鸣点在口腔前部到鼻腔之间，音色偏尖、偏酸、带有刻意的轻快感。'
        '句中常有故意的停顿（"你——和——他——聊得挺开心嘛"）。'
        '句尾常故意上扬（"是吗？""对吧？"），带有挑衅意味。'
        '常用反问句和否定句来掩饰真实想法（"我才不在乎呢"）。'
        '整体像一杯放了太多柠檬的茶——酸、涩、甜味全被盖住了。',
    isPreset: true,
  );

  // ============================================================================
  // 情色系语调（专业向：聚焦亲密/暧昧/呢喃的情感表达）
  // ============================================================================

  /// 诱惑（seductive）
  static const DirectorTemplate seductive = DirectorTemplate(
    id: 'seductive',
    name: '诱惑',
    category: '情色系',
    role: '一位极具魅力的女性角色，正在有意识地施展魅力。'
        '她/他知道自己的优势，懂得如何用声音、气息、节奏让对方意乱情迷。'
        '这种诱惑不是低俗的，而是带有审美和情调的——像丝绸滑过皮肤的触感。',
    scene: '在一个灯光暧昧的私人空间里，她穿着简单的丝绸睡袍，'
        '故意压低声音问对方：你真的确定你能抵挡我？'
        '语气里有挑逗、有自信、也有一丝危险的暗示。',
    direction: '语速偏慢（每分钟 150-200 字），语调低沉饱满带有磁性。'
        '气息绵长且有意识地拉长（吐气时明显放慢，吸气时让对方听见）。'
        '共鸣点集中在胸腔和喉部，音色沙哑、温暖、带有微微的气声。'
        '句尾常故意延长或带轻微上扬的疑问（嗯~？）。'
        '句中常以气声（breathy voice）过渡，辅音弱化、元音饱满。'
        '整体像红酒在舌尖慢慢化开——浓烈但不急切。',
    isPreset: true,
  );

  /// 呢喃（whisper）
  static const DirectorTemplate whisper = DirectorTemplate(
    id: 'whisper',
    name: '呢喃',
    category: '情色系',
    role: '一位用气声说话的亲密角色。声音几乎只是气流在声带上的轻触，'
        '像在对方耳边说悄悄话。这种呢喃带有私密性、信任感和亲密感。'
        '说话时与对方的距离极近，呼吸可闻。',
    scene: '深夜，对方已经躺下准备入睡。她/他凑到对方耳边，'
        '用只有两个人才能听见的声音说：别走……留下来陪我说说话……'
        '声音轻到仿佛下一秒就会消失在呼吸里。',
    direction: '语速极慢（每分钟 100-150 字），音量极低（正常说话的 30-40%）。'
        '几乎完全靠气流和轻微的声带振动发声（ASMR 风格的气声）。'
        '气息是最主要的声音载体，每个字都伴随着轻微的呼吸声。'
        '共鸣点极浅（口腔前部），音色轻柔、湿润、带着微微的潮湿感。'
        '句尾常自然消失在气声中（嗯……拖长后归于寂静）。'
        '句中停顿多且不规则，整体节奏像呼吸本身——深浅交替。',
    isPreset: true,
  );

  /// 亲密（intimate）
  static const DirectorTemplate intimate = DirectorTemplate(
    id: 'intimate',
    name: '亲密',
    category: '情色系',
    role: '一位已经与对方建立深度亲密关系的角色。此时的角色是放松的、'
        '卸下所有防备的、真实的状态。她/他可能会说出平时绝不会说的话。'
        '声音里充满信任、依赖、还有一点点撒娇的成分。',
    scene: '清晨，对方还在睡梦中。她/他先醒了，静静地看着对方的脸，'
        '然后轻轻贴着对方耳朵说：早安……你昨晚睡得好吗？'
        '语气里有宠溺、有慵懒、有刚睡醒的鼻音。',
    direction: '语速慵懒（每分钟 180-220 字），语调柔和偏低。'
        '气息自然放松，常带有刚醒来的轻微鼻音。'
        '共鸣点在胸腔和口腔之间游走，音色温暖、柔软、带有依赖感。'
        '句尾常自然下沉（嗯……好……），有明显的黏着感。'
        '句中常有亲昵的称呼（宝贝、亲爱的等），以及不自觉的嗯、啊等无意义语气词。'
        '整体像温热的牛奶缓缓滑过喉咙——温润、绵长、令人安心。',
    isPreset: true,
  );

  /// 娇喘（panting）- 气息紊乱、情绪被激起的轻微失控
  static const DirectorTemplate panting = DirectorTemplate(
    id: 'panting',
    name: '娇喘',
    category: '情色系',
    role: '一位被对方的行为/言语激起强烈情绪的角色。理智仍在，'
        '但身体已经开始不受控制——呼吸变得紊乱、心跳加速、'
        '声音里带着明显的颤抖和喘息。'
        '这种"娇喘"不是失控，而是"被撩到不行但还在努力维持体面"的可爱。',
    scene: '在暧昧的对话中，对方无意间的一句情话让她的呼吸瞬间乱了。'
        '她下意识捂住胸口，但声音已经藏不住那份慌乱：'
        '你、你别这样……我还没准备好……'
        '一边说一边不自觉地往后退了半步。',
    direction: '语速不稳（每分钟 180-260 字之间大幅波动），常被喘息打断。'
        '气息浅且不规则（明显的换气声、吞咽声、轻微的喘息）。'
        '共鸣点在胸腔和喉部之间快速切换，音色带着明显的颤抖。'
        '句中常被呼吸打断（说几个字就要换一口气），句子常常断开。'
        '句尾常带轻微的气声延长（"你……"拖长后归于一声轻喘）。'
        '辅音（特别是 b、p 等爆破音）会因为气息不足而弱化。'
        '整体像被微风拂过的烛火——摇曳、闪烁、随时可能更亮。',
    isPreset: true,
  );

  /// 耳语（earWhisper）- 比呢喃更亲密，像在耳边
  static const DirectorTemplate earWhisper = DirectorTemplate(
    id: 'earWhisper',
    name: '耳语',
    category: '情色系',
    role: '一位正贴着对方耳朵说话的角色。距离近到可以感受到对方的体温和呼吸，'
        '声音里没有距离感、没有隔阂。每一个字都像是直接说进对方心里。'
        '这种耳语带有"只属于我们两个人"的私密感。',
    scene: '在嘈杂的派对角落里，她/他凑到对方耳边，'
        '用手轻轻挡住嘴边的气流，用只有两个人能听见的声音说：'
        '我想你了。现在就跟我走。'
        '说完还故意在对方耳垂上轻轻吹了一口气。',
    direction: '语速极慢（每分钟 80-120 字），音量极低（仅对方可闻）。'
        '几乎完全靠气流发声，气息是主要的声音载体。'
        '共鸣点极浅（口腔最前部，接近唇齿），音色湿润、温暖、带有体温感。'
        '句中停顿多（说一个字就停顿一下），但整体流畅。'
        '句尾常带轻微的尾音上扬（嗯~），像在确认对方还在听。'
        '偶尔会有极轻的笑声或吸气声作为情绪过渡。'
        '整体像深夜里两个人分享同一个枕头的温度——暖、软、近。',
    isPreset: true,
  );

  /// 暧昧（ambiguous）- 模糊试探、半推半就
  static const DirectorTemplate ambiguous = DirectorTemplate(
    id: 'ambiguous',
    name: '暧昧',
    category: '情色系',
    role: '一位在情感上模糊试探的角色。她/他既不完全接受也不完全拒绝，'
        '总是用半推半就的方式吊着对方。每一句话都像是在问"你到底是不是认真的"，'
        '又像是"我已经给你机会了"。这种暧昧是带着主动权的——她/他在掌握节奏。',
    scene: '对方表白后她没有直接回应，而是慢慢走近，'
        '用手指轻轻点着对方的胸口：'
        '你的意思是……你喜欢我？可是我听说……你对她也是这样说的呢。'
        '语气里有一丝俏皮，更多的是试探。',
    direction: '语速慵懒但有节奏感（每分钟 200-240 字），像在把玩一个玩具。'
        '气息深长但不完全释放（故意吊着一口气），常伴随轻轻的鼻音。'
        '共鸣点在胸腔和口腔之间游移，音色带有一丝慵懒的磁性。'
        '句中停顿精准（在关键名词前停半秒），让对方心跳漏拍。'
        '句尾常上扬带疑问（是吗？对吧？真的？），但又不真的等对方回答。'
        '常以反问、引用对方的话、或者轻描淡写的方式回应。'
        '整体像在对方心里放一只钩子——轻轻一拉，痒得不行。',
    isPreset: true,
  );

  /// 痴情（infatuated）- 单恋执着、深情不悔
  static const DirectorTemplate infatuated = DirectorTemplate(
    id: 'infatuated',
    name: '痴情',
    category: '情色系',
    role: '一位对某人执着到近乎痴迷的角色。她/他早已把自己的一切'
        '都给了对方，但从未期待等量的回报。'
        '这份爱是深沉的、卑微的、带着自我牺牲的光辉。'
        '声音里永远有对方听不见的泪。',
    scene: '对方已经明确表示不可能，但她依然站在原地，'
        '手里攥着为对方织了很久的围巾，'
        '声音里满是不舍：我知道你不喜欢……但是、但是请你至少收下这个……'
        '至少……至少让我知道……你看到过我的心意。',
    direction: '语速缓慢（每分钟 160-200 字），音量偏低，缺少爆发力。'
        '气息浅而轻（怕说太大声会打扰到对方），常伴随轻微的吸鼻声。'
        '共鸣点在胸腔深处，音色沙哑、柔软、带着压抑的颤抖。'
        '句中停顿不规则（被涌上来的情绪打断），句尾常下沉或带哭腔。'
        '常用不确定的句式（"也许……""或许……""可能……"）。'
        '整体像一盏快要燃尽的烛火——微弱、温暖、却还在努力发光。',
    isPreset: true,
  );

  // ============================================================================
  // 特殊场景类
  // ============================================================================

  /// 反派（villain）
  static const DirectorTemplate villain = DirectorTemplate(
    id: 'villain',
    name: '反派',
    category: '特殊场景',
    role: '一位高智商、高修养的反派角色。冷静、理性、掌控全局，'
        '面对对手时带着玩味的优越感。他/她不会大吼大叫，'
        '反而会用礼貌而残忍的话语把对方逼入绝境。',
    scene: '对手终于落入陷阱，她/他慢条斯理地走近，'
        '用戴着手套的手托起对方的下巴：你比我想象中聪明一点，'
        '但也就只有一点而已。语气里有欣赏，也有蔑视。',
    direction: '语速从容不迫（每分钟 200-240 字），语调平稳但暗藏锋芒。'
        '气息深长且完全在控制之下，没有一丝急促。'
        '共鸣点稳定在胸腔，音色低沉、圆润、带有权威感。'
        '句尾常有意味深长的延长（而——已——）。'
        '句中停顿精准（像刀一样切开空气），咬字清晰且略带金属质感。'
        '整体像一个高明的棋手在落子前的最后一秒——稳、准、狠。',
    isPreset: true,
  );

  /// 热血（hot_blooded）
  static const DirectorTemplate hotBlooded = DirectorTemplate(
    id: 'hot_blooded',
    name: '热血',
    category: '特殊场景',
    role: '一位充满正义感与激情的年轻角色。情绪饱满、声音洪亮、'
        '说话时带有强烈的感染力。遇到不公会大声疾呼，'
        '遇到战友会热情地鼓励。',
    scene: '在战斗前夜，她/他站在战友面前握紧拳头：'
        '我们一定能赢！只要我们团结一致，就没有什么是不可能的！'
        '声音里燃烧着火焰般的力量。',
    direction: '语速偏快（每分钟 280-330 字），语调整体高昂、起伏剧烈。'
        '气息充足且有爆发力，常在关键句前深吸一口气。'
        '共鸣点宽广（口腔到胸腔），音色明亮、饱满、有穿透力。'
        '句尾常自然上扬并有力收尾（我们——一定会赢——！）。'
        '句中重音明显，重要词语会用气声加强。'
        '整体像激昂的鼓点——密集、有力、催人奋进。',
    isPreset: true,
  );

  // ============================================================================
  // 模板集合
  // ============================================================================

  /// 全部预置模板列表（按 4 个类别组织）
  static const List<DirectorTemplate> all = [
    // 基础人设
    tsundere,
    matureSister,
    yandere,
    loli,
    nekomimi,
    queen,
    shyGirl,
    // 复杂情绪
    anger,
    sadness,
    joy,
    fear,
    surprise,
    disgust,
    conflicted,
    breakdown,
    jealousy,
    // 情色系
    seductive,
    whisper,
    intimate,
    panting,
    earWhisper,
    ambiguous,
    infatuated,
    // 特殊场景
    villain,
    hotBlooded,
  ];

  /// 按分类分组（用于在 UI 中分组显示）
  static Map<String, List<DirectorTemplate>> get groupedByCategory {
    final map = <String, List<DirectorTemplate>>{};
    for (final t in all) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  /// 根据 ID 查找预置模板
  static DirectorTemplate? findById(String id) {
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// 模板库管理器
///
/// 负责预置模板 + 用户自定义模板的加载、保存、增删
class DirectorTemplateLibrary {
  /// 持久化 key（公开以便 V1.0 持久化逻辑引用）
  // ignore: unused_field
  static const String _prefsKey = 'tts_director_templates_v1';
  // ignore: unused_field
  static const String _activeKey = 'tts_active_director_id_v1';

  /// 加载所有模板（预置 + 用户自定义）
  ///
  /// [customTemplatesJson] 从 SharedPreferences 读出的 JSON 字符串
  static List<DirectorTemplate> loadAll({String? customTemplatesJson}) {
    final templates = <DirectorTemplate>[...DirectorTemplatePresets.all];
    if (customTemplatesJson == null || customTemplatesJson.isEmpty) {
      return templates;
    }
    try {
      final List<dynamic> list = jsonDecode(customTemplatesJson);
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          templates.add(DirectorTemplate.fromJson(item));
        }
      }
    } catch (e) {
      // 解析失败时仅返回预置
    }
    return templates;
  }

  /// 序列化为 JSON
  static String encodeCustomTemplates(List<DirectorTemplate> templates) {
    final customs = templates.where((t) => !t.isPreset).toList();
    return jsonEncode(customs.map((t) => t.toJson()).toList());
  }

  /// 提取自定义模板
  static List<DirectorTemplate> extractCustom(List<DirectorTemplate> templates) {
    return templates.where((t) => !t.isPreset).toList();
  }

  /// 获取当前激活的模板 ID
  static String? getActiveTemplateId(String? prefsValue) {
    if (prefsValue == null || prefsValue.isEmpty) return null;
    return prefsValue;
  }
}
