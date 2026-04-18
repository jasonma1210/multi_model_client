import 'package:flutter_test/flutter_test.dart';
import 'package:multi_model_client/core/platform/hardware/device_env.dart';
import 'package:multi_model_client/core/services/quant_level_matcher.dart';
import 'package:multi_model_client/core/models/model_hardware_requirement.dart';

void main() {
  group('QuantLevelMatcher', () {
    test('低配设备应推荐Q2_K', () {
      // Arrange
      final env = DeviceEnv(
        cpuArch: 'x86_64',
        cpuCores: 4,
        totalMemoryMB: 4096,
      );
      final matcher = QuantLevelMatcher(env);
      final qwen7B = getModelRequirement('Qwen2.5-7B-Instruct')!;

      // Act
      final result = matcher.matchModel(qwen7B);

      // Assert
      expect(result.recommendLevel, equals('Q2_K'));
      expect(result.validLevels.keys, contains('Q2_K'));
      expect(result.validLevels.keys, isNot(contains('Q8_0')));
    });

    test('中配设备应推荐Q4_K_M', () {
      // Arrange
      final env = DeviceEnv(
        cpuArch: 'x86_64',
        cpuCores: 8,
        totalMemoryMB: 16384,
      );
      final matcher = QuantLevelMatcher(env);
      final qwen7B = getModelRequirement('Qwen2.5-7B-Instruct')!;

      // Act
      final result = matcher.matchModel(qwen7B);

      // Assert
      expect(result.recommendLevel, equals('Q4_K_M'));
      expect(result.validLevels.keys, containsAll(['Q4_K_M', 'Q3_K_L', 'Q2_K']));
    });

    test('GPU加速设备应有更多可用级别', () {
      // Arrange
      final env = DeviceEnv(
        cpuArch: 'x86_64',
        cpuCores: 8,
        totalMemoryMB: 8192,
        isCudaAvailable: true,
        gpuName: 'NVIDIA RTX 3060',
        gpuMemoryMB: 6144,
      );
      final matcher = QuantLevelMatcher(env);
      final qwen7B = getModelRequirement('Qwen2.5-7B-Instruct')!;

      // Act
      final result = matcher.matchModel(qwen7B);

      // Assert
      expect(result.validLevels.keys, contains('Q5_K_M'));
      expect(result.availableMemoryMB, greaterThan(8192));
    });

    test('Metal统一内存设备应支持更高量化级别', () {
      // Arrange
      final env = DeviceEnv(
        cpuArch: 'arm64',
        cpuCores: 8,
        totalMemoryMB: 16384,
        isMetalAvailable: true,
        gpuName: 'Apple M1 Pro',
        gpuMemoryMB: 16384, // 统一内存
      );
      final matcher = QuantLevelMatcher(env);
      final llama8B = getModelRequirement('Llama3.1-8B-Instruct')!;

      // Act
      final result = matcher.matchModel(llama8B);

      // Assert
      expect(result.validLevels.keys, containsAll(['Q5_K_M', 'Q8_0']));
      expect(result.recommendLevel, equals('Q4_K_M'));
    });

    test('大模型在低配设备上应只支持低量化级别', () {
      // Arrange
      final env = DeviceEnv(
        cpuArch: 'x86_64',
        cpuCores: 4,
        totalMemoryMB: 8192,
      );
      final matcher = QuantLevelMatcher(env);
      final qwen72B = getModelRequirement('Qwen2.5-72B-Instruct')!;

      // Act
      final result = matcher.matchModel(qwen72B);

      // Assert
      expect(result.validLevels, isEmpty);
      expect(result.invalidLevels.keys, containsAll(['Q4_K_M', 'Q5_K_M', 'Q8_0']));
    });

    test('推荐理由应正确生成', () {
      // Arrange
      final env = DeviceEnv(
        cpuArch: 'arm64',
        cpuCores: 8,
        totalMemoryMB: 16384,
        isMetalAvailable: true,
        gpuName: 'Apple M1',
        gpuMemoryMB: 16384,
      );
      final matcher = QuantLevelMatcher(env);
      final model = getModelRequirement('Qwen2.5-7B-Instruct')!;

      // Act
      final result = matcher.matchModel(model);

      // Assert
      expect(result.reason, isNotNull);
      expect(result.reason!, contains('Q4_K_M'));
      expect(result.reason!, contains('Metal'));
    });

    test('GPU层数计算应正确', () {
      // Arrange
      final env = DeviceEnv(
        cpuArch: 'x86_64',
        cpuCores: 8,
        totalMemoryMB: 16384,
        isCudaAvailable: true,
        gpuName: 'NVIDIA RTX 4090',
        gpuMemoryMB: 24576,
      );
      final matcher = QuantLevelMatcher(env);
      final model = getModelRequirement('Llama3.1-8B-Instruct')!;

      // Act
      final gpuLayers = matcher.getRecommendedGpuLayers(model, 'Q4_K_M');

      // Assert
      expect(gpuLayers, greaterThan(0));
      expect(gpuLayers, lessThanOrEqualTo(model.totalLayers));
    });
  });

  group('ModelHardwareRequirement', () {
    test('应正确获取模型需求', () {
      final qwen = getModelRequirement('Qwen2.5-7B-Instruct');

      expect(qwen, isNotNull);
      expect(qwen!.modelId, equals('Qwen2.5-7B-Instruct'));
      expect(qwen.paramsGB, equals(14.0));
      expect(qwen.totalLayers, equals(35));
      expect(qwen.minMemoryMB, isNotEmpty);
    });

    test('应支持模糊匹配', () {
      final qwen = getModelRequirement('qwen2.5-7b');

      expect(qwen, isNotNull);
      expect(qwen!.modelId, contains('Qwen'));
    });

    test('应推断未知模型需求', () {
      final inferred = inferModelRequirement('MyModel-13B', 13);

      expect(inferred.modelId, equals('MyModel-13B'));
      expect(inferred.paramsGB, equals(26.0));
      expect(inferred.minMemoryMB, isNotEmpty);
    });

    test('内存描述应正确格式化', () {
      final model = getModelRequirement('Qwen2.5-7B-Instruct')!;

      expect(model.getMemoryDescription('Q4_K_M'), equals('4.0 GB'));
      expect(model.getMemoryDescription('Q8_0'), equals('8.0 GB'));
    });
  });
}
