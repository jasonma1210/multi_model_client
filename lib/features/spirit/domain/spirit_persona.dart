/// 名灵回响 - 名灵角色数据模型
///
/// 通过大模型+网络搜索蒸馏出某个公众人物的思想风格，
/// 封装为可交互的 ExpertSkill，并绑定克隆音色。
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';

/// 名灵角色状态
enum SpiritStatus {
  /// 蒸馏中
  distilling,

  /// 音色克隆中
  cloningVoice,

  /// 就绪（蒸馏+克隆完成）
  ready,

  /// 蒸馏失败
  distillFailed,

  /// 克隆失败
  cloneFailed,
}

/// 名灵角色数据模型
class SpiritPersona {
  final String id;
  final String nickname; // 昵称（对外显示，如"大幂幂"）
  final String? realName; // 真名（加密存储，仅内部使用）
  final String domain; // 领域（演员/歌手/企业家...）
  final String? description; // 角色描述
  final String? distilledPrompt; // 蒸馏后的 system prompt
  final String? clonedVoiceId; // 绑定的克隆音色 ID（VoiceCloneService 中的 id）
  final String? mimoVoiceId; // MiMo 默认音色 ID（未克隆时使用）
  final String? lastUsedModelId; // 上次对话使用的模型 ID
  final String? lastUsedVoiceId; // 上次对话使用的音色 ID（MIMO voice name）
  final String avatarEmoji; // 头像 emoji
  final SpiritStatus status;
  final String? errorMessage; // 错误信息
  final List<String> searchSources; // 蒸馏时引用的搜索来源
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SpiritPersona({
    required this.id,
    required this.nickname,
    this.realName,
    required this.domain,
    this.description,
    this.distilledPrompt,
    this.clonedVoiceId,
    this.mimoVoiceId,
    this.lastUsedModelId,
    this.lastUsedVoiceId,
    this.avatarEmoji = '👤',
    this.status = SpiritStatus.distilling,
    this.errorMessage,
    this.searchSources = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// 是否就绪
  bool get isReady => status == SpiritStatus.ready;

  /// 是否正在处理中
  bool get isProcessing =>
      status == SpiritStatus.distilling ||
      status == SpiritStatus.cloningVoice;

  /// 是否失败
  bool get isFailed =>
      status == SpiritStatus.distillFailed ||
      status == SpiritStatus.cloneFailed;

  /// 获取状态描述
  String get statusText {
    switch (status) {
      case SpiritStatus.distilling:
        return '正在蒸馏...';
      case SpiritStatus.cloningVoice:
        return '正在克隆音色...';
      case SpiritStatus.ready:
        return '就绪';
      case SpiritStatus.distillFailed:
        return '蒸馏失败: ${errorMessage ?? "未知错误"}';
      case SpiritStatus.cloneFailed:
        return '音色克隆失败: ${errorMessage ?? "未知错误"}';
    }
  }

  SpiritPersona copyWith({
    String? id,
    String? nickname,
    String? realName,
    String? domain,
    String? description,
    String? distilledPrompt,
    String? clonedVoiceId,
    String? mimoVoiceId,
    String? lastUsedModelId,
    String? lastUsedVoiceId,
    String? avatarEmoji,
    SpiritStatus? status,
    String? errorMessage,
    List<String>? searchSources,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpiritPersona(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      realName: realName ?? this.realName,
      domain: domain ?? this.domain,
      description: description ?? this.description,
      distilledPrompt: distilledPrompt ?? this.distilledPrompt,
      clonedVoiceId: clonedVoiceId ?? this.clonedVoiceId,
      mimoVoiceId: mimoVoiceId ?? this.mimoVoiceId,
      lastUsedModelId: lastUsedModelId ?? this.lastUsedModelId,
      lastUsedVoiceId: lastUsedVoiceId ?? this.lastUsedVoiceId,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      searchSources: searchSources ?? this.searchSources,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'realName': realName,
        'domain': domain,
        'description': description,
        'distilledPrompt': distilledPrompt,
        'clonedVoiceId': clonedVoiceId,
        'mimoVoiceId': mimoVoiceId,
        'lastUsedModelId': lastUsedModelId,
        'lastUsedVoiceId': lastUsedVoiceId,
        'avatarEmoji': avatarEmoji,
        'status': status.index,
        'errorMessage': errorMessage,
        'searchSources': searchSources,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory SpiritPersona.fromJson(Map<String, dynamic> json) => SpiritPersona(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        realName: json['realName'] as String?,
        domain: json['domain'] as String,
        description: json['description'] as String?,
        distilledPrompt: json['distilledPrompt'] as String?,
        clonedVoiceId: json['clonedVoiceId'] as String?,
        mimoVoiceId: json['mimoVoiceId'] as String?,
        lastUsedModelId: json['lastUsedModelId'] as String?,
        lastUsedVoiceId: json['lastUsedVoiceId'] as String?,
        avatarEmoji: json['avatarEmoji'] as String? ?? '👤',
        status: SpiritStatus
            .values[json['status'] as int? ?? SpiritStatus.distilling.index],
        errorMessage: json['errorMessage'] as String?,
        searchSources: (json['searchSources'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  /// 序列化为 JSON 字符串
  String toJsonString() => jsonEncode(toJson());

  /// 从 JSON 字符串反序列化
  static SpiritPersona fromJsonString(String jsonStr) =>
      SpiritPersona.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

  @override
  String toString() =>
      'SpiritPersona(id: $id, nickname: $nickname, status: $status, domain: $domain)';
}

/// 名灵蒸馏进度通知
class SpiritDistillProgress {
  final String spiritId;
  final SpiritDistillPhase phase;
  final String? message;
  final double? progress; // 0.0 ~ 1.0

  const SpiritDistillProgress({
    required this.spiritId,
    required this.phase,
    this.message,
    this.progress,
  });
}

/// 蒸馏阶段（基于女娲 skill 方法论）
enum SpiritDistillPhase {
  /// Phase 1: 多维度信息采集（6路并行搜索）
  searching,

  /// Phase 1.5: 调研质量检查
  researchReview,

  /// Phase 2: 框架提炼（心智模型 + 决策启发式 + 表达DNA）
  distilling,

  /// Phase 3: 构建技能（生成 SKILL.md 风格的 system prompt）
  buildingSkill,

  /// Phase 4: 质量验证
  qualityCheck,

  /// 搜索声音素材
  searchingVoice,

  /// 克隆音色
  cloningVoice,

  /// 完成
  completed,

  /// 失败
  failed,
}
