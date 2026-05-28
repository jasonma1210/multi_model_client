import 'dart:io';
import '../platform/hardware/device_env.dart';
import '../models/model_hardware_requirement.dart';

/// 量化匹配结果
class QuantMatchResult {
  final String recommendLevel;           // 推荐量化级别
  final Map<String, int> validLevels;    // 可用量化级别（级别 -> 内存需求MB）
  final Map<String, int> invalidLevels;  // 禁用量化级别（级别 -> 内存需求MB）
  final int availableMemoryMB;           // 可用内存
  final String? reason;                  // 推荐理由

  QuantMatchResult({
    required this.recommendLevel,
    required this.validLevels,
    required this.invalidLevels,
    required this.availableMemoryMB,
    this.reason,
  });

  /// 是否支持指定量化级别
  bool isLevelSupported(String level) {
    return validLevels.containsKey(level);
  }

  /// 获取级别描述
  String getLevelDescription(String level) {
    return quantLevelDescriptions[level] ?? '未知量化级别';
  }

  /// 获取内存需求描述
  String getMemoryRequirementDescription(String level) {
    final memMB = validLevels[level] ?? invalidLevels[level] ?? 0;
    if (memMB == 0) return '未知';

    final memGB = memMB / 1024;
    return '${memGB.toStringAsFixed(1)} GB';
  }
}

/// 量化级别匹配器
class QuantLevelMatcher {
  final DeviceEnv deviceEnv;

  QuantLevelMatcher(this.deviceEnv);

  /// 匹配最佳量化级别
  QuantMatchResult matchModel(ModelHardwareRequirement model, {int? customContextWindow}) {
    // 1. 计算可用内存（预留30%系统内存）
    int availableMemoryMB = (deviceEnv.totalMemoryMB * 0.7).toInt();

    // 2. 叠加GPU内存（如果启用加速）
    if (deviceEnv.supportsGpuAcceleration) {
      availableMemoryMB += deviceEnv.effectiveGpuMemoryMB;
    }

    // 3. 考虑上下文窗口内存
    if (customContextWindow != null && customContextWindow != model.recommendCtx) {
      // 上下文窗口变化会影响内存需求
      // 估算：每1024 tokens约需要100-200 MB
      final contextDelta = customContextWindow - model.recommendCtx;
      final _ = (contextDelta.abs() / 1024 * 150).toInt();

      if (contextDelta > 0) {
        // 增大上下文窗口，需要更多内存
        // 所有级别的内存需求都会增加
        // 这里简化处理，实际应该重新计算
      }
    }

    // 4. 过滤可用量化级别
    Map<String, int> validLevels = {};
    Map<String, int> invalidLevels = {};

    model.minMemoryMB.forEach((level, minMem) {
      if (minMem <= availableMemoryMB) {
        validLevels[level] = minMem;
      } else {
        invalidLevels[level] = minMem;
      }
    });

    // 5. 推荐最佳级别
    String? recommendLevel;
    String? reason;

    // 按优先级选择第一个可用级别
    for (final level in quantLevelPriority) {
      if (validLevels.containsKey(level)) {
        recommendLevel = level;

        // 生成推荐理由
        if (deviceEnv.supportsGpuAcceleration) {
          reason = '推荐使用$level，结合${deviceEnv.isMetalAvailable ? "Metal" : "CUDA"}加速可达到最佳性能。';
        } else {
          reason = '推荐使用$level，在当前设备上可达到最佳性能与精度平衡。';
        }
        break;
      }
    }

    // 6. 移动端特殊适配
    if (Platform.isAndroid || Platform.isIOS) {
      // 移动端优先考虑低内存级别
      if (availableMemoryMB < 8192 && validLevels.containsKey('Q3_K_L')) {
        recommendLevel = 'Q3_K_L';
        reason = '移动设备推荐使用Q3_K_L，可在保证流畅的同时节省内存。';
      }
    }

    // 7. 兜底：如果没有可用级别，选择最低需求
    if (recommendLevel == null && validLevels.isNotEmpty) {
      recommendLevel = validLevels.keys.first;
      reason = '当前设备仅支持$recommendLevel级别。';
    }

    return QuantMatchResult(
      recommendLevel: recommendLevel ?? 'Q2_K',
      validLevels: validLevels,
      invalidLevels: invalidLevels,
      availableMemoryMB: availableMemoryMB,
      reason: reason,
    );
  }

  /// 检查设备是否可以运行指定量化级别
  bool canRunQuantizationLevel(ModelHardwareRequirement model, String level) {
    final result = matchModel(model);
    return result.isLevelSupported(level);
  }

  /// 获取推荐的GPU层数（针对指定量化级别）
  int getRecommendedGpuLayers(ModelHardwareRequirement model, String quantLevel) {
    if (!deviceEnv.supportsGpuAcceleration) {
      return 0;
    }

    // Metal：统一内存架构，全量offload
    if (deviceEnv.isMetalAvailable) {
      return model.totalLayers;
    }

    // CUDA：根据显存精确计算
    if (deviceEnv.isCudaAvailable && deviceEnv.gpuMemoryMB != null) {
      return _calculateCudaLayers(model, quantLevel);
    }

    return 0;
  }

  /// 计算CUDA最优层数
  int _calculateCudaLayers(ModelHardwareRequirement model, String quantLevel) {
    final gpuMemoryMB = deviceEnv.gpuMemoryMB ?? 0;
    if (gpuMemoryMB == 0) return 0;

    // 量化系数
    final quantCoefficients = {
      'Q2_K': 0.25,
      'Q3_K_L': 0.30,
      'Q4_K_M': 0.40,
      'Q5_K_M': 0.50,
      'Q8_0': 0.80,
      'FP16': 1.0,
    };

    final coef = quantCoefficients[quantLevel] ?? 0.4;

    // 计算每层所需显存（MB）
    final layerMemMB = (model.paramsGB / model.totalLayers) * 1024 * coef;

    // 预留20%显存作为缓冲
    final availableMemMB = (gpuMemoryMB * 0.8).toInt();

    // 计算最大层数
    final maxLayers = (availableMemMB / layerMemMB).floor();

    return maxLayers.clamp(0, model.totalLayers);
  }

  /// 生成内存使用报告
  String generateMemoryReport(ModelHardwareRequirement model, String quantLevel) {
    final result = matchModel(model);
    final memMB = model.minMemoryMB[quantLevel] ?? 0;
    final memGB = memMB / 1024;

    final buffer = StringBuffer();
    buffer.writeln('=== 内存使用报告 ===');
    buffer.writeln('模型: ${model.modelId}');
    buffer.writeln('量化级别: $quantLevel');
    buffer.writeln('预计内存需求: ${memGB.toStringAsFixed(1)} GB');
    buffer.writeln('设备可用内存: ${(result.availableMemoryMB / 1024).toStringAsFixed(1)} GB');
    buffer.writeln('设备总内存: ${(deviceEnv.totalMemoryMB / 1024).toStringAsFixed(1)} GB');

    if (deviceEnv.supportsGpuAcceleration) {
      buffer.writeln('GPU加速: ${deviceEnv.isMetalAvailable ? "Metal" : "CUDA"}');
      buffer.writeln('GPU内存: ${(deviceEnv.gpuMemoryMB ?? 0) / 1024} GB');
    }

    if (result.isLevelSupported(quantLevel)) {
      buffer.writeln('状态: ✅ 可运行');
    } else {
      buffer.writeln('状态: ❌ 内存不足');
      buffer.writeln('建议: 选择${result.recommendLevel}或其他更低的量化级别');
    }

    return buffer.toString();
  }
}
