/// OCR 服务 - LLM Studio 文字识别模块
///
/// 功能：
/// - Tesseract OCR 引擎集成
/// - PDF 页面渲染为图片后 OCR 识别
/// - 图片 OCR 识别
/// - 多语言支持（中英文）
///
/// @author Jianma
/// @version 1.0.0
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// OCR 识别服务
class OcrService {
  /// 单例
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  /// 是否已初始化
  bool _initialized = false;

  /// Tesseract 语言数据文件列表
  static const List<String> _languageFiles = [
    'chi_sim.traineddata',  // 简体中文
    'eng.traineddata',      // 英文
  ];

  /// 初始化 OCR 引擎
  /// 将 assets 中的语言数据复制到本地沙盒目录
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tessDataDir = Directory(p.join(appDir.path, 'tessdata'));
      
      if (!await tessDataDir.exists()) {
        await tessDataDir.create(recursive: true);
        debugPrint('[OcrService] 创建 tessdata 目录: ${tessDataDir.path}');
      }

      // 检查语言数据是否已存在，不存在则从 assets 复制
      for (final langFile in _languageFiles) {
        final destFile = File(p.join(tessDataDir.path, langFile));
        
        if (!await destFile.exists()) {
          try {
            // 从 assets 读取并复制到沙盒
            final ByteData assetData = await rootBundle.load('assets/ocr/tessdata/$langFile');
            final Uint8List bytes = assetData.buffer.asUint8List();
            await destFile.writeAsBytes(bytes);
            debugPrint('[OcrService] 已复制语言数据: $langFile (${bytes.length} bytes)');
          } catch (e) {
            debugPrint('[OcrService] 复制语言数据失败: $langFile, 错误: $e');
          }
        } else {
          debugPrint('[OcrService] 语言数据已存在: $langFile');
        }
      }

      // 验证语言数据是否就绪
      final chiSimFile = File(p.join(tessDataDir.path, 'chi_sim.traineddata'));
      final engFile = File(p.join(tessDataDir.path, 'eng.traineddata'));

      if (await chiSimFile.exists() && await engFile.exists()) {
        debugPrint('[OcrService] Tesseract 语言数据已就绪: ${tessDataDir.path}');
      } else {
        debugPrint('[OcrService] 警告: 部分语言数据文件缺失');
      }

      _initialized = true;
    } catch (e) {
      debugPrint('[OcrService] 初始化失败: $e');
    }
  }

  /// 识别图片中的文字
  /// 
  /// 参数：
  /// - imagePath: 图片文件路径
  /// - language: 语言代码，默认 chi_sim+eng（中文简体+英文）
  Future<String> recognizeImage(String imagePath, {String language = 'chi_sim+eng'}) async {
    try {
      // 确保已初始化
      await initialize();

      // 检查文件是否存在
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('图片文件不存在: $imagePath');
      }

      debugPrint('[OcrService] 开始识别图片: $imagePath, 语言: $language');

      final result = await FlutterTesseractOcr.extractText(
        imagePath,
        language: language,
        args: {
          '--psm': '6',  // 假设统一文本块
          '--oem': '3',  // LSTM + 传统 OCR
        },
      );

      debugPrint('[OcrService] OCR 识别完成，结果长度: ${result.length}');
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
  Future<String> recognizeBytes(Uint8List imageBytes, {String language = 'chi_sim+eng'}) async {
    try {
      await initialize();

      // 将字节写入临时文件（Tesseract 需要文件路径）
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'ocr_temp_${DateTime.now().millisecondsSinceEpoch}.png'));
      await tempFile.writeAsBytes(imageBytes);

      final result = await recognizeImage(tempFile.path, language: language);

      // 清理临时文件
      try {
        await tempFile.delete();
      } catch (_) {}

      return result;
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

  /// 检查 OCR 是否可用（语言数据是否已配置）
  Future<bool> isAvailable() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tessDataDir = Directory(p.join(appDir.path, 'tessdata'));
      
      if (!await tessDataDir.exists()) return false;
      
      final chiSimFile = File(p.join(tessDataDir.path, 'chi_sim.traineddata'));
      final engFile = File(p.join(tessDataDir.path, 'eng.traineddata'));
      
      return await chiSimFile.exists() && await engFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// 获取语言数据目录路径
  Future<String> getTessDataPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'tessdata');
  }
}