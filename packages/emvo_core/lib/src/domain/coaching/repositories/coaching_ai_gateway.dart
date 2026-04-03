import 'package:fpdart/fpdart.dart';

import '../../failures/failure.dart';
import '../entities/message.dart';

/// Contract for LLM / AI coach backends (OpenAI, on-device, mock, etc.).
abstract class CoachingAiGateway {
  /// Returns the coach-authored message for this turn (non-streaming).
  Future<Either<Failure, Message>> completeTurn({
    required CoachingSession session,
    required Message userMessage,
  });

  /// Optional incremental tokens for typing-style UIs; implementations may
  /// omit streaming and emit nothing until [completeTurn] is used instead.
  Stream<String> streamCoachTokens({
    required CoachingSession session,
    required Message userMessage,
  });

  /// Derive structured insights from the recent conversation context.
  Future<Either<Failure, List<CoachingInsight>>> generateInsights({
    required CoachingSession session,
  });

  /// Conversation starters tailored to optional user context (e.g. assessment scores).
  Future<Either<Failure, List<String>>> suggestConversationStarters(
    Map<String, dynamic> userContext,
  );
}
