/// OCR 服务 - LLM Studio 文字识别模块（跨平台版本）
///
/// 功能：
/// - 使用 textify 纯 Dart OCR 库
/// - 支持：Android、iOS、macOS、Windows、Linux、Web
/// - 100% 离线，无需网络
/// - PDF 页面渲染为图片后 OCR 识别
/// - 图片 OCR 识别
///
/// @author Jianma
/// @version 4.1.0 (修复 dart:ui Image 类型兼容)
library;

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:textify/textify.dart';

/// OCR 识别服务（跨平台版本 - 使用 textify）
class OcrService {
  /// 单例
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  /// Textify OCR 实例
  Textify? _textify;

  /// 是否已初始化
  bool _initialized = false;

  /// 初始化 OCR 引擎
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 初始化 textify
      _textify = Textify();
      await _textify!.init();
      debugPrint('[OcrService] Textify OCR 已初始化（跨平台）');
      _initialized = true;
    } catch (e) {
      debugPrint('[OcrService] 初始化失败: $e');
    }
  }

  /// 将字节数据转换为 ui.Image
  Future<ui.Image?> _bytesToUiImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      // 获取 image 后立即释放 codec 资源
      final image = frameInfo.image;
      codec.dispose();
      return image;
    } catch (e) {
      debugPrint('[OcrService] 图像转换失败: $e');
      return null;
    }
  }

  /// 识别图片中的文字
  ///
  /// 参数：
  /// - imagePath: 图片文件路径
  /// - language: 语言代码（textify 自动检测）
  Future<String> recognizeImage(String imagePath, {String language = 'auto'}) async {
    try {
      // 确保已初始化
      await initialize();

      // 检查文件是否存在
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('图片文件不存在: $imagePath');
      }

      debugPrint('[OcrService] 开始识别图片: $imagePath');

      // 读取图片文件
      final bytes = await file.readAsBytes();

      // 转换为 ui.Image
      final uiImage = await _bytesToUiImage(bytes);
      if (uiImage == null) {
        throw Exception('无法解码图片: $imagePath');
      }

      // 使用 textify 识别 - 使用 dart:ui Image
      final result = await _textify!.getTextFromImage(
        image: uiImage,
      );

      // 识别完成后释放 ui.Image GPU 资源
      uiImage.dispose();

      debugPrint('[OcrService] OCR 识别完成，字符数: ${result.length}');
      return result.trim();
    } catch (e) {
      debugPrint('[OcrService] OCR 识别失败: $e');
      return '';
    }
  }

  /// 识别图片字节数据中的文字
  ///
  /// 参数：
  /// - imageBytes: 图片字节数据
  /// - language: 语言代码
  Future<String> recognizeBytes(Uint8List imageBytes, {String language = 'auto'}) async {
    try {
      await initialize();

      // 转换为 ui.Image
      final uiImage = await _bytesToUiImage(imageBytes);
      if (uiImage == null) {
        throw Exception('无法解码图片数据');
      }

      // 使用 textify 识别
      final result = await _textify!.getTextFromImage(
        image: uiImage,
      );

      // 识别完成后释放 ui.Image GPU 资源
      uiImage.dispose();

      return result.trim();
    } catch (e) {
      debugPrint('[OcrService] 字节 OCR 识别失败: $e');
      return '';
    }
  }

  /// 识别 PDF 某一页的图片数据
  ///
  /// 参数：
  /// - pageImageBytes: PDF 页面渲染的图片字节数据
  /// - pageNumber: 页码（用于日志）
  Future<String> recognizePdfPage(Uint8List pageImageBytes, int pageNumber) async {
    debugPrint('[OcrService] 开始 OCR 识别第 $pageNumber 页');

    final result = await recognizeBytes(pageImageBytes);

    if (result.isEmpty) {
      debugPrint('[OcrService] 第 $pageNumber 页 OCR 无结果（可能是空白页或图片无法识别）');
    } else {
      debugPrint('[OcrService] 第 $pageNumber 页 OCR 识别完成，字符数: ${result.length}');
    }

    return result;
  }

  /// 检查 OCR 是否可用
  Future<bool> isAvailable() async {
    return _initialized && _textify != null;
  }

  /// 释放资源
  void dispose() {
    _textify?.clear();
    _textify = null;
    _initialized = false;
    debugPrint('[OcrService] 资源已释放');
  }
}