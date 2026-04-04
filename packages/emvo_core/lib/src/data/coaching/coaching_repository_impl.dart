import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../domain/coaching/entities/message.dart';
import '../../domain/coaching/repositories/coaching_ai_gateway.dart';
import '../../domain/coaching/repositories/coaching_repository.dart';
import '../../domain/failures/failure.dart';

class CoachingRepositoryImpl implements CoachingRepository {
  CoachingRepositoryImpl(this._gateway);

  final CoachingAiGateway _gateway;
  CoachingSession? _currentSession;

  @override
  CoachingSession? get cachedActiveSession => _currentSession;
  Map<String, dynamic>? _pendingContext;
  final _messageController = StreamController<Message>.broadcast();

  @override
  void applyCoachingContext(Map<String, dynamic> context) {
    if (context.isEmpty) return;
    _pendingContext = {...?_pendingContext, ...context};
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        context: {...?_currentSession!.context, ...context},
      );
    }
  }

  @override
  Future<Either<Failure, CoachingSession>> getActiveSession() async {
    try {
      _currentSession ??= CoachingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startedAt: DateTime.now(),
        messages: [],
        context: _pendingContext,
      );
      _pendingContext = null;
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
        final previousMessages = session.messages;
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

          final turn = await _gateway.completeTurn(
            session: _currentSession!,
            userMessage: userMessage,
          );

          return turn.match(
            (f) {
              _currentSession = session.copyWith(messages: previousMessages);
              return Left<Failure, Message>(f);
            },
            (aiResponse) {
              _currentSession = _currentSession!.copyWith(
                messages: [..._currentSession!.messages, aiResponse],
              );
              _messageController.add(aiResponse);
              return Right<Failure, Message>(aiResponse);
            },
          );
        } catch (e) {
          _currentSession = session.copyWith(messages: previousMessages);
          return Left(
            ServerFailure('Failed to send message: $e'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<String>>> getSuggestedPrompts() async {
    final sessionEither = await getActiveSession();
    return sessionEither.match(
      (f) async => Left<Failure, List<String>>(f),
      (session) async => _gateway.suggestConversationStarters(
        session.context ?? {},
      ),
    );
  }

  @override
  Future<Either<Failure, List<CoachingInsight>>> getInsights() async {
    final sessionEither = await getActiveSession();
    return sessionEither.match(
      (f) async => Left<Failure, List<CoachingInsight>>(f),
      (session) async => _gateway.generateInsights(session: session),
    );
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
