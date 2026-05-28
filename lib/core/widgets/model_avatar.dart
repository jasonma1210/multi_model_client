import 'package:flutter/material.dart';

/// 模型头像组件：随机背景色 + 首字母图标
class ModelAvatar extends StatelessWidget {
  /// 模型名称（用于提取首字母）
  final String modelName;
  
  /// 头像尺寸
  final double size;
  
  /// 是否显示加载状态指示器
  final bool isLoaded;
  
  /// 自定义背景色（可选）
  final Color? backgroundColor;

  const ModelAvatar({
    super.key,
    required this.modelName,
    this.size = 52,
    this.isLoaded = false,
    this.backgroundColor,
  });

  /// 预定义的配色方案（10种）
  static const List<List<Color>> _colorSchemes = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)], // 紫色
    [Color(0xFF3B82F6), Color(0xFF60A5FA)], // 蓝色
    [Color(0xFF10B981), Color(0xFF34D399)], // 绿色
    [Color(0xFFF59E0B), Color(0xFFFBBF24)], // 橙色
    [Color(0xFFEF4444), Color(0xFFF87171)], // 红色
    [Color(0xFFEC4899), Color(0xFFF472B6)], // 粉色
    [Color(0xFF06B6D4), Color(0xFF22D3EE)], // 青色
    [Color(0xFF8B5CF6), Color(0xFFA78BFA)], // 紫罗兰
    [Color(0xFF14B8A6), Color(0xFF2DD4BF)], // 青绿
    [Color(0xFFF97316), Color(0xFFFB923C)], // 深橙
  ];

  /// 根据名称生成稳定的随机颜色
  static List<Color> _getColorsForName(String name) {
    final hash = name.hashCode.abs();
    final index = hash % _colorSchemes.length;
    return _colorSchemes[index];
  }

  /// 提取首字母（处理中英文）
  static String _getInitial(String name) {
    if (name.isEmpty) return '?';
    
    // 移除常见前缀
    String cleanName = name
        .replaceAll(RegExp(r'^(gguf|qwen|llama|qwen2|qwen2\.5|qwen2-5|yi|deepseek|mistral|phi|gemma|phi3|llava|vision)-*', caseSensitive: false), '')
        .trim();
    
    if (cleanName.isEmpty) cleanName = name;
    
    // 获取第一个字符
    final firstChar = cleanName[0];
    
    // 如果是中文，取第一个汉字
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(firstChar)) {
      return firstChar;
    }
    
    // 如果是英文，转换为大写
    if (RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
      return firstChar.toUpperCase();
    }
    
    // 其他情况返回第一个字符
    return firstChar;
  }

  @override
  Widget build(BuildContext context) {
    final colors = backgroundColor != null 
        ? [backgroundColor!, backgroundColor!.withValues(alpha: 0.7)]
        : _getColorsForName(modelName);
    final initial = _getInitial(modelName);

    return Stack(
      children: [
        // 头像主体
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoaded 
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.27),
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // 加载状态指示器
        if (isLoaded)
          Positioned(
            right: -size * 0.04,
            bottom: -size * 0.04,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: size * 0.04,
                ),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: size * 0.2,
              ),
            ),
          ),
      ],
    );
  }
}