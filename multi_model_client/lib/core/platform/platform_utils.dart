import 'dart:io';

/// 平台工具类：提供跨平台兼容的默认配置
class PlatformUtils {
  PlatformUtils._();

  /// 根据当前平台返回 Ollama 默认连接地址
  ///
  /// 各平台策略：
  /// - macOS/Windows/Linux 桌面端 → http://localhost:11434
  /// - Android 模拟器 → http://10.0.2.2:11434（10.0.2.2 映射到宿主机）
  /// - Android 真机 → http://10.0.2.2:11434（用户可在设置中改为局域网 IP）
  /// - iOS 模拟器 → http://localhost:11434（模拟器可直接访问宿主机）
  /// - iOS 真机 → http://localhost:11434（用户可在设置中改为局域网 IP）
  static String getDefaultOllamaBaseUrl() {
    if (Platform.isAndroid) {
      // Android 模拟器用 10.0.2.2 访问宿主机
      // 真机用户需要在设置中配置实际局域网 IP
      return 'http://10.0.2.2:11434';
    }
    // macOS / Windows / Linux / iOS
    return 'http://localhost:11434';
  }

  /// 是否为移动平台
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// 是否为桌面平台
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  /// 是否为 Apple 平台
  static bool get isApple => Platform.isMacOS || Platform.isIOS;

  /// 是否支持 Metal（macOS / iOS）
  static bool get supportsMetal => Platform.isMacOS || Platform.isIOS;

  /// 是否支持 CUDA（Windows）
  static bool get supportsCuda => Platform.isWindows;

  /// 获取平台显示名称
  static String get platformName {
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return Platform.operatingSystem;
  }

  /// 获取 Ollama 连接提示（根据平台给出不同建议）
  static String get ollamaConnectionHint {
    if (Platform.isAndroid) {
      return 'Android 设备默认连接模拟器宿主机（10.0.2.2）。'
          '如使用真机，请将地址改为电脑的局域网 IP（如 192.168.1.100）。';
    }
    if (Platform.isIOS) {
      return 'iOS 模拟器可直接使用 localhost。'
          '如使用真机，请将地址改为电脑的局域网 IP（如 192.168.1.100）。';
    }
    return '请确保 Ollama 服务已在本机启动（ollama serve）。';
  }
}
