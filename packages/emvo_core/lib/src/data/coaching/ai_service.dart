import '../../domain/coaching/entities/message.dart';

abstract class AIService {
  /// Send message to AI and get streaming response
  Future<Message> sendMessage({
    required String userMessage,
    required List<Message> conversationHistory,
    required Map<String, dynamic> userContext,
  });

  /// Get suggested conversation starters
  Future<List<String>> getSuggestedPrompts({
    required Map<String, dynamic> userContext,
  });
}

/// Lightweight mock for **unit tests** of code that still depends on [AIService].
/// The app uses [CoachingAiGateway] via [createCoachingAiGateway] instead.
class MockAIService implements AIService {
  @override
  Future<Message> sendMessage({
    required String userMessage,
    required List<Message> conversationHistory,
    required Map<String, dynamic> userContext,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final lowerMessage = userMessage.toLowerCase();
    final String response;

    if (lowerMessage.contains('stress') || lowerMessage.contains('anxious')) {
      response =
          "I hear that you're feeling stressed. Let's try a quick grounding exercise. Can you name 3 things you can see right now? This helps activate your prefrontal cortex.";
    } else if (lowerMessage.contains('angry') ||
        lowerMessage.contains('frustrated')) {
      response =
          "Anger often masks other emotions. Before reacting, try the 6-second pause - it takes about that long for chemicals to flush from your brain. What do you think is beneath the anger?";
    } else if (lowerMessage.contains('happy') ||
        lowerMessage.contains('good')) {
      response =
          "That's wonderful! Let's savor this moment. What specifically contributed to this feeling? Understanding your wins helps replicate them.";
    } else if (lowerMessage.contains('work') ||
        lowerMessage.contains('boss')) {
      response =
          "Workplace dynamics can be complex. Based on your EQ profile, you have strong self-regulation. How might you use that strength in this situation?";
    } else {
      response =
          "Thank you for sharing. I'm here to help you explore this. Could you tell me more about what emotions you're experiencing in your body right now?";
    }

    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      sender: MessageSender.coach,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  @override
  Future<List<String>> getSuggestedPrompts({
    required Map<String, dynamic> userContext,
  }) async {
    return [
      "I'm feeling overwhelmed today",
      "Help me prepare for a difficult conversation",
      "Why do I react so strongly to criticism?",
      "I want to improve my empathy",
    ];
  }
}
