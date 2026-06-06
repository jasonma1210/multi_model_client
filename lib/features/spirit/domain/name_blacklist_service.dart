/// 名灵回响 - 黑名单与昵称映射服务
///
/// 黑名单机制：
/// - Release 版本：内置黑名单，禁止直接使用真人名称
/// - Debug/Test 版本：可配置黑名单，但默认不添加对应人物
/// - 所有对外显示均使用昵称替代真名
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 黑名单条目
class BlacklistEntry {
  final String realName; // 真名（如"杨幂"）
  final String nickname; // 昵称（如"大幂幂"）
  final String? domain; // 领域
  final bool isBuiltin; // 是否内置（不可删除）

  const BlacklistEntry({
    required this.realName,
    required this.nickname,
    this.domain,
    this.isBuiltin = false,
  });

  Map<String, dynamic> toJson() => {
        'realName': realName,
        'nickname': nickname,
        'domain': domain,
        'isBuiltin': isBuiltin,
      };

  factory BlacklistEntry.fromJson(Map<String, dynamic> json) => BlacklistEntry(
        realName: json['realName'] as String,
        nickname: json['nickname'] as String,
        domain: json['domain'] as String?,
        isBuiltin: json['isBuiltin'] as bool? ?? false,
      );
}

/// 黑名单服务
class NameBlacklistService {
  static const String _tag = 'NameBlacklistService';
  static const String _blacklistKey = 'spirit_blacklist_entries';
  static const String _initializedKey = 'spirit_blacklist_initialized';

  /// Release 版本内置黑名单（禁止直接显示真名）
  /// 仅在 release 模式下自动加载
  static const List<BlacklistEntry> _releaseBlacklist = [
    // 演员
    BlacklistEntry(realName: '杨幂', nickname: '大幂幂', domain: '演员', isBuiltin: true),
    BlacklistEntry(realName: '赵丽颖', nickname: '颖宝', domain: '演员', isBuiltin: true),
    BlacklistEntry(realName: '刘亦菲', nickname: '神仙姐姐', domain: '演员', isBuiltin: true),
    BlacklistEntry(realName: '迪丽热巴', nickname: '胖迪', domain: '演员', isBuiltin: true),
    BlacklistEntry(realName: '杨洋', nickname: '洋洋', domain: '演员', isBuiltin: true),
    BlacklistEntry(realName: '肖战', nickname: '战战', domain: '演员', isBuiltin: true),
    BlacklistEntry(realName: '王一博', nickname: '一博', domain: '演员', isBuiltin: true),
    BlacklistEntry(realName: '易烊千玺', nickname: '千禧', domain: '演员', isBuiltin: true),
    // 歌手
    BlacklistEntry(realName: '周杰伦', nickname: '周董', domain: '歌手', isBuiltin: true),
    BlacklistEntry(realName: '林俊杰', nickname: 'JJ', domain: '歌手', isBuiltin: true),
    BlacklistEntry(realName: '邓紫棋', nickname: 'GEM', domain: '歌手', isBuiltin: true),
    BlacklistEntry(realName: '薛之谦', nickname: '老薛', domain: '歌手', isBuiltin: true),
    // 企业家
    BlacklistEntry(realName: '马云', nickname: '马老师', domain: '企业家', isBuiltin: true),
    BlacklistEntry(realName: '马化腾', nickname: '小马哥', domain: '企业家', isBuiltin: true),
    BlacklistEntry(realName: '雷军', nickname: '雷总', domain: '企业家', isBuiltin: true),
    BlacklistEntry(realName: '任正非', nickname: '任总', domain: '企业家', isBuiltin: true),
    // 政治人物（严格禁止）
    BlacklistEntry(realName: '习近平', nickname: '---', domain: '政治', isBuiltin: true),
    BlacklistEntry(realName: '拜登', nickname: '---', domain: '政治', isBuiltin: true),
    BlacklistEntry(realName: '特朗普', nickname: '---', domain: '政治', isBuiltin: true),
  ];

  /// 缓存
  List<BlacklistEntry>? _cachedEntries;

  /// 是否为 Release 模式
  bool get isReleaseMode => !kDebugMode;

  /// 获取所有黑名单条目
  Future<List<BlacklistEntry>> getAllEntries() async {
    if (_cachedEntries != null) return _cachedEntries!;

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_blacklistKey);

    if (jsonStr != null) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedEntries = list
          .map((e) => BlacklistEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // 首次初始化
      await _initializeBlacklist();
      return _cachedEntries ?? [];
    }

    return _cachedEntries!;
  }

  /// 初始化黑名单
  Future<void> _initializeBlacklist() async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(_initializedKey) ?? false;

    List<BlacklistEntry> entries;

    if (!initialized) {
      if (isReleaseMode) {
        // Release 模式：加载内置黑名单
        entries = List.from(_releaseBlacklist);
        debugPrint('[$_tag] Release 模式，加载 ${entries.length} 条内置黑名单');
      } else {
        // Debug/Test 模式：空黑名单，用户可自行配置
        entries = [];
        debugPrint('[$_tag] Debug 模式，黑名单为空，用户可自行配置');
      }
      await _saveEntries(entries);
      await prefs.setBool(_initializedKey, true);
    } else {
      entries = [];
    }

    _cachedEntries = entries;
  }

  /// 检查名称是否在黑名单中
  Future<bool> isBlacklisted(String name) async {
    final entries = await getAllEntries();
    return entries.any((e) => e.realName == name);
  }

  /// 获取昵称替代（如果真名在黑名单中）
  /// 返回 null 表示不在黑名单中
  Future<String?> getNickname(String realName) async {
    final entries = await getAllEntries();
    final entry = entries.where((e) => e.realName == realName).firstOrNull;
    return entry?.nickname;
  }

  /// 将文本中的真名替换为昵称
  Future<String> replaceRealNames(String text) async {
    final entries = await getAllEntries();
    var result = text;
    for (final entry in entries) {
      if (entry.nickname == '---') {
        // 政治人物：完全移除
        result = result.replaceAll(entry.realName, '[已屏蔽]');
      } else {
        result = result.replaceAll(entry.realName, entry.nickname);
      }
    }
    return result;
  }

  /// 添加自定义黑名单条目
  Future<void> addEntry(BlacklistEntry entry) async {
    final entries = await getAllEntries();
    // 检查是否已存在
    if (entries.any((e) => e.realName == entry.realName)) {
      debugPrint('[$_tag] 黑名单已存在: ${entry.realName}');
      return;
    }
    entries.add(entry);
    await _saveEntries(entries);
    debugPrint('[$_tag] 添加黑名单: ${entry.realName} → ${entry.nickname}');
  }

  /// 删除自定义黑名单条目（内置条目不可删除）
  Future<void> removeEntry(String realName) async {
    final entries = await getAllEntries();
    final entry = entries.where((e) => e.realName == realName).firstOrNull;
    if (entry != null && entry.isBuiltin) {
      debugPrint('[$_tag] 内置条目不可删除: $realName');
      return;
    }
    entries.removeWhere((e) => e.realName == realName);
    await _saveEntries(entries);
    debugPrint('[$_tag] 删除黑名单: $realName');
  }

  /// 获取黑名单中的所有真名
  Future<List<String>> getAllRealNames() async {
    final entries = await getAllEntries();
    return entries.map((e) => e.realName).toList();
  }

  /// 验证输入名称是否合规
  /// 返回 (是否合规, 替代昵称或错误信息)
  Future<(bool, String?)> validateName(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return (false, '名称不能为空');
    }

    final entries = await getAllEntries();
    final entry = entries.where((e) => e.realName == trimmed).firstOrNull;

    if (entry == null) {
      // 不在黑名单中，允许使用
      return (true, null);
    }

    if (entry.nickname == '---') {
      // 政治人物：完全禁止
      return (false, '该人物不允许创建名灵');
    }

    // 在黑名单中，返回昵称替代
    return (true, entry.nickname);
  }

  /// 保存条目到持久化
  Future<void> _saveEntries(List<BlacklistEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_blacklistKey, jsonStr);
    _cachedEntries = entries;
  }

  /// 清除缓存（用于测试）
  void clearCache() {
    _cachedEntries = null;
  }

  /// 重置黑名单为默认状态
  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_blacklistKey);
    await prefs.remove(_initializedKey);
    _cachedEntries = null;
    debugPrint('[$_tag] 黑名单已重置');
  }
}
