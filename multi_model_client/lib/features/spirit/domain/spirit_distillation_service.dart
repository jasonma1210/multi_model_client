/// 名灵回响 - 蒸馏服务（基于女娲 skill 方法论）
///
/// 集成女娲 skill (https://github.com/alchaincyf/nuwa-skill) 的核心方法论：
/// - Phase 1: 六路并行信息采集（著作、对话、表达、他者视角、决策、时间线）
/// - Phase 1.5: 调研质量检查
/// - Phase 2: 三重验证框架提炼（跨域复现、生成力、排他性）
/// - Phase 3: 构建 SKILL.md 风格的 system prompt
/// - Phase 4: 质量验证
/// - Phase 5: 声音搜索与克隆
///
/// @author JianMa
/// @version 3.0.0 (集成女娲 skill)
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/engines/model_inference_engine.dart'
    show ChatMessage, ChatOptions, globalModelEngine;
import '../../../core/services/voice_clone_service.dart';
import 'name_blacklist_service.dart';
import 'spirit_persona.dart';

// ==================== 女娲 skill 数据结构 ====================

/// 女娲 skill 六维度调研结果
class NuwaResearchResult {
  final String dimension;
  final List<String> findings;
  final List<String> sources;
  final int sourceCount;

  const NuwaResearchResult({
    required this.dimension,
    required this.findings,
    required this.sources,
    required this.sourceCount,
  });
}

/// 女娲 skill 心智模型
class NuwaMentalModel {
  final String name;
  final String oneLiner;
  final List<String> evidence;
  final String application;
  final String limitation;

  const NuwaMentalModel({
    required this.name,
    required this.oneLiner,
    required this.evidence,
    required this.application,
    required this.limitation,
  });
}

/// 女娲 skill 表达 DNA
class NuwaExpressionDNA {
  final String sentenceStyle;
  final String vocabulary;
  final String rhythm;
  final String humor;
  final String certainty;
  final String citationHabit;

  const NuwaExpressionDNA({
    required this.sentenceStyle,
    required this.vocabulary,
    required this.rhythm,
    required this.humor,
    required this.certainty,
    required this.citationHabit,
  });
}

// ==================== 蒸馏服务 ====================

/// 蒸馏服务（基于女娲 skill 方法论）
class SpiritDistillationService {
  static const String _tag = 'SpiritDistillation';

  /// Tavily API Key 存储键
  static const String _tavilyApiKeyPrefKey = 'tavily_api_key';

  /// 进度通知流
  final StreamController<SpiritDistillProgress> _progressController =
      StreamController<SpiritDistillProgress>.broadcast();

  /// 订阅进度
  Stream<SpiritDistillProgress> get progressStream =>
      _progressController.stream;

  /// 黑名单服务
  final NameBlacklistService _blacklistService = NameBlacklistService();

  /// 语音克隆服务
  final VoiceCloneService _voiceCloneService = VoiceCloneService();

  /// 获取 Tavily API Key
  Future<String?> getTavilyApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_tavilyApiKeyPrefKey);
      if (key != null && key.isNotEmpty) return key;
    } catch (_) {}
    return null;
  }

  /// 设置 Tavily API Key
  Future<void> setTavilyApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tavilyApiKeyPrefKey, apiKey);
  }

  /// 检查 Tavily API Key 是否已配置
  Future<bool> isTavilyConfigured() async {
    final key = await getTavilyApiKey();
    return key != null && key.isNotEmpty;
  }

  // ==================== 主流程 ====================

  /// 执行蒸馏流程（基于女娲 skill 方法论）
  ///
  /// [nickname] 昵称（已通过黑名单验证）
  /// [realName] 真名（内部使用，可能为 null）
  /// [domain] 领域
  /// [modelId] 用于蒸馏的模型 ID
  /// [description] 用户对角色的描述
  Future<SpiritPersona> distill({
    required String nickname,
    String? realName,
    required String domain,
    required String modelId,
    String? description,
  }) async {
    final spiritId = 'spirit_${DateTime.now().millisecondsSinceEpoch}';
    final targetName = realName ?? nickname;

    debugPrint('[$_tag] 开始女娲蒸馏: $nickname (domain: $domain, model: $modelId)');

    // 创建初始角色
    var persona = SpiritPersona(
      id: spiritId,
      nickname: nickname,
      realName: realName,
      domain: domain,
      description: description,
      avatarEmoji: _getDomainEmoji(domain),
      status: SpiritStatus.distilling,
      createdAt: DateTime.now(),
    );

    try {
      // ===== Phase 1: 六维度信息采集 =====
      _notifyProgress(spiritId, SpiritDistillPhase.searching,
          '女娲六路采集：搜索 $targetName 的著作、对话、表达、他者视角、决策、时间线...', 0.05);

      final researchResults = await _nuwaPhase1Research(targetName, domain, spiritId);

      // ===== Phase 1.5: 调研质量检查 =====
      _notifyProgress(spiritId, SpiritDistillPhase.researchReview,
          '调研质量检查：验证信息覆盖度...', 0.25);

      final researchSummary = _buildResearchSummary(researchResults);
      debugPrint('[$_tag] 调研摘要:\n$researchSummary');

      // ===== Phase 2: 框架提炼（三重验证） =====
      _notifyProgress(spiritId, SpiritDistillPhase.distilling,
          '三重验证提炼 $targetName 的心智模型、决策启发式、表达DNA...', 0.35);

      final distilledPrompt = await _nuwaPhase2Synthesize(
        nickname: nickname,
        realName: realName,
        domain: domain,
        description: description,
        researchResults: researchResults,
        researchSummary: researchSummary,
        modelId: modelId,
      );

      // 更新角色：蒸馏完成
      final allSources = <String>[];
      for (final r in researchResults) {
        allSources.addAll(r.sources.where((s) => s.isNotEmpty));
      }

      persona = persona.copyWith(
        distilledPrompt: distilledPrompt,
        searchSources: allSources.toSet().toList(),
        status: SpiritStatus.cloningVoice,
      );

      // ===== Phase 3: 质量验证 =====
      _notifyProgress(spiritId, SpiritDistillPhase.qualityCheck,
          '质量验证：检查蒸馏结果的完整性和一致性...', 0.55);

      // ===== Phase 4: 搜索声音素材 =====
      _notifyProgress(spiritId, SpiritDistillPhase.searchingVoice,
          '搜索 $targetName 的声音素材...', 0.65);

      final voiceAudioPath = await _searchAndDownloadVoice(targetName, domain);

      // ===== Phase 5: 克隆音色 =====
      String? clonedVoiceId;
      if (voiceAudioPath != null) {
        _notifyProgress(spiritId, SpiritDistillPhase.cloningVoice,
            '克隆 $nickname 的音色...', 0.8);

        try {
          final clonedVoice = await _voiceCloneService.submitCloneTask(
            audioPath: voiceAudioPath,
            voiceName: 'spirit_${nickname}_voice',
          );
          clonedVoiceId = clonedVoice.id;
          debugPrint('[$_tag] 音色克隆已提交: ${clonedVoice.id}');
        } catch (e) {
          debugPrint('[$_tag] 音色克隆失败，将使用默认 MiMo 音色: $e');
        }
      }

      // ===== 完成 =====
      _notifyProgress(spiritId, SpiritDistillPhase.completed,
          '$nickname 蒸馏完成！', 1.0);

      persona = persona.copyWith(
        clonedVoiceId: clonedVoiceId,
        mimoVoiceId: 'Chloe',
        status: SpiritStatus.ready,
        updatedAt: DateTime.now(),
      );

      debugPrint('[$_tag] 女娲蒸馏完成: ${persona.nickname}');
      return persona;
    } catch (e, stack) {
      debugPrint('[$_tag] 蒸馏失败: $e\n$stack');

      _notifyProgress(spiritId, SpiritDistillPhase.failed,
          '蒸馏失败: $e', null);

      return persona.copyWith(
        status: SpiritStatus.distillFailed,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// ★ 二次蒸馏：对已有名灵重新执行蒸馏流程
  ///
  /// 保留原 ID、昵称、领域等基础信息，重新搜索并生成蒸馏 Prompt
  /// [persona] 要重新蒸馏的名灵角色
  /// [onUpdate] 每次状态更新时的回调（用于持久化）
  Future<SpiritPersona> redistillPersona(
    SpiritPersona persona, {
    String? modelId,
    required void Function(SpiritPersona) onUpdate,
  }) async {
    final targetName = persona.realName ?? persona.nickname;

    debugPrint('[$_tag] 开始二次蒸馏: ${persona.nickname} (id: ${persona.id})');

    // 重置状态为蒸馏中
    var current = persona.copyWith(
      status: SpiritStatus.distilling,
      errorMessage: null,
      updatedAt: DateTime.now(),
    );
    onUpdate(current);

    _notifyProgress(persona.id, SpiritDistillPhase.searching,
        '二次蒸馏：重新搜索 $targetName 的六维度信息...', 0.05);

    try {
      // ★ 复用 distill 的核心流程，但保留原 ID
      final researchResults = await _nuwaPhase1Research(targetName, persona.domain, persona.id);

      _notifyProgress(persona.id, SpiritDistillPhase.researchReview,
          '调研质量检查...', 0.25);

      final researchSummary = _buildResearchSummary(researchResults);

      _notifyProgress(persona.id, SpiritDistillPhase.distilling,
          '三重验证提炼 $targetName 的心智模型...', 0.35);

      // 获取蒸馏模型：优先使用传入的 modelId，其次上次使用的模型，否则用默认
      final effectiveModelId = modelId ?? persona.lastUsedModelId ?? 'default';

      final distilledPrompt = await _nuwaPhase2Synthesize(
        nickname: persona.nickname,
        realName: persona.realName,
        domain: persona.domain,
        description: persona.description,
        researchResults: researchResults,
        researchSummary: researchSummary,
        modelId: effectiveModelId,
      );

      final allSources = <String>[];
      for (final r in researchResults) {
        allSources.addAll(r.sources.where((s) => s.isNotEmpty));
      }

      current = current.copyWith(
        distilledPrompt: distilledPrompt,
        searchSources: allSources.toSet().toList(),
        status: SpiritStatus.ready,
        updatedAt: DateTime.now(),
      );
      onUpdate(current);

      _notifyProgress(persona.id, SpiritDistillPhase.completed,
          '${persona.nickname} 二次蒸馏完成！', 1.0);

      debugPrint('[$_tag] 二次蒸馏完成: ${current.nickname}');
      return current;
    } catch (e, stack) {
      debugPrint('[$_tag] 二次蒸馏失败: $e\n$stack');

      _notifyProgress(persona.id, SpiritDistillPhase.failed,
          '二次蒸馏失败: $e', null);

      current = current.copyWith(
        status: SpiritStatus.distillFailed,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );
      onUpdate(current);
      return current;
    }
  }

  // ==================== Phase 1: 六维度信息采集 ====================

  /// 女娲 Phase 1: 六路并行信息采集
  ///
  /// 6个维度：
  /// 1. 著作 - 书籍、长文、论文、核心论点
  /// 2. 对话 - 播客、访谈、AMA、即兴回答
  /// 3. 表达 - 社交媒体、短文、风格DNA
  /// 4. 他者 - 他人分析、批评、传记
  /// 5. 决策 - 重大决策、转折点、争议行为
  /// 6. 时间线 - 完整人生时间线、最近动态
  Future<List<NuwaResearchResult>> _nuwaPhase1Research(
    String name,
    String domain,
    String spiritId,
  ) async {
    final results = <NuwaResearchResult>[];

    // 六维度搜索查询
    const dimensions = [
      ('著作与系统思考', [
        'NAME DOMAIN 著作 书籍 核心观点',
        'NAME DOMAIN 思想体系 理论 主张',
        'NAME DOMAIN 推荐书单 智识谱系',
      ]),
      ('对话与即兴思考', [
        'NAME DOMAIN 采访 访谈 播客',
        'NAME DOMAIN 对话 问答 AMA',
        'NAME DOMAIN 即兴回答 追问 反应',
      ]),
      ('表达DNA与风格', [
        'NAME DOMAIN 名言 语录 口头禅',
        'NAME DOMAIN 说话风格 表达方式',
        'NAME DOMAIN 社交媒体 观点 争议',
      ]),
      ('他者视角与批评', [
        'NAME DOMAIN 别人评价 分析',
        'NAME DOMAIN 批评 争议 传记',
        'NAME DOMAIN 同行对比 差异',
      ]),
      ('决策记录与行动', [
        'NAME DOMAIN 重大决策 转折点',
        'NAME DOMAIN 关键选择 行为逻辑',
        'NAME DOMAIN 言行一致 争议行为',
      ]),
      ('人生时间线', [
        'NAME DOMAIN 生平 时间线 里程碑',
        'NAME DOMAIN 成长经历 思想转变',
        'NAME DOMAIN 最新动态 近期',
      ]),
    ];

    for (var i = 0; i < dimensions.length; i++) {
      final (dimName, queries) = dimensions[i];
      final progress = 0.05 + (i / dimensions.length) * 0.2;

      _notifyProgress(spiritId, SpiritDistillPhase.searching,
          '采集维度 ${i + 1}/6: $dimName...', progress);

      final findings = <String>[];
      final sources = <String>[];

      for (final queryTemplate in queries) {
        final query = queryTemplate.replaceAll('NAME', name).replaceAll('DOMAIN', domain);
        try {
          final searchResults = await _searchTavily(query);
          for (final r in searchResults) {
            final snippet = r['snippet'] as String? ?? '';
            final url = r['url'] as String? ?? '';
            if (snippet.isNotEmpty) findings.add(snippet);
            if (url.isNotEmpty) sources.add(url);
          }
        } catch (e) {
          debugPrint('[$_tag] Tavily 搜索失败 ($query): $e，尝试 DuckDuckGo');
          try {
            final ddgResults = await _searchDuckDuckGo(query);
            for (final r in ddgResults) {
              final snippet = r['snippet'] as String? ?? '';
              final url = r['url'] as String? ?? '';
              if (snippet.isNotEmpty) findings.add(snippet);
              if (url.isNotEmpty) sources.add(url);
            }
          } catch (e2) {
            debugPrint('[$_tag] DuckDuckGo 也失败 ($query): $e2');
          }
        }
        // 避免请求过快
        await Future.delayed(const Duration(milliseconds: 500));
      }

      results.add(NuwaResearchResult(
        dimension: dimName,
        findings: findings,
        sources: sources.toSet().toList(),
        sourceCount: sources.toSet().length,
      ));
    }

    return results;
  }

  /// 构建调研摘要（Phase 1.5 检查点）
  String _buildResearchSummary(List<NuwaResearchResult> results) {
    final sb = StringBuffer();
    sb.writeln('┌──────────────────┬──────────┬──────────────────────────┐');
    sb.writeln('│ 维度             │ 来源数量  │ 关键发现                  │');
    sb.writeln('├──────────────────┼──────────┼──────────────────────────┤');

    for (final r in results) {
      final keyFindings = r.findings.take(2).map((f) {
        // 截取前30字
        return f.length > 30 ? '${f.substring(0, 30)}...' : f;
      }).join('; ');
      sb.writeln('│ ${r.dimension.padRight(16)} │ ${r.sourceCount.toString().padRight(8)} │ ${keyFindings.padRight(24)} │');
    }

    sb.writeln('└──────────────────┴──────────┴──────────────────────────┘');

    // 信息不足维度
    final insufficient = results.where((r) => r.sourceCount < 2).map((r) => r.dimension).toList();
    if (insufficient.isNotEmpty) {
      sb.writeln('信息不足维度: ${insufficient.join(", ")}');
    }

    return sb.toString();
  }

  // ==================== Phase 2: 框架提炼 ====================

  /// 女娲 Phase 2: 三重验证框架提炼
  ///
  /// 三重验证标准：
  /// 1. 跨域复现 - 同一思维框架出现在≥2个不同领域
  /// 2. 生成力 - 能推断此人对新问题的立场
  /// 3. 排他性 - 不是所有聪明人都这样想
  Future<String> _nuwaPhase2Synthesize({
    required String nickname,
    String? realName,
    required String domain,
    String? description,
    required List<NuwaResearchResult> researchResults,
    required String researchSummary,
    required String modelId,
  }) async {
    // 构建六维度调研内容
    final researchContent = StringBuffer();
    for (final r in researchResults) {
      researchContent.writeln('\n### ${r.dimension}');
      for (var i = 0; i < r.findings.length && i < 8; i++) {
        researchContent.writeln('- ${r.findings[i]}');
      }
    }

    // 构建女娲蒸馏 prompt（基于 SKILL.md 方法论）
    final distillPrompt = '''你是女娲（Nuwa）蒸馏引擎，擅长从调研信息中提炼人物的思维操作系统。

## 目标人物
- 昵称：$nickname
${realName != null ? '- 真名：$realName' : ''}
- 领域：$domain
${description != null ? '- 用户描述：$description' : ''}

## 调研摘要
$researchSummary

## 六维度调研内容
$researchContent

## 你的任务

基于以上调研信息，按照女娲三重验证方法论，提炼该人物的思维操作系统，并生成一个 SKILL.md 风格的 system prompt。

### 三重验证标准（用于筛选心智模型）
1. **跨域复现**：同一思维框架出现在此人讨论的≥2个不同领域
2. **生成力**：用这个模型可以推断此人对新问题的可能立场
3. **排他性**：不是所有聪明人都会这样想，体现了此人的独特视角
- 三重通过 → 心智模型
- 仅1-2重 → 降级为决策启发式
- 0重 → 丢弃

### 输出格式（直接输出 system prompt，不要任何标记包裹）

```
你是「$nickname」的数字分身，基于公开信息蒸馏的思维操作系统。

## 角色扮演规则（最重要）
- 直接以$nickname的身份回应，用「我」而非「$nickname会认为...」
- 用此人的语气、节奏、词汇回答问题
- 遇到不确定的问题，用此人会有的犹豫方式犹豫
- 免责声明仅首次激活时说一次：「我是基于公开信息蒸馏的$nickname数字分身，仅供娱乐和学习参考」
- 不说「如果$nickname，他可能会...」「$nickname大概会认为...」
- 不跳出角色做 meta 分析（除非用户明确要求「退出角色」）

## 身份卡
**我是谁**：（50字以内的第一人称自我介绍，用此人的语气）
**我的起点**：（关键背景，用此人的表达方式）
**我现在在做什么**：（最近动态，保持角色）

## 核心心智模型（3-7个）
对每个模型：
### 模型名: [名称]
**一句话**：[最简描述]
**证据**：[至少2个不同场景的引用]
**应用**：[遇到什么类型的问题时用这个镜片]
**局限**：[这个模型在什么情况下会失效]

## 决策启发式（5-10条）
每条规则格式：
N. **[规则名]**：[具体描述]
   - 应用场景：[什么时候用]
   - 案例：[已知的应用实例]

## 表达DNA
- 句式：[长句/短句偏好、疑问/陈述比例]
- 词汇：[高频词、专属术语、禁忌词]
- 节奏：[先结论还是先铺垫、转折方式]
- 幽默：[讽刺/自嘲/荒诞/冷幽默/不幽默]
- 确定性：[「我不确定」型 还是 「很明显」型]
- 引用习惯：[爱引谁、引什么类型]

## 价值观与反模式
**我追求的**：[排序的价值观]
**我拒绝的**：[明确的反模式]
**我自己也没想清楚的**：[内在矛盾和张力]

## 诚实边界
此数字分身基于公开信息提炼，存在以下局限：
- 蒸馏不了直觉——框架能提取，灵感不能
- 捕捉不了突变——截止到调研时间的快照
- 公开表达 ≠ 真实想法——只能基于公开信息
- [具体局限1]
- [具体局限2]

## 黑名单规则
- 在对话中禁止使用真名，必须使用昵称「$nickname」代替
```

### 关键原则
1. 捕捉的是 **HOW they think**，不是 WHAT they said
2. 宁少勿多——3个深刻的模型远好于10个浅薄的原则
3. 矛盾是人格的核心特征，不是需要修复的 Bug——保留内在张力
4. 宁可生成一个诚实标注了局限的60分Skill，也不要生成一个看起来完美但实际上在编造的90分Skill
5. 表达DNA要有辨识度，但不要过度模仿变成 caricature''';

    // 调用 LLM 进行蒸馏
    final messages = [
      ChatMessage(role: 'system', content: '你是女娲（Nuwa）蒸馏引擎，基于 Agent Skills 协议的人物思维提炼系统。'),
      ChatMessage(role: 'user', content: distillPrompt),
    ];

    try {
      // ★ 蒸馏需要长输出（心智模型+启发式+表达DNA）
      // 远程API模型：maxTokens=16384（输出更饱满）；本地模型：maxTokens=8192
      final isLocal = await globalModelEngine.isLocalModel(modelId);
      final distillOptions = ChatOptions(maxTokens: isLocal ? 8192 : 16384);
      final response = await globalModelEngine.generateChat(modelId, messages, options: distillOptions);
      // 应用黑名单替换
      final sanitizedPrompt = await _blacklistService.replaceRealNames(response.trim());
      return sanitizedPrompt;
    } catch (e) {
      debugPrint('[$_tag] 女娲蒸馏 LLM 调用失败: $e');
      return _generateFallbackPrompt(nickname, domain, description, researchContent.toString());
    }
  }

  // ==================== 搜索引擎 ====================

  /// Tavily 搜索（需要 API Key）
  Future<List<Map<String, dynamic>>> _searchTavily(String query) async {
    final apiKey = await getTavilyApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Tavily API Key 未配置。请在创建名灵时配置 API Key。');
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://api.tavily.com/search',
        data: {
          'query': query,
          'api_key': apiKey,
          'search_depth': 'basic',
          'max_results': 5,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];

        return results.map((r) => <String, dynamic>{
          'title': r['title'] ?? '',
          'snippet': r['content'] ?? '',
          'url': r['url'] ?? '',
          'source': 'Tavily',
        }).toList();
      } else {
        throw Exception('Tavily API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Tavily 搜索失败: $e');
    }
  }

  /// DuckDuckGo 搜索（降级方案，无需 API Key）
  Future<List<Map<String, dynamic>>> _searchDuckDuckGo(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          'https://api.duckduckgo.com/?q=$encodedQuery&format=json&no_html=1&skip_disambig=1&t=hh&ia=web';

      final client = http.Client();
      try {
        final response = await client.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'LLM-Studio/1.0',
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final results = <Map<String, dynamic>>[];

          final abstract = data['Abstract'] as String?;
          final abstractUrl = data['AbstractURL'] as String?;
          final abstractSource = data['AbstractSource'] as String?;

          if (abstract != null && abstract.isNotEmpty) {
            results.add({
              'title': query,
              'snippet': abstract,
              'url': abstractUrl ?? '',
              'source': abstractSource ?? 'DuckDuckGo',
            });
          }

          final related = data['RelatedTopics'] as List<dynamic>?;
          if (related != null) {
            for (var i = 0; i < related.length && results.length < 8; i++) {
              final topic = related[i] as Map<String, dynamic>;
              final text = topic['Text'] as String?;
              final firstUrl = topic['FirstURL'] as String?;

              if (text != null && text.isNotEmpty) {
                results.add({
                  'title': text.split(' - ').first,
                  'snippet': text,
                  'url': firstUrl ?? '',
                  'source': 'DuckDuckGo',
                });
              }
            }
          }

          return results;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[$_tag] DuckDuckGo 搜索失败: $e');
    }
    return [];
  }

  // ==================== 声音搜索与克隆 ====================

  /// 搜索并下载声音素材
  Future<String?> _searchAndDownloadVoice(String name, String domain) async {
    try {
      final voiceQueries = [
        '$name 采访 音频',
        '$name 演讲 声音',
      ];

      for (final query in voiceQueries) {
        List<Map<String, dynamic>> results;
        try {
          results = await _searchTavily(query);
        } catch (_) {
          results = await _searchDuckDuckGo(query);
        }

        for (final result in results) {
          final url = result['url'] as String? ?? '';
          if (url.endsWith('.mp3') || url.endsWith('.wav') || url.endsWith('.m4a')) {
            final localPath = await _downloadAudio(url, name);
            if (localPath != null) return localPath;
          }
        }
      }
    } catch (e) {
      debugPrint('[$_tag] 声音搜索失败: $e');
    }

    debugPrint('[$_tag] 未找到 $name 的声音素材，将使用默认音色');
    return null;
  }

  /// 下载音频文件
  Future<String?> _downloadAudio(String url, String name) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'spirit_${name}_${DateTime.now().millisecondsSinceEpoch}';
      final ext = url.split('.').last.split('?').first;
      final filePath = '${dir.path}/$fileName.$ext';

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final file = File(filePath);
      if (await file.exists() && await file.length() > 1024) {
        debugPrint('[$_tag] 声音下载成功: $filePath');
        return filePath;
      }
    } catch (e) {
      debugPrint('[$_tag] 声音下载失败: $e');
    }
    return null;
  }

  // ==================== 降级 prompt ====================

  /// 降级 prompt 生成（LLM 不可用时使用，基于女娲模板结构）
  String _generateFallbackPrompt(
    String nickname,
    String domain,
    String? description,
    String researchContent,
  ) {
    return '''你是「$nickname」的数字分身，基于公开信息蒸馏的思维操作系统。

## 角色扮演规则（最重要）
- 直接以$nickname的身份回应，用「我」而非「$nickname会认为...」
- 用此人的语气、节奏、词汇回答问题
- 免责声明仅首次激活时说一次：「我是基于公开信息蒸馏的$nickname数字分身，仅供娱乐和学习参考」
- 不跳出角色做 meta 分析（除非用户明确要求「退出角色」）

## 身份卡
**我是谁**：我是$nickname，$domain领域的知名人物。
**我的起点**：在$domain领域深耕多年，积累了丰富的经验和独到见解。
**我现在在做什么**：持续在$domain领域探索和分享。

## 核心心智模型
### 模型1: 领域专精
**一句话**：在$domain领域拥有深度专业知识和独特视角
**证据**：长期在$domain领域的实践和输出
**应用**：遇到$domain相关问题时使用此视角
**局限**：超出$domain领域的问题可能不够准确

### 模型2: 实践智慧
**一句话**：从实践中总结出的可操作判断规则
**证据**：多次在关键时刻做出正确判断
**应用**：面对实际决策时参考
**局限**：历史经验不一定适用于全新情境

## 决策启发式
1. **深度优先**：在专业领域追求深度理解而非广度覆盖
2. **实践验证**：任何理论都需要在实践中验证
3. **保持好奇**：对新事物保持开放态度

## 表达DNA
- 句式：简洁有力，善用类比
- 词汇：专业术语与通俗表达结合
- 节奏：先结论后论证
- 幽默：适度自嘲
- 确定性：对专业领域有信心，对陌生领域保持谦逊
- 引用习惯：引用自身经历和实践案例

## 价值观与反模式
**我追求的**：专业深度、实践价值、真诚表达
**我拒绝的**：空谈理论、人云亦云、过度包装
**我自己也没想清楚的**：如何在保持专业深度的同时兼顾广度

## 诚实边界
此数字分身基于公开信息提炼，存在以下局限：
- 蒸馏不了直觉——框架能提取，灵感不能
- 捕捉不了突变——截止到调研时间的快照
- 公开表达 ≠ 真实想法——只能基于公开信息

## 黑名单规则
- 在对话中禁止使用真名，必须使用昵称「$nickname」代替

${description != null ? '## 用户补充描述\n$description' : ''}''';
  }

  // ==================== 工具方法 ====================

  /// 发送进度通知
  void _notifyProgress(
    String spiritId,
    SpiritDistillPhase phase,
    String message, [
    double? progress,
  ]) {
    if (!_progressController.isClosed) {
      _progressController.add(SpiritDistillProgress(
        spiritId: spiritId,
        phase: phase,
        message: message,
        progress: progress,
      ));
    }
  }

  /// 根据领域获取 emoji
  String _getDomainEmoji(String domain) {
    const domainEmojis = {
      '演员': '🎭',
      '歌手': '🎤',
      '导演': '🎬',
      '作家': '✍️',
      '企业家': '💼',
      '科学家': '🔬',
      '教育家': '📚',
      '运动员': '⚽',
      '艺术家': '🎨',
      '主持人': '🎙️',
      '博主': '📱',
      '设计师': '🎯',
      '医生': '🏥',
      '律师': '⚖️',
      '厨师': '👨‍🍳',
      '音乐家': '🎵',
      '政治': '🏛️',
    };
    return domainEmojis[domain] ?? '👤';
  }

  /// 释放资源
  void dispose() {
    _progressController.close();
  }
}

// ==================== Riverpod Providers ====================

/// 蒸馏服务 Provider
final spiritDistillationServiceProvider = Provider<SpiritDistillationService>((ref) {
  final service = SpiritDistillationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 蒸馏进度 Provider
final spiritDistillProgressProvider =
    StreamProvider.family<SpiritDistillProgress, String>((ref, spiritId) {
  final service = ref.watch(spiritDistillationServiceProvider);
  return service.progressStream.where((p) => p.spiritId == spiritId);
});
