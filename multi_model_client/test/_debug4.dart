import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/tts_style_parser.dart';

void main() {
  test('debug conflict detail', () {
    final text = '[tts:style=开心]你好[/tts][tts:natural=气声]再见[/tts]';
    final conflicts = detectTTSConflicts(text);
    print('text: $text');
    print('conflicts: ${conflicts.length}');
    for (final c in conflicts) {
      print('  type=${c.type} message=${c.message}');
    }
  });
}
