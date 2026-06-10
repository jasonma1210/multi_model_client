import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 硬件特性
enum HardwareFeature {
  gpu,      // GPU支持
  metal,    // Metal API (iOS/macOS)
  vulkan,   // Vulkan API (Android/Linux)
  neon,     // ARM NEON指令集
  avx,      // x86 AVX指令集
  cuda,     // NVIDIA CUDA
}

/// 硬件信息
class HardwareInfo {
  final String deviceName;
  final String osVersion;
  final int totalRamMB;
  final int availableRamMB;
  final int totalStorageGB;
  final int availableStorageGB;
  final String cpuArchitecture;
  final int cpuCores;
  final Set<HardwareFeature> supportedFeatures;
  final String? gpuName;
  final int? gpuMemoryMB;

  HardwareInfo({
    required this.deviceName,
    required this.osVersion,
    required this.totalRamMB,
    required this.availableRamMB,
    required this.totalStorageGB,
    required this.availableStorageGB,
    required this.cpuArchitecture,
    required this.cpuCores,
    required this.supportedFeatures,
    this.gpuName,
    this.gpuMemoryMB,
  });

  int get totalRamGB => (totalRamMB / 1024).round();
  int get availableRamGB => (availableRamMB / 1024).round();

  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'osVersion': osVersion,
      'totalRamMB': totalRamMB,
      'availableRamMB': availableRamMB,
      'totalStorageGB': totalStorageGB,
      'availableStorageGB': availableStorageGB,
      'cpuArchitecture': cpuArchitecture,
      'cpuCores': cpuCores,
      'supportedFeatures': supportedFeatures.map((f) => f.name).toList(),
      'gpuName': gpuName,
      'gpuMemoryMB': gpuMemoryMB,
    };
  }
}

/// 兼容性检查结果
class CompatibilityResult {
  final bool isCompatible;
  final List<String> reasons;
  final List<String> warnings;
  final Map<String, dynamic> details;

  CompatibilityResult({
    required this.isCompatible,
    this.reasons = const [],
    this.warnings = const [],
    this.details = const {},
  });

  String get summary {
    if (isCompatible) {
      if (warnings.isEmpty) {
        return '✅ 完全兼容';
      } else {
        return '⚠️ 兼容但有警告';
      }
    } else {
      return '❌ 不兼容: ${reasons.join(", ")}';
    }
  }
}

/// 硬件兼容性检查器
class HardwareCompatibilityChecker {
  static const MethodChannel _channel = MethodChannel('hardware_checker');
  HardwareInfo? _cachedInfo;

  /// 获取硬件信息
  Future<HardwareInfo> getHardwareInfo() async {
    if (_cachedInfo != null) {
      return _cachedInfo!;
    }

    try {
      final Map<String, dynamic> info;

      if (Platform.isIOS || Platform.isAndroid) {
        // 使用平台通道获取原生硬件信息
        info = await _channel.invokeMethod('getHardwareInfo');
      } else {
        // 桌面平台使用基础信息
        info = await _getDesktopHardwareInfo();
      }

      _cachedInfo = HardwareInfo(
        deviceName: info['deviceName'] as String? ?? 'Unknown',
        osVersion: info['osVersion'] as String? ?? 'Unknown',
        totalRamMB: info['totalRamMB'] as int? ?? 4096,
        availableRamMB: info['availableRamMB'] as int? ?? 2048,
        totalStorageGB: info['totalStorageGB'] as int? ?? 64,
        availableStorageGB: info['availableStorageGB'] as int? ?? 32,
        cpuArchitecture: info['cpuArchitecture'] as String? ?? 'arm64',
        cpuCores: info['cpuCores'] as int? ?? 4,
        supportedFeatures: _parseFeatures(info['supportedFeatures'] as List<dynamic>?),
        gpuName: info['gpuName'] as String?,
        gpuMemoryMB: info['gpuMemoryMB'] as int?,
      );

      return _cachedInfo!;
    } catch (e) {
      debugPrint('Error getting hardware info: $e');

      // 返回默认信息
      return HardwareInfo(
        deviceName: 'Unknown',
        osVersion: 'Unknown',
        totalRamMB: 4096,
        availableRamMB: 2048,
        totalStorageGB: 64,
        availableStorageGB: 32,
        cpuArchitecture: 'arm64',
        cpuCores: 4,
        supportedFeatures: {},
      );
    }
  }

  /// 检查模型兼容性
  Future<CompatibilityResult> checkModelCompatibility({
    required int minRamGB,
    required int minStorageGB,
    List<String> requiredFeatures = const [],
  }) async {
    try {
      final hardware = await getHardwareInfo();
      final reasons = <String>[];
      final warnings = <String>[];
      final details = <String, dynamic>{};

      // 检查内存
      if (hardware.availableRamGB < minRamGB) {
        reasons.add('内存不足: 需要${minRamGB}GB，可用${hardware.availableRamGB}GB');
      } else if (hardware.availableRamGB < minRamGB * 1.5) {
        warnings.add('内存较少: 建议至少${(minRamGB * 1.5).round()}GB');
      }
      details['ram'] = {
        'required': minRamGB,
        'available': hardware.availableRamGB,
        'sufficient': hardware.availableRamGB >= minRamGB,
      };

      // 检查存储空间
      if (hardware.availableStorageGB < minStorageGB) {
        reasons.add('存储空间不足: 需要${minStorageGB}GB，可用${hardware.availableStorageGB}GB');
      }
      details['storage'] = {
        'required': minStorageGB,
        'available': hardware.availableStorageGB,
        'sufficient': hardware.availableStorageGB >= minStorageGB,
      };

      // 检查硬件特性
      final missingFeatures = <String>[];
      for (final feature in requiredFeatures) {
        final featureEnum = _parseFeature(feature);
        if (featureEnum != null && !hardware.supportedFeatures.contains(featureEnum)) {
          missingFeatures.add(feature);
        }
      }

      if (missingFeatures.isNotEmpty) {
        reasons.add('缺少硬件特性: ${missingFeatures.join(", ")}');
      }
      details['features'] = {
        'required': requiredFeatures,
        'supported': hardware.supportedFeatures.map((f) => f.name).toList(),
        'missing': missingFeatures,
      };

      // 检查CPU核心数
      if (hardware.cpuCores < 4) {
        warnings.add('CPU核心数较少: ${hardware.cpuCores}核，建议4核以上');
      }
      details['cpu'] = {
        'cores': hardware.cpuCores,
        'architecture': hardware.cpuArchitecture,
      };

      // 检查GPU（可选）
      if (hardware.gpuName != null) {
        details['gpu'] = {
          'name': hardware.gpuName,
          'memoryMB': hardware.gpuMemoryMB,
        };

        if (hardware.gpuMemoryMB != null && hardware.gpuMemoryMB! < 4096) {
          warnings.add('GPU显存较少: ${hardware.gpuMemoryMB}MB，建议4GB以上');
        }
      }

      return CompatibilityResult(
        isCompatible: reasons.isEmpty,
        reasons: reasons,
        warnings: warnings,
        details: details,
      );
    } catch (e) {
      debugPrint('Error checking compatibility: $e');
      return CompatibilityResult(
        isCompatible: false,
        reasons: ['无法检查硬件信息: $e'],
      );
    }
  }

  /// 检查是否有足够的存储空间
  Future<bool> hasEnoughStorage(int requiredGB) async {
    try {
      final hardware = await getHardwareInfo();
      return hardware.availableStorageGB >= requiredGB;
    } catch (e) {
      debugPrint('Error checking storage: $e');
      return false;
    }
  }

  /// 检查是否有足够的内存
  Future<bool> hasEnoughRam(int requiredGB) async {
    try {
      final hardware = await getHardwareInfo();
      return hardware.availableRamGB >= requiredGB;
    } catch (e) {
      debugPrint('Error checking RAM: $e');
      return false;
    }
  }

  /// 检查是否支持特定硬件特性
  Future<bool> supportsFeature(HardwareFeature feature) async {
    try {
      final hardware = await getHardwareInfo();
      return hardware.supportedFeatures.contains(feature);
    } catch (e) {
      debugPrint('Error checking feature: $e');
      return false;
    }
  }

  /// 获取推荐模型配置
  Future<Map<String, dynamic>> getRecommendedModelConfig() async {
    try {
      final hardware = await getHardwareInfo();
      final config = <String, dynamic>{};

      // 根据硬件配置推荐参数
      config['contextSize'] = _recommendContextSize(hardware);
      config['threads'] = _recommendThreads(hardware);
      config['useGpu'] = hardware.supportedFeatures.contains(HardwareFeature.gpu) ||
                         hardware.supportedFeatures.contains(HardwareFeature.metal);
      config['batchSize'] = _recommendBatchSize(hardware);

      return config;
    } catch (e) {
      debugPrint('Error getting recommended config: $e');
      return {
        'contextSize': 2048,
        'threads': 2, // ★ 默认 2 线程：骁龙 8 Elite 超大核绑定
        'useGpu': false,
        'batchSize': 128, // ★ 默认 128：移动端大 batch 会导致首字延迟
      };
    }
  }

  /// 推荐上下文大小
  int _recommendContextSize(HardwareInfo hardware) {
    final ramGB = hardware.availableRamGB;

    if (ramGB >= 16) {
      return 8192;
    } else if (ramGB >= 8) {
      return 4096;
    } else if (ramGB >= 4) {
      return 2048;
    } else {
      return 1024;
    }
  }

  /// 推荐线程数
  int _recommendThreads(HardwareInfo hardware) {
    // 使用物理核心数，但不超过8
    return hardware.cpuCores.clamp(2, 8);
  }

  /// 推荐批处理大小
  int _recommendBatchSize(HardwareInfo hardware) {
    final ramGB = hardware.availableRamGB;

    if (ramGB >= 16) {
      return 1024;
    } else if (ramGB >= 8) {
      return 512;
    } else {
      return 256;
    }
  }

  /// 获取桌面平台硬件信息
  Future<Map<String, dynamic>> _getDesktopHardwareInfo() async {
    final info = <String, dynamic>{};

    // CPU架构
    info['cpuArchitecture'] = Platform.isMacOS ? 'arm64' : 'x86_64';

    // CPU核心数
    info['cpuCores'] = Platform.numberOfProcessors;

    // 尝试获取真实内存信息
    int totalRamMB = 8192;
    int availableRamMB = 4096;

    try {
      if (Platform.isMacOS) {
        // 使用 sysctl 获取 Mac 内存信息
        final sysctlResult = await Process.run('sysctl', ['-n', 'hw.memsize']);
        if (sysctlResult.exitCode == 0) {
          totalRamMB = (int.tryParse(sysctlResult.stdout.toString().trim()) ?? 8192 * 1024 * 1024) ~/ (1024 * 1024);
        }
        // 获取可用内存
        final vmStatResult = await Process.run('vm_stat', []);
        if (vmStatResult.exitCode == 0) {
          final output = vmStatResult.stdout.toString();
          // 解析 Pages free: 数值
          final freeMatch = RegExp(r'Pages free:\s+(\d+)').firstMatch(output);
          final inactiveMatch = RegExp(r'Pages inactive:\s+(\d+)').firstMatch(output);
          if (freeMatch != null) {
            final pageSize = 4096; // 默认页大小
            final freePages = int.tryParse(freeMatch.group(1) ?? '0') ?? 0;
            final inactivePages = int.tryParse(inactiveMatch?.group(1) ?? '0') ?? 0;
            availableRamMB = ((freePages + inactivePages) * pageSize) ~/ (1024 * 1024);
          }
        }
      } else if (Platform.isLinux) {
        // 读取 /proc/meminfo 获取 Linux 内存信息
        final meminfo = await File('/proc/meminfo').readAsString();
        final memTotal = RegExp(r'MemTotal:\s+(\d+)').firstMatch(meminfo);
        final memAvailable = RegExp(r'MemAvailable:\s+(\d+)').firstMatch(meminfo);
        if (memTotal != null) {
          totalRamMB = (int.tryParse(memTotal.group(1) ?? '0') ?? 0) ~/ 1024;
        }
        if (memAvailable != null) {
          availableRamMB = (int.tryParse(memAvailable.group(1) ?? '0') ?? 0) ~/ 1024;
        }
      } else if (Platform.isWindows) {
        // Windows 使用 wmic
        final memResult = await Process.run('wmic', ['ComputerSystem', 'get', 'TotalPhysicalMemory']);
        if (memResult.exitCode == 0) {
          final lines = memResult.stdout.toString().trim().split('\n');
          if (lines.length > 1) {
            totalRamMB = (int.tryParse(lines[1].trim()) ?? 0) ~/ (1024 * 1024);
          }
        }
        final availResult = await Process.run('wmic', ['OS', 'get', 'FreePhysicalMemory']);
        if (availResult.exitCode == 0) {
          final lines = availResult.stdout.toString().trim().split('\n');
          if (lines.length > 1) {
            final freeKB = int.tryParse(lines[1].trim()) ?? 0;
            availableRamMB = freeKB ~/ 1024;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting real memory info: $e');
    }

    info['totalRamMB'] = totalRamMB;
    info['availableRamMB'] = availableRamMB;

    // 获取存储空间
    int totalStorageGB = 256;
    int availableStorageGB = 128;
    try {
      if (Platform.isMacOS) {
        final dfResult = await Process.run('df', ['-g', '/']);
        if (dfResult.exitCode == 0) {
          final lines = dfResult.stdout.toString().split('\n');
          if (lines.length > 1) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              availableStorageGB = int.tryParse(parts[3]) ?? 128;
              totalStorageGB = int.tryParse(parts[1]) ?? 256;
            }
          }
        }
      } else if (Platform.isLinux) {
        final dfResult = await Process.run('df', ['-BG', '/']);
        if (dfResult.exitCode == 0) {
          final lines = dfResult.stdout.toString().split('\n');
          if (lines.length > 1) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              availableStorageGB = int.tryParse(parts[3].replaceAll('G', '')) ?? 128;
              totalStorageGB = int.tryParse(parts[1].replaceAll('G', '')) ?? 256;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting storage info: $e');
    }

    info['totalStorageGB'] = totalStorageGB;
    info['availableStorageGB'] = availableStorageGB;
    info['deviceName'] = Platform.operatingSystem;
    info['osVersion'] = Platform.operatingSystemVersion;

    // 检测支持的特性
    final features = <String>[];
    if (Platform.isMacOS) {
      features.add('metal');
      features.add('neon');
      // 检测 Apple Silicon
      if (Platform.isIOS || info['cpuArchitecture'] == 'arm64') {
        features.add('gpu');
      }
    } else if (Platform.isLinux) {
      features.add('vulkan');
    }
    info['supportedFeatures'] = features;

    // 尝试获取 GPU 信息 (macOS)
    if (Platform.isMacOS) {
      try {
        final systemProfilerResult = await Process.run('system_profiler', ['SPDisplaysDataType']);
        if (systemProfilerResult.exitCode == 0) {
          final output = systemProfilerResult.stdout.toString();
          // 提取 GPU 名称
          final gpuMatch = RegExp(r'Chipset Model:\s*(.+)').firstMatch(output);
          if (gpuMatch != null) {
            info['gpuName'] = gpuMatch.group(1)?.trim();
          }
          // 提取 GPU 显存 (Apple Silicon 使用统一内存)
          final vramMatch = RegExp(r'VRAM \(Dynamic, Max\):\s*(.+)').firstMatch(output);
          if (vramMatch != null) {
            final vramStr = vramMatch.group(1)?.trim() ?? '';
            final vramGB = double.tryParse(vramStr.replaceAll('GB', '').trim());
            if (vramGB != null) {
              info['gpuMemoryMB'] = (vramGB * 1024).round();
            }
          }
        }
      } catch (e) {
        debugPrint('Error getting GPU info: $e');
      }
    }

    return info;
  }

  /// 解析硬件特性列表
  Set<HardwareFeature> _parseFeatures(List<dynamic>? features) {
    if (features == null) return {};

    return features
        .map((f) => _parseFeature(f.toString()))
        .where((f) => f != null)
        .cast<HardwareFeature>()
        .toSet();
  }

  /// 解析单个硬件特性
  HardwareFeature? _parseFeature(String feature) {
    switch (feature.toLowerCase()) {
      case 'gpu':
        return HardwareFeature.gpu;
      case 'metal':
        return HardwareFeature.metal;
      case 'vulkan':
        return HardwareFeature.vulkan;
      case 'neon':
        return HardwareFeature.neon;
      case 'avx':
        return HardwareFeature.avx;
      case 'cuda':
        return HardwareFeature.cuda;
      default:
        return null;
    }
  }

  /// 清除缓存
  void clearCache() {
    _cachedInfo = null;
  }
}
