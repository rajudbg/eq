import 'package:fpdart/fpdart.dart';
import 'package:emvo_core/emvo_core.dart';

import '../entities/assessment_result.dart';
import '../entities/question.dart';

abstract class AssessmentRepository {
  /// Save assessment result
  Future<Either<Failure, Unit>> saveResult(AssessmentResult result);

  /// Get assessment history
  Future<Either<Failure, List<AssessmentResult>>> getHistory();

  /// Get latest result
  Future<Either<Failure, AssessmentResult?>> getLatestResult();

  /// Calculate result from answers
  AssessmentResult calculateResult({
    required Map<String, String> answers, // questionId -> optionId
    required List<Question> questions,
  });
}
