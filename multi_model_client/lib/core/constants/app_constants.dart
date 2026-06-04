/// 应用常量定义
/// 用于替代代码中的魔法数字和字符串
library;

/// API 超时常量
class ApiTimeouts {
  ApiTimeouts._();

  static const Duration short = Duration(seconds: 10);
  static const Duration normal = Duration(seconds: 30);
  static const Duration long = Duration(seconds: 60);
  static const Duration download = Duration(minutes: 10);
}

/// 动画时长常量
class AnimationDurations {
  AnimationDurations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// 缓存大小常量
class CacheSizes {
  CacheSizes._();

  static const int maxMessages = 100;
  static const int maxImageCacheMB = 50;
  static const int maxMemoryMB = 512;
}

/// 模型参数常量
class ModelDefaults {
  ModelDefaults._();

  static const int contextLength = 4096;
  static const int maxTokens = 2048;
  static const double temperature = 0.7;
  static const double topP = 0.9;
  static const int topK = 40;
}

/// UI 尺寸常量
class UIDimensions {
  UIDimensions._();

  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
}

/// 语音识别常量
class VoiceConstants {
  VoiceConstants._();

  static const int maxRecordingDurationSec = 30;
  static const int silencePauseDurationSec = 3;
  static const int asrSampleRate = 16000;
  static const double ttsDefaultSpeed = 1.0;
  static const double ttsMinSpeed = 0.5;
  static const double ttsMaxSpeed = 2.0;
}

/// 网络重试常量
class NetworkConstants {
  NetworkConstants._();

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration retryDelayMax = Duration(seconds: 10);
}

/// 存储键常量
class StorageKeys {
  StorageKeys._();

  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String lastModelId = 'last_model_id';
  static const String voiceSettings = 'voice_settings';
  static const String asrProvider = 'asr_provider';
  static const String ttsProvider = 'tts_provider';
}

/// URL 正则表达式常量
class UrlPatterns {
  UrlPatterns._();

  // 抖音
  static final RegExp douyin = RegExp(
    r'(?:https?://)?(?:www\.)?douyin\.com/(?:video/|)/([A-Za-z0-9]+)',
    caseSensitive: false,
  );

  // 小红书
  static final RegExp xiaohongshu = RegExp(
    r'(?:https?://)?(?:www\.)?xiaohongshu\.com/explore/([A-Za-z0-9]+)',
    caseSensitive: false,
  );

  // B站
  static final RegExp bilibili = RegExp(
    r'(?:https?://)?(?:www\.)?bilibili\.com/video/(?:av|AV|BV)([BbAaCcDdEeFfGgHhJjKkLlMmNnPpQqRrSsTtVvWwXxYyZz0-9]+)',
    caseSensitive: false,
  );

  // 通用 URL
  static final RegExp url = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );
}

/// 错误消息常量
class ErrorMessages {
  ErrorMessages._();

  static const String networkError = '网络连接失败，请检查网络设置';
  static const String timeoutError = '请求超时，请稍后重试';
  static const String serverError = '服务器错误，请稍后重试';
  static const String modelNotFound = '未找到指定模型';
  static const String modelLoadFailed = '模型加载失败';
  static const String asrInitFailed = '语音识别初始化失败';
  static const String ttsInitFailed = '语音合成初始化失败';
  static const String permissionDenied = '权限被拒绝';
  static const String fileNotFound = '文件不存在';
  static const String unknownError = '发生未知错误';
}

/// 成功消息常量
class SuccessMessages {
  SuccessMessages._();

  static const String sessionCreated = '会话创建成功';
  static const String sessionDeleted = '会话已删除';
  static const String modelDownloaded = '模型下载完成';
  static const String settingsSaved = '设置已保存';
  static const String exportSuccess = '导出成功';
  static const String importSuccess = '导入成功';
}

/// 平台特定常量
class PlatformConstants {
  PlatformConstants._();

  // iOS
  static const String iosModelDirectory = 'models';
  static const String iosCacheDirectory = 'Library/Caches';

  // Android
  static const String androidModelDirectory = '/data/local/llm';
  static const String androidCacheDirectory = 'cache';

  // 共享首选项键
  static const String spModelConfig = 'model_config';
  static const String spUserPrefs = 'user_preferences';
}