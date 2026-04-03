import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../domain/coaching/entities/message.dart';
import '../../domain/coaching/repositories/coaching_repository.dart';
import '../../domain/failures/failure.dart';
import 'ai_service.dart';

class CoachingRepositoryImpl implements CoachingRepository {
  CoachingRepositoryImpl(this._aiService);

  final AIService _aiService;
  CoachingSession? _currentSession;
  final _messageController = StreamController<Message>.broadcast();

  @override
  Future<Either<Failure, CoachingSession>> getActiveSession() async {
    try {
      _currentSession ??= CoachingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startedAt: DateTime.now(),
        messages: [],
      );
      return Right(_currentSession!);
    } catch (e) {
      return Left(ServerFailure('Failed to get session'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(String content) async {
    final sessionEither = await getActiveSession();
    return sessionEither.match(
      (failure) async => Left<Failure, Message>(failure),
      (session) async {
        try {
          final userMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: content,
            sender: MessageSender.user,
            timestamp: DateTime.now(),
          );

          _currentSession = session.copyWith(
            messages: [...session.messages, userMessage],
          );
          _messageController.add(userMessage);

          final historyForAi = [...session.messages, userMessage];
          final aiResponse = await _aiService.sendMessage(
            userMessage: content,
            conversationHistory: historyForAi,
            userContext: {},
          );

          _currentSession = _currentSession!.copyWith(
            messages: [..._currentSession!.messages, aiResponse],
          );
          _messageController.add(aiResponse);

          return Right(aiResponse);
        } catch (e) {
          return Left(ServerFailure('Failed to send message'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<String>>> getSuggestedPrompts() async {
    try {
      final prompts = await _aiService.getSuggestedPrompts(userContext: {});
      return Right(prompts);
    } catch (e) {
      return Left(ServerFailure('Failed to get prompts'));
    }
  }

  @override
  Future<Either<Failure, List<CoachingInsight>>> getInsights() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Unit>> endSession() async {
    try {
      _currentSession = _currentSession?.copyWith(endedAt: DateTime.now());
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to end session'));
    }
  }

  @override
  Stream<Message> messageStream() => _messageController.stream;

  void dispose() {
    _messageController.close();
  }
}
