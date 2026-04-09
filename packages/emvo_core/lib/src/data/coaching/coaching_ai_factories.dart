import '../../domain/coaching/repositories/coaching_ai_gateway.dart';
import 'local_context_coaching_gateway.dart';
import 'openrouter_chat_client.dart';
import 'openrouter_coaching_gateway.dart';

/// OpenRouter when `OPENROUTER_API_KEY` is set; otherwise a rich local coach
/// that still uses assessment context when provided via [CoachingRepository.applyCoachingContext].
CoachingAiGateway createCoachingAiGateway() {
  const apiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
  const model = String.fromEnvironment(
    'OPENROUTER_MODEL',
    defaultValue: 'openai/gpt-oss-20b:free',
  );
  if (apiKey.isEmpty) {
    return LocalContextCoachingAiGateway();
  }
  return OpenRouterCoachingAiGateway(
    OpenRouterChatClient(apiKey: apiKey, model: model),
  );
}
