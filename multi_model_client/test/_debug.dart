import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/tts_style_parser.dart';

void main() {
  test('debug', () {
    final text = '[笑]你[哭]好[喘息]啊';
    print('Text bytes: ${text.codeUnits.length}');
    print('Text runes: ${text.runes.toList()}');
    final result = TTSStyleParser.countAudioTags(text);
    print('Result: $result');
    final has = TTSStyleParser.hasAudioTag(text);
    print('hasAudioTag: $has');
    expect(result, 3);
  });
}
