import 'package:flutter_test/flutter_test.dart';

import 'package:emvo_assessment/emvo_assessment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssessmentRepositoryImpl scoring', () {
    late List<Question> questions;
    late AssessmentRepositoryImpl repo;

    setUp(() async {
      questions = await LocalQuestionDataSource().getQuestions();
      repo = AssessmentRepositoryImpl();
    });

    test('normalizes against per-question maxima, not a fixed 20', () {
      final answered = questions.map((q) => q.id).toSet();
      final maxRaw = AssessmentRepositoryImpl.maxAchievableRawByDimensionForAnswers(
        questions: questions,
        answeredQuestionIds: answered,
      );
      expect(maxRaw[EQDimension.selfAwareness], greaterThan(20.0));
      expect(maxRaw[EQDimension.selfRegulation], greaterThan(20.0));
    });

    test('always picking first option does not yield 100 on self-awareness', () {
      final answers = <String, String>{
        for (final q in questions) q.id: q.options.first.id,
      };
      final r = repo.calculateResult(answers: answers, questions: questions);
      expect(
        r.dimensionScores[EQDimension.selfAwareness],
        lessThan(100.0),
      );
    });

    test('best self-awareness option each question yields ~100 for that dimension', () {
      final answers = <String, String>{};
      for (final q in questions) {
        final best = q.options.reduce((a, b) {
          final sa = a.scores[EQDimension.selfAwareness] ?? 0;
          final sb = b.scores[EQDimension.selfAwareness] ?? 0;
          return sb > sa ? b : a;
        });
        answers[q.id] = best.id;
      }
      final r = repo.calculateResult(answers: answers, questions: questions);
      expect(r.dimensionScores[EQDimension.selfAwareness], greaterThanOrEqualTo(99.0));
    });

    test('worst self-awareness option each question yields a low score', () {
      final answers = <String, String>{};
      for (final q in questions) {
        final worst = q.options.reduce((a, b) {
          final sa = a.scores[EQDimension.selfAwareness] ?? 0;
          final sb = b.scores[EQDimension.selfAwareness] ?? 0;
          return sb < sa ? b : a;
        });
        answers[q.id] = worst.id;
      }
      final r = repo.calculateResult(answers: answers, questions: questions);
      expect(r.dimensionScores[EQDimension.selfAwareness]!, lessThan(50.0));
    });

    test('dimension scores stay within 0–100', () {
      final answers = <String, String>{
        for (final q in questions) q.id: q.options.last.id,
      };
      final r = repo.calculateResult(answers: answers, questions: questions);
      for (final d in EQDimension.values) {
        final v = r.dimensionScores[d]!;
        expect(v, inInclusiveRange(0.0, 100.0));
      }
    });
  });
}
