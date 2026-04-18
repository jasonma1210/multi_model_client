/// 语言区域 Provider - LLM Studio 国际化模块
/// 
/// 功能：
/// - 多语言支持（中/英/日/韩等）
/// - 语言切换状态管理
/// - 系统语言检测
/// - 语言偏好持久化
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported locales - extend as needed
const supportedLocales = [
  Locale('en', 'US'),  // English (US)
  Locale('en', 'GB'),  // English (UK)
  Locale('zh', 'CN'),  // Chinese (Simplified)
  Locale('zh', 'TW'),  // Chinese (Traditional)
  Locale('zh', 'HK'),  // Chinese (Hong Kong)
  Locale('ja', 'JP'),  // Japanese
  Locale('ko', 'KR'),  // Korean
  Locale('fr', 'FR'),  // French
  Locale('de', 'DE'),  // German
  Locale('es', 'ES'),  // Spanish
  Locale('pt', 'BR'),  // Portuguese (Brazil)
  Locale('ru', 'RU'),  // Russian
  Locale('ar', 'SA'),  // Arabic
  Locale('hi', 'IN'),  // Hindi
];

/// Fallback locale when system locale is not supported
const fallbackLocale = Locale('en', 'US');

/// Language provider with system locale detection
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  // Initialize with system locale or fallback
  return LocaleNotifier(_getInitialLocale());
});

/// Get the initial locale based on system settings
Locale _getInitialLocale() {
  try {
    // Get system locale from platform
    final systemLocale = PlatformDispatcher.instance.locale;

    // If system locale is invalid, return fallback
    if (systemLocale.languageCode.isEmpty) {
      return fallbackLocale;
    }

    // Try to find a matching supported locale
    // First try exact match (language + country)
    for (final locale in supportedLocales) {
      if (locale.languageCode == systemLocale.languageCode &&
          locale.countryCode == systemLocale.countryCode) {
        return locale;
      }
    }

    // Then try language-only match
    for (final locale in supportedLocales) {
      if (locale.languageCode == systemLocale.languageCode) {
        return locale;
      }
    }

    // If Chinese variants exist but not exact match, default to Simplified Chinese
    if (systemLocale.languageCode == 'zh') {
      return const Locale('zh', 'CN');
    }

    // Return fallback if no match found
    return fallbackLocale;
  } catch (e) {
    // If any error occurs, return fallback
    return fallbackLocale;
  }
}

/// Get system preferred locales in order
List<Locale> getSystemPreferredLocales() {
  try {
    final platformDispatcher = PlatformDispatcher.instance;
    return platformDispatcher.locales
        .where((locale) => locale.languageCode.isNotEmpty)
        .toList();
  } catch (e) {
    return [fallbackLocale];
  }
}

/// Find the best matching supported locale from a list
Locale findBestMatchingLocale(List<Locale> preferredLocales) {
  for (final preferred in preferredLocales) {
    // Try exact match first
    for (final supported in supportedLocales) {
      if (supported.languageCode == preferred.languageCode &&
          supported.countryCode == preferred.countryCode) {
        return supported;
      }
    }

    // Then try language-only match
    for (final supported in supportedLocales) {
      if (supported.languageCode == preferred.languageCode) {
        // For Chinese, prefer Simplified if user hasn't specified
        if (preferred.languageCode == 'zh') {
          return const Locale('zh', 'CN');
        }
        return supported;
      }
    }
  }

  return fallbackLocale;
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.initialLocale);

  /// Set locale manually
  void setLocale(Locale locale) {
    // Check if locale is supported
    final isSupported = supportedLocales.any(
      (l) => l.languageCode == locale.languageCode &&
             (l.countryCode == locale.countryCode || l.countryCode == null),
    );

    if (isSupported) {
      state = locale;
    } else {
      // Find closest match
      state = findBestMatchingLocale([locale]);
    }
  }

  /// Set locale by language code only
  void setLocaleByLanguageCode(String languageCode) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        state = locale;
        return;
      }
    }
    // Default to English if not found
    state = fallbackLocale;
  }

  /// Toggle between English and Chinese
  void toggleLocale() {
    if (state.languageCode == 'en') {
      state = const Locale('zh', 'CN');
    } else {
      state = const Locale('en', 'US');
    }
  }

  /// Detect and apply system locale
  void detectSystemLocale() {
    final systemLocale = findBestMatchingLocale(getSystemPreferredLocales());
    state = systemLocale;
  }
}

/// Get language display name
String getLanguageName(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return locale.countryCode == 'GB' ? 'English (UK)' : 'English (US)';
    case 'zh':
      switch (locale.countryCode) {
        case 'TW':
        case 'HK':
          return '繁體中文';
        case 'CN':
        default:
          return '简体中文';
      }
    case 'ja':
      return '日本語';
    case 'ko':
      return '한국어';
    case 'fr':
      return 'Français';
    case 'de':
      return 'Deutsch';
    case 'es':
      return 'Español';
    case 'pt':
      return 'Português';
    case 'ru':
      return 'Русский';
    case 'ar':
      return 'العربية';
    case 'hi':
      return 'हिन्दी';
    default:
      return 'English';
  }
}

/// Get all supported languages for settings UI
List<Map<String, dynamic>> getSupportedLanguages() {
  return [
    {'locale': const Locale('en', 'US'), 'name': 'English (US)', 'nativeName': 'English'},
    {'locale': const Locale('en', 'GB'), 'name': 'English (UK)', 'nativeName': 'English'},
    {'locale': const Locale('zh', 'CN'), 'name': 'Chinese Simplified', 'nativeName': '简体中文'},
    {'locale': const Locale('zh', 'TW'), 'name': 'Chinese Traditional', 'nativeName': '繁體中文'},
    {'locale': const Locale('ja', 'JP'), 'name': 'Japanese', 'nativeName': '日本語'},
    {'locale': const Locale('ko', 'KR'), 'name': 'Korean', 'nativeName': '한국어'},
    {'locale': const Locale('fr', 'FR'), 'name': 'French', 'nativeName': 'Français'},
    {'locale': const Locale('de', 'DE'), 'name': 'German', 'nativeName': 'Deutsch'},
    {'locale': const Locale('es', 'ES'), 'name': 'Spanish', 'nativeName': 'Español'},
    {'locale': const Locale('pt', 'BR'), 'name': 'Portuguese', 'nativeName': 'Português'},
    {'locale': const Locale('ru', 'RU'), 'name': 'Russian', 'nativeName': 'Русский'},
  ];
}