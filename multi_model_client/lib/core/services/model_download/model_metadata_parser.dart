import 'package:flutter/foundation.dart';

/// 模型元数据解析器
class ModelMetadataParser {
  /// 解析参数量（亿）
  static int parseParameterSize(String modelName) {
    final lowerName = modelName.toLowerCase();

    // 匹配常见格式：7B, 13B, 70B, 1.5B, 0.5B
    final patterns = [
      RegExp(r'(\d+\.?\d*)\s*b'),
      RegExp(r'-(\d+\.?\d*)b'),
      RegExp(r'_(\d+\.?\d*)b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerName);
      if (match != null) {
        final size = double.tryParse(match.group(1) ?? '0') ?? 0;
        return (size).round();
      }
    }

    return 0;
  }

  /// 解析量化级别
  static String? parseQuantizationLevel(String fileName) {
    final lowerName = fileName.toLowerCase();

    // GGUF量化级别
    if (lowerName.contains('q2_k')) return 'Q2_K';
    if (lowerName.contains('q3_k_l')) return 'Q3_K_L';
    if (lowerName.contains('q3_k_m')) return 'Q3_K_M';
    if (lowerName.contains('q3_k_s')) return 'Q3_K_S';
    if (lowerName.contains('q4_k_m')) return 'Q4_K_M';
    if (lowerName.contains('q4_k_s')) return 'Q4_K_S';
    if (lowerName.contains('q5_k_m')) return 'Q5_K_M';
    if (lowerName.contains('q5_k_s')) return 'Q5_K_S';
    if (lowerName.contains('q6_k')) return 'Q6_K';
    if (lowerName.contains('q8_0')) return 'Q8_0';

    // GPTQ/AWQ量化
    if (lowerName.contains('gptq')) return 'GPTQ';
    if (lowerName.contains('awq')) return 'AWQ';

    // FP16/FP32
    if (lowerName.contains('fp16')) return 'FP16';
    if (lowerName.contains('fp32')) return 'FP32';

    return null;
  }

  /// 解析上下文窗口大小
  static int parseContextWindow(String modelName) {
    final lowerName = modelName.toLowerCase();

    // 匹配常见格式：8k, 16k, 32k, 128k
    final patterns = [
      RegExp(r'(\d+)k'),
      RegExp(r'context[_-]?(\d+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerName);
      if (match != null) {
        final size = int.tryParse(match.group(1) ?? '0') ?? 0;
        return size * 1024; // 转换为tokens
      }
    }

    // 根据参数量推断默认上下文窗口
    final params = parseParameterSize(modelName);
    if (params >= 70) return 8192;
    if (params >= 13) return 4096;
    if (params >= 7) return 8192;

    return 2048; // 默认2k
  }

  /// 解析模型层数
  static int parseTotalLayers(String modelName, int parameterSize) {
    // 根据参数量和模型家族推断层数
    final lowerName = modelName.toLowerCase();

    // Llama系列
    if (lowerName.contains('llama')) {
      if (parameterSize >= 70) return 80;
      if (parameterSize >= 13) return 40;
      if (parameterSize >= 7) return 32;
      return 32;
    }

    // Qwen系列
    if (lowerName.contains('qwen')) {
      if (parameterSize >= 72) return 80;
      if (parameterSize >= 14) return 40;
      if (parameterSize >= 7) return 35;
      return 32;
    }

    // Mistral系列
    if (lowerName.contains('mistral')) {
      return 32;
    }

    // 默认值
    if (parameterSize >= 70) return 80;
    if (parameterSize >= 13) return 40;
    if (parameterSize >= 7) return 32;

    return 32;
  }

  /// 解析模型架构
  static String? parseArchitecture(String modelName) {
    final lowerName = modelName.toLowerCase();

    if (lowerName.contains('llama')) return 'llama';
    if (lowerName.contains('qwen')) return 'qwen';
    if (lowerName.contains('mistral')) return 'mistral';
    if (lowerName.contains('phi')) return 'phi';
    if (lowerName.contains('gemma')) return 'gemma';
    if (lowerName.contains('chatglm')) return 'chatglm';

    return null;
  }

  /// 解析是否为量化模型
  static bool isQuantized(String fileName) {
    return parseQuantizationLevel(fileName) != null;
  }

  /// 解析是否为GGUF格式
  static bool isGguf(String fileName) {
    return fileName.toLowerCase().endsWith('.gguf');
  }

  /// 估算内存需求（MB）
  static int estimateMemoryRequirement({
    required int parameterSize,
    required String? quantLevel,
    required int contextWindow,
  }) {
    // FP16参数量（GB）
    final fp16SizeGB = parameterSize * 2.0;

    // 量化系数
    final quantCoefficient = _getQuantizationCoefficient(quantLevel);

    // 模型权重内存（MB）
    final modelMemoryMB = (fp16SizeGB * 1024 * quantCoefficient).toInt();

    // 上下文窗口内存（估算：每1024 tokens约需要 100-200 MB）
    final contextMemoryMB = (contextWindow / 1024 * 150).toInt();

    return modelMemoryMB + contextMemoryMB;
  }

  /// 获取量化系数
  static double _getQuantizationCoefficient(String? quantLevel) {
    switch (quantLevel) {
      case 'Q2_K':
        return 0.25;
      case 'Q3_K_S':
      case 'Q3_K_M':
      case 'Q3_K_L':
        return 0.30;
      case 'Q4_K_S':
      case 'Q4_K_M':
        return 0.40;
      case 'Q5_K_S':
      case 'Q5_K_M':
        return 0.50;
      case 'Q6_K':
        return 0.60;
      case 'Q8_0':
        return 0.80;
      case 'FP16':
        return 1.0;
      case 'GPTQ':
      case 'AWQ':
        return 0.35;
      default:
        return 0.40; // 默认Q4_K_M
    }
  }

  /// 完整解析模型元数据
  static ModelMetadata parse(String modelName, String fileName) {
    final paramSize = parseParameterSize(modelName);
    final quantLevel = parseQuantizationLevel(fileName);
    final contextWindow = parseContextWindow(modelName);
    final totalLayers = parseTotalLayers(modelName, paramSize);
    final architecture = parseArchitecture(modelName);
    final isQ = isQuantized(fileName);
    final isGgufFile = isGguf(fileName);
    final memoryRequirement = estimateMemoryRequirement(
      parameterSize: paramSize,
      quantLevel: quantLevel,
      contextWindow: contextWindow,
    );

    return ModelMetadata(
      parameterSize: paramSize,
      quantizationLevel: quantLevel,
      contextWindow: contextWindow,
      totalLayers: totalLayers,
      architecture: architecture,
      isQuantized: isQ,
      isGguf: isGgufFile,
      estimatedMemoryMB: memoryRequirement,
    );
  }
}

/// 模型元数据
class ModelMetadata {
  final int parameterSize;         // 参数量（亿）
  final String? quantizationLevel; // 量化级别
  final int contextWindow;         // 上下文窗口
  final int totalLayers;           // 总层数
  final String? architecture;      // 架构
  final bool isQuantized;          // 是否量化
  final bool isGguf;               // 是否GGUF格式
  final int estimatedMemoryMB;     // 估算内存需求

  ModelMetadata({
    required this.parameterSize,
    this.quantizationLevel,
    required this.contextWindow,
    required this.totalLayers,
    this.architecture,
    required this.isQuantized,
    required this.isGguf,
    required this.estimatedMemoryMB,
  });

  /// 参数量描述
  String get parameterSizeDescription {
    if (parameterSize == 0) return 'Unknown';
    return '$parameterSize B';
  }

  /// 内存需求描述
  String get memoryRequirementDescription {
    if (estimatedMemoryMB == 0) return 'Unknown';
    return '${(estimatedMemoryMB / 1024).toStringAsFixed(1)} GB';
  }

  @override
  String toString() {
    return 'ModelMetadata(params: ${parameterSize}B, quant: $quantizationLevel, '
        'ctx: ${contextWindow} tokens, layers: $totalLayers, '
        'mem: ${memoryRequirementDescription})';
  }
}
