/// 文件解析服务 - LLM Studio 文档处理模块
/// 
/// 功能：
/// - 多格式文档解析（TXT/MD/PDF/DOCX）
/// - 文本内容提取
/// - 文档分块处理
/// - 编码自动检测
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as spdf;
import 'package:pdfx/pdfx.dart';
import 'ocr_service.dart';

/// 文件解析服务 - 从各种文档格式提取文本内容
class FileParserService {
  /// 解析文件并返回文本内容
  static Future<String> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final extension = p.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.txt':
        return _parseTxt(file);
      case '.md':
      case '.markdown':
        return _parseMarkdown(file);
      case '.pdf':
        return _parsePdf(file);
      case '.ppt':
      case '.pptx':
        return _parsePpt(file);
      case '.doc':
      case '.docx':
        return _parseDoc(file);
      case '.html':
      case '.htm':
        return _parseHtml(file);
      case '.json':
        return _parseJson(file);
      case '.csv':
        return _parseCsv(file);
      case '.xlsx':
      case '.xls':
        return _parseXlsx(file);
      case '.xmind':
        return _parseXmind(file);
      // 图片文件：直接调用本地 OCR 识别文字
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.bmp':
      case '.tiff':
      case '.tif':
      case '.webp':
        return _parseImageWithOcr(file);
      default:
        // 尝试作为纯文本处理
        try {
          return await file.readAsString();
        } catch (e) {
          throw Exception('不支持的文件格式: $extension');
        }
    }
  }

  /// 解析图片文件（使用本地 OCR 识别文字）
  static Future<String> _parseImageWithOcr(File file) async {
    debugPrint('[FileParserService] 图片文件 OCR 识别: ${file.path}');
    try {
      final ocrService = OcrService();
      final text = await ocrService.recognizeImage(file.path);
      if (text.isEmpty) {
        return '【图片未识别到文字】\n\n可能原因：图片中无文字，或文字清晰度不够。';
      }
      debugPrint('[FileParserService] 图片 OCR 完成，字符数: ${text.length}');
      return text;
    } catch (e) {
      debugPrint('[FileParserService] 图片 OCR 失败: $e');
      return '【图片 OCR 识别失败】\n\n错误: $e';
    }
  }

  /// 解析 TXT 文件
  static Future<String> _parseTxt(File file) async {
    return await file.readAsString();
  }

  /// 解析 Markdown 文件（简单处理，保留文本内容）
  static Future<String> _parseMarkdown(File file) async {
    final content = await file.readAsString();
    // 简单处理：移除常见 Markdown 语法
    return content
        .replaceAll(RegExp(r'#{1,6}\s+'), '')
        .replaceAll(RegExp(r'\*{1,2}'), '')
        .replaceAll(RegExp(r'_{1,2}'), '')
        .replaceAll(RegExp(r'`{1,3}'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), '')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^>.*$', multiLine: true), '')
        .replaceAll(RegExp(r'---+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// 解析 PDF 文件（重写版：使用 syncfusion_flutter_pdf 优先提取文本）
  ///
  /// 流程：
  /// 1. 优先用 syncfusion_flutter_pdf 原生提取（支持压缩流、多种编码）
  /// 2. 提取成功且有足够文本 → 清理后返回
  /// 3. 文本极少（< 每页 50 字符）→ 降级为 pdfx + Tesseract OCR
  /// 4. OCR 仍无结果 → 返回原始提取结果或报错
  static Future<String> _parsePdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      debugPrint('[FileParserService] PDF 文件大小: ${bytes.length} bytes');

      // === 第一步：用 syncfusion_flutter_pdf 提取文本（最可靠方案）===
      debugPrint('[FileParserService] [PDF] 步骤1: 使用 syncfusion_flutter_pdf 提取文本...');
      String textResult = '';
      int pageCount = 0;

      try {
        final spdfDocument = spdf.PdfDocument(inputBytes: bytes);
        pageCount = spdfDocument.pages.count;
        debugPrint('[FileParserService] [PDF] 检测到 $pageCount 页');

        // 使用 PdfTextExtractor 逐页提取，每页单独记录日志
        final extractor = spdf.PdfTextExtractor(spdfDocument);
        final textExtractorResults = <String>[];
        int pageWithText = 0;

        // 限制最多处理 50 页（避免超大 PDF 超时）
        final maxPages = pageCount > 50 ? 50 : pageCount;
        for (int i = 0; i < maxPages; i++) {
          final pageIndex = i + 1; // 1-based for display
          try {
            final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
            final trimmedText = pageText.trim();
            textExtractorResults.add(trimmedText);

            if (trimmedText.isNotEmpty) {
              pageWithText++;
              // ✅ 按页输出提取到的文本片段（chunk 日志）
              final preview = trimmedText.length > 200
                  ? '${trimmedText.substring(0, 200)}...'
                  : trimmedText;
              debugPrint(
                '[FileParserService] [PDF Chunk $pageIndex] 字符数=${trimmedText.length} '
                '内容预览: $preview',
              );
            } else {
              debugPrint('[FileParserService] [PDF Chunk $pageIndex] (空白页)');
            }
          } catch (e) {
            debugPrint('[FileParserService] [PDF Chunk $pageIndex] 提取失败: $e');
          }
        }

        textResult = textExtractorResults.join('\n\n');

        // 计算统计信息
        final avgCharsPerPage = pageCount > 0 ? textResult.length / pageCount : 0;
        debugPrint(
          '[FileParserService] [PDF] syncfusion 提取完成: '
          '总字符=${textResult.length}, 有文字页数=$pageWithText/$pageCount, '
          '平均=${avgCharsPerPage.toStringAsFixed(1)} 字符/页',
        );

        spdfDocument.dispose();
      } catch (e) {
        debugPrint('[FileParserService] [PDF] syncfusion 提取失败: $e，将尝试降级方案');
      }

      // === 第二步：判断是否需要降级 OCR ===
      // 如果提取到的文本极少（< 50 字符/页），说明可能是扫描版 PDF
      final avgCharsPerPage =
          pageCount > 0 ? textResult.length / pageCount : textResult.length;

      if (avgCharsPerPage >= 50 && _isReadableText(textResult)) {
        // ✅ 纯文本 PDF，提取成功
        debugPrint('[FileParserService] [PDF] 判断为纯文本 PDF，清理后返回');
        return _cleanPdfText(textResult);
      }

      // === 第三步：降级为 pdfx + Tesseract OCR ===
      debugPrint(
        '[FileParserService] [PDF] 文本量不足（$avgCharsPerPage 字符/页），'
        '降级为 pdfx + OCR...',
      );

      try {
        final ocrResult = await _parsePdfWithOcr(file.path);
        if (ocrResult.trim().length > textResult.length) {
          debugPrint('[FileParserService] [PDF] OCR 结果更完整，使用 OCR 结果');
          return _cleanPdfText(ocrResult);
        }
        debugPrint('[FileParserService] [PDF] OCR 结果不如文本提取，保留文本提取结果');
      } catch (e) {
        debugPrint('[FileParserService] [PDF] OCR 降级失败: $e');
      }

      // === 第四步：返回结果 ===
      if (textResult.trim().length >= 10) {
        debugPrint(
          '[FileParserService] [PDF] 最终返回 syncfusion 文本提取结果，'
          '字符数=${textResult.length}',
        );
        return _cleanPdfText(textResult);
      }

      return '【PDF 文件无法解析文本内容】\n\n'
          '该 PDF 可能是：\n'
          '1. 扫描版/图片版 PDF 且 OCR 识别失败\n'
          '2. 加密的 PDF（需要密码解锁）\n'
          '3. 特殊编码的 PDF\n\n'
          '建议：使用系统"预览"应用打开并"另存为"文本，或直接复制文本到 TXT 文件上传。';
    } catch (e) {
      throw Exception('PDF 解析失败: $e');
    }
  }

  /// 快速文本提取（策略一~三合并）
  static String _extractPdfText(Uint8List bytes) {
    final buffer = StringBuffer();
    // 将 PDF 字节转换为 Latin-1 字符串
    final pdfString = String.fromCharCodes(bytes);

    // 策略一：提取 BT...ET 文本块
    final btEtPattern = RegExp(r'BT(.*?)ET', dotAll: true);
    for (final block in btEtPattern.allMatches(pdfString)) {
      final blockContent = block.group(1) ?? '';

      // (text) Tj 格式
      for (final m in RegExp(r'\(([^)\\]*(?:\\.[^)\\]*)*)\)\s*Tj', dotAll: true).allMatches(blockContent)) {
        final text = _decodePdfString(m.group(1) ?? '');
        if (text.isNotEmpty) { buffer.write(text); buffer.write(' '); }
      }

      // [(text)] TJ 格式（数组）
      for (final m in RegExp(r'\[([^\]]*)\]\s*TJ', dotAll: true).allMatches(blockContent)) {
        final arrayContent = m.group(1) ?? '';
        for (final s in RegExp(r'\(([^)\\]*(?:\\.[^)\\]*)*)\)', dotAll: true).allMatches(arrayContent)) {
          final text = _decodePdfString(s.group(1) ?? '');
          if (text.isNotEmpty) buffer.write(text);
        }
        buffer.write(' ');
      }
    }

    debugPrint('[FileParserService] 策略一结果: ${buffer.toString().trim().length} 字符');

    // 策略二：全文扫描
    if (buffer.toString().trim().length < 20) {
      buffer.clear();
      for (final m in RegExp(r'\(([^)\\]*(?:\\.[^)\\]*)*)\)\s*T[jJ]', dotAll: true).allMatches(pdfString)) {
        final text = _decodePdfString(m.group(1) ?? '');
        if (text.isNotEmpty && !_isPdfBinaryGarbage(text)) { buffer.write(text); buffer.write(' '); }
      }
      debugPrint('[FileParserService] 策略二结果: ${buffer.toString().trim().length} 字符');
    }

    // 策略三：stream 块
    if (buffer.toString().trim().length < 20) {
      buffer.clear();
      for (final m in RegExp(r'stream\r?\n(.*?)\r?\nendstream', dotAll: true).allMatches(pdfString)) {
        final streamContent = m.group(1) ?? '';
        for (final t in RegExp(r'\(([^)]{1,200})\)\s*Tj').allMatches(streamContent)) {
          final text = _decodePdfString(t.group(1) ?? '');
          if (text.isNotEmpty && !_isPdfBinaryGarbage(text)) { buffer.write(text); buffer.write(' '); }
        }
      }
      debugPrint('[FileParserService] 策略三结果: ${buffer.toString().trim().length} 字符');
    }

    return buffer.toString().trim();
  }

  /// 判断文本是否是可读文本（而非乱码）
  static bool _isReadableText(String text) {
    if (text.isEmpty) return false;
    // 统计中文字符 + 英文字母数字的比例
    int readableCount = 0;
    for (final r in text.runes) {
      if ((r >= 0x4E00 && r <= 0x9FFF) || // 中文
          (r >= 0x0020 && r <= 0x007E) ||  // ASCII 可打印字符
          (r >= 0x3000 && r <= 0x303F)) {  // CJK 标点
        readableCount++;
      }
    }
    final ratio = readableCount / text.length;
    debugPrint('[FileParserService] 可读字符比例: $ratio');
    return ratio >= 0.6; // 60% 以上是可读字符
  }


  /// 解码 PDF 字符串（处理转义字符和常见编码）
  static String _decodePdfString(String raw) {
    if (raw.isEmpty) return '';

    // 处理 PDF 转义序列
    final result = raw
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\\', '\\')
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAllMapped(RegExp(r'\\(\d{3})'), (match) {
          // 八进制转义 \nnn
          final octal = int.tryParse(match.group(1) ?? '', radix: 8);
          if (octal != null && octal >= 32 && octal < 256) {
            return String.fromCharCode(octal);
          }
          return '';
        });

    // 过滤掉控制字符，保留可打印字符
    return result.runes
        .where((r) => r == 0x0A || r == 0x0D || r == 0x09 || (r >= 0x20 && r < 0xFF))
        .map((r) => String.fromCharCode(r))
        .join();
  }

  /// 检查提取的文本是否是 PDF 二进制垃圾
  static bool _isPdfBinaryGarbage(String text) {
    if (text.isEmpty) return true;
    // 如果大于 70% 是不可打印字符，认为是垃圾数据
    final printableCount = text.runes.where((r) => r >= 0x20 && r < 0xFF).length;
    return printableCount / text.length < 0.3;
  }

  /// 清理 PDF 提取的文本
  static String _cleanPdfText(String text) {
    return text
        // 合并多余的空白
        .replaceAll(RegExp(r' {3,}'), '  ')
        // 修复断行
        .replaceAll(RegExp(r'(\S) \n(\S)'), r'$1$2')
        // 规范化换行
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// 使用 OCR 解析 PDF（将 PDF 页面渲染为图片后识别文字）
  /// 
  /// 流程：
  /// 1. 使用 pdfx 打开 PDF 文档
  /// 2. 逐页渲染为图片
  /// 3. 使用 Tesseract OCR 识别图片中的文字
  /// 4. 合并所有页的识别结果
  static Future<String> _parsePdfWithOcr(String filePath) async {
    final ocrService = OcrService();
    final buffer = StringBuffer();
    
    try {
      // 打开 PDF 文档
      final document = await PdfDocument.openFile(filePath);
      final pageCount = document.pagesCount;
      
      debugPrint('[FileParserService] PDF OCR: 共 $pageCount 页，开始逐页识别...');
      
      // 限制最多识别 20 页（避免处理过大的 PDF）
      final maxPages = pageCount > 20 ? 20 : pageCount;
      
      for (int i = 1; i <= maxPages; i++) {
        try {
          final page = await document.getPage(i);
          
          // 渲染页面为图片（2x 分辨率以提高 OCR 准确率）
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.png,
            backgroundColor: '#FFFFFF',
          );
          
          if (pageImage != null) {
            // 使用 OCR 识别页面
            final ocrText = await ocrService.recognizePdfPage(
              pageImage.bytes,
              i,
            );
            
            if (ocrText.isNotEmpty) {
              buffer.writeln('--- 第 $i 页 ---');
              buffer.writeln(ocrText);
              buffer.writeln();
            }
          }
          
          await page.close();
        } catch (e) {
          debugPrint('[FileParserService] PDF 第 $i 页渲染/识别失败: $e');
        }
      }
      
      await document.close();
      
      final result = buffer.toString().trim();
      if (result.isEmpty) {
        debugPrint('[FileParserService] PDF OCR 识别无结果');
        return '';
      }
      
      debugPrint('[FileParserService] PDF OCR 完成，总字符数: ${result.length}');
      return result;
    } catch (e) {
      debugPrint('[FileParserService] PDF OCR 流程失败: $e');
      return '';
    }
  }


  /// 解析 PPT/PPTX 文件（使用 archive 手动解析）
  static Future<String> _parsePpt(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final buffer = StringBuffer();
      
      // 查找所有 slide XML 文件
      final slides = archive.files
          .where((f) => f.name.startsWith('ppt/slides/slide') && f.name.endsWith('.xml'))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      
      for (int i = 0; i < slides.length; i++) {
        final slideXml = String.fromCharCodes(slides[i].content as List<int>);
        
        // 简单提取 <a:t> 标签中的文本（PPT 中的文本元素）
        final textMatches = RegExp(r'<a:t>([^<]+)</a:t>').allMatches(slideXml);
        for (final match in textMatches) {
          final text = match.group(1);
          if (text != null && text.isNotEmpty) {
            buffer.writeln(text);
          }
        }
        
        buffer.writeln('\n--- Slide ${i + 1} ---\n');
      }
      
      return buffer.toString().trim();
    } catch (e) {
      throw Exception('PPT 解析失败: $e');
    }
  }

  /// 解析 Word 文件（使用 archive 手动解析）
  static Future<String> _parseDoc(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final buffer = StringBuffer();
      
      // 查找 document.xml 文件
      final docXml = archive.files.firstWhere(
        (f) => f.name == 'word/document.xml',
        orElse: () => throw Exception('Word 文档结构无效'),
      );
      
      final xmlContent = String.fromCharCodes(docXml.content as List<int>);
      
      // 提取所有 <w:t> 标签中的文本
      final textMatches = RegExp(r'<w:t[^>]*>([^<]+)</w:t>').allMatches(xmlContent);
      for (final match in textMatches) {
        final text = match.group(1);
        if (text != null && text.isNotEmpty) {
          buffer.writeln(text);
        }
      }
      
      return buffer.toString().trim();
    } catch (e) {
      throw Exception('Word 解析失败: $e');
    }
  }

  /// 解析 HTML 文件
  static Future<String> _parseHtml(File file) async {
    final content = await file.readAsString();
    // 简单处理：移除 HTML 标签
    return content
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// 解析 JSON 文件
  static Future<String> _parseJson(File file) async {
    // JSON 作为纯文本返回
    return await file.readAsString();
  }

  /// 解析 CSV 文件
  static Future<String> _parseCsv(File file) async {
    final content = await file.readAsString();
    // CSV 转换为易读的文本格式
    final lines = content.split('\n');
    final buffer = StringBuffer();
    
    for (var i = 0; i < lines.length && i < 100; i++) {
      if (lines[i].trim().isNotEmpty) {
        buffer.writeln(lines[i].replaceAll(',', ' | '));
      }
    }
    
    return buffer.toString();
  }

  /// 获取文件类型
  static String getFileType(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    switch (extension) {
      case '.txt':
        return 'txt';
      case '.md':
      case '.markdown':
        return 'md';
      case '.pdf':
        return 'pdf';
      case '.ppt':
      case '.pptx':
        return 'ppt';
      case '.doc':
      case '.docx':
        return 'doc';
      case '.html':
      case '.htm':
        return 'html';
      case '.json':
        return 'json';
      case '.csv':
        return 'csv';
      case '.xlsx':
      case '.xls':
        return 'xlsx';
      case '.xmind':
        return 'xmind';
      default:
        return 'unknown';
    }
  }

  /// 检查文件类型是否支持
  static bool isSupported(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    return ['.txt', '.md', '.markdown', '.pdf', '.ppt', '.pptx', '.doc', '.docx', '.html', '.htm', '.json', '.csv', '.xlsx', '.xls', '.xmind'].contains(extension);
  }

  /// 解析 XLSX 文件（使用 archive 提取 Excel XML）
  static Future<String> _parseXlsx(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final buffer = StringBuffer();

      // 查找 workbook.xml（工作簿）
      final workbookXml = archive.files.firstWhere(
        (f) => f.name == 'xl/workbook.xml',
        orElse: () => throw Exception('Excel 文件结构无效：找不到 workbook.xml'),
      );
      final workbookContent = String.fromCharCodes(workbookXml.content as List<int>);
      
      // 提取工作表名称
      final sheetNames = <String>[];
      final sheetPattern = RegExp(r'<sheet[^>]+name="([^"]+)"', caseSensitive: false);
      for (final match in sheetPattern.allMatches(workbookContent)) {
        sheetNames.add(match.group(1) ?? 'Sheet');
      }

      // 查找 sharedStrings.xml（共享字符串表）
      String? sharedStrings;
      try {
        final ss = archive.files.firstWhere((f) => f.name == 'xl/sharedStrings.xml');
        sharedStrings = String.fromCharCodes(ss.content as List<int>);
      } catch (_) {
        // 没有共享字符串表
      }

      // 解析共享字符串表
      final stringList = <String>[];
      if (sharedStrings != null) {
        final siPattern = RegExp(r'<si>(.*?)</si>', dotAll: true);
        for (final match in siPattern.allMatches(sharedStrings)) {
          final siContent = match.group(1) ?? '';
          // 提取 <t> 标签中的文本
          final tPattern = RegExp(r'<t[^>]*>([^<]*)</t>');
          final textMatches = tPattern.allMatches(siContent);
          final texts = textMatches.map((m) => m.group(1) ?? '').join('');
          if (texts.isNotEmpty) stringList.add(texts);
        }
      }

      // 解析每个工作表的 sheet*.xml
      final sheetFiles = archive.files
          .where((f) => RegExp(r'xl/worksheets/sheet\d+\.xml').hasMatch(f.name))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      for (int i = 0; i < sheetFiles.length && i < 10; i++) {
        final sheetXml = String.fromCharCodes(sheetFiles[i].content as List<int>);
        final sheetName = i < sheetNames.length ? sheetNames[i] : 'Sheet${i + 1}';
        
        buffer.writeln('=== $sheetName ===\n');
        
        // 提取所有单元格值
        final rowPattern = RegExp(r'<row[^>]*r="(\d+)"[^>]*>(.*?)</row>', dotAll: true);
        int lastRow = 0;
        
        for (final rowMatch in rowPattern.allMatches(sheetXml)) {
          final rowNum = int.tryParse(rowMatch.group(1) ?? '') ?? 0;
          final rowContent = rowMatch.group(2) ?? '';
          
          // 跳过空行
          if (rowNum == lastRow) continue;
          lastRow = rowNum;
          
          final cellPattern = RegExp(r'<c[^>]*r="([A-Z]+)(\d+)"[^>]*>(.*?)</c>', dotAll: true);
          final rowData = <String, String>{};
          
          for (final cellMatch in cellPattern.allMatches(rowContent)) {
            final col = cellMatch.group(1) ?? '';
            final cellContent = cellMatch.group(3) ?? '';
            
            String cellValue = '';
            
            // 检查单元格类型
            if (cellContent.contains('<v>')) {
              // 数值类型：直接取 <v> 中的值
              final vPattern = RegExp(r'<v>([^<]*)</v>');
              final vMatch = vPattern.firstMatch(cellContent);
              if (vMatch != null) {
                cellValue = vMatch.group(1) ?? '';
              }
            } else if (cellContent.contains('<t>')) {
              // 内联字符串：取 <t> 中的值
              final tPattern = RegExp(r'<t[^>]*>([^<]*)</t>');
              final tMatch = tPattern.firstMatch(cellContent);
              if (tMatch != null) {
                cellValue = tMatch.group(1) ?? '';
              }
            } else if (cellContent.contains('t="s"')) {
              // 共享字符串：从 stringList 中获取
              final vPattern = RegExp(r'<v>(\d+)</v>');
              final vMatch = vPattern.firstMatch(cellContent);
              if (vMatch != null) {
                final idx = int.tryParse(vMatch.group(1) ?? '');
                if (idx != null && idx < stringList.length) {
                  cellValue = stringList[idx];
                }
              }
            }
            
            if (cellValue.isNotEmpty) {
              rowData[col] = cellValue;
            }
          }
          
          // 按列顺序输出
          if (rowData.isNotEmpty) {
            final sortedCols = rowData.keys.toList()..sort();
            buffer.writeln(sortedCols.map((c) => rowData[c]).join(' | '));
          }
        }
        
        buffer.writeln('\n');
      }

      final result = buffer.toString().trim();
      if (result.isEmpty) {
        throw Exception('Excel 文件为空或无法解析');
      }
      return result;
    } catch (e) {
      throw Exception('XLSX 解析失败: $e');
    }
  }

  /// 解析 XMind 文件（ZIP 解压 + JSON 转 Markdown 树）
  static Future<String> _parseXmind(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      String? contentJson;
      String? contentXml;
      
      // 遍历压缩包内的文件
      for (final f in archive.files) {
        if (f.name == 'content.json') {
          contentJson = utf8.decode(f.content as List<int>);
        } else if (f.name == 'content.xml') {
          contentXml = utf8.decode(f.content as List<int>);
        }
      }
      
      if (contentJson != null) {
        return _parseXmindJson(contentJson);
      } else if (contentXml != null) {
        return _parseXmindXml(contentXml);
      } else {
        throw Exception('XMind 文件结构无效：找不到 content.json 或 content.xml');
      }
    } catch (e) {
      throw Exception('XMind 解析失败: $e');
    }
  }

  /// 解析新版 XMind (content.json)
  static String _parseXmindJson(String jsonContent) {
    try {
      final data = json.decode(jsonContent);
      final buffer = StringBuffer();
      
      // 提取主题信息
      Map<String, dynamic>? rootTopic;
      
      // XMind 2020+ 结构
      if (data is Map && data.containsKey('rootTopic')) {
        rootTopic = data['rootTopic'] as Map<String, dynamic>?;
      } else if (data is List && data.isNotEmpty) {
        // 可能是数组结构
        for (final item in data) {
          if (item is Map && item.containsKey('rootTopic')) {
            rootTopic = item['rootTopic'] as Map<String, dynamic>?;
            break;
          }
        }
      }
      
      if (rootTopic == null) {
        return '【XMind 文件结构无法识别】\n\n$jsonContent';
      }
      
      // 递归解析主题树
      void parseNode(Map<String, dynamic> node, int depth) {
        final indent = '  ' * depth;
        
        // 提取标题
        final title = node['title'] ?? node['text'] ?? '';
        if (title.toString().isNotEmpty) {
          buffer.writeln('$indent- $title');
        }
        
        // 提取批注/笔记
        if (node['notes'] != null) {
          final notes = node['notes'];
          String? notesContent;
          if (notes is Map) {
            notesContent = notes['plain']?['content'] ?? notes['content'];
          }
          if (notesContent != null && notesContent.toString().isNotEmpty) {
            buffer.writeln('$indent  > ${notesContent.toString().trim()}');
          }
        }
        
        // 递归处理子节点
        final children = node['children'];
        if (children != null) {
          List? attached;
          if (children is Map) {
            attached = children['attached'] as List?;
          } else if (children is List) {
            attached = children;
          }
          
          if (attached != null) {
            for (final child in attached) {
              if (child is Map<String, dynamic>) {
                parseNode(child, depth + 1);
              }
            }
          }
        }
      }
      
      parseNode(rootTopic, 0);
      
      final result = buffer.toString().trim();
      if (result.isEmpty) {
        return '【XMind 文件为空】';
      }
      return '📊 思维导图结构：\n\n$result';
    } catch (e) {
      return '【XMind JSON 解析失败】\n\n错误: $e\n\n原始内容:\n$jsonContent';
    }
  }

  /// 解析老版 XMind (content.xml)
  static String _parseXmindXml(String xmlContent) {
    try {
      final buffer = StringBuffer();
      
      // 提取所有主题
      final topicPattern = RegExp(r'<topic[^>]*text="([^"]*)"[^>]*>(.*?)</topic>', dotAll: true);
      
      // 简单解析：提取所有 topic 的 text 属性
      // 实际生产中需要更复杂的 XML 解析来处理层级
      final topics = topicPattern.allMatches(xmlContent);
      
      for (final match in topics) {
        final text = match.group(1);
        if (text != null && text.isNotEmpty) {
          buffer.writeln('- $text');
        }
      }
      
      final result = buffer.toString().trim();
      if (result.isEmpty) {
        return '【XMind XML 内容为空】';
      }
      return '📊 思维导图结构：\n\n$result';
    } catch (e) {
      return '【XMind XML 解析失败】\n\n错误: $e';
    }
  }

  /// 将文本分块（改进版）
  /// 支持中英文混合文本，智能分块
  /// 
  /// 参数：
  /// - maxChunkSize: 最大分块大小（字符数），默认 500
  /// - overlap: 分块重叠大小（字符数），默认 50
  /// - minChunkSize: 最小分块大小，默认 100
  static List<String> chunkText(
    String text, {
    int maxChunkSize = 500,
    int overlap = 50,
    int minChunkSize = 100,
  }) {
    if (text.isEmpty) return [];

    final chunks = <String>[];
    
    // 预处理：规范化换行符
    final normalizedText = text.replaceAll(RegExp(r'\r\n?'), '\n');
    
    // 按段落分割（支持中英文段落标记）
    var paragraphs = normalizedText.split(RegExp(r'\n{2,}'));
    paragraphs = paragraphs.where((p) => p.trim().isNotEmpty).toList();
    
    debugPrint('[FileParserService] chunkText: 原始段落数 = ${paragraphs.length}');
    
    // ===== 策略一：正常按段落分块 =====
    if (paragraphs.length > 1) {
      debugPrint('[FileParserService] chunkText: 使用策略一（按段落分块）');
      String currentChunk = '';
      
      for (final paragraph in paragraphs) {
        final trimmed = paragraph.trim();
        if (trimmed.isEmpty) continue;
        
        if (trimmed.length > maxChunkSize) {
          // 长段落按句子拆分
          if (currentChunk.isNotEmpty && currentChunk.length >= minChunkSize ~/ 2) {
            chunks.add(currentChunk.trim());
            currentChunk = _getOverlapContent(currentChunk, overlap);
          } else if (currentChunk.isNotEmpty) {
            currentChunk += '\n\n';
          }
          
          final sentences = _splitIntoSentences(trimmed);
          String tempChunk = currentChunk;
          
          for (final sentence in sentences) {
            final newChunk = tempChunk + sentence;
            
            if (newChunk.length > maxChunkSize && tempChunk.length >= minChunkSize ~/ 2) {
              chunks.add(tempChunk.trim());
              tempChunk = _getOverlapContent(tempChunk, overlap) + sentence;
            } else {
              tempChunk = newChunk;
            }
          }
          
          currentChunk = tempChunk;
        } else if ((currentChunk + '\n\n' + trimmed).length > maxChunkSize) {
          if (currentChunk.isNotEmpty && currentChunk.length >= minChunkSize ~/ 2) {
            chunks.add(currentChunk.trim());
            currentChunk = _getOverlapContent(currentChunk, overlap) + '\n\n' + trimmed;
          } else {
            currentChunk = currentChunk.isEmpty ? trimmed : currentChunk + '\n\n' + trimmed;
          }
        } else {
          currentChunk = currentChunk.isEmpty ? trimmed : currentChunk + '\n\n' + trimmed;
        }
      }
      
      if (currentChunk.isNotEmpty && currentChunk.length >= minChunkSize ~/ 3) {
        chunks.add(currentChunk.trim());
      }
      
      if (chunks.length > 1) {
        debugPrint('[FileParserService] chunkText: 策略一成功，生成了 ${chunks.length} 个块');
        return chunks.where((c) => c.trim().isNotEmpty).toList();
      }
      
      // 策略一失败，清空重新尝试
      chunks.clear();
    }
    
    // ===== 策略二：只有一个超长段落，按句子分块 =====
    final singleText = paragraphs.isNotEmpty ? paragraphs.first : normalizedText;
    debugPrint('[FileParserService] chunkText: 策略二，单段落长度 = ${singleText.length}');
    
    if (singleText.length > maxChunkSize) {
      final sentences = _splitIntoSentences(singleText);
      debugPrint('[FileParserService] chunkText: 策略二，句子数 = ${sentences.length}');
      
      if (sentences.length > 1) {
        String currentChunk = '';
        for (final sentence in sentences) {
          final trimmed = sentence.trim();
          if (trimmed.isEmpty) continue;
          
          if ((currentChunk + trimmed).length > maxChunkSize && currentChunk.isNotEmpty) {
            if (currentChunk.length >= minChunkSize ~/ 3) {
              chunks.add(currentChunk.trim());
            }
            currentChunk = _getOverlapContent(currentChunk, overlap) + trimmed;
          } else {
            currentChunk = currentChunk.isEmpty ? trimmed : currentChunk + trimmed;
          }
        }
        
        if (currentChunk.isNotEmpty && currentChunk.length >= minChunkSize ~/ 3) {
          chunks.add(currentChunk.trim());
        }
        
        if (chunks.length > 1) {
          debugPrint('[FileParserService] chunkText: 策略二成功，生成了 ${chunks.length} 个块');
          return chunks.where((c) => c.trim().isNotEmpty).toList();
        }
        
        chunks.clear();
      }
    }
    
    // ===== 策略三：按固定长度强制拆分（无句子边界） =====
    debugPrint('[FileParserService] chunkText: 策略三，强制按固定长度拆分');
    final fixedChunks = _chunkByFixedLength(singleText, maxChunkSize, overlap);
    debugPrint('[FileParserService] chunkText: 策略三，生成了 ${fixedChunks.length} 个块');
    
    return fixedChunks;
  }
  
  /// 按固定长度强制拆分（无句子边界时的降级策略）
  static List<String> _chunkByFixedLength(
    String text, 
    int maxChunkSize, 
    int overlap,
  ) {
    final chunks = <String>[];
    if (text.isEmpty) return chunks;
    
    int start = 0;
    while (start < text.length) {
      int end = start + maxChunkSize;
      if (end > text.length) end = text.length;
      
      String chunk = text.substring(start, end).trim();
      
      // 尝试在句子边界处截断
      final lastSentenceEnd = chunk.lastIndexOf(RegExp(r'[。！？.!?]'));
      if (lastSentenceEnd > maxChunkSize ~/ 2 && lastSentenceEnd < chunk.length - 10) {
        chunk = chunk.substring(0, lastSentenceEnd + 1).trim();
        start = start + lastSentenceEnd + 1;
      } else {
        // 在单词边界处截断（中文按字符）
        start = end;
      }
      
      if (chunk.isNotEmpty) {
        chunks.add(chunk);
      }
      
      // 重叠处理
      if (start < text.length) {
        start -= overlap;
        if (start < 0) start = 0;
      }
    }
    
    return chunks.where((c) => c.trim().isNotEmpty).toList();
  }
  
  /// 按句子分割文本（支持中英文）
  static List<String> _splitIntoSentences(String text) {
    // 中英文句子分隔符
    final sentences = text.split(RegExp(r'(?<=[。！？.!?])\s*'));
    return sentences.where((s) => s.trim().isNotEmpty).toList();
  }
  
  /// 获取重叠内容
  static String _getOverlapContent(String text, int overlap) {
    if (text.length <= overlap) return text;
    
    // 尝试在句子边界处截断
    final lastSentenceEnd = text.lastIndexOf(RegExp(r'[。！？.!?]'), text.length - overlap);
    if (lastSentenceEnd > text.length - overlap * 2) {
      return text.substring(lastSentenceEnd + 1).trim();
    }
    
    return text.substring(text.length - overlap);
  }
}