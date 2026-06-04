/// 跨平台统一接口封装 — LlamaCppSandbox
///
/// 职责：
/// - 统一的沙箱生命周期管理（初始化/推理/卸载）
/// - 整合 PlatformDetector + HardwareProfiler + SandboxLauncher
/// - 对外暴露简洁的 API，隐藏平台差异
/// - 错误恢复（上下文失效自动重载、GPU 崩溃 CPU 回退）
///
/// ★ 基于 llamadart 0.6.16+ 后端选择指南：
///   - 使用 engine.create() 的 enableThinking 参数控制思考模式
///   - 利用 LlamaCompletionChunkDelta.thinking 分离思考内容
///   - 利用 engine.getBackendName()/getResolvedGpuLayers() 诊断
///   - ChatSession 自动管理上下文窗口和消息历史
///
/// @author JianMa
/// @version 2.1.0 (fix garbled output)
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';

import 'platform_detector.dart';
import 'hardware_profiler.dart';
import 'sandbox_config.dart';
import 'sandbox_launcher.dart';
import '../model_inference_engine.dart' show ChatMessage, ChatOptions;
import '../../models/model_entry.dart';
import '../../services/security_bookmark_service.dart';

// ════════════════════════════════════════════════════════════════════════
//  沙箱错误分类器
// ════════════════════════════════════════════════════════════════════════

enum _SandboxErrorType {
  contextInvalid,
  gpuCrash,
  outOfMemory,
  sigill,
  unknown,
}

_SandboxErrorType _classifySandboxError(String errMsg) {
  final lower = errMsg.toLowerCase();
  if (lower.contains('out of memory') || lower.contains('oom') || lower.contains('cannot allocate')) {
    return _SandboxErrorType.outOfMemory;
  }
  if (lower.contains('sigill') || lower.contains('illegal instruction')) {
    return _SandboxErrorType.sigill;
  }
  if (lower.contains('no such instance') ||
      (lower.contains('context') && (lower.contains('invalid') || lower.contains('not found'))) ||
      lower.contains('kv cache')) {
    return _SandboxErrorType.contextInvalid;
  }
  if (lower.contains('sigsegv') ||
      lower.contains('exc_bad_access') ||
      lower.contains('metal') ||
      (lower.contains('gpu') && !lower.contains('debug')) ||
      lower.contains('ggml_metal') ||
      lower.contains('ggml_backend') ||
      lower.contains('abort')) {
    return _SandboxErrorType.gpuCrash;
  }
  return _SandboxErrorType.unknown;
}

// ════════════════════════════════════════════════════════════════════════
//  沙箱状态
// ════════════════════════════════════════════════════════════════════════

enum SandboxState { idle, initializing, ready, inferencing, contextInvalidated, error }

class SandboxStatus {
  final SandboxState state;
  final PlatformProfile? platform;
  final HardwareProfile? hardware;
  final SandboxConfig? config;
  final String? currentModelPath;
  final bool supportsVision;

  const SandboxStatus({
    required this.state,
    this.platform,
    this.hardware,
    this.config,
    this.currentModelPath,
    this.supportsVision = false,
  });
}

// ════════════════════════════════════════════════════════════════════════
//  LlamaCppSandbox
// ════════════════════════════════════════════════════════════════════════

/// 跨平台统一 llama.cpp 沙箱
class LlamaCppSandbox {
  LlamaCppSandbox._();
  static final LlamaCppSandbox instance = LlamaCppSandbox._();

  LlamaEngine? _engine;
  ChatSession? _chatSession;
  int? _contextMaxSize;
  String? _currentModelPath;
  bool _isInitialized = false;
  bool _contextInvalidated = false;
  bool _generationCancelled = false;
  bool? _visionSupported;
  SandboxConfig? _activeConfig;
  PlatformProfile? _platformProfile;
  HardwareProfile? _hardwareProfile;
  static bool _loggingConfigured = false;
  final Set<String> _tempImageFiles = {};
  int _uuidCounter = 0;
  int _estimatedUsedTokens = 0;

  // ── think 标签常量 ──
  static const String _thinkOpen = '\u{1F4AD}'; // 用特殊标记避免与模板冲突
  static const String _thinkClose = '\u{1F4AE}';

  // ════════════════════════════════════════════════════════════════════════
  //  生命周期管理
  // ════════════════════════════════════════════════════════════════════════

  SandboxStatus get status => SandboxStatus(
        state: _isInitialized ? SandboxState.ready : SandboxState.idle,
        platform: _platformProfile,
        hardware: _hardwareProfile,
        config: _activeConfig,
        currentModelPath: _currentModelPath,
        supportsVision: _visionSupported ?? false,
      );

  bool get isInitialized => _isInitialized;
  String? get currentModelPath => _currentModelPath;
  bool get supportsVision => _visionSupported ?? false;

  double get currentContextUsage {
    if (_contextMaxSize == null || _contextMaxSize == 0) return 0.0;
    return _estimatedUsedTokens / _contextMaxSize!;
  }

  int get estimatedUsedTokens => _estimatedUsedTokens;
  int get maxContextTokens => _contextMaxSize ?? 0;

  /// 初始化沙箱
  Future<void> initialize({
    required String modelPath,
    String? mmprojPath,
    LocalModelParams? userParams,
    void Function(double progress, String message)? onProgress,
  }) async {
    if (_isInitialized) {
      await dispose();
    }

    onProgress?.call(0.05, 'Detecting platform...');
    _platformProfile = PlatformDetector.instance.detect();
    debugPrint('[LlamaCppSandbox] 平台: $_platformProfile');

    onProgress?.call(0.1, 'Profiling hardware...');
    _hardwareProfile = await HardwareProfiler.instance.profile(_platformProfile!);
    debugPrint('[LlamaCppSandbox] 硬件: $_hardwareProfile');

    onProgress?.call(0.15, 'Preparing sandbox...');
    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      throw SandboxException('模型文件不存在: $modelPath');
    }
    final modelSizeMB = await modelFile.length() ~/ (1024 * 1024);

    onProgress?.call(0.2, 'Launching sandbox...');
    final launchResult = await SandboxLauncher.instance.launch(
      platform: _platformProfile!,
      hardware: _hardwareProfile!,
      modelSizeMB: modelSizeMB,
      modelPath: modelPath,
      userParams: userParams,
    );

    if (!launchResult.success) {
      throw SandboxException(launchResult.errorMessage ?? '沙箱启动失败');
    }

    _activeConfig = launchResult.appliedConfig;
    for (final w in launchResult.warnings) {
      debugPrint('[LlamaCppSandbox] WARNING: $w');
    }

    onProgress?.call(0.3, 'Configuring logging...');
    _configureLogging();

    onProgress?.call(0.4, 'Loading model...');
    try {
      final engine = LlamaEngine(LlamaBackend());
      _engine = engine;

      final modelParams = _activeConfig!.toModelParams();
      debugPrint('[LlamaCppSandbox] 配置: $_activeConfig');
      debugPrint('[LlamaCppSandbox] ModelParams: gpuLayers=${modelParams.gpuLayers}, '
          'ctx=${modelParams.contextSize}, threads=${modelParams.numberOfThreads}, '
          'batch=${modelParams.batchSize}, microBatch=${modelParams.microBatchSize}, '
          'flashAttn=${modelParams.flashAttention}, '
          'useMmap=${modelParams.useMmap}, '
          'backend=${modelParams.preferredBackend}, '
          'splitMode=${modelParams.splitMode}, '
          'cacheK=${modelParams.cacheTypeK}, cacheV=${modelParams.cacheTypeV}');

      await engine.loadModel(modelPath, modelParams: modelParams);

      _currentModelPath = modelPath;
      _isInitialized = true;
      _contextInvalidated = false;

      if (mmprojPath != null && mmprojPath.isNotEmpty) {
        try {
          await engine.loadMultimodalProjector(mmprojPath);
        } catch (e) {
          debugPrint('[LlamaCppSandbox] mmproj 加载失败: $e');
        }
      }

      _visionSupported = true;
      _initChatSession(modelParams.contextSize);
      await SandboxLauncher.instance.clearCrashFlag();

      try {
        final backendName = await engine.getBackendName();
        final resolvedGpu = await engine.getResolvedGpuLayers();
        debugPrint('[LlamaCppSandbox] 后端: $backendName, 解析 GPU 层数: ${resolvedGpu ?? "N/A"}');
      } catch (e) {
        debugPrint('[LlamaCppSandbox] 后端诊断失败: $e');
      }

      onProgress?.call(1.0, 'Model loaded');
      debugPrint('[LlamaCppSandbox] 沙箱初始化完成');
    } catch (e) {
      final isGpuCrash = _isGpuCrashError(e.toString());
      if (isGpuCrash && _platformProfile != null && _hardwareProfile != null) {
        debugPrint('[LlamaCppSandbox] GPU 崩溃，回退到 CPU 模式...');
        await _engine?.dispose();
        _engine = null;

        try {
          final cpuConfig = SandboxLauncher.instance.fallbackToCpu(
            platform: _platformProfile!,
            hardware: _hardwareProfile!,
          );
          _activeConfig = cpuConfig;

          final cpuEngine = LlamaEngine(LlamaBackend());
          _engine = cpuEngine;
          await cpuEngine.loadModel(modelPath, modelParams: cpuConfig.toModelParams());

          _currentModelPath = modelPath;
          _isInitialized = true;
          _contextInvalidated = false;

          if (mmprojPath != null && mmprojPath.isNotEmpty) {
            try {
              await cpuEngine.loadMultimodalProjector(mmprojPath);
            } catch (_) {}
          }

          _visionSupported = true;
          _initChatSession(cpuConfig.contextSize);
          await SandboxLauncher.instance.clearCrashFlag();

          onProgress?.call(1.0, 'Model loaded (CPU fallback)');
          return;
        } catch (cpuError) {
          await _engine?.dispose();
          _engine = null;
          throw SandboxException('模型加载失败（GPU崩溃，CPU模式也失败）: $cpuError');
        }
      }

      await _engine?.dispose();
      _engine = null;
      throw SandboxException('模型加载失败: $e');
    }
  }

  /// 卸载模型，释放资源
  Future<void> dispose() async {
    await _cleanupTempFiles();

    final engineToDispose = _engine;
    if (engineToDispose != null) {
      await engineToDispose.dispose();
      _engine = null;
      _chatSession = null;
      _contextMaxSize = null;

      if (Platform.isMacOS && _currentModelPath != null) {
        try {
          final modelDir = _currentModelPath!.substring(0, _currentModelPath!.lastIndexOf('/'));
          await SecurityBookmarkService.instance.stopAccessing(modelDir);
        } catch (_) {}
      }

      _currentModelPath = null;
      _isInitialized = false;
      _visionSupported = null;
      _contextInvalidated = false;
      _activeConfig = null;
      debugPrint('[LlamaCppSandbox] 沙箱已卸载');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  推理接口
  // ════════════════════════════════════════════════════════════════════════

  /// 阻塞式生成
  Future<String> generate(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    _ensureInitialized();

    if (_contextInvalidated && _currentModelPath != null) {
      await _autoReloadContext();
    }

    final enableReasoning = options?.enableReasoning ?? false;
    final processedMessages = _applyThinkingMode(messages, enableReasoning);
    final llamaMessages = _buildLlamaMessages(processedMessages);
    final genParams = _buildGenerationParams(options);
    final engine = _engine!;

    final contentBuffer = StringBuffer();
    final thinkingBuffer = StringBuffer();

    try {
      await for (final chunk in engine.create(llamaMessages, params: genParams, enableThinking: enableReasoning)) {
        _contextInvalidated = false;
        if (chunk.choices.isEmpty) continue;
        final delta = chunk.choices.first.delta;
        if (delta.content != null) contentBuffer.write(delta.content);
        if (delta.thinking != null) thinkingBuffer.write(delta.thinking);
      }
    } catch (e) {
      final errorType = _classifyError(e.toString());
      if (errorType == _SandboxErrorType.contextInvalid && _currentModelPath != null) {
        await _autoReloadContext();
        final retryEngine = _engine;
        if (retryEngine == null) throw SandboxException('上下文重载后引擎为 null');
        _contextInvalidated = false;
        await for (final chunk in retryEngine.create(
          _buildLlamaMessages(_applyThinkingMode(messages, enableReasoning)),
          params: genParams,
          enableThinking: enableReasoning,
        )) {
          if (chunk.choices.isEmpty) continue;
          final delta = chunk.choices.first.delta;
          if (delta.content != null) contentBuffer.write(delta.content);
          if (delta.thinking != null) thinkingBuffer.write(delta.thinking);
        }
      } else {
        rethrow;
      }
    }

    refreshContextUsage();

    if (enableReasoning && thinkingBuffer.isNotEmpty) {
      return '${thinkingBuffer.toString()}\n\n${contentBuffer.toString()}';
    }
    return contentBuffer.toString();
  }

  /// 流式生成
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async* {
    _ensureInitialized();

    if (_contextInvalidated && _currentModelPath != null) {
      await _autoReloadContext();
    }

    // ★ 默认 false，与 generate() 保持一致
    final enableReasoning = options?.enableReasoning ?? false;

    // ★★★ 关键修复：应用思考模式控制 ★★★
    // 旧版 LocalFFIEngine 通过 ModelInferenceEngine._applyThinkingMode() 处理
    // 新版 LlamaCppSandbox 必须自行处理，因为 _streamLocalFFI 不再调用 _applyThinkingMode()
    final processedMessages = _applyThinkingMode(messages, enableReasoning);

    final llamaMessages = _buildLlamaMessages(processedMessages);
    final genParams = _buildGenerationParams(options);
    final engine = _engine!;

    // ★ 调试日志：打印关键参数
    debugPrint('[LlamaCppSandbox] generateStream: enableReasoning=$enableReasoning, '
        'messages=${messages.length}->processed=${processedMessages.length}->llama=${llamaMessages.length}, '
        'temp=${genParams.temp}, topK=${genParams.topK}, topP=${genParams.topP}, '
        'maxTokens=${genParams.maxTokens}');

    _generationCancelled = false;
    var thinkingStarted = false;
    try {
      await for (final chunk in engine.create(llamaMessages, params: genParams, enableThinking: enableReasoning)) {
        _contextInvalidated = false;
        if (chunk.choices.isEmpty) continue;
        final delta = chunk.choices.first.delta;

        // ★ llamadart 原生分离 thinking/content
        // delta.content 和 delta.thinking 是互斥的（同一 chunk 只有一个）
        if (delta.content != null && delta.content!.isNotEmpty) {
          if (_generationCancelled) return;
          if (thinkingStarted) {
            thinkingStarted = false;
            yield _thinkClose;
          }
          yield delta.content!;
        }
        if (enableReasoning && delta.thinking != null && delta.thinking!.isNotEmpty) {
          if (_generationCancelled) return;
          if (!thinkingStarted) {
            thinkingStarted = true;
            yield _thinkOpen;
          }
          yield delta.thinking!;
        }
      }
      if (thinkingStarted) {
        yield _thinkClose;
      }
      refreshContextUsage();
    } catch (e) {
      final errorType = _classifyError(e.toString());

      if (errorType == _SandboxErrorType.outOfMemory) {
        throw SandboxException('内存不足，请关闭其他应用或选择更小的模型');
      }

      if (errorType == _SandboxErrorType.contextInvalid && _currentModelPath != null) {
        _contextInvalidated = true;
        try {
          await _autoReloadContext();
          final retryEngine = _engine;
          if (retryEngine == null) throw SandboxException('上下文重载后引擎为 null');
          _contextInvalidated = false;
          var retryThinkingStarted = false;
          await for (final chunk in retryEngine.create(
            _buildLlamaMessages(_applyThinkingMode(messages, enableReasoning)),
            params: genParams,
            enableThinking: enableReasoning,
          )) {
            if (chunk.choices.isEmpty) continue;
            final delta = chunk.choices.first.delta;
            if (delta.content != null && delta.content!.isNotEmpty) {
              if (retryThinkingStarted) {
                retryThinkingStarted = false;
                yield _thinkClose;
              }
              yield delta.content!;
            }
            if (enableReasoning && delta.thinking != null && delta.thinking!.isNotEmpty) {
              if (!retryThinkingStarted) {
                retryThinkingStarted = true;
                yield _thinkOpen;
              }
              yield delta.thinking!;
            }
          }
          if (retryThinkingStarted) yield _thinkClose;
          return;
        } catch (retryError) {
          _contextInvalidated = true;
          throw SandboxException('上下文失效且自动重载失败: $retryError');
        }
      }

      if (errorType == _SandboxErrorType.gpuCrash && _currentModelPath != null) {
        _contextInvalidated = true;
        try {
          await _autoReloadContext(forceCpuMode: true);
          final retryEngine = _engine;
          if (retryEngine == null) throw SandboxException('CPU 模式重载后引擎为 null');
          _contextInvalidated = false;
          var cpuThinkingStarted = false;
          await for (final chunk in retryEngine.create(
            _buildLlamaMessages(_applyThinkingMode(messages, enableReasoning)),
            params: genParams,
            enableThinking: enableReasoning,
          )) {
            if (chunk.choices.isEmpty) continue;
            final delta = chunk.choices.first.delta;
            if (delta.content != null && delta.content!.isNotEmpty) {
              if (cpuThinkingStarted) {
                cpuThinkingStarted = false;
                yield _thinkClose;
              }
              yield delta.content!;
            }
            if (enableReasoning && delta.thinking != null && delta.thinking!.isNotEmpty) {
              if (!cpuThinkingStarted) {
                cpuThinkingStarted = true;
                yield _thinkOpen;
              }
              yield delta.thinking!;
            }
          }
          if (cpuThinkingStarted) yield _thinkClose;
          return;
        } catch (cpuError) {
          _contextInvalidated = true;
          throw SandboxException('GPU崩溃，CPU模式也失败: $cpuError');
        }
      }

      rethrow;
    }
  }

  /// 停止当前生成
  Future<void> stopGeneration() async {
    _generationCancelled = true;
    _engine?.cancelGeneration();
    debugPrint('[LlamaCppSandbox] 生成停止请求已发送');
  }

  // ════════════════════════════════════════════════════════════════════════
  //  上下文管理
  // ════════════════════════════════════════════════════════════════════════

  void _initChatSession(int contextSize) {
    final engine = _engine;
    if (engine == null) return;
    _contextMaxSize = contextSize;
    _chatSession = ChatSession(engine, maxContextTokens: contextSize, systemPrompt: null);
    refreshContextUsage();
  }

  void refreshContextUsage() {
    if (_chatSession != null) {
      _estimatedUsedTokens = _estimateHistoryTokens(_chatSession!.history);
    }
  }

  void updateContextUsageFromMessages(List<dynamic> messages, {int extraTokens = 0}) {
    _estimatedUsedTokens = _estimateHistoryTokens(messages) + extraTokens;
  }

  void resetChatSession({bool keepSystemPrompt = true}) {
    _chatSession?.reset(keepSystemPrompt: keepSystemPrompt);
    refreshContextUsage();
  }

  int _estimateHistoryTokens(List<dynamic> messages) {
    int total = 0;
    for (final msg in messages) {
      final content = msg.content?.toString() ?? '';
      if (content.isEmpty) continue;
      int cjkCount = 0;
      int otherCount = 0;
      for (int i = 0; i < content.length; i++) {
        final c = content.codeUnitAt(i);
        if (c > 0x2E80) {
          cjkCount++;
        } else {
          otherCount++;
        }
      }
      total += (cjkCount * 1.5 + otherCount * 0.3).ceil();
    }
    return total;
  }

  // ════════════════════════════════════════════════════════════════════════
  //  内部辅助
  // ════════════════════════════════════════════════════════════════════════

  void _ensureInitialized() {
    if (!_isInitialized || _engine == null) {
      throw SandboxException('沙箱未初始化，请先调用 initialize()');
    }
  }

  void _configureLogging() {
    if (_loggingConfigured) return;
    _loggingConfigured = true;
    try {
      LlamaEngine.configureLogging(
        level: LlamaLogLevel.warn,
        handler: (record) {
          if (record.level == LlamaLogLevel.error || record.level == LlamaLogLevel.warn) {
            debugPrint('[llama.cpp] ${record.level.name}: ${record.message}');
          }
        },
      );
    } catch (e) {
      debugPrint('[LlamaCppSandbox] 配置日志失败: $e');
    }
  }

  /// 采样参数转换
  GenerationParams _buildGenerationParams(ChatOptions? options) {
    return GenerationParams(
      temp: options?.temperature ?? 0.7,
      topK: options?.topK ?? 40,
      topP: options?.topP ?? 0.95,
      minP: 0.05,
      penalty: options?.repeatPenalty ?? 1.1,
      maxTokens: options?.maxTokens ?? 4096,
    );
  }

  /// 思考模式控制 — 双层策略
  ///
  /// ★ 此方法从旧版 ModelInferenceEngine._applyThinkingMode() 迁移而来
  /// 因为 _streamLocalFFI() 不再调用 ModelInferenceEngine._applyThinkingMode()
  ///
  /// 层1：System prompt 注入/清理思考引导语
  /// 层2：enableReasoning=false 时在最后一条 user 消息末尾追加 /no_think
  ///       （Qwen3 / QwQ 等模型的原生 thinking_budget 控制 token）
  List<ChatMessage> _applyThinkingMode(List<ChatMessage> messages, bool enableReasoning) {
    if (messages.isEmpty) return messages;

    final modifiedMessages = List<ChatMessage>.from(messages);

    // ── 层 1：处理 system prompt ──
    final firstMessage = messages.first;
    if (firstMessage.role != 'system') {
      final thinkingPrompt = enableReasoning
          ? '你是一个善于思考的AI助手。在回答复杂问题时，请先展示你的思考过程，然后再给出最终答案。'
          : '你是一个高效的AI助手，请直接给出简洁的答案。';
      modifiedMessages.insert(0, ChatMessage(role: 'system', content: thinkingPrompt));
    } else {
      var sysContent = firstMessage.content;
      // 清理旧的思考引导语
      sysContent = sysContent
          .replaceAll(RegExp(r'\n\n请在回答复杂问题时先展示思考过程.*', dotAll: true), '')
          .replaceAll(RegExp(r'\n\n请直接给出简洁明了的答案.*', dotAll: true), '')
          .replaceAll(RegExp(r'\n\n你是一个高效的AI助手.*', dotAll: true), '');
      if (enableReasoning) {
        sysContent += '\n\n请在回答复杂问题时先展示思考过程，然后再给出最终答案。';
      }
      modifiedMessages[0] = ChatMessage(role: 'system', content: sysContent);
    }

    // ── 层 2：用户消息追加 /no_think 控制 token（仅关闭时）──
    if (!enableReasoning) {
      for (int i = modifiedMessages.length - 1; i >= 0; i--) {
        if (modifiedMessages[i].role == 'user') {
          final userMsg = modifiedMessages[i];
          if (!userMsg.content.endsWith('/no_think')) {
            modifiedMessages[i] = ChatMessage(
              role: 'user',
              content: '${userMsg.content} /no_think',
              images: userMsg.images,
            );
          }
          break;
        }
      }
    }

    return modifiedMessages;
  }

  /// 构建 llamadart 消息列表
  List<LlamaChatMessage> _buildLlamaMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) return [];

    // ── Step 1: 合并连续 system 消息 ──
    final merged = <ChatMessage>[];
    final systemParts = <String>[];
    var collectingSystem = true;

    for (final msg in messages) {
      if (msg.role == 'system' && collectingSystem) {
        if (msg.content.isNotEmpty) systemParts.add(msg.content);
      } else {
        if (collectingSystem && systemParts.isNotEmpty) {
          collectingSystem = false;
          merged.add(ChatMessage(role: 'system', content: systemParts.join('\n\n')));
        }
        collectingSystem = false;
        merged.add(msg);
      }
    }
    if (collectingSystem && systemParts.isNotEmpty) {
      merged.add(ChatMessage(role: 'system', content: systemParts.join('\n\n')));
    }

    // ── Step 2: 合并连续相同角色消息 ──
    final deduped = <ChatMessage>[];
    for (final msg in merged) {
      if (deduped.isNotEmpty && deduped.last.role == msg.role) {
        final prev = deduped.removeLast();
        deduped.add(ChatMessage(role: prev.role, content: '${prev.content}\n\n${msg.content}'));
      } else {
        deduped.add(msg);
      }
    }

    // ── Step 3: 确保角色交替 ──
    final fixed = <ChatMessage>[];
    for (int i = 0; i < deduped.length; i++) {
      final msg = deduped[i];
      fixed.add(msg);
      if (msg.role == 'system' && i + 1 < deduped.length && deduped[i + 1].role == 'assistant') {
        fixed.add(ChatMessage(role: 'user', content: '继续'));
      }
    }

    // ── Step 4: 确保首条非 system 消息是 user ──
    if (fixed.isNotEmpty && fixed.first.role != 'system' && fixed.first.role != 'user') {
      fixed.insert(0, ChatMessage(role: 'user', content: '你好'));
    }

    // ── Step 5: 转换为 llamadart 消息 ──
    final result = <LlamaChatMessage>[];
    for (final msg in fixed) {
      final role = switch (msg.role) {
        'system' => LlamaChatRole.system,
        'user' => LlamaChatRole.user,
        'assistant' => LlamaChatRole.assistant,
        _ => LlamaChatRole.user,
      };

      if (msg.hasImages) {
        final parts = <LlamaContentPart>[];
        for (final img in msg.images) {
          final tmpPath = _writeImageToTempFile(img.base64Data, img.mimeType);
          parts.add(LlamaImageContent(path: tmpPath));
        }
        if (msg.content.isNotEmpty) parts.add(LlamaTextContent(msg.content));
        result.add(LlamaChatMessage.withContent(role: role, content: parts));
      } else {
        result.add(LlamaChatMessage.fromText(role: role, text: msg.content));
      }
    }

    final roleSeq = result.map((m) => m.role.name[0].toUpperCase()).join('->');
    debugPrint('[LlamaCppSandbox] 消息角色序列: $roleSeq (${result.length}条)');

    return result;
  }

  String _writeImageToTempFile(String base64Data, String mimeType) {
    final tmpDir = Directory.systemTemp;
    final ext = mimeType == 'image/png' ? 'png' : 'jpg';
    final fileName = 'llama_img_${DateTime.now().millisecondsSinceEpoch}_${_uuidCounter++}.$ext';
    final file = File('${tmpDir.path}/$fileName');
    final dataUri = Uri.parse('data:$mimeType;base64,$base64Data');
    file.writeAsBytesSync(dataUri.data!.contentAsBytes());
    _tempImageFiles.add(file.path);
    return file.path;
  }

  Future<void> _cleanupTempFiles() async {
    for (final path in _tempImageFiles.toList()) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    _tempImageFiles.clear();
  }

  /// 自动重载上下文
  Future<void> _autoReloadContext({bool forceCpuMode = false}) async {
    if (_currentModelPath == null) throw SandboxException('无法重载：未记录模型路径');

    debugPrint('[LlamaCppSandbox] 自动重载上下文 (CPU=$forceCpuMode)...');

    final oldEngine = _engine;
    if (oldEngine != null) {
      try {
        await oldEngine.dispose();
      } catch (_) {}
      _engine = null;
    }

    _isInitialized = false;
    _contextInvalidated = false;

    final newEngine = LlamaEngine(LlamaBackend());
    _engine = newEngine;

    if (forceCpuMode && _platformProfile != null && _hardwareProfile != null) {
      _activeConfig = SandboxLauncher.instance.fallbackToCpu(
        platform: _platformProfile!,
        hardware: _hardwareProfile!,
      );
    }

    final modelParams = _activeConfig?.toModelParams() ?? ModelParams();
    await newEngine.loadModel(_currentModelPath!, modelParams: modelParams);

    _isInitialized = true;
    _contextInvalidated = false;
    _visionSupported = true;
    _initChatSession(modelParams.contextSize);

    debugPrint('[LlamaCppSandbox] 上下文重载完成');
  }

  _SandboxErrorType _classifyError(String errMsg) => _classifySandboxError(errMsg);

  bool _isGpuCrashError(String errMsg) {
    final lower = errMsg.toLowerCase();
    return lower.contains('sigsegv') ||
        lower.contains('exc_bad_access') ||
        lower.contains('metal') ||
        lower.contains('gpu') ||
        lower.contains('signal') ||
        lower.contains('abort') ||
        lower.contains('ggml_metal') ||
        lower.contains('ggml_backend') ||
        lower.contains('sigill') ||
        lower.contains('illegal');
  }
}

// ════════════════════════════════════════════════════════════════════════
//  异常类
// ════════════════════════════════════════════════════════════════════════

class SandboxException implements Exception {
  final String message;
  SandboxException(this.message);
  @override
  String toString() => 'SandboxException: $message';
}
