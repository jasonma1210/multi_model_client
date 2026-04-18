/// LLM Studio 应用入口
/// 
/// 多平台 AI 助手应用，支持本地大模型推理、多会话管理、
/// 知识库 RAG、语音对话等功能。
/// 
/// 支持平台：macOS、iOS、Android、Windows
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/chinese_segmenter_service.dart';
import 'core/services/llama_library_loader.dart';

/// 应用入口函数
/// 
/// 初始化流程：
/// 1. 绑定 Flutter 框架
/// 2. 初始化中文分词器（jieba）
/// 3. 初始化设置服务
/// 4. 启动 Riverpod 状态管理
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Workaround: 修复 macOS 模拟器键盘状态 bug
  // Flutter 框架 bug：模拟器在处理 Meta (Command) 键时会重复触发 KeyDown
  // 忽略这个断言错误，不影响实际功能
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('physical key is already pressed')) {
      debugPrint('⚠️ 忽略键盘重复按下错误 (Flutter framework bug)');
      return;
    }
    FlutterError.presentError(details);
  };

  // 初始化中文分词器（jieba）- 使用延迟初始化确保 rootBundle 可用
  // 注意：不再在此处等待初始化完成，而是触发异步初始化
  // 分词器会在首次使用时自动懒加载
  try {
    ChineseSegmenterService.init(); // 异步触发，不阻塞应用启动
    debugPrint('⚡ 已触发 jieba 异步初始化');
  } catch (e) {
    debugPrint('⚠️ 中文分词器初始化失败: $e');
    debugPrint('⚠️ 应用将继续运行，但知识库搜索可能使用简单分词');
  }

  // 初始化 llama.cpp 库加载器（查找动态库路径并缓存）
  // 注意：实际的 Llama.libraryPath 设置在 LocalFFIEngine.loadModel() 时完成
  // 这里只是预查找库路径，加速后续模型加载
  try {
    await LlamaLibraryLoader.instance.init();
    final libAvailable = await LlamaLibraryLoader.instance.isLibraryAvailable();
    if (libAvailable) {
      debugPrint('⚡ llama.cpp 库已就绪');
    } else {
      debugPrint('⚠️ llama.cpp 库未找到，本地模型功能不可用');
    }
  } catch (e) {
    debugPrint('⚠️ llama.cpp 库加载器初始化失败: $e');
  }

  // 初始化 SettingsService
  final settingsService = SettingsService();
  await settingsService.initialize();

  // NOTE: SessionManager、SessionRepository、MessageRepository 均由 Riverpod
  // 按需懒初始化，不在这里手动创建实例，避免产生双重实例和幽灵会话。
  // 首次启动时，若没有任何会话，UI 会在 SessionListPage 的空状态下
  // 引导用户通过「+」按钮手动创建第一个会话并选择模型。

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const App(),
    ),
  );
}
