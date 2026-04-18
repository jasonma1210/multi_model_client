import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import '../skill.dart';

/// 计算器技能
/// 支持数学表达式计算
class CalculatorSkill extends Skill {
  const CalculatorSkill()
      : super(
          id: 'native.calculator',
          name: '计算器',
          description: '计算数学表达式，支持基本运算、函数和常量',
          type: SkillType.native,
          parameters: const [
            SkillParameter(
              name: 'expression',
              description: '数学表达式，例如: 2 + 2 * 3, sin(pi/2), sqrt(16)',
              type: SkillParameterType.string,
              required: true,
            ),
            SkillParameter(
              name: 'precision',
              description: '结果精度（小数位数）',
              type: SkillParameterType.number,
              required: false,
              defaultValue: 10,
            ),
          ],
          icon: 'calculate',
          category: '工具',
          tags: const ['math', 'calculation', 'calculator'],
          isBuiltin: true,
        );

  @override
  Future<SkillResult> execute(Map<String, dynamic> params) async {
    try {
      final validatedParams = validateParams(params);
      final expression = validatedParams['expression'] as String;
      final precision = validatedParams['precision'] as int? ?? 10;

      // 创建解析器
      final parser = Parser();
      final exp = parser.parse(expression);

      // 创建上下文并添加常量
      final context = ContextModel();
      context.bindVariable(
          Variable('pi'), Number(math.pi));
      context.bindVariable(
          Variable('e'), Number(math.e));

      // 计算结果
      final result = exp.evaluate(EvaluationType.REAL, context);

      // 格式化结果
      String formattedResult;
      if (result is double) {
        if (result.isInfinite) {
          return SkillResult.error('结果无穷大');
        }
        if (result.isNaN) {
          return SkillResult.error('结果不是数字');
        }

        // 根据精度格式化
        formattedResult = result
            .toStringAsFixed(precision)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      } else {
        formattedResult = result.toString();
      }

      return SkillResult.success({
        'result': result,
        'formatted': formattedResult,
        'expression': expression,
      }, metadata: {
        'expression': expression,
        'precision': precision,
      });
    } on SkillValidationException {
      rethrow;
    } catch (e) {
      return SkillResult.error('计算错误: $e');
    }
  }

  @override
  String getExecutePrompt() {
    return '''
## 计算器

计算数学表达式，支持以下功能：

### 基本运算
- 加法: `+`
- 减法: `-`
- 乘法: `*`
- 除法: `/`
- 幂运算: `^`
- 取模: `%`

### 数学函数
- 三角函数: `sin(x)`, `cos(x)`, `tan(x)`
- 反三角函数: `asin(x)`, `acos(x)`, `atan(x)`
- 对数: `ln(x)` (自然对数), `log(x)` (以10为底)
- 指数: `exp(x)`
- 平方根: `sqrt(x)`
- 绝对值: `abs(x)`
- 取整: `ceil(x)`, `floor(x)`, `round(x)`

### 常量
- `pi`: 圆周率 π (3.14159...)
- `e`: 自然常数 e (2.71828...)

### 示例
- `2 + 3 * 4` = 14
- `sin(pi / 2)` = 1
- `sqrt(16) + log(100)` = 6
- `2^10` = 1024

### 参数
- **expression** (string, 必需): 数学表达式
- **precision** (number, 可选): 结果精度，默认 10
'''.trim();
  }
}
