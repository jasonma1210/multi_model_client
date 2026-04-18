/// 中文分词服务 - LLM Studio NLP 模块
/// 
/// 功能：
/// - 中文分词处理（jieba 词典分词）
/// - 中英文混合支持
/// - 停用词过滤
/// - 分词结果缓存
/// 
/// @author JianMa
/// @version 2.0.0 (使用 jieba_flutter)
library;

import 'package:flutter/widgets.dart';
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:jieba_flutter/analysis/seg_token.dart';

/// 中文分词服务
/// 使用 jieba 词典分词，支持中英文混合文本
class ChineseSegmenterService {
  static bool _initialized = false;
  static bool _initStarted = false;
  
  /// jieba 分词器实例（延迟初始化）
  static JiebaSegmenter? _jieba;
  
  /// 常用停用词表
  static final Set<String> _stopWords = {
    // 中文停用词
    '的', '了', '在', '是', '我', '有', '和', '就', '不', '人',
    '都', '一', '一个', '上', '也', '很', '到', '说', '要', '去',
    '你', '会', '着', '没有', '看', '好', '自己', '这', '那', '他',
    '她', '它', '们', '这个', '那个', '什么', '怎么', '为什么',
    '哪', '哪里', '谁', '多少', '几', '能', '可以', '应该', '必须',
    '但', '但是', '而', '而且', '或', '或者', '与', '及', '等',
    '对', '对于', '关于', '通过', '根据', '按照', '为了', '因为',
    '所以', '如果', '虽然', '即使', '无论', '不管', '只要', '除非',
    '比', '比较', '更', '最', '非常', '特别', '相当', '太', '真',
    '把', '被', '让', '给', '向', '往', '从', '到', '为', '以',
    '并', '且', '只', '已', '已经', '正在',
    // 英文停用词
    'the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
    'would', 'could', 'should', 'may', 'might', 'must', 'can',
    'this', 'that', 'these', 'those', 'i', 'you', 'he', 'she',
    'it', 'we', 'they', 'what', 'which', 'who', 'when', 'where',
    'why', 'how', 'all', 'each', 'every', 'both', 'few', 'more',
    'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only',
    'own', 'same', 'so', 'than', 'too', 'very', 'just', 'and',
    'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of',
    'at', 'by', 'for', 'with', 'about', 'against', 'between',
    'into', 'through', 'during', 'before', 'after', 'above',
    'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off',
    'over', 'under', 'again', 'further', 'then', 'once',
  };

  /// 初始化分词器（延迟初始化模式）
  /// 由于 jieba 需要使用 rootBundle 加载词典文件，必须在 Flutter 完全初始化后调用
  /// 使用 postFrameCallback 确保在 Flutter 渲染帧之后执行
  static Future<void> init() async {
    // 防止重复初始化
    if (_initialized || _initStarted) {
      debugPrint('[ChineseSegmenterService] 初始化跳过 (已初始化: $_initialized, 已开始: $_initStarted)');
      return;
    }
    
    _initStarted = true;
    debugPrint('[ChineseSegmenterService] 计划延迟初始化 jieba...');
    
    // 使用 postFrameCallback 确保 Flutter 完全初始化后再加载 jieba
    // 这样 rootBundle 才能正常工作
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('[ChineseSegmenterService] Post frame callback 触发');
        await _doInit();
      });
      debugPrint('[ChineseSegmenterService] 已注册 postFrameCallback');
    } catch (e) {
      // 如果无法使用 postFrameCallback（如在测试中），直接初始化
      debugPrint('[ChineseSegmenterService] 无法使用 postFrameCallback，直接初始化: $e');
      await _doInit();
    }
  }
  
  /// 实际执行初始化
  static Future<void> _doInit() async {
    debugPrint('[ChineseSegmenterService] 开始初始化 jieba...');
    
    try {
      // 初始化 jieba 词典（这会使用 rootBundle 加载 assets）
      debugPrint('[ChineseSegmenterService] 调用 JiebaSegmenter.init()...');
      await JiebaSegmenter.init();
      debugPrint('[ChineseSegmenterService] JiebaSegmenter.init() 完成');
      
      // 创建分词器实例
      _jieba = JiebaSegmenter();
      debugPrint('[ChineseSegmenterService] JiebaSegmenter 实例已创建');
      
      _initialized = true;
      
      // 测试分词
      final testResult = _jieba!.process('测试中文分词', SegMode.SEARCH);
      debugPrint('[ChineseSegmenterService] jieba 测试分词结果: $testResult');
      debugPrint('[ChineseSegmenterService] ✅ jieba 分词器初始化成功！');
    } catch (e, stack) {
      // jieba 初始化失败，使用回退方案
      debugPrint('[ChineseSegmenterService] ❌ jieba 初始化失败: $e');
      debugPrint('[ChineseSegmenterService] ❌ 堆栈: $stack');
      debugPrint('[ChineseSegmenterService] 将使用简单分词作为回退方案');
      _initialized = true; // 标记为已初始化（使用回退方案）
    }
  }

  /// 对文本进行分词（自动懒加载初始化）
  /// 返回分词后的词列表
  static List<String> segment(String text) {
    // 懒加载：如果未初始化且未开始，触发异步初始化
    if (!_initialized && !_initStarted) {
      debugPrint('[ChineseSegmenterService] 触发异步初始化 jieba...');
      init(); // 异步初始化，不等待
      // 初始化未完成时使用回退
      debugPrint('[ChineseSegmenterService] ⚠️ 异步初始化已触发，使用简单分词');
      return _fallbackSegment(text);
    }
    
    // 如果正在初始化但未完成，使用回退
    if (_initStarted && !_initialized) {
      debugPrint('[ChineseSegmenterService] ⚠️ 初始化进行中，使用简单分词');
      return _fallbackSegment(text);
    }
    
    // 如果 jieba 实例为空，使用回退方案
    if (_jieba == null) {
      debugPrint('[ChineseSegmenterService] ⚠️ jieba 实例为空，回退到简单分词');
      return _fallbackSegment(text);
    }
    
    try {
      // 使用 jieba 的 SEARCH 模式（更全面的分词，适合搜索）
      final tokens = _jieba!.process(text, SegMode.SEARCH);
      
      // 提取词语（SegToken 有 word 属性）
      final words = <String>[];
      for (final token in tokens) {
        final word = token.word;
        if (word.isNotEmpty) {
          words.add(word);
        }
      }
      
      debugPrint('[ChineseSegmenterService] jieba 分词结果: $words');
      return words;
    } catch (e, stack) {
      debugPrint('[ChineseSegmenterService] ❌ jieba 分词失败: $e');
      debugPrint('[ChineseSegmenterService] ❌ 堆栈: $stack');
      return _fallbackSegment(text);
    }
  }

  /// 简单分词回退方案
  static List<String> _fallbackSegment(String text) {
    final words = <String>[];
    
    // 预处理：清理文本，保留中文、英文、数字
    final cleaned = text.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fff]'), ' ');
    
    // 按空白字符分割
    final tokens = cleaned.split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    
    for (final token in tokens) {
      // 判断是中文还是英文
      if (_isAllChinese(token)) {
        // 中文：使用滑动窗口生成 2-gram 和 3-gram
        words.addAll(_generateChineseNgrams(token));
      } else if (_isAllEnglish(token)) {
        // 英文：直接添加，转小写
        words.add(token.toLowerCase());
      } else {
        // 中英文混合：按字符类型分割
        words.addAll(_splitMixedText(token));
      }
    }
    
    // 去重并保持顺序
    return words.toSet().toList();
  }
  
  /// 生成中文 n-gram（回退方案）
  static List<String> _generateChineseNgrams(String text) {
    final result = <String>[];
    final chars = text.split('');
    
    // 2-gram（双字词）
    for (int i = 0; i < chars.length - 1; i++) {
      result.add(chars[i] + chars[i + 1]);
    }
    
    // 3-gram（三字词）
    for (int i = 0; i < chars.length - 2; i++) {
      result.add(chars[i] + chars[i + 1] + chars[i + 2]);
    }
    
    // 4-gram（四字成语等）
    for (int i = 0; i < chars.length - 3; i++) {
      result.add(chars[i] + chars[i + 1] + chars[i + 2] + chars[i + 3]);
    }
    
    return result;
  }
  
  /// 分割中英文混合文本（回退方案）
  static List<String> _splitMixedText(String text) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool? lastWasChinese;
    
    for (final char in text.split('')) {
      final isChinese = _isChineseChar(char);
      
      if (lastWasChinese != null && lastWasChinese != isChinese) {
        if (buffer.isNotEmpty) {
          if (lastWasChinese == true) {
            result.addAll(_generateChineseNgrams(buffer.toString()));
          } else {
            result.add(buffer.toString().toLowerCase());
          }
          buffer.clear();
        }
      }
      
      buffer.write(char);
      lastWasChinese = isChinese;
    }
    
    if (buffer.isNotEmpty) {
      if (lastWasChinese == true) {
        result.addAll(_generateChineseNgrams(buffer.toString()));
      } else {
        result.add(buffer.toString().toLowerCase());
      }
    }
    
    return result;
  }

  /// 判断字符串是否全部为中文字符
  static bool _isAllChinese(String text) {
    if (text.isEmpty) return false;
    for (final char in text.split('')) {
      if (!_isChineseChar(char)) return false;
    }
    return true;
  }

  /// 判断字符串是否全部为英文字符
  static bool _isAllEnglish(String text) {
    if (text.isEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(text);
  }

  /// 判断单个字符是否为中文字符
  static bool _isChineseChar(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 0x4E00 && code <= 0x9FFF;
  }

  /// 判断是否为中文字符（旧方法，保持兼容）
  static bool _isChinese(String text) {
    return _isAllChinese(text);
  }

  /// 判断是否为英文字符（旧方法，保持兼容）
  static bool _isEnglish(String text) {
    return _isAllEnglish(text);
  }

  /// 将文本转换为查询词列表
  /// 提取关键词（过滤停用词和短词）
  static List<String> extractKeywords(String text, {int minLength = 2}) {
    final words = segment(text);
    
    // 过滤停用词和短词，并去重
    final keywords = words
        .where((w) => w.length >= minLength && !_stopWords.contains(w.toLowerCase()))
        .toSet()
        .toList();
    
    return keywords;
  }
  
  /// 检查是否为停用词
  static bool isStopWord(String word) {
    return _stopWords.contains(word.toLowerCase());
  }
  
  /// 调试输出
  static void debugPrint(String message) {
    // ignore: avoid_print
    print(message);
  }
}