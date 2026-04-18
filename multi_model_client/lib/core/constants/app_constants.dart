class AppConstants {
  // App Info
  static const String appName = 'Multi-Model Client';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String sessionBox = 'sessions';
  static const String messageBox = 'messages';
  static const String modelBox = 'models';
  static const String memoryBox = 'memories';
  static const String knowledgeBox = 'knowledge_bases';

  // Cache Keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String defaultModelKey = 'default_model';

  // Limits
  static const int maxContextWindow = 4096;
  static const int maxMemoryCount = 10000;
  static const int maxMessageLength = 100000;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // File Size Limits (in bytes)
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const int maxKnowledgeBaseSize = 1024 * 1024 * 1024; // 1GB
}
