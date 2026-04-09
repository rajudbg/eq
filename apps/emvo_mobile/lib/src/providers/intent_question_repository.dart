import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'user_intent_provider.dart';

/// Asset path for the bundled question bank matching onboarding [UserIntent].
String assessmentAssetPathForIntent(UserIntent? intent) {
  switch (intent) {
    case UserIntent.workRelationships:
      return 'packages/emvo_assessment/lib/src/data/work.json';
    case UserIntent.managingReactions:
      return 'packages/emvo_assessment/lib/src/data/reactions.json';
    case UserIntent.leadershipCommunication:
      return 'packages/emvo_assessment/lib/src/data/leadership.json';
    case UserIntent.personalGrowth:
      return 'packages/emvo_assessment/lib/src/data/growth.json';
    case null:
      return LocalQuestionDataSource.defaultAssetPath;
  }
}

/// Resolves the correct JSON pack from [userIntentProvider] once hydration
/// completes. Returns [CacheFailure] while loading, if load failed, or if no
/// intent is set (assessment must not run without a chosen focus).
class IntentAwareQuestionRepository implements QuestionRepository {
  IntentAwareQuestionRepository(this._ref);

  final Ref _ref;

  Either<Failure, QuestionRepositoryImpl> _delegateOrFailure() {
    final async = _ref.read(userIntentProvider);
    if (async.isLoading) {
      return left(
        const CacheFailure('User intent is still loading'),
      );
    }
    if (async.hasError) {
      return left(
        CacheFailure(
          'User intent failed to load: ${async.error}',
        ),
      );
    }
    final intent = async.requireValue;
    if (intent == null) {
      return left(
        const CacheFailure(
          'Choose a focus area before starting the assessment',
        ),
      );
    }
    final path = assessmentAssetPathForIntent(intent);
    return right(
      QuestionRepositoryImpl(LocalQuestionDataSource(assetPath: path)),
    );
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestions() async {
    return _delegateOrFailure().fold(
      left,
      (impl) => impl.getQuestions(),
    );
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestionsByDimension(
    EQDimension dimension,
  ) async {
    return _delegateOrFailure().fold(
      left,
      (impl) => impl.getQuestionsByDimension(dimension),
    );
  }

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) async {
    return _delegateOrFailure().fold(
      left,
      (impl) => impl.getQuestionById(id),
    );
  }

  @override
  Future<Either<Failure, Unit>> refreshQuestions() async {
    return _delegateOrFailure().fold(
      left,
      (impl) => impl.refreshQuestions(),
    );
  }
}
