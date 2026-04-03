import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Assessment Calculation', () {
    test('should calculate overall score correctly', () {
      final repository = AssessmentRepositoryImpl();

      final answers = {
        'q1': 'a', // score: {selfAwareness: 5}
        'q2': 'b', // score: {selfRegulation: 5}
      };

      final questions = [
        Question(
          id: 'q1',
          scenario: 'Test',
          primaryDimension: EQDimension.selfAwareness,
          options: [
            AnswerOption(
              id: 'a',
              text: 'Option A',
              scores: {EQDimension.selfAwareness: 5},
            ),
          ],
        ),
        Question(
          id: 'q2',
          scenario: 'Test 2',
          primaryDimension: EQDimension.selfRegulation,
          options: [
            AnswerOption(
              id: 'b',
              text: 'Option B',
              scores: {EQDimension.selfRegulation: 5},
            ),
          ],
        ),
      ];

      final result = repository.calculateResult(
        answers: answers,
        questions: questions,
      );

      // Normalized per dimension: raw / 20 * 100; two dimensions at 5 => 25 each.
      expect(result.overallScore, closeTo(12.5, 0.01));
      expect(
        result.dimensionScores[EQDimension.selfAwareness],
        closeTo(25.0, 0.01),
      );
      expect(
        result.dimensionScores[EQDimension.selfRegulation],
        closeTo(25.0, 0.01),
      );
    });
  });
}
