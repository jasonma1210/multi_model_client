import '../skill.dart';

/// 当前时间技能
/// 获取当前日期和时间信息
class CurrentTimeSkill extends Skill {
  const CurrentTimeSkill()
      : super(
          id: 'native.current_time',
          name: '当前时间',
          description: '获取当前日期和时间，支持多种格式和时区',
          type: SkillType.native,
          parameters: const [
            SkillParameter(
              name: 'format',
              description: '时间格式',
              type: SkillParameterType.string,
              required: false,
              defaultValue: 'full',
              enumValues: [
                'full',
                'date',
                'time',
                'iso',
                'timestamp',
                'relative'
              ],
            ),
            SkillParameter(
              name: 'timezone',
              description: '时区偏移（小时），例如: 8 表示东八区',
              type: SkillParameterType.number,
              required: false,
              defaultValue: 0,
            ),
          ],
          icon: 'schedule',
          category: '工具',
          tags: const ['time', 'date', 'clock'],
          isBuiltin: true,
        );

  @override
  Future<SkillResult> execute(Map<String, dynamic> params) async {
    try {
      final validatedParams = validateParams(params);
      final format = validatedParams['format'] as String? ?? 'full';
      final timezone = validatedParams['timezone'] as num? ?? 0;

      // 计算时区偏移
      final now = DateTime.now().toUtc();
      final adjustedTime = now.add(Duration(hours: timezone.toInt()));

      String result;
      Map<String, dynamic> details;

      switch (format) {
        case 'full':
          result = _formatFull(adjustedTime);
          break;
        case 'date':
          result =
              '${adjustedTime.year}-${_pad(adjustedTime.month)}-${_pad(adjustedTime.day)}';
          break;
        case 'time':
          result =
              '${_pad(adjustedTime.hour)}:${_pad(adjustedTime.minute)}:${_pad(adjustedTime.second)}';
          break;
        case 'iso':
          result = adjustedTime.toIso8601String();
          break;
        case 'timestamp':
          result = adjustedTime.millisecondsSinceEpoch.toString();
          break;
        case 'relative':
          result = _formatRelative(DateTime.now());
          break;
        default:
          result = _formatFull(adjustedTime);
      }

      details = {
        'year': adjustedTime.year,
        'month': adjustedTime.month,
        'day': adjustedTime.day,
        'hour': adjustedTime.hour,
        'minute': adjustedTime.minute,
        'second': adjustedTime.second,
        'weekday': _getWeekdayName(adjustedTime.weekday),
        'timezone': timezone,
        'isUtc': timezone == 0,
      };

      return SkillResult.success({
        'result': result,
        'details': details,
        'format': format,
      }, metadata: {
        'format': format,
        'timezone': timezone,
      });
    } on SkillValidationException {
      rethrow;
    } catch (e) {
      return SkillResult.error('获取时间失败: $e');
    }
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  String _formatFull(DateTime dt) {
    return '${dt.year}年${_pad(dt.month)}月${_pad(dt.day)}日 '
        '${_getWeekdayName(dt.weekday)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  String _getWeekdayName(int weekday) {
    const names = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[weekday];
  }

  String _formatRelative(DateTime dt) {
    final hour = dt.hour;
    if (hour < 6) return '凌晨';
    if (hour < 9) return '早上';
    if (hour < 12) return '上午';
    if (hour < 14) return '中午';
    if (hour < 18) return '下午';
    return '晚上';
  }

  @override
  String getExecutePrompt() {
    return '''
## 当前时间

获取当前日期和时间信息。

### 格式选项
- **full**: 完整格式（年月日 星期 时分秒）
- **date**: 仅日期（YYYY-MM-DD）
- **time**: 仅时间（HH:MM:SS）
- **iso**: ISO 8601 格式
- **timestamp**: Unix 时间戳（毫秒）
- **relative**: 相对时间段（凌晨/早上/上午/中午/下午/晚上）

### 时区
- 使用小时偏移量指定时区
- 0 = UTC
- 8 = 东八区（北京时间）
- -5 = 西五区（纽约时间）

### 示例
- 获取完整时间: `{"format": "full"}`
- 获取北京时间: `{"format": "full", "timezone": 8}`
- 获取时间戳: `{"format": "timestamp"}`

### 参数
- **format** (string, 可选): 时间格式，默认 "full"
- **timezone** (number, 可选): 时区偏移，默认 0 (UTC)
'''.trim();
  }
}
