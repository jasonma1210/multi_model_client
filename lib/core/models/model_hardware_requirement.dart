/// 模型硬件需求基准
class ModelHardwareRequirement {
  final String modelId;
  final double paramsGB;        // FP16参数量（GB）
  final int totalLayers;        // 总层数
  final int minCtx;             // 最小上下文窗口
  final int recommendCtx;       // 推荐上下文窗口
  final Map<String, int> minMemoryMB;  // 各量化级别的最小内存需求

  const ModelHardwareRequirement({
    required this.modelId,
    required this.paramsGB,
    required this.totalLayers,
    required this.minCtx,
    required this.recommendCtx,
    required this.minMemoryMB,
  });

  /// 内存需求描述
  String getMemoryDescription(String quantLevel) {
    final memMB = minMemoryMB[quantLevel] ?? 0;
    if (memMB == 0) return 'Unknown';

    final memGB = memMB / 1024;
    return '${memGB.toStringAsFixed(1)} GB';
  }
}

/// 内置主流模型基准库
const Map<String, ModelHardwareRequirement> modelBaseLibrary = {
  // Qwen系列
  "Qwen2.5-7B-Instruct": ModelHardwareRequirement(
    modelId: "Qwen2.5-7B-Instruct",
    paramsGB: 14.0,
    totalLayers: 35,
    minCtx: 2048,
    recommendCtx: 4096,
    minMemoryMB: {
      "Q2_K": 2048,
      "Q3_K_L": 3072,
      "Q4_K_M": 4096,
      "Q5_K_M": 5120,
      "Q8_0": 8192,
      "FP16": 16384,
    },
  ),

  "Qwen2.5-14B-Instruct": ModelHardwareRequirement(
    modelId: "Qwen2.5-14B-Instruct",
    paramsGB: 28.0,
    totalLayers: 40,
    minCtx: 2048,
    recommendCtx: 4096,
    minMemoryMB: {
      "Q2_K": 4096,
      "Q3_K_L": 6144,
      "Q4_K_M": 8192,
      "Q5_K_M": 10240,
      "Q8_0": 16384,
      "FP16": 32768,
    },
  ),

  "Qwen2.5-72B-Instruct": ModelHardwareRequirement(
    modelId: "Qwen2.5-72B-Instruct",
    paramsGB: 144.0,
    totalLayers: 80,
    minCtx: 2048,
    recommendCtx: 4096,
    minMemoryMB: {
      "Q2_K": 20480,
      "Q3_K_L": 30720,
      "Q4_K_M": 40960,
      "Q5_K_M": 51200,
      "Q8_0": 81920,
      "FP16": 163840,
    },
  ),

  // Llama系列
  "Llama3.1-8B-Instruct": ModelHardwareRequirement(
    modelId: "Llama3.1-8B-Instruct",
    paramsGB: 16.0,
    totalLayers: 32,
    minCtx: 2048,
    recommendCtx: 8192,
    minMemoryMB: {
      "Q2_K": 2560,
      "Q3_K_L": 3584,
      "Q4_K_M": 4608,
      "Q5_K_M": 5888,
      "Q8_0": 9216,
      "FP16": 18432,
    },
  ),

  "Llama3.1-70B-Instruct": ModelHardwareRequirement(
    modelId: "Llama3.1-70B-Instruct",
    paramsGB: 140.0,
    totalLayers: 80,
    minCtx: 2048,
    recommendCtx: 8192,
    minMemoryMB: {
      "Q2_K": 20480,
      "Q3_K_L": 30720,
      "Q4_K_M": 40960,
      "Q5_K_M": 51200,
      "Q8_0": 81920,
      "FP16": 163840,
    },
  ),

  // Mistral系列
  "Mistral-7B-Instruct": ModelHardwareRequirement(
    modelId: "Mistral-7B-Instruct",
    paramsGB: 14.0,
    totalLayers: 32,
    minCtx: 2048,
    recommendCtx: 32768,
    minMemoryMB: {
      "Q2_K": 2048,
      "Q3_K_L": 3072,
      "Q4_K_M": 4096,
      "Q5_K_M": 5120,
      "Q8_0": 8192,
      "FP16": 16384,
    },
  ),

  // Phi系列
  "Phi-3-mini-4k-instruct": ModelHardwareRequirement(
    modelId: "Phi-3-mini-4k-instruct",
    paramsGB: 7.2,
    totalLayers: 32,
    minCtx: 2048,
    recommendCtx: 4096,
    minMemoryMB: {
      "Q2_K": 1024,
      "Q3_K_L": 1536,
      "Q4_K_M": 2048,
      "Q5_K_M": 2560,
      "Q8_0": 4096,
      "FP16": 8192,
    },
  ),

  // Gemma系列
  "gemma-7b": ModelHardwareRequirement(
    modelId: "gemma-7b",
    paramsGB: 14.0,
    totalLayers: 28,
    minCtx: 2048,
    recommendCtx: 8192,
    minMemoryMB: {
      "Q2_K": 2048,
      "Q3_K_L": 3072,
      "Q4_K_M": 4096,
      "Q5_K_M": 5120,
      "Q8_0": 8192,
      "FP16": 16384,
    },
  ),
};

/// 量化级别优先级（推荐顺序）
const List<String> quantLevelPriority = [
  'Q4_K_M',  // 最佳平衡
  'Q5_K_M',  // 高精度
  'Q3_K_L',  // 低内存
  'Q8_0',    // 高精度大内存
  'Q2_K',    // 极低内存
  'FP16',    // 无损
];

/// 量化级别描述
const Map<String, String> quantLevelDescriptions = {
  'Q2_K': '极致压缩，适合极低配设备。内存占用25%，精度一般。',
  'Q3_K_L': '低内存需求，适合移动端。内存占用30%，精度良好。',
  'Q4_K_M': '推荐选择，精度与速度最佳平衡。内存占用40%，精度优秀。',
  'Q5_K_M': '高精度量化，适合中高配设备。内存占用50%，精度接近原生。',
  'Q8_0': '高精度量化，适合高配设备。内存占用80%，精度几乎无损。',
  'FP16': '无损精度，适合专业级设备。内存占用100%，推理速度最慢。',
};

/// 获取模型硬件需求
ModelHardwareRequirement? getModelRequirement(String modelId) {
  // 精确匹配
  if (modelBaseLibrary.containsKey(modelId)) {
    return modelBaseLibrary[modelId];
  }

  // 模糊匹配
  final lowerModelId = modelId.toLowerCase();
  for (final entry in modelBaseLibrary.entries) {
    if (entry.key.toLowerCase().contains(lowerModelId) ||
        lowerModelId.contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }

  return null;
}

/// 根据模型名称推断硬件需求
ModelHardwareRequirement inferModelRequirement(String modelName, int? parameterSize) {
  // 尝试从库中获取
  final fromLibrary = getModelRequirement(modelName);
  if (fromLibrary != null) return fromLibrary;

  // 根据参数量推断
  final params = parameterSize ?? _inferParameterSize(modelName);

  // 默认配置
  return ModelHardwareRequirement(
    modelId: modelName,
    paramsGB: params * 2.0,
    totalLayers: _inferTotalLayers(params),
    minCtx: 2048,
    recommendCtx: 4096,
    minMemoryMB: {
      "Q2_K": (params * 0.25 * 1024).toInt(),
      "Q3_K_L": (params * 0.30 * 1024).toInt(),
      "Q4_K_M": (params * 0.40 * 1024).toInt(),
      "Q5_K_M": (params * 0.50 * 1024).toInt(),
      "Q8_0": (params * 0.80 * 1024).toInt(),
      "FP16": (params * 2.0 * 1024).toInt(),
    },
  );
}

/// 从模型名称推断参数量
int _inferParameterSize(String modelName) {
  final lowerName = modelName.toLowerCase();

  // 匹配常见格式
  final patterns = [
    RegExp(r'(\d+\.?\d*)\s*b'),
    RegExp(r'-(\d+\.?\d*)b'),
    RegExp(r'_(\d+\.?\d*)b'),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(lowerName);
    if (match != null) {
      final size = double.tryParse(match.group(1) ?? '0') ?? 0;
      return size.round();
    }
  }

  // 默认7B
  return 7;
}

/// 推断总层数
int _inferTotalLayers(int paramsGB) {
  if (paramsGB >= 70) return 80;
  if (paramsGB >= 13) return 40;
  if (paramsGB >= 7) return 32;
  return 28;
}
