import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/tts_style_parser.dart';

void main() {
  test('debug conflict', () {
    final text = '[tts:style=开心]你好[/tts][tts:natural=气声]再见[/tts]';
    final regex = RegExp(
      r'\[tts:(style|emotion|natural)=([^\]]+)\](.*?)\[/tts\]',
      dotAll: true,
    );
    final matches = regex.allMatches(text).toList();
    print('matches count: ${matches.length}');
    for (final m in matches) {
      print('  ${m.group(0)} group1=${m.group(1)}');
    }
    final conflicts = detectTTSConflicts(text);
    print('conflicts: ${conflicts.length}');
  });
}
