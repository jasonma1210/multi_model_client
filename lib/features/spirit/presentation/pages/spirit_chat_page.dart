// ignore_for_file: use_build_context_synchronously
/// 名灵回响 - 名灵对话入口页面
///
/// 与蒸馏完成的名灵角色进行对话
/// - 首次点击：选择模型和MIMO音色，保存选择
/// - 后续点击：直接进入实时语音对话
/// - 支持文字对话模式
///
/// @author JianMa
/// @version 4.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/model_provider.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/voice_clone_service.dart';
import '../../data/spirit_repository.dart';
import '../../domain/spirit_persona.dart';
import '../../domain/spirit_skill.dart';
import '../../../skill/domain/skill_dispatcher.dart';
import '../../../session/domain/session_manager.dart';
import '../../../session/data/repositories/session_repository.dart';

/// MIMO 预设音色描述映射
const Map<String, String> _mimoVoiceDescriptions = {
  'Chloe': '默认女声',
  'mimo_default': '默认音色 V2',
  'default_zh': '中文女声',
  'default_en': '英文女声',
};

class SpiritChatPage extends ConsumerStatefulWidget {
  final String spiritId;

  const SpiritChatPage({super.key, required this.spiritId});

  @override
  ConsumerState<SpiritChatPage> createState() => _SpiritChatPageState();
}

class _SpiritChatPageState extends ConsumerState<SpiritChatPage> {
  SpiritPersona? _persona;
  bool _isLoading = true;

  /// 选中的对话模型 ID
  String _selectedModelId = '';

  /// 选中的 MIMO 音色
  String _selectedVoiceId = '';

  /// 克隆音色列表
  List<ClonedVoice> _clonedVoices = [];

  @override
  void initState() {
    super.initState();
    _loadPersona();
  }

  Future<void> _loadPersona() async {
    try {
      final repo = ref.read(spiritRepositoryProvider);
      final persona = await repo.getPersonaById(widget.spiritId);

      if (persona == null || !persona.isReady) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('名灵角色不存在或未就绪')),
          );
          context.pop();
        }
        return;
      }

      if (mounted) {
        setState(() {
          _persona = persona;
          _isLoading = false;
        });

        // 初始化默认选择（首次或已有保存的配置都会预填）
        _initDefaults();
      }
    } catch (e) {
      debugPrint('[SpiritChat] 加载失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
        context.pop();
      }
    }
  }

  /// 初始化默认模型和音色选择
  void _initDefaults() {
    final modelState = ref.read(modelProvider);
    final remoteModels = modelState.remoteModels;
    final localModels = modelState.localModels;

    // 优先使用已保存的模型，其次选择远程模型，再次已加载的本地模型
    if (_persona?.lastUsedModelId != null && _persona!.lastUsedModelId!.isNotEmpty) {
      _selectedModelId = _persona!.lastUsedModelId!;
    } else if (remoteModels.isNotEmpty) {
      _selectedModelId = remoteModels.first.id;
    } else {
      final loaded = localModels.where((m) => m.isLoaded).toList();
      _selectedModelId = loaded.isNotEmpty ? loaded.first.id : (localModels.isNotEmpty ? localModels.first.id : '');
    }

    // 默认音色：优先使用已保存的音色，其次克隆音色 > 语音设置中的音色 > Chloe
    _initDefaultVoice();

    // 异步加载克隆音色列表
    _loadClonedVoices();
    setState(() {});
  }

  /// 初始化默认音色：已保存音色 > 克隆音色 > 语音设置中的音色 > Chloe
  Future<void> _initDefaultVoice() async {
    // 0. 如果有已保存的音色选择，优先使用
    if (_persona?.lastUsedVoiceId != null && _persona!.lastUsedVoiceId!.isNotEmpty) {
      _selectedVoiceId = _persona!.lastUsedVoiceId!;
      return;
    }
    // 1. 如果有克隆音色，优先使用
    if (_persona?.clonedVoiceId != null && _persona!.clonedVoiceId!.isNotEmpty) {
      _selectedVoiceId = 'clone_${_persona!.clonedVoiceId}';
      return;
    }
    // 2. 读取语音设置中的音色
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProvider = prefs.getString('tts_provider') ?? '';
      final savedVoice = prefs.getString('tts_voice_id') ?? '';
      if (savedProvider == 'mimo' && savedVoice.isNotEmpty) {
        _selectedVoiceId = savedVoice;
      } else if (savedVoice.isNotEmpty) {
        _selectedVoiceId = savedVoice;
      } else {
        _selectedVoiceId = 'Chloe';
      }
    } catch (_) {
      _selectedVoiceId = 'Chloe';
    }
  }

  /// 加载克隆音色列表
  Future<void> _loadClonedVoices() async {
    try {
      final cloneService = VoiceCloneService();
      final voices = await cloneService.getClonedVoices();
      if (mounted) {
        setState(() => _clonedVoices = voices);
      }
    } catch (e) {
      debugPrint('[SpiritChat] 加载克隆音色失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _persona != null
            ? Text('${_persona!.avatarEmoji} ${_persona!.nickname}')
            : const Text('名灵对话'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载名灵...'),
                ],
              ),
            )
          : _persona != null
              ? _buildModeSelector(theme, isDark)
              : const Center(child: Text('名灵角色加载失败')),
    );
  }

  /// 对话模式选择界面（首次使用时显示）
  Widget _buildModeSelector(ThemeData theme, bool isDark) {
    final persona = _persona!;
    final hasClonedVoice = persona.clonedVoiceId != null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 名灵头像
            Text(
              persona.avatarEmoji,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 16),
            Text(
              persona.nickname,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                persona.domain,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            if (persona.description != null) ...[
              const SizedBox(height: 8),
              Text(
                persona.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 32),

            // 对话模型选择
            _buildModelSelectorSection(theme, isDark),
            const SizedBox(height: 16),

            // MIMO 音色选择
            _buildVoiceSelectorSection(theme, isDark, hasClonedVoice),
            const SizedBox(height: 24),

            // 语音对话按钮（主要入口）
            _buildModeCard(
              theme: theme,
              isDark: isDark,
              icon: Icons.record_voice_over_rounded,
              title: '语音对话',
              subtitle: hasClonedVoice
                  ? '按住说话 · 实时打断 · 克隆音色'
                  : '按住说话 · 实时打断 · $_getSelectedVoiceName',
              color: theme.colorScheme.primary,
              onTap: () => _enterVoiceChat(persona),
            ),
            const SizedBox(height: 12),

            // 文字对话按钮
            _buildModeCard(
              theme: theme,
              isDark: isDark,
              icon: Icons.chat_rounded,
              title: '文字对话',
              subtitle: '传统文字聊天 · 语音朗读回复',
              color: theme.colorScheme.tertiary,
              onTap: () => _enterTextChat(persona),
            ),
          ],
        ),
      ),
    );
  }

  String get _getSelectedVoiceName {
    if (_persona?.clonedVoiceId != null) return '克隆音色';
    // 检查是否是克隆音色
    if (_selectedVoiceId.startsWith('clone_')) {
      final cloneId = _selectedVoiceId.substring(6);
      final clone = _clonedVoices.where((v) => v.id == cloneId).firstOrNull;
      return clone?.name ?? '克隆音色';
    }
    // Mimo 预设音色
    final desc = _mimoVoiceDescriptions[_selectedVoiceId];
    if (desc != null) return desc;
    return _selectedVoiceId;
  }

  /// 对话模型选择区域
  Widget _buildModelSelectorSection(ThemeData theme, bool isDark) {
    final modelState = ref.watch(modelProvider);
    final localModels = modelState.localModels;
    final remoteModels = modelState.remoteModels;

    if (localModels.isEmpty && remoteModels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '暂无可用模型，请先在设置中添加模型',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final items = <DropdownMenuItem<String>>[];

    if (localModels.isNotEmpty) {
      for (final model in localModels) {
        items.add(DropdownMenuItem(
          value: model.id,
          child: Row(
            children: [
              Icon(
                Icons.computer_rounded,
                size: 16,
                color: model.isLoaded ? Colors.green : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  model.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: model.isLoaded ? null : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (model.isLoaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '已加载',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
        ));
      }
    }

    if (remoteModels.isNotEmpty) {
      for (final model in remoteModels) {
        items.add(DropdownMenuItem(
          value: model.id,
          child: Row(
            children: [
              Icon(Icons.cloud_rounded, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  model.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  model.remoteConfig?.protocol.name.toUpperCase() ?? 'API',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '对话模型',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedModelId.isNotEmpty && items.any((i) => i.value == _selectedModelId)
                ? _selectedModelId
                : null,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: const Text('选择对话模型'),
            items: items,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedModelId = value);
              }
            },
          ),
        ),
      ],
    );
  }

  /// MIMO 音色选择区域（预设 + 克隆音色）
  Widget _buildVoiceSelectorSection(ThemeData theme, bool isDark, bool hasClonedVoice) {
    // 构建音色选项：克隆音色 + Mimo 预设音色
    final items = <DropdownMenuItem<String>>[];

    // ★ 克隆音色分组
    final readyClones = _clonedVoices.where((v) => v.isReady).toList();
    if (readyClones.isNotEmpty) {
      for (final clone in readyClones) {
        items.add(DropdownMenuItem(
          value: 'clone_${clone.id}',
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 16, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  clone.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '克隆',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
    }

    // ★ Mimo 预设音色分组
    for (final voice in MiMoVoice.values) {
      final desc = _mimoVoiceDescriptions[voice.name] ?? voice.name;
      items.add(DropdownMenuItem(
        value: voice.name,
        child: Row(
          children: [
            Icon(Icons.record_voice_over, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(voice.name)),
            const SizedBox(width: 4),
            Text(
              desc,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ));
    }

    // 确保当前选中的值在列表中
    final validValues = items.map((i) => i.value).toSet();
    if (!validValues.contains(_selectedVoiceId)) {
      _selectedVoiceId = hasClonedVoice && readyClones.isNotEmpty
          ? 'clone_${readyClones.first.id}'
          : MiMoVoice.Chloe.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '对话音色',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedVoiceId,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: const Text('选择音色'),
            items: items,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedVoiceId = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isEnabled = _selectedModelId.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEnabled
              ? color.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? color.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isEnabled ? color : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? null : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isEnabled
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 解析选中的音色ID：clone_ 前缀 → 返回真实UUID；否则原样返回
  String _resolveVoiceId(String voiceId) {
    if (voiceId.startsWith('clone_')) {
      return voiceId.substring(6);
    }
    return voiceId;
  }

  /// 进入语音对话模式（保存选择后跳转）
  Future<void> _enterVoiceChat(SpiritPersona persona) async {
    // 保存模型和音色选择到 persona
    final resolvedVoice = _resolveVoiceId(_selectedVoiceId);
    final repo = ref.read(spiritRepositoryProvider);
    await repo.updatePersona(persona.copyWith(
      lastUsedModelId: _selectedModelId,
      lastUsedVoiceId: _selectedVoiceId,
      // 如果选了克隆音色，同步更新 clonedVoiceId
      clonedVoiceId: _selectedVoiceId.startsWith('clone_') ? resolvedVoice : persona.clonedVoiceId,
    ));

    // 注册技能到调度器
    final dispatcher = SkillDispatcher();
    final skillManager = SpiritSkillManager();
    skillManager.registerSpiritSkill(persona, dispatcher);

    // 导航到名灵语音对话页面
    if (mounted) {
      context.push('/spirit/voice-chat/${persona.id}?modelId=${Uri.encodeComponent(_selectedModelId)}');
    }
  }

  /// 进入文字对话模式
  Future<void> _enterTextChat(SpiritPersona persona) async {
    try {
      // 保存模型选择
      final resolvedVoice = _resolveVoiceId(_selectedVoiceId);
      final repo = ref.read(spiritRepositoryProvider);
      await repo.updatePersona(persona.copyWith(
        lastUsedModelId: _selectedModelId,
        lastUsedVoiceId: _selectedVoiceId,
        clonedVoiceId: _selectedVoiceId.startsWith('clone_') ? resolvedVoice : persona.clonedVoiceId,
      ));

      // 更新 persona 引用
      persona = (await repo.getPersonaById(persona.id)) ?? persona;

      // 注册技能
      final dispatcher = SkillDispatcher();
      final skillManager = SpiritSkillManager();
      skillManager.registerSpiritSkill(persona, dispatcher);

      // 查找已有的名灵会话
      final sessionRepo = SessionRepository();
      var session = await sessionRepo.findSpiritSession(persona.id);

      if (session == null) {
        session = await sessionRepo.createSession(
          name: '${persona.avatarEmoji} ${persona.nickname}',
          modelId: _selectedModelId,
          isSpirit: true,
        );
        await sessionRepo.updateEnabledSkill(session.id, 'spirit.${persona.id}');

        // 名灵对话始终启用语音输出（有克隆音色用克隆，否则用 MiMo 预设音色）
        final isCloneVoice = _selectedVoiceId.startsWith('clone_');
        if (isCloneVoice) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('tts_provider', 'mimo');
          await prefs.setString('tts_voice_id', resolvedVoice);
        } else {
          // MiMo 预设音色
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('tts_provider', 'mimo');
          await prefs.setString('tts_voice_id', _selectedVoiceId);
        }

        await sessionRepo.updateSession(
          id: session.id,
          enableVoiceOutput: true, // 名灵对话始终启用 TTS
        );
      } else {
        // 已有会话：更新模型和音色
        if (_selectedModelId.isNotEmpty && session.modelId != _selectedModelId) {
          await sessionRepo.updateSession(
            id: session.id,
            modelId: _selectedModelId,
          );
          session = (await sessionRepo.getSession(session.id))!;
        }
        // 确保启用语音输出
        if (!session.enableVoiceOutput) {
          await sessionRepo.updateSession(
            id: session.id,
            enableVoiceOutput: true,
          );
        }
        // 更新 TTS 音色设置
        final isCloneVoice = _selectedVoiceId.startsWith('clone_');
        if (isCloneVoice) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('tts_provider', 'mimo');
          await prefs.setString('tts_voice_id', resolvedVoice);
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('tts_provider', 'mimo');
          await prefs.setString('tts_voice_id', _selectedVoiceId);
        }
      }

      final sessionManager = ref.read(sessionManagerProvider);
      await sessionManager.switchSession(session.id);

      if (mounted) {
        context.go('/session/${session.id}');
      }
    } catch (e) {
      debugPrint('[SpiritChat] 创建文字对话失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建对话失败: $e')),
        );
      }
    }
  }
}
