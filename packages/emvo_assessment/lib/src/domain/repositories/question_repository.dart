import 'package:fpdart/fpdart.dart';
import 'package:emvo_core/emvo_core.dart';

import '../entities/question.dart';

abstract class QuestionRepository {
  /// Get all questions for assessment
  Future<Either<Failure, List<Question>>> getQuestions();

  /// Get questions filtered by dimension (for targeted practice)
  Future<Either<Failure, List<Question>>> getQuestionsByDimension(
    EQDimension dimension,
  );

  /// Get question by ID
  Future<Either<Failure, Question>> getQuestionById(String id);

  /// Refresh questions from remote (if needed)
  Future<Either<Failure, Unit>> refreshQuestions();
}
