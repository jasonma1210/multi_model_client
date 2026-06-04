/// 镜像源管理服务
///
/// 职责：
/// 1. 根据当前语言/网络环境自动选择最佳下载源
/// 2. 检测镜像可用性（HEAD 请求）
/// 3. 提供国内/海外镜像切换
///
/// 国内镜像：
/// - modelscope.cn（魔搭社区）
/// - hf-mirror.com（HuggingFace 国内镜像）
///
/// 海外源：
/// - huggingface.co（HuggingFace 官方）
/// - github.com（GitHub Releases）
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 镜像源类型
enum MirrorType {
  /// 自动选择（根据语言/网络检测）
  auto,
  /// 国内镜像（modelscope.cn, hf-mirror.com）
  china,
  /// 海外源（huggingface.co, github.com）
  global,
}

/// 单个镜像源定义
class MirrorSource {
  final String name;
  final String url;
  final MirrorType type;
  final int priority; // 数字越小优先级越高
  final List<String> tags; // 'asr', 'tts', 'gguf', 'sherpa'

  const MirrorSource({
    required this.name,
    required this.url,
    required this.type,
    required this.priority,
    this.tags = const [],
  });
}

/// 镜像管理服务（单例）
class MirrorService {
  MirrorService._();
  static final MirrorService instance = MirrorService._();

  // ── 内置镜像源定义 ──
  static const List<MirrorSource> _builtinMirrors = [
    // ── 国内镜像 ──
    MirrorSource(
      name: 'ModelScope 魔搭',
      url: 'https://modelscope.cn',
      type: MirrorType.china,
      priority: 1,
      tags: ['asr', 'tts', 'gguf'],
    ),
    MirrorSource(
      name: 'HuggingFace 国内镜像',
      url: 'https://hf-mirror.com',
      type: MirrorType.china,
      priority: 2,
      tags: ['asr', 'tts', 'gguf'],
    ),
    // ── 海外源 ──
    MirrorSource(
      name: 'HuggingFace 官方',
      url: 'https://huggingface.co',
      type: MirrorType.global,
      priority: 3,
      tags: ['asr', 'tts', 'gguf'],
    ),
    MirrorSource(
      name: 'GitHub Releases',
      url: 'https://github.com',
      type: MirrorType.global,
      priority: 4,
      tags: ['sherpa', 'llama'],
    ),
  ];

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
  ));

  // 缓存检测结果（URL → 是否可用）
  final Map<String, bool> _availabilityCache = {};
  // 缓存时间戳
  final Map<String, DateTime> _cacheTime = {};
  static const Duration _cacheTTL = Duration(minutes: 30);

  // 用户偏好（null = 自动）
  MirrorType? _userPreference;
  String? _detectedLocale; // 'zh' / 'en'

  // ── 公共 API ──

  /// 获取所有内置镜像源
  List<MirrorSource> get allMirrors => _builtinMirrors;

  /// 设置用户偏好
  void setUserPreference(MirrorType? type) {
    _userPreference = type;
  }

  /// 获取当前偏好
  MirrorType? get userPreference => _userPreference;

  /// 异步检测并返回最佳镜像（用于下载时调用）
  Future<MirrorType> detectBestMirror() async {
    // 1. 用户显式偏好优先
    if (_userPreference != null) return _userPreference!;

    // 2. 根据系统语言判断
    final locale = _detectedLocale ?? await _detectLocale();
    _detectedLocale = locale;

    if (locale == 'zh') {
      return MirrorType.china;
    } else {
      return MirrorType.global;
    }
  }

  /// 根据模型类型与镜像偏好，获取可用的下载 URL 列表
  ///
  /// 逻辑：
  /// 1. 按优先级对镜像排序
  /// 2. 过滤出匹配 tag 的镜像
  /// 3. 优先使用用户偏好的镜像，未设置则使用 detectBestMirror
  /// 4. 过滤出可用的镜像（已缓存或检测通过）
  Future<List<MirrorSource>> getAvailableMirrors({
    required List<String> tags,
    bool preferChina = false,
  }) async {
    // 1. 过滤匹配的镜像
    final candidates = _builtinMirrors.where((m) {
      // 必须包含至少一个 tag
      if (tags.isEmpty) return true;
      return tags.any((t) => m.tags.contains(t));
    }).toList();

    // 2. 按偏好排序
    MirrorType preferred = preferChina
        ? MirrorType.china
        : (_userPreference ?? await detectBestMirror());

    candidates.sort((a, b) {
      // 偏好类型优先
      if (a.type == preferred && b.type != preferred) return -1;
      if (b.type == preferred && a.type != preferred) return 1;
      // 同类型按 priority
      return a.priority.compareTo(b.priority);
    });

    // 3. 过滤可用的
    final available = <MirrorSource>[];
    for (final mirror in candidates) {
      final isAvail = await isMirrorAvailable(mirror.url);
      if (isAvail) {
        available.add(mirror);
      }
    }
    return available;
  }

  /// 检测镜像是否可用
  Future<bool> isMirrorAvailable(String baseUrl) async {
    // 检查缓存
    final cached = _availabilityCache[baseUrl];
    final cacheTime = _cacheTime[baseUrl];
    if (cached != null && cacheTime != null) {
      if (DateTime.now().difference(cacheTime) < _cacheTTL) {
        return cached;
      }
    }

    try {
      final response = await _dio.head<dynamic>(
        baseUrl,
        options: Options(
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      final isAvail = response.statusCode != null && response.statusCode! < 400;
      _availabilityCache[baseUrl] = isAvail;
      _cacheTime[baseUrl] = DateTime.now();
      return isAvail;
    } catch (e) {
      debugPrint('[MirrorService] 检测失败 $baseUrl: $e');
      _availabilityCache[baseUrl] = false;
      _cacheTime[baseUrl] = DateTime.now();
      return false;
    }
  }

  /// 检测系统语言
  Future<String> _detectLocale() async {
    try {
      final locale = Platform.localeName.toLowerCase();
      if (locale.startsWith('zh')) return 'zh';
      return 'en';
    } catch (_) {
      return 'en';
    }
  }

  /// 清除缓存
  void clearCache() {
    _availabilityCache.clear();
    _cacheTime.clear();
  }
}
