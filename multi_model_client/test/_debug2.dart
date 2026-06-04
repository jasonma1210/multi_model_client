import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/tts_style_parser.dart';

void main() {
  test('direct regex comparison', () {
    // 复制 tts_style_parser.dart 中的 _audioTagRegex
    final classRegex = RegExp(
      r'\[('
      r'吸气|深呼吸|叹气|长叹一口气|喘息|屏息'
      r'|紧张|害怕|激动|疲惫|委屈|撒娇|心虚|震惊|不耐烦'
      r'|颤抖|声音颤抖|变调|破音|鼻音|气声|沙哑'
      r'|笑|轻笑|大笑|冷笑|抽泣|呜咽|哽咽|嚎啕大哭'
      r')\]',
    );
    final classMatch = classRegex.allMatches('[笑]你[哭]好[喘息]啊').length;
    print('class regex matches: $classMatch');
    final parserMatch = TTSStyleParser.countAudioTags('[笑]你[哭]好[喘息]啊');
    print('parser count: $parserMatch');
    print('Are they equal? ${classMatch == parserMatch}');
  });
}
