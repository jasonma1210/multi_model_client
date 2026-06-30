// v0.43.0 多模态消息单元测试

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/multimodal/domain/multimodal_message.dart';

void main() {
  group('MultimodalMessage', () {
    test('纯文本消息', () {
      final msg = MultimodalMessage.text('user', 'Hello');
      expect(msg.role, 'user');
      expect(msg.text, 'Hello');
      expect(msg.hasImages, false);
      expect(msg.images, isEmpty);
    });

    test('消息带图片', () {
      final img = ImagePart.fromBase64('abc123', mimeType: 'image/jpeg');
      final msg = MultimodalMessage.userWithImage('看看这个', img);
      expect(msg.hasImages, true);
      expect(msg.images.length, 1);
      expect(msg.text, '看看这个');
    });

    test('多张图片', () {
      final imgs = [
        ImagePart.fromBase64('img1'),
        ImagePart.fromBase64('img2'),
      ];
      final msg = MultimodalMessage.userWithImages('两张', imgs);
      expect(msg.images.length, 2);
    });

    test('token 估算（无 metadata）', () {
      final img = ImagePart.fromBase64('abc');
      expect(img.estimateTokens(), 85);
    });

    test('token 估算（带 metadata 1024x1024）', () {
      final img = ImagePart.fromBase64(
        'abc',
        metadata: const ImageMetadata(width: 1024, height: 1024),
      );
      // 1024/512 = 2 瓦片 → 2*2 = 4 瓦片 → 85*4 = 340
      expect(img.estimateTokens(), 340);
    });

    test('provider format - OpenAI image', () {
      final img = ImagePart.fromBase64('abc', mimeType: 'image/png');
      final format = img.toProviderFormat(LLMProvider.openai);
      expect(format['type'], 'image_url');
      expect((format['image_url'] as Map)['url'], 'data:image/png;base64,abc');
    });

    test('provider format - Anthropic image', () {
      final img = ImagePart.fromBase64('abc', mimeType: 'image/jpeg');
      final format = img.toProviderFormat(LLMProvider.anthropic);
      expect(format['type'], 'image');
      final source = format['source'] as Map;
      expect(source['type'], 'base64');
      expect(source['media_type'], 'image/jpeg');
      expect(source['data'], 'abc');
    });

    test('provider format - Gemini inline_data', () {
      final img = ImagePart.fromBase64('xyz', mimeType: 'image/png');
      final format = img.toProviderFormat(LLMProvider.gemini);
      final inline = format['inline_data'] as Map;
      expect(inline['mime_type'], 'image/png');
      expect(inline['data'], 'xyz');
    });

    test('provider format - URL image (Anthropic)', () {
      final img = ImagePart.fromUrl('https://example.com/a.jpg');
      final format = img.toProviderFormat(LLMProvider.anthropic);
      expect(format['source']['type'], 'url');
      expect(format['source']['url'], 'https://example.com/a.jpg');
    });

    test('dataUri 生成', () {
      final img = ImagePart.fromBase64('hi', mimeType: 'image/webp');
      expect(img.dataUri, 'data:image/webp;base64,hi');
    });
  });
}
