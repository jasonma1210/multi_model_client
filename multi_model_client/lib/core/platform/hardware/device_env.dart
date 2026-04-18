/// 设备环境信息
class DeviceEnv {
  final String cpuArch;           // 'arm64', 'x86_64'
  final int cpuCores;
  final int totalMemoryMB;
  final int? gpuMemoryMB;         // macOS统一内存 / Windows显存
  final bool isMetalAvailable;     // Metal可用性（macOS/iOS）
  final bool isCudaAvailable;      // CUDA可用性（Windows）
  final int cudaDeviceCount;       // CUDA设备数量
  final String? gpuName;           // GPU型号
  final String? cudaVersion;       // CUDA版本
  final String? metalVersion;      // Metal版本

  const DeviceEnv({
    required this.cpuArch,
    required this.cpuCores,
    required this.totalMemoryMB,
    this.gpuMemoryMB,
    this.isMetalAvailable = false,
    this.isCudaAvailable = false,
    this.cudaDeviceCount = 0,
    this.gpuName,
    this.cudaVersion,
    this.metalVersion,
  });

  /// 可用内存（预留30%系统内存）
  int get availableMemoryMB => (totalMemoryMB * 0.7).toInt();

  /// 是否支持GPU加速
  bool get supportsGpuAcceleration => isMetalAvailable || isCudaAvailable;

  /// GPU内存（含统一内存）
  int get effectiveGpuMemoryMB {
    if (isMetalAvailable) {
      // macOS统一内存架构：可用内存 + GPU内存
      return availableMemoryMB + (gpuMemoryMB ?? 0);
    } else if (isCudaAvailable) {
      // Windows：专用显存
      return gpuMemoryMB ?? 0;
    }
    return 0;
  }

  /// 从JSON创建
  factory DeviceEnv.fromJson(Map<String, dynamic> json) {
    return DeviceEnv(
      cpuArch: json['cpuArch'] as String? ?? 'unknown',
      cpuCores: json['cpuCores'] as int? ?? 1,
      totalMemoryMB: json['totalMemoryMB'] as int? ?? 0,
      gpuMemoryMB: json['gpuMemoryMB'] as int?,
      isMetalAvailable: json['isMetalAvailable'] as bool? ?? false,
      isCudaAvailable: json['isCudaAvailable'] as bool? ?? false,
      cudaDeviceCount: json['cudaDeviceCount'] as int? ?? 0,
      gpuName: json['gpuName'] as String?,
      cudaVersion: json['cudaVersion'] as String?,
      metalVersion: json['metalVersion'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'cpuArch': cpuArch,
      'cpuCores': cpuCores,
      'totalMemoryMB': totalMemoryMB,
      'gpuMemoryMB': gpuMemoryMB,
      'isMetalAvailable': isMetalAvailable,
      'isCudaAvailable': isCudaAvailable,
      'cudaDeviceCount': cudaDeviceCount,
      'gpuName': gpuName,
      'cudaVersion': cudaVersion,
      'metalVersion': metalVersion,
    };
  }

  @override
  String toString() {
    return 'DeviceEnv(cpuArch: $cpuArch, cores: $cpuCores, mem: ${totalMemoryMB}MB, '
        'gpuMem: ${gpuMemoryMB}MB, metal: $isMetalAvailable, cuda: $isCudaAvailable, '
        'gpuName: $gpuName)';
  }
}
