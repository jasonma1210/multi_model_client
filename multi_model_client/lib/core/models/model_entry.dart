import '../platform/platform_utils.dart';

/// 模型类型
enum ModelType {
  local,  // 本地 gguf 模型
  remote, // 远程 API 模型
  ollama, // Ollama 本地服务
}

/// 远程模型协议
enum RemoteProtocol {
  openai,    // OpenAI 兼容 API
  anthropic, // Anthropic API
  ollama,    // Ollama API
}

/// 本地模型推理参数（对应效果图的参数面板）
class LocalModelParams {
  final double temperature;
  final bool limitResponseLength;
  final int? maxTokens;
  final int contextSize; // 上下文窗口大小
  final String contextOverflow; // 'truncate_middle' | 'truncate_start' | 'truncate_end'
  final String? stopString;
  final int cpuThreads;
  final int gpuLayers; // GPU 加速层数（99 = 全部卸载到 GPU）
  final int topK;
  final bool repeatPenaltyEnabled;
  final double repeatPenalty;
  final bool presencePenaltyEnabled;
  final bool topPEnabled;
  final double topP;
  final bool minPEnabled;
  final double minP;
  final bool structuredOutput;
  final bool speculativeDecoding;
  final String? systemPrompt; // 系统提示词（人设）
  final bool enableReasoning; // 快速模式：关闭思考链，禁用 reasoning

  const LocalModelParams({
    this.temperature = 0.8,
    this.limitResponseLength = false,
    this.maxTokens,
    this.contextSize = 32768, // 默认 32K 上下文
    this.contextOverflow = 'truncate_middle',
    this.stopString,
    this.cpuThreads = 4,
    this.gpuLayers = 99, // 默认全部 GPU 加速
    this.topK = 40,
    this.repeatPenaltyEnabled = true,
    this.repeatPenalty = 1.1,
    this.presencePenaltyEnabled = false,
    this.topPEnabled = true,
    this.topP = 0.95,
    this.minPEnabled = true,
    this.minP = 0.05,
    this.structuredOutput = false,
    this.speculativeDecoding = false,
    this.systemPrompt,
    this.enableReasoning = false, // 默认关闭思考模式（快速模式）
  });

  LocalModelParams copyWith({
    double? temperature,
    bool? limitResponseLength,
    int? maxTokens,
    int? contextSize,
    String? contextOverflow,
    String? stopString,
    int? cpuThreads,
    int? gpuLayers,
    int? topK,
    bool? repeatPenaltyEnabled,
    double? repeatPenalty,
    bool? presencePenaltyEnabled,
    bool? topPEnabled,
    double? topP,
    bool? minPEnabled,
    double? minP,
    bool? structuredOutput,
    bool? speculativeDecoding,
    String? systemPrompt,
    bool? enableReasoning,
  }) {
    return LocalModelParams(
      temperature: temperature ?? this.temperature,
      limitResponseLength: limitResponseLength ?? this.limitResponseLength,
      maxTokens: maxTokens ?? this.maxTokens,
      contextSize: contextSize ?? this.contextSize,
      contextOverflow: contextOverflow ?? this.contextOverflow,
      stopString: stopString ?? this.stopString,
      cpuThreads: cpuThreads ?? this.cpuThreads,
      gpuLayers: gpuLayers ?? this.gpuLayers,
      topK: topK ?? this.topK,
      repeatPenaltyEnabled: repeatPenaltyEnabled ?? this.repeatPenaltyEnabled,
      repeatPenalty: repeatPenalty ?? this.repeatPenalty,
      presencePenaltyEnabled: presencePenaltyEnabled ?? this.presencePenaltyEnabled,
      topPEnabled: topPEnabled ?? this.topPEnabled,
      topP: topP ?? this.topP,
      minPEnabled: minPEnabled ?? this.minPEnabled,
      minP: minP ?? this.minP,
      structuredOutput: structuredOutput ?? this.structuredOutput,
      speculativeDecoding: speculativeDecoding ?? this.speculativeDecoding,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      enableReasoning: enableReasoning ?? this.enableReasoning,
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'limitResponseLength': limitResponseLength,
    'maxTokens': maxTokens,
    'contextSize': contextSize,
    'contextOverflow': contextOverflow,
    'stopString': stopString,
    'cpuThreads': cpuThreads,
    'gpuLayers': gpuLayers,
    'topK': topK,
    'repeatPenaltyEnabled': repeatPenaltyEnabled,
    'repeatPenalty': repeatPenalty,
    'presencePenaltyEnabled': presencePenaltyEnabled,
    'topPEnabled': topPEnabled,
    'topP': topP,
    'minPEnabled': minPEnabled,
    'minP': minP,
    'structuredOutput': structuredOutput,
    'speculativeDecoding': speculativeDecoding,
    'systemPrompt': systemPrompt,
    'enableReasoning': enableReasoning,
  };

  factory LocalModelParams.fromJson(Map<String, dynamic> json) {
    return LocalModelParams(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.8,
      limitResponseLength: json['limitResponseLength'] as bool? ?? false,
      maxTokens: json['maxTokens'] as int?,
      contextSize: json['contextSize'] as int? ?? 32768,
      contextOverflow: json['contextOverflow'] as String? ?? 'truncate_middle',
      stopString: json['stopString'] as String?,
      cpuThreads: json['cpuThreads'] as int? ?? 4,
      gpuLayers: json['gpuLayers'] as int? ?? 99,
      topK: json['topK'] as int? ?? 40,
      repeatPenaltyEnabled: json['repeatPenaltyEnabled'] as bool? ?? true,
      repeatPenalty: (json['repeatPenalty'] as num?)?.toDouble() ?? 1.1,
      presencePenaltyEnabled: json['presencePenaltyEnabled'] as bool? ?? false,
      topPEnabled: json['topPEnabled'] as bool? ?? true,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.95,
      minPEnabled: json['minPEnabled'] as bool? ?? true,
      minP: (json['minP'] as num?)?.toDouble() ?? 0.05,
      structuredOutput: json['structuredOutput'] as bool? ?? false,
      speculativeDecoding: json['speculativeDecoding'] as bool? ?? false,
      systemPrompt: json['systemPrompt'] as String?,
      enableReasoning: json['enableReasoning'] as bool? ?? false,
    );
  }
}

class RemoteModelConfig {
  final RemoteProtocol protocol;
  final String baseUrl;
  final String apiKey;
  final String modelId;
  // 扩展推理参数（用于 Ollama 等支持更多参数的 API）
  final double temperature;
  final double topP;
  final int maxTokens;
  final bool streamEnabled;
  // 额外参数（Ollama 专用）
  final int? numKeep;
  final int? numCtx;
  final int? numGpu;
  final String? format; // JSON 格式

  const RemoteModelConfig({
    required this.protocol,
    required this.baseUrl,
    required this.apiKey,
    required this.modelId,
    this.temperature = 0.7,
    this.topP = 0.9,
    this.maxTokens = 4096,
    this.streamEnabled = true,
    this.numKeep,
    this.numCtx,
    this.numGpu,
    this.format,
  });

  RemoteModelConfig copyWith({
    RemoteProtocol? protocol,
    String? baseUrl,
    String? apiKey,
    String? modelId,
    double? temperature,
    double? topP,
    int? maxTokens,
    bool? streamEnabled,
    int? numKeep,
    int? numCtx,
    int? numGpu,
    String? format,
  }) {
    return RemoteModelConfig(
      protocol: protocol ?? this.protocol,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      modelId: modelId ?? this.modelId,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      maxTokens: maxTokens ?? this.maxTokens,
      streamEnabled: streamEnabled ?? this.streamEnabled,
      numKeep: numKeep ?? this.numKeep,
      numCtx: numCtx ?? this.numCtx,
      numGpu: numGpu ?? this.numGpu,
      format: format ?? this.format,
    );
  }

  Map<String, dynamic> toJson() => {
    'protocol': protocol.name,
    'baseUrl': baseUrl,
    'apiKey': apiKey,
    'modelId': modelId,
    'temperature': temperature,
    'topP': topP,
    'maxTokens': maxTokens,
    'streamEnabled': streamEnabled,
    'numKeep': numKeep,
    'numCtx': numCtx,
    'numGpu': numGpu,
    'format': format,
  };

  factory RemoteModelConfig.fromJson(Map<String, dynamic> json) {
    return RemoteModelConfig(
      protocol: RemoteProtocol.values.firstWhere(
        (e) => e.name == json['protocol'],
        orElse: () => RemoteProtocol.openai,
      ),
      baseUrl: json['baseUrl'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      modelId: json['modelId'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      maxTokens: json['maxTokens'] as int? ?? 4096,
      streamEnabled: json['streamEnabled'] as bool? ?? true,
      numKeep: json['numKeep'] as int?,
      numCtx: json['numCtx'] as int?,
      numGpu: json['numGpu'] as int?,
      format: json['format'] as String?,
    );
  }

  /// 预设 OpenAI 配置
  static RemoteModelConfig openAIPreset({String modelId = 'gpt-4o'}) {
    return RemoteModelConfig(
      protocol: RemoteProtocol.openai,
      baseUrl: 'https://api.openai.com/v1',
      apiKey: '',
      modelId: modelId,
    );
  }

  /// 预设 Anthropic 配置
  static RemoteModelConfig anthropicPreset({String modelId = 'claude-3-5-sonnet-20241022'}) {
    return RemoteModelConfig(
      protocol: RemoteProtocol.anthropic,
      baseUrl: 'https://api.anthropic.com',
      apiKey: '',
      modelId: modelId,
    );
  }

  /// 预设 Ollama 配置（优先使用全局配置，否则使用跨平台默认地址）
  ///
  /// - Android → http://10.0.2.2:11434
  /// - 其他平台 → http://localhost:11434
  static RemoteModelConfig ollamaPreset({
    String? baseUrl,
    String modelId = 'llama3.2',
    String apiKey = '',
  }) {
    return RemoteModelConfig(
      protocol: RemoteProtocol.ollama,
      baseUrl: baseUrl ?? PlatformUtils.getDefaultOllamaBaseUrl(),
      apiKey: apiKey,
      modelId: modelId,
    );
  }
}

/// 统一模型实体（用于 UI 层展示和状态管理）
class ModelEntry {
  final String id;
  final String displayName;
  final ModelType type;
  /// 本地模型文件路径（type == local 时有效）
  final String? filePath;
  /// 本地模型推理参数
  final LocalModelParams? localParams;
  /// 远程模型配置（type == remote 时有效）
  final RemoteModelConfig? remoteConfig;
  /// 模型是否已加载到内存中（本地模型）
  final bool isLoaded;
  /// 模型参数量（B）
  final int? parameterSize;
  /// 量化级别，如 Q4_K_M
  final String? quantLevel;
  /// 模型描述
  final String? description;
  /// 是否支持多模态（图片/视频理解）
  final bool? isMultimodal;
  /// mmproj 投影仪文件路径（本地多模态模型需要）
  final String? mmprojFileName;
  /// ★★★ 顶级 Reasoning 开关（本地/远程模型通用）★★★
  ///
  /// 优先级：此字段 > localParams.enableReasoning
  /// 远程模型没有 localParams，直接读此字段
  final bool? enableReasoning;

  const ModelEntry({
    required this.id,
    required this.displayName,
    required this.type,
    this.filePath,
    this.localParams,
    this.remoteConfig,
    this.isLoaded = false,
    this.parameterSize,
    this.quantLevel,
    this.description,
    this.isMultimodal,
    this.mmprojFileName,
    this.enableReasoning,
  });

  /// 获取有效的 reasoning 开关值
  /// 优先读顶级字段，回退到 localParams
  bool get effectiveEnableReasoning =>
      enableReasoning ?? localParams?.enableReasoning ?? false;

  bool get isLocal => type == ModelType.local;

  /// 自动判断是否支持多模态（图片输入）
  ///
  /// 策略：
  /// - 若用户手动设置了 isMultimodal，以该值为准
  /// - 远程模型（remote/ollama）默认允许多模态：主流 API（OpenAI/Anthropic/Gemini/等）
  ///   均支持图片，阻止发送比发送后报错用户体验更差
  /// - 本地模型（local）需要名称显式包含视觉关键词才允许
  bool get supportsMultimodal {
    if (isMultimodal != null) return isMultimodal!;

    // ✅ 远程/Ollama 模型：默认支持多模态
    // OpenAI gpt-4o/gpt-4-turbo/o1/o3、Anthropic claude-*、Google gemini-* 等都支持图片
    // 若将来需要明确排除某个模型，通过 isMultimodal=false 手动覆盖
    if (type == ModelType.remote || type == ModelType.ollama) return true;

    // 本地模型：通过名称关键词判断是否是多模态模型
    final lowerId = id.toLowerCase();
    final lowerName = displayName.toLowerCase();
    final localVisionPatterns = [
      'vision', 'vl', 'llava', 'moondream', 'bakllava',
      'llama-vision', 'llama3.2-vision', 'phi4-vision',
      'qwen2.5vl', 'qwen-vl', 'qwen2-vl', 'qwen3-vl', 'qwen3',
      'yi-vision', 'yi-vl', 'deepseek-vl', 'internvl',
      'mistral-vision', 'pixtral',
      'video', 'multimodal', 'img2txt', 'image',
    ];
    for (final p in localVisionPatterns) {
      if (lowerId.contains(p) || lowerName.contains(p)) return true;
    }
    return false;
  }
  bool get isRemote => type == ModelType.remote || type == ModelType.ollama;

  ModelEntry copyWith({
    String? displayName,
    String? filePath,
    bool? isLoaded,
    LocalModelParams? localParams,
    RemoteModelConfig? remoteConfig,
    bool? isMultimodal,
    String? mmprojFileName,
    bool? enableReasoning,
  }) {
    return ModelEntry(
      id: id,
      displayName: displayName ?? this.displayName,
      type: type,
      filePath: filePath ?? this.filePath,
      localParams: localParams ?? this.localParams,
      remoteConfig: remoteConfig ?? this.remoteConfig,
      isLoaded: isLoaded ?? this.isLoaded,
      parameterSize: parameterSize,
      quantLevel: quantLevel,
      description: description,
      isMultimodal: isMultimodal ?? this.isMultimodal,
      mmprojFileName: mmprojFileName ?? this.mmprojFileName,
      enableReasoning: enableReasoning ?? this.enableReasoning,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'type': type.name,
    'filePath': filePath,
    'localParams': localParams?.toJson(),
    'remoteConfig': remoteConfig?.toJson(),
    'isLoaded': isLoaded,
    'parameterSize': parameterSize,
    'quantLevel': quantLevel,
    'description': description,
    'isMultimodal': isMultimodal,
    'mmprojFileName': mmprojFileName,
    'enableReasoning': enableReasoning,
  };

  factory ModelEntry.fromJson(Map<String, dynamic> json) {
    return ModelEntry(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      type: ModelType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ModelType.remote,
      ),
      filePath: json['filePath'] as String?,
      localParams: json['localParams'] != null
          ? LocalModelParams.fromJson(json['localParams'] as Map<String, dynamic>)
          : null,
      remoteConfig: json['remoteConfig'] != null
          ? RemoteModelConfig.fromJson(json['remoteConfig'] as Map<String, dynamic>)
          : null,
      isLoaded: json['isLoaded'] as bool? ?? false,
      parameterSize: json['parameterSize'] as int?,
      quantLevel: json['quantLevel'] as String?,
      description: json['description'] as String?,
      isMultimodal: json['isMultimodal'] as bool?,
      mmprojFileName: json['mmprojFileName'] as String?,
      enableReasoning: json['enableReasoning'] as bool?,
    );
  }
}
