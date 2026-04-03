import 'package:flutter_test/flutter_test.dart';
import 'package:emvo_core/emvo_core.dart';

void main() {
  group('Coaching', () {
    test('Mock AI Service returns response', () async {
      final service = MockAIService();
      final response = await service.sendMessage(
        userMessage: 'I am stressed',
        conversationHistory: [],
        userContext: {},
      );

      expect(response.content, isNotEmpty);
      expect(response.sender, MessageSender.coach);
    });
  });
}
