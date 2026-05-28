// LLM Studio 应用入口
//
// 多平台 AI 助手应用，支持本地大模型推理、多会话管理、
// 知识库 RAG、语音对话等功能。
//
// 支持平台：macOS、iOS、Android、Windows
//
// @author Jianma
// @version 1.0.0
// @version 0.20.0 - 修复启动死锁问题
library;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/chinese_segmenter_service.dart';
import 'core/services/model_download/download_task_manager.dart';
import 'core/services/log_service.dart';
import 'core/services/local_proxy_service.dart';

/// 应用入口函数
///
/// 初始化流程（简化，解决死锁问题）：
/// 1. 绑定 Flutter 框架
/// 2. 初始化中文分词器（不等待，使用懒加载）
/// 3. 初始化设置服务
/// 4. 启动应用
void main() async {
  // ★ Zone 级错误捕获：捕获所有未处理的异步错误
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // ========== 1. 全局异常处理 ==========
    FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('physical key is already pressed')) {
      debugPrint('⚠️ 忽略键盘重复按下错误');
      return;
    }
    // ★ 增强：null check 错误特殊标记，输出完整上下文
    final isNullCheck = details.exceptionAsString().contains('Null check operator');
    if (isNullCheck) {
      debugPrint('🔴🔴🔴 [NullCheck] 检测到 Null check operator 错误 🔴🔴🔴');
      debugPrint('🔴 [NullCheck] 异常: ${details.exception}');
      debugPrint('🔴 [NullCheck] 库: ${details.library}');
      debugPrint('🔴 [NullCheck] 上下文: ${details.context}');
      debugPrint('🔴 [NullCheck] 堆栈:\n${details.stack}');
      debugPrint('🔴🔴🔴 [NullCheck] 结束 🔴🔴🔴');
    } else {
      debugPrint('⚠️ FlutterError: ${details.exceptionAsString()}');
      debugPrint('⚠️ FlutterError stack: ${details.stack}');
    }
  };
  
    PlatformDispatcher.instance.onError = (error, stack) {
    final isNullCheck = error.toString().contains('Null check operator');
    if (isNullCheck) {
      debugPrint('🔴🔴🔴 [PlatformNullCheck] Null check operator 错误 🔴🔴🔴');
      debugPrint('🔴 [PlatformNullCheck] 异常: $error');
      debugPrint('🔴 [PlatformNullCheck] 堆栈:\n$stack');
      debugPrint('🔴🔴🔴 [PlatformNullCheck] 结束 🔴🔴🔴');
    } else {
      debugPrint('⚠️ PlatformDispatcherError: $error');
      debugPrint('⚠️ PlatformDispatcher stack: $stack');
    }
    return true;
  };
  
    // ========== 2. 初始化设置服务（最优先）==========
    debugPrint('[main] 开始初始化设置服务...');
    final settingsService = SettingsService();
    await settingsService.initialize();
    debugPrint('[main] ✅ SettingsService 已初始化');
    
    // ========== 3. 初始化 DownloadTaskManager（不等待）==========
    debugPrint('[main] 启动 DownloadTaskManager 初始化...');
    DownloadTaskManager.instance.initialize().catchError((e) {
      debugPrint('[main] ⚠️ DownloadTaskManager 初始化失败: $e');
    });
    debugPrint('[main] ✅ DownloadTaskManager 已启动');
    
    // ========== 4. 初始化中文分词器（后台异步，不阻塞启动）==========
    debugPrint('[main] 启动中文分词器（后台）...');
    ChineseSegmenterService.init().catchError((e) {
      debugPrint('[main] ⚠️ 中文分词器初始化失败: $e');
    });
    debugPrint('[main] ✅ 中文分词器已启动（异步）');
    
    // ========== 5. 尝试初始化日志服务（失败不阻塞）==========
    try {
      await LogService.instance.initialize();
      debugPrint('[main] ✅ LogService 已初始化');
    } catch (e) {
      debugPrint('[main] ⚠️ LogService 初始化失败（跳过）: $e');
    }
    
    // ========== 6. 启动本地代理服务（后台，失败不阻塞）==========
    debugPrint('[main] 启动本地代理服务...');
    localProxyService.start().then((url) {
      if (url != null) {
        debugPrint('[main] ✅ 本地代理已启动: $url');
      } else {
        debugPrint('[main] ⚠️ 本地代理启动失败');
      }
    }).catchError((e) {
      debugPrint('[main] ⚠️ 本地代理启动异常: $e');
    });
    
    // ========== 7. 启动应用 ==========
    debugPrint('[main] 🚀 启动应用...');
    runApp(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWithValue(settingsService),
        ],
        child: const App(),
      ),
    );
  }, (error, stack) {
    // Zone 级错误处理：捕获 FlutterError.onError 和 PlatformDispatcher 之外的错误
    final isNullCheck = error.toString().contains('Null check operator');
    if (isNullCheck) {
      debugPrint('🔴🔴🔴 [ZoneNullCheck] Zone 级 Null check operator 错误 🔴🔴🔴');
      debugPrint('🔴 [ZoneNullCheck] 异常: $error');
      debugPrint('🔴 [ZoneNullCheck] 堆栈:\n$stack');
      debugPrint('🔴🔴🔴 [ZoneNullCheck] 结束 🔴🔴🔴');
    } else {
      debugPrint('⚠️ [Zone] 未处理异常: $error');
      debugPrint('⚠️ [Zone] 堆栈: $stack');
    }
  });
}