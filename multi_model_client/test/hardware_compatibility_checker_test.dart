import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multi_model_client/core/services/hardware_compatibility_checker.dart';
import 'package:multi_model_client/core/platform/hardware_checker_channel.dart';

// Mock classes
class MockHardwareCheckerChannel extends Mock implements HardwareCheckerPlatformChannel {}

void main() {
  group('HardwareCompatibilityChecker', () {
    late HardwareCompatibilityChecker checker;

    setUp(() {
      checker = HardwareCompatibilityChecker();
    });

    tearDown(() {
      checker.clearCache();
    });

    group('getHardwareInfo', () {
      test('should return hardware info with all required fields', () async {
        // Act
        final info = await checker.getHardwareInfo();

        // Assert
        expect(info.deviceName, isNotEmpty);
        expect(info.osVersion, isNotEmpty);
        expect(info.totalRamMB, greaterThan(0));
        expect(info.availableRamMB, greaterThan(0));
        expect(info.totalStorageGB, greaterThan(0));
        expect(info.availableStorageGB, greaterThan(0));
        expect(info.cpuArchitecture, isNotEmpty);
        expect(info.cpuCores, greaterThan(0));
      });

      test('should cache hardware info', () async {
        // Act
        final info1 = await checker.getHardwareInfo();
        final info2 = await checker.getHardwareInfo();

        // Assert
        expect(identical(info1, info2), isTrue);
      });

      test('should return GB values correctly', () async {
        // Act
        final info = await checker.getHardwareInfo();

        // Assert
        expect(info.totalRamGB, equals((info.totalRamMB / 1024).round()));
        expect(info.availableRamGB, equals((info.availableRamMB / 1024).round()));
      });

      test('should return supported features', () async {
        // Act
        final info = await checker.getHardwareInfo();

        // Assert
        expect(info.supportedFeatures, isA<Set<HardwareFeature>>());
      });

      test('should clear cache and refetch info', () async {
        // Act
        final info1 = await checker.getHardwareInfo();
        checker.clearCache();
        final info2 = await checker.getHardwareInfo();

        // Assert
        expect(identical(info1, info2), isFalse);
      });
    });

    group('checkModelCompatibility', () {
      test('should return compatible when requirements met', () async {
        // Act
        final result = await checker.checkModelCompatibility(
          minRamGB: 1,
          minStorageGB: 1,
        );

        // Assert
        expect(result.isCompatible, isTrue);
        expect(result.reasons, isEmpty);
      });

      test('should return incompatible when RAM insufficient', () async {
        // Act
        final result = await checker.checkModelCompatibility(
          minRamGB: 10000, // Unreasonably high
          minStorageGB: 1,
        );

        // Assert
        expect(result.isCompatible, isFalse);
        expect(result.reasons.any((r) => r.contains('内存不足')), isTrue);
      });

      test('should return incompatible when storage insufficient', () async {
        // Act
        final result = await checker.checkModelCompatibility(
          minRamGB: 1,
          minStorageGB: 10000, // Unreasonably high
        );

        // Assert
        expect(result.isCompatible, isFalse);
        expect(result.reasons.any((r) => r.contains('存储空间不足')), isTrue);
      });

      test('should add warning when RAM is low but sufficient', () async {
        // Act
        final result = await checker.checkModelCompatibility(
          minRamGB: 1,
          minStorageGB: 1,
        );

        // Assert
        // If available RAM is less than 1.5x required, should warn
        final info = await checker.getHardwareInfo();
        if (info.availableRamGB < 2) {
          expect(result.warnings.any((w) => w.contains('内存较少')), isTrue);
        }
      });

      test('should check hardware features', () async {
        // Arrange
        final info = await checker.getHardwareInfo();

        // Act
        final result = await checker.checkModelCompatibility(
          minRamGB: 1,
          minStorageGB: 1,
          requiredFeatures: ['nonexistent_feature_xyz'],
        );

        // Assert
        expect(result.isCompatible, isFalse);
        expect(result.reasons.any((r) => r.contains('缺少硬件特性')), isTrue);
      });

      test('should include detailed compatibility info', () async {
        // Act
        final result = await checker.checkModelCompatibility(
          minRamGB: 4,
          minStorageGB: 8,
        );

        // Assert
        expect(result.details['ram'], isNotNull);
        expect(result.details['storage'], isNotNull);
        expect(result.details['cpu'], isNotNull);
      });
    });

    group('hasEnoughStorage', () {
      test('should return true when storage is sufficient', () async {
        // Act
        final result = await checker.hasEnoughStorage(1);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when storage is insufficient', () async {
        // Act
        final result = await checker.hasEnoughStorage(100000);

        // Assert
        expect(result, isFalse);
      });
    });

    group('hasEnoughRam', () {
      test('should return true when RAM is sufficient', () async {
        // Act
        final result = await checker.hasEnoughRam(1);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when RAM is insufficient', () async {
        // Act
        final result = await checker.hasEnoughRam(100000);

        // Assert
        expect(result, isFalse);
      });
    });

    group('supportsFeature', () {
      test('should check GPU feature', () async {
        // Act
        final result = await checker.supportsFeature(HardwareFeature.gpu);

        // Assert
        expect(result, isA<bool>());
      });

      test('should check Metal feature', () async {
        // Act
        final result = await checker.supportsFeature(HardwareFeature.metal);

        // Assert
        expect(result, isA<bool>());
      });

      test('should check Vulkan feature', () async {
        // Act
        final result = await checker.supportsFeature(HardwareFeature.vulkan);

        // Assert
        expect(result, isA<bool>());
      });

      test('should check NEON feature', () async {
        // Act
        final result = await checker.supportsFeature(HardwareFeature.neon);

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('getRecommendedModelConfig', () {
      test('should return valid configuration', () async {
        // Act
        final config = await checker.getRecommendedModelConfig();

        // Assert
        expect(config['contextSize'], isA<int>());
        expect(config['threads'], isA<int>());
        expect(config['useGpu'], isA<bool>());
        expect(config['batchSize'], isA<int>());
      });

      test('should recommend config based on hardware', () async {
        // Arrange
        final info = await checker.getHardwareInfo();

        // Act
        final config = await checker.getRecommendedModelConfig();

        // Assert
        expect(config['contextSize'], lessThanOrEqualTo(8192));
        expect(config['threads'], lessThanOrEqualTo(info.cpuCores));
        expect(config['threads'], greaterThanOrEqualTo(2));
      });

      test('should recommend appropriate context size for RAM', () async {
        // Arrange
        final info = await checker.getHardwareInfo();

        // Act
        final config = await checker.getRecommendedModelConfig();

        // Assert
        if (info.availableRamGB >= 16) {
          expect(config['contextSize'], equals(8192));
        } else if (info.availableRamGB >= 8) {
          expect(config['contextSize'], equals(4096));
        } else if (info.availableRamGB >= 4) {
          expect(config['contextSize'], equals(2048));
        } else {
          expect(config['contextSize'], equals(1024));
        }
      });

      test('should recommend appropriate thread count', () async {
        // Arrange
        final info = await checker.getHardwareInfo();

        // Act
        final config = await checker.getRecommendedModelConfig();

        // Assert
        expect(config['threads'], greaterThanOrEqualTo(2));
        expect(config['threads'], lessThanOrEqualTo(8));
      });
    });

    group('HardwareInfo', () {
      test('should serialize to JSON correctly', () async {
        // Arrange
        final info = await checker.getHardwareInfo();

        // Act
        final json = info.toJson();

        // Assert
        expect(json['deviceName'], equals(info.deviceName));
        expect(json['osVersion'], equals(info.osVersion));
        expect(json['totalRamMB'], equals(info.totalRamMB));
        expect(json['availableRamMB'], equals(info.availableRamMB));
        expect(json['totalStorageGB'], equals(info.totalStorageGB));
        expect(json['availableStorageGB'], equals(info.availableStorageGB));
        expect(json['cpuArchitecture'], equals(info.cpuArchitecture));
        expect(json['cpuCores'], equals(info.cpuCores));
      });
    });

    group('CompatibilityResult', () {
      test('should return correct summary for compatible result', () {
        // Arrange
        final result = CompatibilityResult(
          isCompatible: true,
          reasons: [],
          warnings: [],
        );

        // Act
        final summary = result.summary;

        // Assert
        expect(summary, contains('✅'));
        expect(summary, contains('完全兼容'));
      });

      test('should return correct summary for compatible with warnings', () {
        // Arrange
        final result = CompatibilityResult(
          isCompatible: true,
          reasons: [],
          warnings: ['内存较少'],
        );

        // Act
        final summary = result.summary;

        // Assert
        expect(summary, contains('⚠️'));
        expect(summary, contains('警告'));
      });

      test('should return correct summary for incompatible result', () {
        // Arrange
        final result = CompatibilityResult(
          isCompatible: false,
          reasons: ['内存不足'],
          warnings: [],
        );

        // Act
        final summary = result.summary;

        // Assert
        expect(summary, contains('❌'));
        expect(summary, contains('不兼容'));
      });
    });
  });
}
