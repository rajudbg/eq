import 'package:fpdart/fpdart.dart';

import '../../failures/failure.dart';
import '../entities/message.dart';

abstract class CoachingRepository {
  /// Merge assessment / profile data into the active (or next) coaching session.
  void applyCoachingContext(Map<String, dynamic> context);

  /// Get or create active session
  Future<Either<Failure, CoachingSession>> getActiveSession();

  /// Send message to AI coach and get response
  Future<Either<Failure, Message>> sendMessage(String content);

  /// Get suggested prompts based on user state
  Future<Either<Failure, List<String>>> getSuggestedPrompts();

  /// Get coaching insights/history
  Future<Either<Failure, List<CoachingInsight>>> getInsights();

  /// End current session
  Future<Either<Failure, Unit>> endSession();

  /// Stream of messages for real-time updates
  Stream<Message> messageStream();
}
