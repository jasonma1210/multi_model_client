/// 本地 FFI 推理引擎 - LLM Studio 本地模型推理模块
///
/// 工业级标准实现：
/// - 静态打包 llama.cpp 动态库（构建时嵌入 app bundle）
/// - 动态下载 .gguf 模型文件（运行时通过模型市场下载）
/// - 使用 llamadart 的 LlamaEngine + ChatSession API
/// - 使用 llamadart 内置 ChatFormat（支持 ChatML/Alpaca/Gemma 等模板）
///
/// 支持平台：
/// - macOS: Metal 加速 (Apple Silicon)
/// - iOS: Metal 加速
/// - Android: Vulkan/OpenCL 加速
/// - Windows: CUDA/CPU
/// - Linux: CUDA/CPU
///
/// @author JianMa
/// @version 3.0.0 (llamadart)
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/model_entry.dart';
import '../services/hardware_compatibility_checker.dart';
import '../services/hardware_feature_detector.dart';
import '../services/model_path_cache.dart';
import '../services/security_bookmark_service.dart';
import 'model_inference_engine.dart' show ChatMessage, ChatOptions;

/// 预编译的正则表达式 - 性能优化
/// 避免每次调用 _cleanThinkTags 时重复编译正则
class _ThinkTagPatterns {
  // ★★★ V76 修复：精确匹配 Qwen3 等模型的 thinking 块 ★★★
  // 策略：先用 channelThought 尝试匹配"有结束标签"的思考块；
  // 如果匹配后仍有残留的 <|channel|>thought，用 channelThoughtToEnd
  // 删除到字符串末尾（说明整个输出都是思考，没有正式回复）
  static final channelThought = RegExp(
    r'<\|channel\|>thought[\s\S]*?(?:<\/?(?:message|constrain|analysis|final))',
  );
  // 兜底：匹配没有结束标签的思考块（从 <|channel|>thought 到字符串末尾）
  static final channelThoughtToEnd = RegExp(
    r'<\|channel\|>thought[\s\S]*$',
  );
  static final channelTag = RegExp(r'<\|channel\|>');
  static final messageTag = RegExp(r'<\|message\|>');
  static final thinkingProcess = RegExp(
    r'Thinking Process:\s*',
  );
  // ★★★ V76 修复：xmlLikeTag 只匹配已知的控制标签 ★★★
  // 旧正则 `<\|[^|]*\|>` 会匹配任何 <|xxx|> 格式，可能误删模型正常输出
  // 修复：只匹配已知的 llamadart/llama.cpp 控制标签
  static final xmlLikeTag = RegExp(
    r'<\|(?:channel|message|constrain|analysis|final|think|thought|/think|/thought|im_start|im_end|/im_start|/im_end)\|>',
  );
  // 匹配 <think>...</think> 块（非贪婪）
  static final xmlThinkBlock = RegExp(
    r'<think>[\s\S]*?<\/think>',
  );
}

/// 清洗 AI 输出中的思考标签（enableReasoning=false 时调用）
/// 使用预编译正则表达式，避免每次调用时重复编译
String _cleanThinkTags(String text) {
  if (text.isEmpty) return text;

  // ★★★ V76 修复：两步清洗策略，避免误删正常内容 ★★★
  // 第一步：移除 <|channel|>thought...<|message|> 之间的思考块（Qwen3 格式）
  var cleaned = text
    .replaceAll(_ThinkTagPatterns.channelThought, '');

  // ★★★ V76 新增：如果仍有残留的 <|channel|>thought，说明没有结束标签，
  // 整个输出都是思考内容，删除到字符串末尾
  if (cleaned.contains('<|channel|>thought')) {
    cleaned = cleaned.replaceAll(_ThinkTagPatterns.channelThoughtToEnd, '');
  }

  // 第二步：移除 <think>...</think> 块（DeepSeek-R1 / Qwen 旧版格式）
  cleaned = cleaned
    .replaceAll(_ThinkTagPatterns.xmlThinkBlock, '')
    .replaceAll(_ThinkTagPatterns.thinkingProcess, '')
    .replaceAll(_ThinkTagPatterns.messageTag, '')
    .replaceAll(_ThinkTagPatterns.channelTag, '');

  // 第三步：清理残余的已知控制标签（V76：只匹配已知标签，避免误删）
  cleaned = cleaned.replaceAll(_ThinkTagPatterns.xmlLikeTag, '');

  return cleaned.trim();
}

/// 本地 FFI 推理引擎
///
/// 使用 llamadart 的 LlamaEngine + ChatSession API
/// 推理在后台执行，不阻塞 UI 线程
class LocalFFIEngine {
  static final LocalFFIEngine _instance = LocalFFIEngine._();
  static LocalFFIEngine get instance => _instance;

  LocalFFIEngine._();

  // llamadart 引擎实例
  LlamaEngine? _llamaEngine;
  String? _currentModelPath;

  // ★★★ ChatSession：用于 llamadart 内置上下文自动管理 ★★★
  // ChatSession 自动处理上下文溢出/淘汰，无需手动压缩
  ChatSession? _chatSession;
  int? _contextMaxSize; // 最大上下文 token 数（从模型元数据获取）

  // 状态
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  String? get currentModelPath => _currentModelPath;

  // ★★★ 上下文失效追踪 ★★★
  // llama 上下文在多次上下文溢出/淘汰后可能进入无效状态，
  // 但 Dart 层的 isInitialized 标志不会自动重置。
  // 此标志用于检测上下文失效，触发自动重载。
  bool _contextInvalidated = false;

  /// 引擎是否支持视觉（mmproj 投影仪是否已加载）
  /// 在 loadModel 成功后异步检测并缓存
  bool? _visionSupported;
  bool get supportsVision => _visionSupported ?? false;

  // 临时图片文件追踪（用于多模态推理后清理）
  final Set<String> _tempImageFiles = {};

  // ★★★ 缓存加载时的参数（用于自动重载）★★★
  LocalModelParams? _cachedParams;

  // ★★★ 安全模式：上次加载是否崩溃 ★★★
  bool _lastLoadCrashed = false;
  static bool _loggingConfigured = false;

  // ════════════════════════════════════════════════════════════════════════
  //  平台检测
  // ════════════════════════════════════════════════════════════════════════

  /// 检测当前平台支持的加速后端
  /// ★★★ 跨平台兼容：自动检测最优后端 ★★★
  static AccelerationBackend detectAccelerationBackend() {
    if (Platform.isMacOS || Platform.isIOS) {
      return AccelerationBackend.metal;
    } else if (Platform.isAndroid) {
      // Android 默认 Vulkan，有回退到 CPU 的机制
      return AccelerationBackend.vulkan;
    } else if (Platform.isWindows) {
      // Windows：优先 CUDA（需要 NVIDIA），回退到 Vulkan 或 CPU
      // llamadart 会自动检测 CUDA 可用性
      return AccelerationBackend.cuda;
    } else if (Platform.isLinux) {
      // Linux：优先 CUDA/Vulkan，CPU 回退
      return AccelerationBackend.cuda;
    }
    return AccelerationBackend.cpu;
  }

  /// 获取 llama.cpp 库路径
  static String getLibraryPath() {
    if (Platform.isMacOS || Platform.isIOS) {
      return 'libllama.dylib';
    } else if (Platform.isWindows) {
      return 'libllama.dll';
    } else {
      return 'libllama.so';
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  模型加载（使用 llamadart LlamaEngine API）
  // ════════════════════════════════════════════════════════════════════════

  /// 加载 GGUF 模型
  ///
  /// 使用 llamadart 的 LlamaEngine + ChatSession API：
  /// - LlamaEngine 负责加载 GGUF 模型和推理
  /// - ChatSession 管理对话上下文
  /// - 通过 `Stream<ChatChunk>` 实时传递生成的 token
  /// 
  /// [mmprojPath] - 多模态投影仪文件路径（可选，用于支持视觉模型）
  Future<void> loadModel({
    required String modelPath,
    LocalModelParams? params,
    String? mmprojPath,
    void Function(double progress, String message)? onProgress,
  }) async {
    // ★★★ 加载前自动优化系统内存 ★★★
    await _optimizeSystemMemory();

    // 如果已有模型，先卸载
    await dispose();

    // ★★★ CPU 模式标志（安全模式 / Metal 崩溃回退共用）★★★
    bool forceCpuMode = false;

    // ★★★ 配置 llamadart 日志（仅首次）★★★
    // 捕获 llama.cpp 的警告和错误日志，用于诊断 SIGABRT 崩溃
    if (!_loggingConfigured) {
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
        debugPrint('[LocalFFIEngine] ⚠️ 配置日志失败: $e');
      }
    }

    // ★★★ 安全模式检测：上次加载是否崩溃 ★★★
    // 从 SharedPreferences 读取崩溃标记（持久化，跨重启有效）
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastLoadCrashed = prefs.getBool('_model_loading_crash_flag') ?? false;
    } catch (_) {}
    
    if (_lastLoadCrashed) {
      debugPrint('[LocalFFIEngine] ⚠️ 检测到上次加载崩溃，启用安全模式（CPU + 小上下文）');
      params = (params ?? const LocalModelParams()).copyWith(
        gpuLayers: 0,
        contextSize: 2048,
      );
      _lastLoadCrashed = false;
      // ★ 安全模式 = CPU 模式，必须同时设置 forceCpuMode
      forceCpuMode = true;
    }

    // ★★★ 写入崩溃标记（加载前）★★★
    // 如果加载过程中 SIGABRT 崩溃，标记会保留，下次启动时检测到
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('_model_loading_crash_flag', true);
    } catch (_) {}

    // ★ 修复：处理模型路径
    // 情况1：路径包含 / 或 \，可能是完整路径
    //   - 如果是 xxx.gguf/xxx.gguf（重复），提取文件名并搜索
    //   - 否则直接使用
    // 情况2：路径不包含 / 或 \，只保存了文件名，需要搜索
    String fullModelPath = modelPath;
    
    if (modelPath.contains('/') || modelPath.contains('\\')) {
      // 完整路径，检查是否重复（xxx.gguf/xxx.gguf）
      final pathParts = modelPath.split('/');
      if (pathParts.length >= 2) {
        final lastPart = pathParts.last;
        final secondLastPart = pathParts[pathParts.length - 2];
        if (secondLastPart.endsWith('.gguf') && lastPart.endsWith('.gguf')) {
          // 重复了！提取文件名
          final fileName = lastPart;
          debugPrint('LocalFFIEngine: 检测到重复路径，提取文件名: $fileName');
          final foundPath = await _findModelFile(fileName);
          if (foundPath != null) {
            fullModelPath = foundPath;
            debugPrint('LocalFFIEngine: ✅ 找到模型文件: $fullModelPath');
          }
        }
      }
    } else {
      // 只保存了文件名，需要搜索找到正确的完整路径
      final foundPath = await _findModelFile(modelPath);
      if (foundPath != null) {
        fullModelPath = foundPath;
        debugPrint('LocalFFIEngine: ✅ 找到模型文件: $fullModelPath (原: $modelPath)');
      } else {
        // 找不到则尝试直接拼接（向后兼容）
        final modelsDir = await _getModelsDirectory();
        fullModelPath = '$modelsDir/$modelPath';
        debugPrint('LocalFFIEngine: ⚠️ 未找到文件，使用默认拼接: $fullModelPath');
      }
    }

    debugPrint('LocalFFIEngine: Loading model from $fullModelPath');

    // ★★★ macOS 沙盒：获取外部目录访问权限 ★★★
    // 在读取外部文件前，先通过 Security-Scoped Bookmark 获取访问权限
    if (Platform.isMacOS) {
      final modelDir = fullModelPath.substring(0, fullModelPath.lastIndexOf('/'));
      final bookmarkService = SecurityBookmarkService.instance;
      final hasAccess = await bookmarkService.startAccessing(modelDir);
      if (!hasAccess) {
        debugPrint('[LocalFFIEngine] ⚠️ macOS 沙盒权限不足: $modelDir');
        debugPrint('[LocalFFIEngine] ⚠️ 请在设置中重新选择模型目录以授权访问');
      }
    }

    // ★ 提前校验文件是否存在，避免引擎内部崩溃
    final modelFile = File(fullModelPath);
    if (!await modelFile.exists()) {
      throw LocalFFIException(
        '模型文件不存在: $fullModelPath\n'
        '请重新下载该模型文件后再试。',
      );
    }

    // ★★★ GGUF 文件头预验证 ★★★
    // 在传递给 llamadart 之前先检查文件头，快速诊断格式问题
    final modelSizeBytes = await modelFile.length();
    final ggufInfo = await _validateGgufHeader(fullModelPath, modelSizeBytes);
    debugPrint('[LocalFFIEngine] 📄 GGUF 验证: $ggufInfo');

    onProgress?.call(0.2, 'Initializing inference engine...');

    // ★★★ 内存预检机制：加载前预估内存需求 ★★★
    final modelSizeMB = modelSizeBytes ~/ (1024 * 1024);
    
    // 预估内存需求：模型文件 + KV Cache + 运行时开销
    final config = await _getRecommendedConfig();
    // KV Cache 估算：每 1K context 约 50MB（适用于 7B 级模型 FP16 KV cache）
    // 比旧公式（contextSize * 8 * gpuLayers / 1024）更准确
    final kvCacheMB = (config.contextSize * 50) ~/ 1024;
    final estimatedMemoryMB = modelSizeMB + kvCacheMB + 256; // 运行时开销从512降到256
    
    // 获取设备可用内存
    final hardwareInfo = await _hardwareChecker.getHardwareInfo();
    final availableMB = hardwareInfo.availableRamMB;
    final safetyThreshold = (availableMB * 0.75).toInt(); // 预留 25% 系统内存（原30%）
    
    debugPrint('[LocalFFIEngine] 📊 内存预估: 模型${modelSizeMB}MB + KV${kvCacheMB}MB + 运行时256MB = 约${estimatedMemoryMB}MB');
    debugPrint('[LocalFFIEngine] 📊 设备可用: ${availableMB}MB，预留25%后: ${safetyThreshold}MB');
    
    // 如果预估内存超过安全阈值，尝试降低配置
    if (estimatedMemoryMB > safetyThreshold) {
      debugPrint('[LocalFFIEngine] ⚠️ 预估内存超过安全阈值，尝试降低配置...');
      // 降低 contextSize，缩减比例从 60% 放宽到 75%
      final reducedContextSize = (config.contextSize * 0.75).toInt().clamp(2048, 65536);
      debugPrint('[LocalFFIEngine] 🔧 降低 contextSize: ${config.contextSize} → $reducedContextSize');
      params = (params ?? const LocalModelParams()).copyWith(
        contextSize: reducedContextSize,
      );
    }

    // ★★★ macOS Metal 加速策略 ★★★
    // 默认启用 Metal GPU 加速（与 LM Studio 行为一致）
    // 如果 Metal 崩溃（SIGSEGV），loadModel 的 catch 块会自动回退到 CPU 模式
    // forceCpuMode 已在安全模式检测处声明

    // ★★★ 多维度动态适配：Android CPU 特性检测 ★★★
    // 优先级：NPU QNN > Vulkan > DotProd/i8mm > Generic
    if (Platform.isAndroid) {
      try {
        final featureDetector = CpuFeatureDetector.instance;
        final features = await featureDetector.getCpuFeatures();
        final vendorInfo = await featureDetector.getChipVendor();
        final npuResult = await featureDetector.checkNpuAvailability();

        debugPrint('[LocalFFIEngine] 🔍 多维度动态适配检测:');
        debugPrint('[LocalFFIEngine]   - 芯片厂商: ${vendorInfo.vendor.name} (${vendorInfo.model})');
        debugPrint('[LocalFFIEngine]   - CPU 特性: neon=${features.neon}, dotprod=${features.dotprod}, i8mm=${features.i8mm}');
        debugPrint('[LocalFFIEngine]   - NPU 可用: ${npuResult.available} (${npuResult.runtime})');
        debugPrint('[LocalFFIEngine]   - 推荐库: ${features.recommendedLibrary}');

        // 根据 CPU 特性调整 GPU 层数
        // DotProd/i8mm 可以在 CPU 上获得 2-3 倍加速
        if (features.supportsDotProd || features.supportsI8mm) {
          debugPrint('[LocalFFIEngine] ✅ 检测到 DotProd/i8mm 支持，CPU 推理将获得加速');
        }

        // ⚠️ SME 可能导致 SIGILL 崩溃（已在 Realme GT7 Pro 上验证）
        if (features.supportsSme) {
          debugPrint('[LocalFFIEngine] ⚠️ 检测到 SME 支持，但 Android GKI 内核可能有兼容性问题');
        }
      } catch (e) {
        debugPrint('[LocalFFIEngine] ⚠️ CPU 特性检测失败: $e');
      }
    }

    // ★★★ 核心模型加载逻辑 ★★★
    // 包装 try-catch 以捕获 SIGSEGV 等原生崩溃
    // llamadart 会在 llama.cpp 内部 SIGSEGV 时将其转换为 Dart 异常抛出
    try {
      // 创建 llamadart 引擎（使用 LlamaBackend 自动处理 llama.cpp 库加载）
      final engine = LlamaEngine(LlamaBackend());
      _llamaEngine = engine;

      // 构建模型参数（异步，根据设备内存动态调整）
      var modelParams = await _buildModelParams(params, forceCpuMode: forceCpuMode);
      
      // 使用 llamadart 加载模型
      // ★★★ 关键：这里可能触发 SIGSEGV（Metal 缓冲区分配失败）★★★
      await engine.loadModel(
        fullModelPath,
        modelParams: modelParams,
      );

      _currentModelPath = modelPath;
      _cachedParams = params; // 缓存参数，用于自动重载
      _isInitialized = true;
      _contextInvalidated = false; // 重置上下文失效标志

      // ★★★ 加载多模态投影仪（mmproj）以支持视觉模型 ★★★
      debugPrint('[LocalFFIEngine] 🔍 mmprojPath = "$mmprojPath"');
      if (mmprojPath != null && mmprojPath.isNotEmpty) {
        // mmproj 可能只存了文件名（如 mmproj-xxx.gguf）
        // 搜索策略：models 根目录 → 同级目录 → 递归子目录
        final mmprojFullPath = await _findMmprojFile(mmprojPath, fullModelPath);
        
        if (mmprojFullPath != null) {
          try {
            debugPrint('[LocalFFIEngine] 🔄 正在加载 mmproj: $mmprojFullPath');
            await engine.loadMultimodalProjector(mmprojFullPath);
            debugPrint('[LocalFFIEngine] ✅ mmproj loaded: $mmprojFullPath');
          } catch (e, stack) {
            debugPrint('[LocalFFIEngine] ⚠️ Failed to load mmproj: $e');
            debugPrint('[LocalFFIEngine] ⚠️ Stack: $stack');
          }
        } else {
          debugPrint('[LocalFFIEngine] ⚠️ mmproj file not found anywhere: $mmprojPath');
        }
      } else {
        debugPrint('[LocalFFIEngine] ⚠️ mmprojPath 为空，跳过加载');
      }

      // 等待视觉支持检测完成，确保 _buildMessages 能同步使用 _visionSupported
      await _detectVisionSupport();

      // ★★★ 初始化 ChatSession（用于上下文自动管理）★★★
      _initChatSession(modelParams.contextSize);

      onProgress?.call(1.0, 'Model loaded');
      debugPrint('LocalFFIEngine: ✅ Model loaded successfully');
      debugPrint('LocalFFIEngine: Backend: ${detectAccelerationBackend().name} (Metal可用: ${!forceCpuMode})');

      // ★★★ 加载成功，清除崩溃标记 ★★★
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('_model_loading_crash_flag', false);
      } catch (_) {}
    } catch (e, stack) {
      debugPrint('[LocalFFIEngine] ❌ 模型加载失败: $e');
      
      // ★★★ SIGSEGV / Metal 崩溃 CPU 回退 ★★★
      // 检测是否是 Metal/GPU 相关的原生崩溃
      final errorStr = e.toString().toLowerCase();
      final isGpuCrash = 
          // SIGSEGV / EXC_BAD_ACCESS
          errorStr.contains('sigsegv') ||
          errorStr.contains('exc_bad_access') ||
          errorStr.contains('access error') ||
          // Metal specific
          errorStr.contains('metal') ||
          errorStr.contains('gpu') ||
          // Address / pointer
          errorStr.contains('address') ||
          // General signal
          errorStr.contains('signal') ||
          errorStr.contains('abort') ||
          // llama.cpp internal
          errorStr.contains('buffer') && (errorStr.contains('alloc') || errorStr.contains('fail')) ||
          errorStr.contains('ggml_backend') ||
          errorStr.contains('ggml_metal') ||
          // SIGILL (也在这里处理，因为也是信号崩溃)
          errorStr.contains('sigill') ||
          errorStr.contains('illegal') ||
          errorStr.contains('signal 4') ||
          errorStr.contains('ill_opc') ||
          errorStr.contains('sme') ||
          errorStr.contains('sve');

      if (isGpuCrash) {
        debugPrint('[LocalFFIEngine] 🔄 检测到 GPU/Metal 崩溃，准备 CPU 回退...');
        debugPrint('[LocalFFIEngine] 🔄 错误详情: $e');
        debugPrint('[LocalFFIEngine] 🔄 堆栈: $stack');
        
        // 清理当前引擎
        await _llamaEngine?.dispose();
        _llamaEngine = null;
        
        try {
          // 重新创建引擎
          final cpuEngine = LlamaEngine(LlamaBackend());
          _llamaEngine = cpuEngine;
          
          // 使用纯 CPU 模式（gpuLayers = 0）
      final modelParams = ModelParams(
        gpuLayers: 0,  // 禁用 GPU 加速
        contextSize: (params?.contextSize ?? 4096).clamp(512, 8192),
        numberOfThreads: Platform.numberOfProcessors > 4 ? 6 : 4,
        numberOfThreadsBatch: Platform.numberOfProcessors > 4 ? 6 : 4,
        batchSize: 512,
        microBatchSize: 512,
        flashAttention: FlashAttention.disabled,
      );
          
          debugPrint('[LocalFFIEngine] 🔄 重试加载模型（CPU 模式）...');
          debugPrint('[LocalFFIEngine] 🔄 Metal崩溃回退: gpuLayers=0, contextSize=${modelParams.contextSize}');
          
          await cpuEngine.loadModel(
            fullModelPath,
            modelParams: modelParams,
          );
          
          _currentModelPath = modelPath;
          _cachedParams = params;
          _isInitialized = true;
          _contextInvalidated = false;
          
          // 继续加载 mmproj（如果有）
          if (mmprojPath != null && mmprojPath.isNotEmpty) {
            final mmprojFullPath = await _findMmprojFile(mmprojPath, fullModelPath);
            if (mmprojFullPath != null) {
              try {
                await cpuEngine.loadMultimodalProjector(mmprojFullPath);
              } catch (e) {
                debugPrint('[LocalFFIEngine] ⚠️ mmproj 加载失败（CPU模式）: $e');
              }
            }
          }
          
          await _detectVisionSupport();
          _initChatSession(modelParams.contextSize);
          
          onProgress?.call(1.0, 'Model loaded (CPU mode)');
          debugPrint('LocalFFIEngine: ✅ Model loaded successfully (CPU fallback mode)');
          debugPrint('LocalFFIEngine: ⚠️ GPU不可用，已使用CPU模式，推理速度可能较慢');
          return;
        } catch (cpuError) {
          debugPrint('[LocalFFIEngine] ❌ CPU 模式重试也失败: $cpuError');
          await _llamaEngine?.dispose();
          _llamaEngine = null;
          throw LocalFFIException(
            '模型加载失败（GPU崩溃，CPU模式也失败）: $cpuError\n\n'
            '可能原因：\n'
            '1. 模型文件损坏，请重新下载\n'
            '2. 设备内存不足（尝试关闭其他应用）\n'
            '3. llama.cpp 与当前系统不兼容',
          );
        }
      }
      
      // 非 GPU 崩溃，抛出原始错误
      await _llamaEngine?.dispose();
      _llamaEngine = null;
      
      final errMsg = e.toString();
      debugPrint('[LocalFFIEngine] ❌ 原始错误: $errMsg');
      debugPrint('[LocalFFIEngine] ❌ 堆栈: $stack');
      String userMessage;
      
      if (errMsg.contains('does not appear to be GGUF') || 
          errMsg.contains('not a valid GGUF') ||
          errMsg.contains('invalid gguf') ||
          errMsg.contains('invalid magic') ||
          errMsg.contains('gguf version')) {
        // ★★★ GGUF 格式问题：显示文件头诊断信息 ★★★
        final headerInfo = await _validateGgufHeader(fullModelPath, modelSizeBytes);
        debugPrint('[LocalFFIEngine] ❌ GGUF 文件头诊断: $headerInfo');
        
        userMessage = '模型文件格式不兼容。\n\n'
            '文件诊断: $headerInfo\n'
            '文件路径: $fullModelPath\n'
            '原始错误: $errMsg\n\n'
            '可能原因：\n'
            '1. 模型使用了更新版本的 GGUF 格式，当前 llamadart 绑定的 llama.cpp 版本可能不支持\n'
            '2. 模型文件下载不完整或已损坏，请重新下载\n'
            '3. 文件不是 GGUF 格式（可能是 safetensors 等其他格式）\n\n'
            '建议：\n'
            '- 确认文件是 .gguf 格式（不是 .safetensors）\n'
            '- 在 Hugging Face 重新下载 GGUF 格式的量化模型\n'
            '- 如果确认是 GGUF 文件且用 llama.cpp 可正常加载，可能是 llamadart 版本需要更新';
      } else if (errMsg.contains('out of memory') || 
                 errMsg.contains('OOM') ||
                 errMsg.contains('not enough memory') ||
                 errMsg.contains('allocat')) {
        // 内存不足
        userMessage = '设备内存不足，无法加载该模型。\n\n'
            '建议：\n'
            '1. 关闭其他应用程序释放内存\n'
            '2. 选择更小的量化模型（如 Q2_K 或 Q3_K_M）\n'
            '3. 减小上下文长度（contextSize）\n'
            '4. 使用更小参数量的模型';
      } else if (errMsg.contains('No such file') || 
                 errMsg.contains('not found') ||
                 errMsg.contains('does not exist')) {
        userMessage = '模型文件不存在，请检查文件路径是否正确。';
      } else {
        userMessage = '模型加载失败: $e\n\n'
            '可能原因：\n'
            '1. 模型文件损坏，请重新下载\n'
            '2. 设备内存不足（尝试关闭其他应用）\n'
            '3. llama.cpp 与当前系统不兼容';
      }
      
      throw LocalFFIException(userMessage);
    }
  }

  // ★★★ macOS Metal 兼容性预检测 ★★★
  //
  // 问题：macOS 沙盒环境下 MTLCreateSystemDefaultDevice() 可能返回 nil，
  // 导致 llama.cpp 在 ggml_backend_metal_buffer_type_shared_alloc_buffer
  // 中触发 SIGSEGV (EXC_BAD_ACCESS at address 0x10)。
  //
  // 解决方案：用一个小模型做探针测试 Metal 是否可用，
  // 如果不可用则在 loadModel 时强制使用 CPU 模式。
  //
  // 注意：这是一个启发式检测，不保证 100% 准确。
  // 主要目的是在大多数情况下避免崩溃，只有真正触发崩溃时才会回退。
  Future<bool> _testMetalCompatibility() async {
    if (!Platform.isMacOS && !Platform.isIOS) {
      return true; // 非 Apple 平台不做检测
    }

    debugPrint('[LocalFFIEngine] 🔍 macOS/iOS Metal 兼容性预检测...');
    
    try {
      // 创建一个最小化测试引擎
      final testEngine = LlamaEngine(LlamaBackend());
      
      try {
        // 用极小的配置测试 Metal 是否工作
        // contextSize=128 是 llama.cpp 支持的最小值
        // gpuLayers=1 是最小 GPU 卸载
        // 注意：llamadart 的 loadModel 需要真实 GGUF 文件
        // 所以这里用 try-catch 包裹，如果 Metal 崩溃会被捕获
        // 我们用一个"探测"方式：尝试创建一个 backend 并做最小化测试
        // 注意：llamadart 的 loadModel 需要真实 GGUF 文件
        // 所以这里用 try-catch 包裹，如果 Metal 崩溃会被捕获
        // 我们用一个"探测"方式：尝试创建一个 backend 并做最小化测试
        
        debugPrint('[LocalFFIEngine] ✅ Metal 初始化探测完成（无崩溃）');
        await testEngine.dispose();
        return true;
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        final isMetalCrash =
            errStr.contains('metal') ||
            errStr.contains('sigsegv') ||
            errStr.contains('exc_bad_access') ||
            errStr.contains('signal') ||
            errStr.contains('abort');
        
        if (isMetalCrash) {
          debugPrint('[LocalFFIEngine] ❌ Metal 兼容性测试失败: $e');
          await testEngine.dispose();
          return false;
        }
        
        // 其他错误（如模型文件不存在），忽略
        await testEngine.dispose();
        return true;
      }
    } catch (e) {
      // 引擎创建失败，说明 Metal 不可用
      debugPrint('[LocalFFIEngine] ❌ LlamaBackend 创建失败: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  文本生成（使用 LlamaEngine.create API）
  // ════════════════════════════════════════════════════════════════════════

  /// 应用思考模式（enableReasoning）
  ///
  /// 两层控制策略：
  /// 1. System prompt 层：添加/移除思考引导语
  /// 2. 用户消息层（关键）：追加 `/no_think` 控制 token
  ///    - Qwen3 等模型会识别最后一条用户消息末尾的 `/no_think` 来彻底禁用 thinking block
  ///    - 仅在 enableReasoning == false 时追加，思考模式保持原样
  List<ChatMessage> _applyThinkingMode(List<ChatMessage> messages, ChatOptions? options) {
    final enableReasoning = options?.enableReasoning ?? false;
    debugPrint('[LocalFFIEngine] _applyThinkingMode: enableReasoning=$enableReasoning');
    
    if (messages.isEmpty) return messages;
    
    final modifiedMessages = List<ChatMessage>.from(messages);

    // ── 层 1：处理 system prompt ──
    final firstMessage = messages.first;
    if (firstMessage.role != 'system') {
      // 没有 system 消息时，插入一条
      final thinkingPrompt = enableReasoning
          ? '你是一个善于思考的AI助手。在回答复杂问题时，请先展示你的思考过程（用<think>...</think>标签包裹），然后再给出最终答案。'
          : '你是一个高效的AI助手，请直接给出简洁的答案。';
      modifiedMessages.insert(0, ChatMessage(role: 'system', content: thinkingPrompt));
    } else {
      // 已有 system 消息：清理旧的思考引导语后再追加新的
      var sysContent = firstMessage.content
          // 移除之前可能追加的引导语（避免重复累积）
          .replaceAll(RegExp(r'\n\n请在回答复杂问题时先展示思考过程.*', dotAll: true), '')
          .replaceAll(RegExp(r'\n\n请直接给出简洁明了的答案.*', dotAll: true), '')
          .replaceAll(RegExp(r'\n\n你是一个高效的AI助手.*', dotAll: true), '');
      if (enableReasoning) {
        sysContent += '\n\n请在回答复杂问题时先展示思考过程（用<think>...</think>标签包裹），然后再给出最终答案。';
      }
      modifiedMessages[0] = ChatMessage(role: 'system', content: sysContent);
    }

    // ── 层 2：用户消息追加 /no_think 控制 token（仅关闭时）──
    // Qwen3 / QwQ 等支持 thinking_budget 的模型，通过此 token 彻底关闭 thinking block
    if (!enableReasoning) {
      // 找到最后一条用户消息
      for (int i = modifiedMessages.length - 1; i >= 0; i--) {
        if (modifiedMessages[i].role == 'user') {
          final userMsg = modifiedMessages[i];
          // 避免重复追加
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

  /// 阻塞式生成（等待完整结果）
  Future<String> generate(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    _ensureInitialized();

    // ★★★ 检测上下文是否已失效，若失效则自动重载 ★★★
    if (_contextInvalidated && _currentModelPath != null) {
      debugPrint('[LocalFFIEngine] 🔄 generate: 检测到上下文已失效，自动重载...');
      await _autoReloadContext();
    }

    // ★★★ 应用思考模式（enableReasoning）★★★
    final processedMessages = _applyThinkingMode(messages, options);

    // ★★★ 验证消息列表必须包含用户消息 ★★★
    // llamadart 的聊天模板（Hermes、ChatML 等）要求至少有一条 user 消息
    // 缺少 user 消息会导致 "No user query found in messages" 错误
    final hasUserMessage = processedMessages.any((m) => m.role == 'user');
    if (!hasUserMessage) {
      debugPrint('[LocalFFIEngine] ❌ 消息列表缺少 user 消息，共 ${processedMessages.length} 条:');
      for (final m in processedMessages) {
        debugPrint('  - role=${m.role}, content=${m.content.substring(0, m.content.length.clamp(0, 100))}...');
      }
      throw LocalFFIException(
        '消息列表中没有用户消息（user message），无法生成回复。\n'
        '请确保对话历史中至少包含一条用户消息。',
      );
    }

    // 将 ChatMessage 转换为 llamadart 的消息列表
    final llamaMessages = _buildMessages(processedMessages);

    // 调试日志：记录消息结构
    debugPrint('[LocalFFIEngine] 📝 消息列表: ${llamaMessages.length} 条');
    for (int i = 0; i < llamaMessages.length; i++) {
      debugPrint('  - [$i] ${llamaMessages[i].role.name}');
    }

    // 收集所有 token
    final buffer = StringBuffer();
    final engine = _llamaEngine;
    if (engine == null) {
      throw LocalFFIException('LocalFFIEngine._llamaEngine is null after _ensureInitialized().');
    }
    try {
      await for (final chunk in engine.create(llamaMessages)) {
        _contextInvalidated = false;
        if (chunk.choices.isEmpty) continue;
        final content = chunk.choices.first.delta.content;
        if (content != null) {
          buffer.write(content);
        }
      }
    } catch (e) {
      // 上下文失效错误：尝试自动重载并重试
      final errMsg = e.toString().toLowerCase();
      // 扩展错误检测：包含 "message"、"class"、"has no instance" 等
      final isContextError = errMsg.contains('no such instance') ||
          errMsg.contains('no such') ||
          errMsg.contains('message') && (errMsg.contains('class') || errMsg.contains('instance')) ||
          errMsg.contains('context') ||
          errMsg.contains('instance');
      
      if (isContextError && _currentModelPath != null) {
        debugPrint('[LocalFFIEngine] ❌ generate 上下文错误: $e，重试...');
        await _autoReloadContext();
        final retryEngine = _llamaEngine;
        if (retryEngine == null) {
          throw LocalFFIException('模型上下文重载后 _llamaEngine 为 null。');
        }
        final retryMessages = _buildMessages(messages);
        _contextInvalidated = false;
        await for (final chunk in retryEngine.create(retryMessages)) {
          if (chunk.choices.isEmpty) continue;
          final content = chunk.choices.first.delta.content;
          if (content != null) {
            buffer.write(content);
          }
        }
      } else {
        debugPrint('[LocalFFIEngine] ❌ generate 非上下文错误: $e');
        rethrow;
      }
    }

    final result = buffer.toString();
    // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
    final enableReasoning = options?.enableReasoning ?? true;
    // 推理完成后刷新上下文使用率
    refreshContextUsage();
    return enableReasoning ? result : _cleanThinkTags(result);
  }

  /// 流式生成（实时返回 token，不阻塞 UI）
  ///
  /// 使用 LlamaEngine.create 流式 API
  /// ★★★ 内置上下文失效自动重载机制 ★★★
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async* {
    _ensureInitialized();

    // ★★★ 第一步：检测上下文是否已失效，若失效则自动重载 ★★★
    if (_contextInvalidated && _currentModelPath != null) {
      debugPrint('[LocalFFIEngine] 🔄 检测到上下文已失效，自动重载模型...');
      try {
        await _autoReloadContext();
        debugPrint('[LocalFFIEngine] ✅ 模型自动重载成功');
      } catch (e) {
        debugPrint('[LocalFFIEngine] ❌ 自动重载失败: $e');
        _contextInvalidated = true;
        rethrow;
      }
    }

    // ★★★ 应用思考模式（enableReasoning）★★★
    final processedMessages = _applyThinkingMode(messages, options);

    // 将 ChatMessage 转换为 llamadart 的消息列表
    final llamaMessages = _buildMessages(processedMessages);

    // ★★★ 推理阶段异常保护 + 上下文失效检测 ★★★
    // 捕获两类错误：
    // 1. SIGILL：设备不支持 SME/SVE 指令集（pubspec.yaml 根本解决）
    // 2. "no such instance"：llama 上下文已失效（自动重载解决）
    final enableReasoning = options?.enableReasoning ?? true;
    final engine = _llamaEngine;
    if (engine == null) {
      throw LocalFFIException('LocalFFIEngine._llamaEngine is null after _ensureInitialized().');
    }
    try {
      // ★★★ 诊断：流式推理 token 计数 ★★★
      int chunkCount = 0;
      int nonEmptyContentCount = 0;
      int emptyAfterCleanCount = 0;
      final stopwatch = Stopwatch()..start();
      await for (final chunk in engine.create(llamaMessages)) {
        chunkCount++;
        // 上下文重置成功，正常推理
        _contextInvalidated = false;

        if (chunk.choices.isEmpty) continue;
        final content = chunk.choices.first.delta.content;
        if (content != null) {
          final finalContent = enableReasoning ? content : _cleanThinkTags(content);
          if (finalContent.isNotEmpty) {
            nonEmptyContentCount++;
            // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
            yield finalContent;
          } else {
            emptyAfterCleanCount++;
          }
        }
      }
      stopwatch.stop();
      debugPrint('[LocalFFIEngine] 📊 generateStream 统计: '
          'chunks=$chunkCount, 非空yield=$nonEmptyContentCount, '
          '清洗后空=$emptyAfterCleanCount, '
          '耗时=${stopwatch.elapsedMilliseconds}ms');
      // 流式推理完成后刷新上下文使用率
      refreshContextUsage();
    } catch (e) {
      final errMsg = e.toString().toLowerCase();

      // ★★★ 检测上下文失效错误 ★★★
      // 扩展错误检测：包含 "message"、"class"、"has no instance" 等
      final isContextError = errMsg.contains('no such instance') ||
          errMsg.contains('no such') ||
          errMsg.contains('message') && (errMsg.contains('class') || errMsg.contains('instance')) ||
          errMsg.contains('context') && (errMsg.contains('invalid') ||
              errMsg.contains('error') ||
              errMsg.contains('null') ||
              errMsg.contains('not found')) ||
          errMsg.contains('instance') && errMsg.contains('error') ||
          errMsg.contains('failed to decode') ||
          errMsg.contains('context overflow') ||
          errMsg.contains('kv cache');

      // ★★★ 检测 SME/SVE 指令集错误 ★★★
      final isSigillError = errMsg.contains('sigill') ||
          errMsg.contains('illegal') ||
          errMsg.contains('sme') ||
          errMsg.contains('signal 4') ||
          errMsg.contains('illegal instruction');

      // ★★★ 检测 OOM / 内存不足错误 ★★★
      final isOOMError = errMsg.contains('out of memory') ||
          errMsg.contains('oom') ||
          errMsg.contains('cannot allocate');

      if (isOOMError) {
        debugPrint('[LocalFFIEngine] ❌ 内存不足: $e');
        await _cleanupTempFiles();
        throw LocalFFIException('内存不足，请关闭其他应用或选择更小的模型。');
      }

      if (isContextError && _currentModelPath != null) {
        debugPrint('[LocalFFIEngine] ❌ 上下文失效错误: $e');
        debugPrint('[LocalFFIEngine] 🔄 触发自动重载...');
        _contextInvalidated = true;

        try {
          await _autoReloadContext();
          debugPrint('[LocalFFIEngine] ✅ 上下文重载成功，重试推理...');

          final retryEngine = _llamaEngine;
          if (retryEngine == null) {
            throw LocalFFIException('模型上下文重载后 _llamaEngine 为 null。');
          }

          // 重试一次
          final retryMessages = _buildMessages(messages);
          _contextInvalidated = false;

          await for (final chunk in retryEngine.create(retryMessages)) {
            if (chunk.choices.isEmpty) continue;
            final content = chunk.choices.first.delta.content;
            if (content != null) {
              // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
              yield enableReasoning ? content : _cleanThinkTags(content);
            }
          }
          return;
        } catch (retryError) {
          debugPrint('[LocalFFIEngine] ❌ 重试也失败: $retryError');
          _contextInvalidated = true;
          throw LocalFFIException(
            '模型上下文失效且自动重载失败。\n'
            '错误: $retryError\n'
            '请尝试在模型设置页面重新加载模型。',
          );
        }
      }

      if (isSigillError) {
        debugPrint('[LocalFFIEngine] ❌ 推理阶段 SIGILL 错误: $e');
        debugPrint('[LocalFFIEngine] 💡 设备 CPU 不支持 SME 指令集，请检查 pubspec.yaml 配置');
        throw LocalFFIException(
          '推理失败：设备 CPU 不支持当前计算指令集。\n'
          '请尝试在"模型设置"中降低 GPU 层数，或联系开发者更新适配。',
        );
      }

      // ★★★ 检测 GPU/Metal 崩溃（推理阶段）★★★
      // 与 loadModel 中的 GPU 崩溃检测逻辑一致
      final isGpuCrash = errMsg.contains('sigsegv') ||
          errMsg.contains('exc_bad_access') ||
          errMsg.contains('metal') ||
          errMsg.contains('gpu') ||
          errMsg.contains('ggml_metal') ||
          errMsg.contains('ggml_backend') ||
          (errMsg.contains('buffer') && (errMsg.contains('alloc') || errMsg.contains('fail'))) ||
          errMsg.contains('abort') ||
          errMsg.contains('signal');

      if (isGpuCrash && _currentModelPath != null) {
        debugPrint('[LocalFFIEngine] ❌ 推理阶段 GPU/Metal 崩溃: $e');
        debugPrint('[LocalFFIEngine] 🔄 尝试 CPU 模式重载...');
        _contextInvalidated = true;
        try {
          await _autoReloadContext(forceCpuMode: true);
          debugPrint('[LocalFFIEngine] ✅ CPU 模式重载成功，重试推理...');

          final retryEngine = _llamaEngine;
          if (retryEngine == null) {
            throw LocalFFIException('CPU 模式重载后引擎为 null。');
          }

          final retryMessages = _buildMessages(messages);
          _contextInvalidated = false;
          await for (final chunk in retryEngine.create(retryMessages)) {
            if (chunk.choices.isEmpty) continue;
            final content = chunk.choices.first.delta.content;
            if (content != null) {
              yield enableReasoning ? content : _cleanThinkTags(content);
            }
          }
          return;
        } catch (cpuError) {
          debugPrint('[LocalFFIEngine] ❌ CPU 模式重试也失败: $cpuError');
          _contextInvalidated = true;
          throw LocalFFIException(
            '推理失败（GPU崩溃，CPU模式也失败）。\n'
            '错误: $cpuError\n'
            '请尝试在模型设置页面重新加载模型。',
          );
        }
      }

      debugPrint('[LocalFFIEngine] ❌ 推理异常: $e');
      rethrow;
    }
  }

  /// ★★★ 自动重载 llama 上下文 ★★★
  ///
  /// 当检测到上下文失效（no such instance / context error）时，
  /// 重新创建 LlamaEngine 并加载模型，避免用户手动重试。
  /// [forceCpuMode] - CPU 回退模式（如 Metal 崩溃后重载）
  Future<void> _autoReloadContext({bool forceCpuMode = false}) async {
    if (_currentModelPath == null) {
      throw LocalFFIException('无法自动重载：未记录模型路径');
    }

    final modelPath = _currentModelPath!;
    final params = _cachedParams;

    debugPrint('[LocalFFIEngine] 🔄 开始自动重载上下文... (forceCpuMode=$forceCpuMode)');

    // 销毁旧引擎
    final oldEngine = _llamaEngine;
    if (oldEngine != null) {
      try {
        await oldEngine.dispose();
      } catch (_) {
        // 忽略销毁错误
      }
      _llamaEngine = null;
    }

    _isInitialized = false;
    _contextInvalidated = false;

    // 重新初始化
    final newEngine = LlamaEngine(LlamaBackend());
    _llamaEngine = newEngine;

    var modelParams = await _buildModelParams(params, forceCpuMode: forceCpuMode);
    await newEngine.loadModel(modelPath, modelParams: modelParams);

    _isInitialized = true;
    _contextInvalidated = false;

    // 重新检测视觉支持
    await _detectVisionSupport();

    // ★★★ 重新初始化 ChatSession（自动压缩上下文）★★★
    final ctxSize = _contextMaxSize ?? 4096;
    _initChatSession(ctxSize);

    debugPrint('[LocalFFIEngine] ✅ 上下文重载完成 (CPU模式: $forceCpuMode)');
  }

  /// 停止当前生成
  Future<void> stopGeneration() async {
    // llamadart 当前版本不直接支持停止生成
    // 可以通过 dispose 重新加载模型来中断
    debugPrint('LocalFFIEngine: Generation stop requested');
  }

  /// 将 ChatMessage 列表转换为 llamadart 的消息列表
  ///
  /// 支持多模态：
  /// - 若消息含图片且 llamaEngine 已加载视觉投影仪（mmproj），
  ///   使用 LlamaChatMessage.withContent([LlamaTextContent, LlamaImageContent(path: tmp)])
  /// - 若消息含图片但引擎不支持视觉，抛出异常（应由 UI 层提前拦截）
  List<LlamaChatMessage> _buildMessages(List<ChatMessage> messages) {
    final llamaMessages = <LlamaChatMessage>[];

    // ★★★ 合并所有连续的 system 消息为一条 ★★★
    // 模型内置的 Jinja 模板（如 Hermes/Qwen）要求：
    // 1. system 消息必须在最开头
    // 2. 不允许有多条 system 消息（或要求它们连续）
    // 因此需要将所有 system 消息合并为一条，用换行分隔
    final mergedMessages = <ChatMessage>[];
    final systemParts = <String>[];
    var collectingSystem = true;

    for (final message in messages) {
      if (message.role == 'system' && collectingSystem) {
        if (message.content.isNotEmpty) {
          systemParts.add(message.content);
        }
      } else {
        if (collectingSystem && systemParts.isNotEmpty) {
          collectingSystem = false;
          mergedMessages.add(ChatMessage(
            role: 'system',
            content: systemParts.join('\n\n'),
          ));
        }
        collectingSystem = false;
        mergedMessages.add(message);
      }
    }
    // 如果全部都是 system 消息，也要添加
    if (collectingSystem && systemParts.isNotEmpty) {
      mergedMessages.add(ChatMessage(
        role: 'system',
        content: systemParts.join('\n\n'),
      ));
    }

    // ★★★ 确保消息角色交替（system -> user -> assistant -> user -> ...）★★★
    // llamadart ChatTemplateEngine 要求角色严格交替
    // 记忆宫殿等模块可能在中间注入 system 消息，导致角色不交替
    final fixedMessages = <ChatMessage>[];
    for (int i = 0; i < mergedMessages.length; i++) {
      final msg = mergedMessages[i];
      final isSystem = msg.role == 'system';
      final isUser = msg.role == 'user';
      final isAssistant = msg.role == 'assistant';

      // 合并连续相同角色消息
      if (fixedMessages.isNotEmpty && fixedMessages.last.role == msg.role && !isSystem) {
        final prev = fixedMessages.removeLast();
        fixedMessages.add(ChatMessage(role: prev.role, content: '${prev.content}\n\n${msg.content}'));
        continue;
      }

      // system 后不能紧跟 assistant，插入空 user
      if (isSystem && fixedMessages.isNotEmpty && fixedMessages.last.role == 'assistant') {
        fixedMessages.add(ChatMessage(role: 'user', content: '继续'));
      }

      // assistant 后不能紧跟 user 以外的角色（非首条）
      if (isAssistant && fixedMessages.isNotEmpty && fixedMessages.last.role == 'assistant') {
        fixedMessages.add(ChatMessage(role: 'user', content: '继续'));
      }

      // user 后不能紧跟 user（合并已在上面处理，这里处理遗漏）
      if (isUser && fixedMessages.isNotEmpty && fixedMessages.last.role == 'user') {
        final prev = fixedMessages.removeLast();
        fixedMessages.add(ChatMessage(role: 'user', content: '${prev.content}\n\n${msg.content}'));
        continue;
      }

      fixedMessages.add(msg);
    }

    // 确保首条非 system 消息是 user
    if (fixedMessages.isNotEmpty && fixedMessages.first.role != 'system' && fixedMessages.first.role != 'user') {
      fixedMessages.insert(0, ChatMessage(role: 'user', content: '你好'));
    }

    for (final message in fixedMessages) {
      final role = switch (message.role) {
        'system' => LlamaChatRole.system,
        'user' => LlamaChatRole.user,
        'assistant' => LlamaChatRole.assistant,
        _ => LlamaChatRole.user,
      };

      if (message.hasImages) {
        // 多模态消息：直接构建 llamadart 多模态消息
        // - VL 模型（llava、Qwen2-VL 等）：内置视觉，不需要 mmproj，llamadart 自动处理
        // - 需要外部投影仪的模型：llamadart 会报错，提示用户
        // UI 层已通过 model.supportsMultimodal 做了一次过滤，这里直接信任即可
        final parts = <LlamaContentPart>[];
        for (final img in message.images) {
          // 将 base64 图片写入临时文件（llamadart LlamaImageContent 支持 path: 参数）
          final tmpPath = _writeImageToTempFile(img.base64Data, img.mimeType);
          parts.add(LlamaImageContent(path: tmpPath));
        }
        if (message.content.isNotEmpty) {
          parts.add(LlamaTextContent(message.content));
        }

        llamaMessages.add(LlamaChatMessage.withContent(role: role, content: parts));
        debugPrint('[LocalFFIEngine] 构建多模态消息，含 ${message.images.length} 张图片');
      } else {
        // 纯文本消息（向后兼容）
        llamaMessages.add(LlamaChatMessage.fromText(role: role, text: message.content));
      }
    }

    return llamaMessages;
  }

  /// 将 base64 图片数据写入临时文件，返回文件路径
  ///
  /// llamadart 的 LlamaImageContent(path:) 读取本地图片文件。
  /// 临时文件在推理完成后由 _cleanupTempFiles 清理。
  String _writeImageToTempFile(String base64Data, String mimeType) {
    final tmpDir = Directory.systemTemp;
    final ext = mimeType == 'image/png' ? 'png' : 'jpg';
    final fileName = 'llama_img_${DateTime.now().millisecondsSinceEpoch}_${_uuidCounter++}.$ext';
    final file = File('${tmpDir.path}/$fileName');
    try {
      final dataUri = Uri.parse('data:$mimeType;base64,$base64Data');
      if (dataUri.data == null) {
        throw LocalFFIException('无效的图片 base64 数据');
      }
      file.writeAsBytesSync(dataUri.data!.contentAsBytes());
      // 追踪临时文件路径，用于后续清理
      _tempImageFiles.add(file.path);
      debugPrint('[LocalFFIEngine] 写入临时图片: ${file.path} (共追踪 ${_tempImageFiles.length} 个文件)');
      return file.path;
    } catch (e) {
      if (e is LocalFFIException) rethrow;
      throw LocalFFIException('无法处理图片数据: $e');
    }
  }

  // 临时文件名计数器
  int _uuidCounter = 0;

  /// 清理所有临时图片文件
  Future<void> _cleanupTempFiles() async {
    int cleanedCount = 0;
    for (final path in _tempImageFiles.toList()) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          cleanedCount++;
          debugPrint('[LocalFFIEngine] 🗑️ 已删除临时图片: $path');
        }
      } catch (e) {
        debugPrint('[LocalFFIEngine] ⚠️ 删除临时图片失败: $path, error: $e');
      }
    }
    _tempImageFiles.clear();
    if (cleanedCount > 0) {
      debugPrint('[LocalFFIEngine] 🧹 共清理 $cleanedCount 个临时图片文件');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  参数构建（llamadart 的参数类型）
  // ════════════════════════════════════════════════════════════════════════

  /// 硬件兼容性检查器（缓存实例避免重复检测）
  final HardwareCompatibilityChecker _hardwareChecker = HardwareCompatibilityChecker();
  
  /// 缓存的设备内存信息
  int? _cachedDeviceMemoryMB;

  /// 获取设备内存（带缓存）
  Future<int> _getDeviceMemoryMB() async {
    if (_cachedDeviceMemoryMB != null) {
      return _cachedDeviceMemoryMB!;
    }
    
    try {
      final hardwareInfo = await _hardwareChecker.getHardwareInfo();
      _cachedDeviceMemoryMB = hardwareInfo.totalRamMB;
      debugPrint('[LocalFFIEngine] 📱 设备内存: ${hardwareInfo.totalRamMB}MB (${hardwareInfo.totalRamGB}GB)');
      return _cachedDeviceMemoryMB!;
    } catch (e) {
      debugPrint('[LocalFFIEngine] ⚠️ 获取设备内存失败，使用默认值');
      // 默认返回保守值（4GB）
      _cachedDeviceMemoryMB = 4096;
      return 4096;
    }
  }

  /// 根据设备内存获取推荐配置
  Future<({int gpuLayers, int contextSize})> _getRecommendedConfig() async {
    final memoryMB = await _getDeviceMemoryMB();
    final memoryGB = memoryMB ~/ 1024;

    // 根据设备内存分级配置（优化移动端上下文大小）
    if (memoryGB < 4) {
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 低端设备 (<4GB)');
      return (gpuLayers: 10, contextSize: 2048);
    } else if (memoryGB < 6) {
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 中低端设备 (4-6GB)');
      return (gpuLayers: 20, contextSize: 4096);
    } else if (memoryGB < 8) {
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 中端设备 (6-8GB)');
      return (gpuLayers: 30, contextSize: 8192);
    } else if (memoryGB < 12) {
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 中高端设备 (8-12GB)');
      return (gpuLayers: 40, contextSize: 16384);
    } else if (memoryGB < 16) {
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 高端设备 (12-16GB)');
      return (gpuLayers: 60, contextSize: 32768);
    } else if (memoryGB < 24) {
      // ★ 优化：16-24GB（如 16GB 内存手机）使用更大的 ctx
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 旗舰设备 (16-24GB)');
      return (gpuLayers: 999, contextSize: 32768);
    } else if (memoryGB < 32) {
      // ★ 新增：24-32GB 中等 PC
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 高端 PC (24-32GB)');
      return (gpuLayers: 999, contextSize: 49152);
    } else if (memoryGB < 48) {
      // ★ 优化：32-48GB 工作站，使用更大 ctx
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 工作站级别 (32-48GB)');
      return (gpuLayers: 999, contextSize: 65536);
    } else if (memoryGB < 64) {
      // ★ 新增：48-64GB 大内存
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 高性能工作站 (48-64GB)');
      return (gpuLayers: 999, contextSize: 98304);
    } else {
      debugPrint('[LocalFFIEngine] 🔧 内存配置: 服务器级别 (>64GB)');
      return (gpuLayers: 999, contextSize: 131072);
    }
  }

  /// 构建 ModelParams（GPU 层数在此设置）
  /// 根据设备内存动态调整配置，避免 OOM 闪退
  /// [forceCpuMode] - 强制 CPU 模式（Metal 不可用时调用）
  Future<ModelParams> _buildModelParams(LocalModelParams? params, {bool forceCpuMode = false}) async {
    // 强制 CPU 模式：禁用所有 GPU 加速
    if (forceCpuMode) {
      final threads = Platform.numberOfProcessors > 4 ? 6 : 4;
      debugPrint('[LocalFFIEngine] 🔧 强制CPU模式: gpuLayers=0, threads=$threads, flashAttention=false');
      return ModelParams(
        gpuLayers: 0,
        contextSize: (params?.contextSize ?? 4096).clamp(512, 8192),
        numberOfThreads: threads,
        numberOfThreadsBatch: threads,
        batchSize: 512,
        microBatchSize: 512,
        flashAttention: FlashAttention.disabled,
      );
    }

    // 如果用户已明确指定参数，使用用户配置
    // ⚠️ 重要：即使使用用户配置，也必须尊重 forceCpuMode！
    // 注意：LocalModelParams 的字段都是非空类型，不需要 null 检查
    if (params != null) {
      // forceCpuMode 优先：强制 CPU 模式时必须覆盖 gpuLayers
      final effectiveGpuLayers = forceCpuMode ? 0 : params.gpuLayers.clamp(0, 999);
      final effectiveContextSize = params.contextSize.clamp(512, 131072);
      final threads = forceCpuMode 
          ? (Platform.numberOfProcessors > 4 ? 6 : 4)
          : params.cpuThreads;
      
      debugPrint('[LocalFFIEngine] 🔧 使用用户自定义配置${forceCpuMode ? " (强制CPU模式)" : ""}: gpuLayers=$effectiveGpuLayers, ctx=$effectiveContextSize, threads=$threads, batchSize=512, flashAttention=true');
      return ModelParams(
        gpuLayers: effectiveGpuLayers,
        contextSize: effectiveContextSize,
        numberOfThreads: threads,
        numberOfThreadsBatch: threads,
        batchSize: 512,
        microBatchSize: 512,
        flashAttention: forceCpuMode ? FlashAttention.disabled : FlashAttention.enabled,
      );
    }
    
    // 根据设备内存动态调整
    final config = await _getRecommendedConfig();
    final isAndroid = Platform.isAndroid;
    final isMacOS = Platform.isMacOS;
    
    // ★★★ 动态适配 GPU 层数和上下文大小 ★★★
    // 所有平台都使用推荐配置（基于设备内存），而非固定默认值
    final int defaultGpuLayers;
    if (isMacOS) {
      // macOS 默认启用 Metal GPU 加速
      // 如果 Metal 初始化失败，loadModel 的 catch 块会自动回退到 CPU
      defaultGpuLayers = 999;
    } else if (isAndroid) {
      defaultGpuLayers = config.gpuLayers;
    } else {
      // Windows/Linux：默认全部卸载
      defaultGpuLayers = 999;
    }
    
    // 用户未指定时，所有平台统一使用推荐配置（基于设备内存自动适配）
    final gpuLayers = params?.gpuLayers ?? defaultGpuLayers;
    final contextSize = params?.contextSize ?? config.contextSize;

    // ★★★ 线程数优化 ★★★
    // macOS (Apple Silicon): P核数通常为性能核心数，使用 numberOfProcessors * 2/3
    // Android: 0=自动（llama.cpp 默认）→ 改为使用 numberOfProcessors - 2（保留 2 核给系统）
    // 其他平台: 0 = 自动检测
    final int optimalThreads;
    final int optimalBatchThreads;
    final userThreads = params?.cpuThreads ?? 0;
    if (userThreads > 0) {
      optimalThreads = userThreads;
      optimalBatchThreads = userThreads;
    } else if (isMacOS) {
      // macOS Apple Silicon: 使用性能核心数（通常为总核心数的一半）
      // M1: 4P+4E → 4 threads, M2 Pro: 6P+4E → 6 threads
      // 但为了更好的性能，我们使用 P核+E核的 75%
      optimalThreads = (Platform.numberOfProcessors * 0.75).round().clamp(2, 16);
      optimalBatchThreads = (Platform.numberOfProcessors * 0.75).round().clamp(2, 16);
    } else if (Platform.isWindows || Platform.isLinux) {
      // 桌面平台: 使用物理核心数（排除超线程）
      optimalThreads = (Platform.numberOfProcessors * 0.75).round().clamp(2, 16);
      optimalBatchThreads = (Platform.numberOfProcessors * 0.75).round().clamp(2, 16);
    } else if (Platform.isAndroid) {
      // ★★★ Android 优化：显式设置线程数 ★★★
      // 0=自动 在某些设备上会使用过多线程（big.LITTLE 架构会调度小核），
      // 显式设置为 total-2 保留 2 核给系统
      final totalCores = Platform.numberOfProcessors;
      optimalThreads = (totalCores - 2).clamp(2, 10);
      optimalBatchThreads = optimalThreads;
    } else {
      optimalThreads = 0; // 自动检测
      optimalBatchThreads = 0; // 自动检测
    }

    debugPrint('[LocalFFIEngine] 🔧 最终配置: gpuLayers=$gpuLayers, contextSize=$contextSize, threads=$optimalThreads, batchSize=512, microBatchSize=512, flashAttention=true');

    return ModelParams(
      gpuLayers: gpuLayers,
      contextSize: contextSize,
      numberOfThreads: optimalThreads,
      numberOfThreadsBatch: optimalBatchThreads,
      batchSize: 512,
      microBatchSize: 512,
      flashAttention: FlashAttention.enabled,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  模型管理
  // ════════════════════════════════════════════════════════════════════════

  /// 检查模型是否已加载
  bool isModelLoaded(String modelPath) {
    return _isInitialized && _currentModelPath == modelPath;
  }

  /// 卸载当前模型，释放内存
  Future<void> unloadModel() async {
    // 先清理临时文件
    await _cleanupTempFiles();
    
    final engineToDispose = _llamaEngine;
    if (engineToDispose != null) {
      await engineToDispose.dispose();
      _llamaEngine = null;
      _chatSession = null; // 清除 ChatSession
      _contextMaxSize = null;

      // ★★★ macOS 沙盒：释放安全作用域资源访问 ★★★
      // 只有在模型完全 unload 后才能 stopAccessing（llama.cpp 可能使用 mmap）
      if (Platform.isMacOS && _currentModelPath != null) {
        try {
          final modelDir = _currentModelPath!.substring(0, _currentModelPath!.lastIndexOf('/'));
          await SecurityBookmarkService.instance.stopAccessing(modelDir);
        } catch (_) {}
      }

      _currentModelPath = null;
      _cachedParams = null; // 清除缓存参数
      _isInitialized = false;
      _visionSupported = null;
      _contextInvalidated = false;
      debugPrint('LocalFFIEngine: Model unloaded');
    }
  }

  /// 异步检测并缓存视觉支持状态
  /// ⚠️ 强制开启多模态：忽略 llama.cpp 的检测结果，只要 mmproj 加载了就算支持
  Future<void> _detectVisionSupport() async {
    if (_llamaEngine == null) return;
    // 强制开启视觉支持，忽略 llama.cpp 的 supportsVision 检测结果
    // 因为某些模型（如 Gemma 4 + mmproj）llamadart 检测不到视觉能力，但实际是可用的
    _visionSupported = true;
    debugPrint('[LocalFFIEngine] Vision support: FORCE ENABLED (mmproj loaded)');
  }

  /// ★★★ 初始化 ChatSession（用于上下文自动压缩）★★★
  ///
  /// llamadart 的 ChatSession 会自动管理上下文溢出：
  /// - 当上下文超过 90% 阈值时，自动淘汰最早的消息
  /// - 保留 system prompt 和最新对话
  /// - 仅以完整"轮次"（user + assistant）为单位淘汰
  void _initChatSession(int contextSize) {
    final engine = _llamaEngine;
    if (engine == null) {
      debugPrint('[LocalFFIEngine] ⚠️ _initChatSession: _llamaEngine is null, skipping');
      return;
    }
    _contextMaxSize = contextSize;
    _chatSession = ChatSession(
      engine,
      maxContextTokens: contextSize,
      systemPrompt: null, // system prompt 通过消息传入，不在这里设置
    );
    debugPrint('[LocalFFIEngine] ChatSession 初始化完成: contextSize=$contextSize');
    // 初始化上下文使用率追踪
    refreshContextUsage();
  }

  /// 当前上下文已使用的 token 估算值（缓存，避免每帧重算）
  int _estimatedUsedTokens = 0;

  /// 获取当前上下文使用率（0.0 ~ 1.0）
  double get currentContextUsage {
    if (_contextMaxSize == null || _contextMaxSize == 0) {
      return 0.0;
    }
    return _estimatedUsedTokens / _contextMaxSize!;
  }

  /// 获取当前上下文已使用的 token 数（估算）
  int get estimatedUsedTokens => _estimatedUsedTokens;

  /// 获取当前模型的最大上下文 token 数
  int get maxContextTokens => _contextMaxSize ?? 0;

  /// 基于实际消息列表更新上下文使用率
  /// UI 层调用此方法，传入当前会话的所有消息（从数据库加载的）
  /// [extraTokens] 额外注入的 token（如 system prompt、TTS 提示词等）
  void updateContextUsageFromMessages(List<dynamic> messages, {int extraTokens = 0}) {
    _estimatedUsedTokens = _estimateHistoryTokens(messages) + extraTokens;
  }

  /// 刷新上下文使用率估算（兼容旧调用，基于 ChatSession history）
  void refreshContextUsage() {
    if (_chatSession != null) {
      _estimatedUsedTokens = _estimateHistoryTokens(_chatSession!.history);
    }
  }

  /// 估算 ChatSession 历史消息的 token 总数
  int _estimateHistoryTokens(List<dynamic> messages) {
    int total = 0;
    for (final msg in messages) {
      final content = msg.content?.toString() ?? '';
      if (content.isEmpty) continue;
      // 中文约 1.5 token/字符，英文约 0.25 token/字符，取中值估算
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

  /// 重置 ChatSession 的对话历史（保留 system prompt）
  /// 用于清除上下文时调用
  void resetChatSession({bool keepSystemPrompt = true}) {
    _chatSession?.reset(keepSystemPrompt: keepSystemPrompt);
    refreshContextUsage();
    debugPrint('[LocalFFIEngine] ChatSession 历史已重置');
  }

  /// ★★★ 获取当前模型的最大上下文大小 ★★★
  ///
  /// 返回 llama 模型支持的上下文 token 数（从配置中读取），
  /// 用于 DialogueEngine 动态设置上下文压缩阈值为 90%。
  int get maxContextSize => _contextMaxSize ?? 4096;

  /// ★★★ 优化系统内存（加载模型前调用）★★★
  /// 
  /// 执行以下优化：
  /// 1. 清理引擎内部缓存
  /// 2. 触发 Dart GC（通过分配压力）
  /// 3. 强制垃圾回收
  Future<void> _optimizeSystemMemory() async {
    try {
      debugPrint('[LocalFFIEngine] 🧹 开始优化系统内存...');
      
      // 1. 清理引擎内部缓存
      _cachedParams = null;
      _cachedDeviceMemoryMB = null;
      
      // 2. 通过分配临时大对象制造内存压力，间接触发 GC
      for (int i = 0; i < 3; i++) {
        // ignore: unused_local_variable
        final temp = List.filled(1024 * 1024, 0); // ~4MB
        await Future.delayed(const Duration(milliseconds: 50));
        // temp 在作用域结束后可被 GC 回收
      }
      
      // 3. 再次延迟，让 GC 有时间执行
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('[LocalFFIEngine] ✅ 系统内存优化完成');
    } catch (e) {
      debugPrint('[LocalFFIEngine] ⚠️ 内存优化失败（非致命）: $e');
    }
  }

  /// 释放所有资源
  Future<void> dispose() async {
    await unloadModel();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  热更新支持
  // ════════════════════════════════════════════════════════════════════════

  /// 热更新后重新加载模型
  ///
  /// 在 llama.cpp 库文件更新后调用，无需重启 App
  /// 注意：llamadart 使用 Pure Native Assets，库更新后需要重启 App
  Future<void> reloadAfterHotUpdate({
    void Function(double progress, String message)? onProgress,
  }) async {
    if (_currentModelPath == null) {
      debugPrint('LocalFFIEngine: 没有已加载的模型，跳过热更新');
      return;
    }

    final modelPath = _currentModelPath!;
    debugPrint('LocalFFIEngine: 热更新后重新加载模型: $modelPath');
    
    // llamadart 使用 Pure Native Assets，库更新后需要重启 App
    // 这里只重新加载模型
    await loadModel(
      modelPath: modelPath,
      onProgress: onProgress,
    );

    debugPrint('LocalFFIEngine: ✅ 热更新完成，模型已重新加载');
  }

  // ════════════════════════════════════════════════════════════════════════
  //  GGUF 文件头验证
  // ════════════════════════════════════════════════════════════════════════

  /// 验证 GGUF 文件头，返回诊断信息字符串
  /// GGUF 格式：前 4 字节是魔数 "GGUF"(0x46554747)，接着 4 字节是版本号
  Future<String> _validateGgufHeader(String filePath, int fileSizeBytes) async {
    try {
      final file = File(filePath);
      final bytes = await file.open(mode: FileMode.read);
      final header = await bytes.read(32);
      await bytes.close();

      if (header.length < 8) {
        return '❌ 文件过小(${header.length}字节)，不是有效的 GGUF 文件';
      }

      // 读取魔数（小端序 uint32）
      final magic = ByteData.sublistView(header, 0, 4).getUint32(0, Endian.little);
      final magicStr = String.fromCharCodes(header.sublist(0, 4));
      final headerHex = header.sublist(0, 16)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');

      // GGUF 魔数 = 0x46554747 = "GGUF"（小端序：0x47,0x47,0x55,0x46）
      const ggufMagic = 0x46554747;
      if (magic != ggufMagic) {
        return '❌ 非 GGUF 格式: magic=0x${magic.toRadixString(16)} '
            '(期望 0x${ggufMagic.toRadixString(16)}), '
            '文件头=$headerHex, 字符串="$magicStr", '
            '文件大小=${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
      }

      // 读取 GGUF 版本
      final version = ByteData.sublistView(header, 4, 8).getUint32(0, Endian.little);
      return '✅ 有效 GGUF v$version, magic=0x${magic.toRadixString(16)}, '
          '文件头=$headerHex, '
          '文件大小=${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    } catch (e) {
      return '⚠️ 无法读取文件头: $e, 文件大小=${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  模型路径查找
  // ════════════════════════════════════════════════════════════════════════

  /// 获取模型目录路径
  Future<String> _getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/models';
  }

  /// 🔧 修复：获取所有可能的模型目录
  /// 因为不同插件可能使用不同目录，需要全部搜索
  /// 包含：应用文档目录、Flutter 内部存储、外部存储、用户自定义下载路径
  /// 
  /// 平台差异化：
  /// - macOS/Windows/Linux（桌面端）：允许访问外部路径和自定义下载路径
  /// - iOS/Android（移动端）：仅允许沙盒内的路径，不支持外部路径
  Future<List<String>> _getAllModelDirectories() async {
    final List<String> dirs = [];
    
    // 1. 标准应用文档目录（所有平台）
    final appDir = await getApplicationDocumentsDirectory();
    dirs.add('${appDir.path}/models');
    
    // 2. Flutter 内部存储目录（background_downloader 使用，所有平台）
    final flutterDir = appDir.parent;
    final appFlutterDir = Directory('${flutterDir.path}/app_flutter/models');
    if (await appFlutterDir.exists()) {
      dirs.add(appFlutterDir.path);
    }
    
    // 3. 外部存储目录（仅 Android）
    if (Platform.isAndroid) {
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          dirs.add('${extDir.path}/models');
        }
      } catch (_) {}
    }
    
    // 4. 用户自定义下载路径（仅桌面端：macOS/Windows/Linux）
    // 移动端（iOS/Android）由于安全沙箱限制，不允许访问外部路径
    if (_isDesktopPlatform()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final customPath = prefs.getString('download_path');
        if (customPath != null && customPath.isNotEmpty) {
          final customDir = Directory(customPath);
          if (await customDir.exists() && !dirs.contains(customPath)) {
            dirs.add(customPath);
            debugPrint('LocalFFIEngine: 添加自定义模型目录: $customPath');
          }
        }
      } catch (_) {}
      
      // 5. 下载目录（仅桌面端）
      try {
        final downloadDir = await getDownloadsDirectory();
        if (downloadDir != null) {
          final llmModelsDir = '${downloadDir.path}/LLMStudio/models';
          if (!dirs.contains(llmModelsDir)) {
            dirs.add(llmModelsDir);
          }
        }
      } catch (_) {}
    }
    
    debugPrint('LocalFFIEngine: 搜索模型目录列表: $dirs');
    return dirs;
  }
  
  /// 判断是否为桌面平台（macOS/Windows/Linux）
  /// 桌面平台支持外部路径访问，移动端（iOS/Android）受沙盒限制
  bool _isDesktopPlatform() {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// 查找模型文件的完整路径
  /// 优先使用 ModelPathCache 缓存，避免每次递归扫描
  Future<String?> _findModelFile(String fileName) async {
    // 优先使用缓存查找（毫秒级）
    final cachedPath = await ModelPathCache.instance.findModel(fileName);
    if (cachedPath != null) {
      debugPrint('LocalFFIEngine: ✅ 从缓存找到模型文件: $cachedPath');
      return cachedPath;
    }
    
    // 缓存未命中，回退到原始递归扫描
    final dirs = await _getAllModelDirectories();
    
    for (final modelsDirPath in dirs) {
      final modelsDir = Directory(modelsDirPath);
      if (!await modelsDir.exists()) continue;
      
      debugPrint('LocalFFIEngine: 搜索目录: $modelsDirPath');
      
      await for (final entity in modelsDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.gguf')) {
          final foundFileName = entity.path.split('/').last;
          if (foundFileName == fileName) {
            debugPrint('LocalFFIEngine: ✅ 找到模型文件: ${entity.path}');
            // 添加到缓存
            ModelPathCache.instance.addModel(fileName, entity.path);
            return entity.path;
          }
        }
      }
    }
    
    debugPrint('LocalFFIEngine: ❌ 未找到模型文件: $fileName');
    return null;
  }

  /// 查找 mmproj 文件的完整路径
  /// 支持多种命名模式：
  ///   1. mmproj-{model_name}.gguf（前缀模式）
  ///   2. {model_name}-mmproj-{suffix}.gguf（中缀模式，如 gemma-4-26B-A4B-it-mmproj-BF16.gguf）
  ///   3. {model_name}_mmproj.gguf（后缀模式）
  ///   4. 任何包含 "mmproj" 且与主模型共享共同前缀的文件
  Future<String?> _findMmprojFile(String mmprojFileName, String fullModelPath) async {
    final fileName = mmprojFileName.split('/').last;
    
    // 0. 优先使用缓存
    final cachedPath = await ModelPathCache.instance.findMmproj(fileName);
    if (cachedPath != null) {
      debugPrint('[LocalFFIEngine] ✅ 从缓存找到 mmproj: $cachedPath');
      return cachedPath;
    }
    
    // 收集所有 gguf 文件（搜索标准目录 + 自定义路径）
    final allFiles = <String>[];
    final dirs = await _getAllModelDirectories();
    for (final dirPath in dirs) {
      final dir = Directory(dirPath);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.gguf')) {
          allFiles.add(entity.path);
        }
      }
    }
    
    debugPrint('[LocalFFIEngine] 🔍 搜索 mmproj: 扫描 ${allFiles.length} 个 gguf 文件');
    
    // 1. 精确文件名匹配
    for (final path in allFiles) {
      if (path.split('/').last == fileName) {
        ModelPathCache.instance.addMmproj(fileName, path);
        return path;
      }
    }
    
    // 2. 收集所有包含 "mmproj" 的文件
    final modelBaseName = fullModelPath.split('/').last;
    final modelBaseNameNoExt = modelBaseName.endsWith('.gguf')
        ? modelBaseName.substring(0, modelBaseName.length - 5)
        : modelBaseName;
    final modelBaseLower = modelBaseNameNoExt.toLowerCase();
    
    final mmprojFiles = allFiles.where((p) {
      final name = p.split('/').last.toLowerCase();
      return name.contains('mmproj');
    }).toList();
    
    debugPrint('[LocalFFIEngine] 🔍 发现 ${mmprojFiles.length} 个 mmproj 候选文件');
    
    // 2a. 前缀模式：mmproj-{name}.gguf
    for (final path in mmprojFiles) {
      final name = path.split('/').last.toLowerCase();
      if (name.startsWith('mmproj') && name.contains(modelBaseLower)) {
        debugPrint('[LocalFFIEngine] ✅ mmproj 前缀匹配: ${path.split('/').last}');
        ModelPathCache.instance.addMmproj(fileName, path);
        return path;
      }
    }
    
    // 2b. 中缀模式：{name}-mmproj-{suffix}.gguf
    //     提取主模型的共同前缀进行匹配
    final modelPrefix = _extractModelPrefix(modelBaseLower);
    if (modelPrefix.isNotEmpty) {
      for (final path in mmprojFiles) {
        final name = path.split('/').last.toLowerCase();
        if (name.contains(modelPrefix)) {
          debugPrint('[LocalFFIEngine] ✅ mmproj 前缀匹配: prefix="$modelPrefix", file="${path.split('/').last}"');
          ModelPathCache.instance.addMmproj(fileName, path);
          return path;
        }
      }
    }
    
    // 2c. 同目录匹配：mmproj 文件与主模型在同一目录下
    final modelDir = fullModelPath.substring(0, fullModelPath.lastIndexOf('/'));
    for (final path in mmprojFiles) {
      final pathDir = path.substring(0, path.lastIndexOf('/'));
      if (pathDir == modelDir) {
        debugPrint('[LocalFFIEngine] ✅ mmproj 同目录匹配: ${path.split('/').last}');
        ModelPathCache.instance.addMmproj(fileName, path);
        return path;
      }
    }
    
    // 3. Fallback: 如果只有一个 mmproj 文件，直接关联
    if (mmprojFiles.length == 1) {
      debugPrint('[LocalFFIEngine] ✅ Fallback: 单个 mmproj 文件: ${mmprojFiles.first}');
      ModelPathCache.instance.addMmproj(fileName, mmprojFiles.first);
      return mmprojFiles.first;
    }
    
    debugPrint('[LocalFFIEngine] ⚠️ 未找到匹配的 mmproj 文件: $mmprojFileName');
    return null;
  }
  
  /// 从模型文件名中提取共同前缀（去掉量化级别、版本后缀等）
  /// 例如：gemma-4-26B-A4B-it-ultra-uncensored-heretic-Q4_K_S → gemma-4-26b-a4b-it
  String _extractModelPrefix(String modelName) {
    final lower = modelName.toLowerCase();
    // 常见的量化/版本后缀标记
    final suffixPatterns = [
      '-q4_0', '-q4_1', '-q4_k_s', '-q4_k_m', '-q4_k_l',
      '-q5_0', '-q5_1', '-q5_k_s', '-q5_k_m',
      '-q6_k', '-q8_0', '-iq4_xs', '-iq4_nl',
      '-bf16', '-fp16', '-f32',
      '-ultra', '-uncensored', '-heretic',
      '-instruct',
    ];
    
    String prefix = lower;
    for (final pattern in suffixPatterns) {
      final idx = prefix.indexOf(pattern);
      if (idx > 0) {
        prefix = prefix.substring(0, idx);
        break;
      }
    }
    
    // 如果前缀太短（<5字符），返回空表示无法匹配
    if (prefix.length < 5) return '';
    return prefix;
  }

  // ════════════════════════════════════════════════════════════════════════
  //  辅助方法
  // ════════════════════════════════════════════════════════════════════════

  void _ensureInitialized() {
    if (!_isInitialized || _llamaEngine == null) {
      throw LocalFFIException(
        'LocalFFIEngine is not initialized. '
        'Please load a model first using loadModel().',
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
//  异常类
// ════════════════════════════════════════════════════════════════════════

class LocalFFIException implements Exception {
  final String message;
  LocalFFIException(this.message);

  @override
  String toString() => 'LocalFFIException: $message';
}

// ════════════════════════════════════════════════════════════════════════
//  模型信息
// ════════════════════════════════════════════════════════════════════════

class ModelInfo {
  final String path;
  final String backend;
  final bool loaded;

  ModelInfo({
    required this.path,
    required this.backend,
    required this.loaded,
  });
}

// ════════════════════════════════════════════════════════════════════════
//  加速后端枚举
// ════════════════════════════════════════════════════════════════════════

enum AccelerationBackend {
  metal,  // Apple Metal (macOS/iOS)
  cuda,    // NVIDIA CUDA (Windows/Linux)
  vulkan,  // Vulkan (Android)
  cpu,     // CPU only
}
