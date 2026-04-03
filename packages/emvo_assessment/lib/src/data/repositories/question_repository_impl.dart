import 'package:fpdart/fpdart.dart';
import 'package:emvo_core/emvo_core.dart';

import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/local_question_datasource.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  QuestionRepositoryImpl(this._localDataSource);

  final LocalQuestionDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Question>>> getQuestions() async {
    try {
      final questions = await _localDataSource.getQuestions();
      return right(questions);
    } on Object catch (e) {
      return left(CacheFailure('Failed to load questions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestionsByDimension(
    EQDimension dimension,
  ) async {
    final result = await getQuestions();
    return result.map(
      (questions) => questions
          .where((q) => q.primaryDimension == dimension)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) async {
    final result = await getQuestions();
    return result.flatMap((questions) {
      for (final q in questions) {
        if (q.id == id) {
          return right(q);
        }
      }
      return left(CacheFailure('Question not found: $id'));
    });
  }

  @override
  Future<Either<Failure, Unit>> refreshQuestions() async {
    return right(unit);
  }
}
