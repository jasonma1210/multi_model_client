import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// macOS 沙盒环境下安全作用域书签服务
///
/// 在 macOS 沙盒中，通过 FilePicker 选择的外部目录权限是临时的。
/// 使用 Security-Scoped Bookmark 可以持久化目录访问权限，跨 App 重启有效。
///
/// Windows 不需要此机制（无沙盒限制），但提供统一接口以便跨平台调用。
class SecurityBookmarkService {
  static final SecurityBookmarkService _instance = SecurityBookmarkService._();
  static SecurityBookmarkService get instance => _instance;

  SecurityBookmarkService._();

  static const _channel = MethodChannel('com.multimodel.client/security_bookmark');
  static const _bookmarkPrefsKey = 'security_scoped_bookmarks';

  /// 是否为 macOS 平台（需要书签机制）
  bool get needsBookmark => Platform.isMacOS;

  /// 保存目录的安全作用域书签
  /// 成功返回 true，失败返回 false
  Future<bool> saveBookmark(String dirPath) async {
    if (!needsBookmark) return true;

    try {
      final result = await _channel.invokeMethod('saveBookmark', {'path': dirPath});
      if (result != null && result['success'] == true) {
        final bookmarkData = result['bookmarkData'] as String?;
        if (bookmarkData != null) {
          await _persistBookmark(dirPath, bookmarkData);
          debugPrint('[SecurityBookmark] ✅ 书签已保存: $dirPath');
          return true;
        }
      }
      debugPrint('[SecurityBookmark] ❌ 保存书签失败: ${result?['error']}');
      return false;
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 保存书签异常: $e');
      return false;
    }
  }

  /// 解析书签并开始访问安全作用域资源
  /// 在访问外部文件前调用此方法
  ///
  /// 如果 [dirPath] 本身没有书签，会自动向上搜索父目录的书签。
  /// 例如：用户通过 NSOpenPanel 授权了 `/Users/jianma/models/`，
  /// 则 `/Users/jianma/models/HauhauCS/model-dir` 也能自动获得访问权限。
  Future<bool> startAccessing(String dirPath) async {
    if (!needsBookmark) return true;

    try {
      // 向上搜索：精确匹配 → 父目录 → 更上级目录 ...
      final bookmarkResult = await _findBookmarkForPath(dirPath);
      if (bookmarkResult != null) {
        final (bookmarkData, matchedPath) = bookmarkResult;
        debugPrint('[SecurityBookmark] 🔍 找到书签: 请求=$dirPath, 匹配=$matchedPath');
        final result = await _channel.invokeMethod('resolveBookmark', {
          'bookmarkData': bookmarkData,
        });
        if (result != null && result['success'] == true) {
          final accessGranted = result['accessGranted'] == true;
          debugPrint('[SecurityBookmark] ✅ 书签解析成功，已获得访问权限: $dirPath (accessGranted=$accessGranted)');
          return accessGranted;
        }
        debugPrint('[SecurityBookmark] ⚠️ 书签解析失败: ${result?['error']}');
      }

      // 没有书签或书签解析失败，尝试直接 startAccessing
      final directResult = await _channel.invokeMethod('startAccessing', {'path': dirPath});
      if (directResult == true) {
        debugPrint('[SecurityBookmark] ✅ 直接访问成功: $dirPath');
        return true;
      }

      debugPrint('[SecurityBookmark] ⚠️ 无法获得访问权限: $dirPath（需要重新选择目录）');
      return false;
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 访问异常: $e');
      return false;
    }
  }

  /// 停止访问安全作用域资源
  Future<void> stopAccessing(String dirPath) async {
    if (!needsBookmark) return;

    try {
      await _channel.invokeMethod('stopAccessing', {'path': dirPath});
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 停止访问异常: $e');
    }
  }

  /// 停止所有安全作用域资源访问
  Future<void> stopAllAccessing() async {
    if (!needsBookmark) return;

    try {
      await _channel.invokeMethod('stopAllAccessing');
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 停止所有访问异常: $e');
    }
  }

  /// 为目录保存书签并立即开始访问
  /// 在 FilePicker 选择目录后调用此方法
  Future<bool> grantAccess(String dirPath) async {
    if (!needsBookmark) return true;

    final saved = await saveBookmark(dirPath);
    if (saved) {
      return await startAccessing(dirPath);
    }
    return false;
  }

  /// 使用系统原生面板选择目录并一步创建安全作用域书签
  /// macOS 专用：通过 NSOpenPanel 选择目录，自动创建 Bookmark 并授权
  /// 返回选中的目录路径，未选择返回 null
  Future<String?> pickDirectoryWithBookmark({String dialogTitle = '选择模型下载目录'}) async {
    if (!needsBookmark) {
      // 非 macOS 平台使用 FilePicker
      return await FilePicker.getDirectoryPath(dialogTitle: dialogTitle);
    }

    try {
      final result = await _channel.invokeMethod('pickDirectory');
      if (result == null) return null;

      final path = result['path'] as String?;
      final bookmark = result['bookmark'] as String?;

      if (path != null && bookmark != null) {
        await _persistBookmark(path, bookmark);
        debugPrint('[SecurityBookmark] ✅ NSOpenPanel 选择目录并保存书签: $path');
      }

      return path;
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 选择目录异常: $e');
      return null;
    }
  }

  /// 检查指定路径是否有有效的书签（含父目录搜索）
  Future<bool> hasBookmark(String dirPath) async {
    if (!needsBookmark) return true;
    final result = await _findBookmarkForPath(dirPath);
    return result != null;
  }

  /// 删除指定路径的书签
  Future<void> removeBookmark(String dirPath) async {
    if (!needsBookmark) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_bookmarkPrefsKey);
      if (raw != null) {
        final Map<String, dynamic> bookmarks = jsonDecode(raw);
        bookmarks.remove(dirPath);
        await prefs.setString(_bookmarkPrefsKey, jsonEncode(bookmarks));
        debugPrint('[SecurityBookmark] 🗑️ 书签已删除: $dirPath');
      }
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 删除书签异常: $e');
    }
  }

  /// 持久化书签数据到 SharedPreferences
  Future<void> _persistBookmark(String dirPath, String bookmarkData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_bookmarkPrefsKey);
      Map<String, dynamic> bookmarks = {};
      if (raw != null) {
        bookmarks = jsonDecode(raw);
      }
      bookmarks[dirPath] = bookmarkData;
      await prefs.setString(_bookmarkPrefsKey, jsonEncode(bookmarks));
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 持久化书签异常: $e');
    }
  }

  /// 从 SharedPreferences 读取书签数据（精确路径匹配）
  Future<String?> _loadBookmark(String dirPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_bookmarkPrefsKey);
      if (raw != null) {
        final Map<String, dynamic> bookmarks = jsonDecode(raw);
        return bookmarks[dirPath] as String?;
      }
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 读取书签异常: $e');
    }
    return null;
  }

  /// 向上搜索：为 [dirPath] 查找可用的安全作用域书签
  ///
  /// 先尝试精确匹配 [dirPath]，若无则逐级向上检查父目录，
  /// 直到找到书签或到达根目录。
  ///
  /// 返回 (书签数据, 匹配的目录路径)，未找到返回 null。
  Future<(String, String)?> _findBookmarkForPath(String dirPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_bookmarkPrefsKey);
      if (raw == null) return null;

      final Map<String, dynamic> bookmarks = jsonDecode(raw);
      if (bookmarks.isEmpty) return null;

      // 精确匹配
      if (bookmarks.containsKey(dirPath)) {
        final data = bookmarks[dirPath] as String?;
        if (data != null) return (data, dirPath);
      }

      // 向上搜索父目录
      String current = dirPath;
      while (current.isNotEmpty && current != '/') {
        final lastSlash = current.lastIndexOf('/');
        if (lastSlash <= 0) break;
        current = current.substring(0, lastSlash);

        if (bookmarks.containsKey(current)) {
          final data = bookmarks[current] as String?;
          if (data != null) {
            debugPrint('[SecurityBookmark] 🔍 父目录书签匹配: $current (请求: $dirPath)');
            return (data, current);
          }
        }
      }
    } catch (e) {
      debugPrint('[SecurityBookmark] ❌ 搜索书签异常: $e');
    }
    return null;
  }
}
