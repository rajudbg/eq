import 'package:flutter_test/flutter_test.dart';

import 'package:emvo_assessment/emvo_assessment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Runs the full scoring suite against a question bank loaded from
  /// [assetPath].  Shared by all intent-specific packs (work, reactions,
  /// leadership, growth) and the legacy 16-question default bank.
  void scoringSuite(String label, String assetPath) {
    group('AssessmentRepositoryImpl scoring – $label', () {
      late List<Question> questions;
      late AssessmentRepositoryImpl repo;

      setUp(() async {
        questions =
            await LocalQuestionDataSource(assetPath: assetPath).getQuestions();
        repo = AssessmentRepositoryImpl();
      });

      test('maxAchievableRaw includes both primary and cross ceilings', () {
        final answered = questions.map((q) => q.id).toSet();
        final maxRaw =
            AssessmentRepositoryImpl.maxAchievableRawByDimensionForAnswers(
          questions: questions,
          answeredQuestionIds: answered,
        );
        // With 6+ primary questions per dimension scoring up to 5 each,
        // the *total* ceiling (primary + cross) must exceed 20.
        expect(maxRaw[EQDimension.selfAwareness], greaterThan(20.0));
        expect(maxRaw[EQDimension.selfRegulation], greaterThan(20.0));
      });

      test(
          'always picking first option does not yield 100 on self-awareness',
          () {
        final answers = <String, String>{
          for (final q in questions) q.id: q.options.first.id,
        };
        final r =
            repo.calculateResult(answers: answers, questions: questions);
        expect(
          r.dimensionScores[EQDimension.selfAwareness],
          lessThan(100.0),
        );
      });

      test(
          'best self-awareness option each question yields high SA score',
          () {
        final answers = <String, String>{};
        for (final q in questions) {
          final best = q.options.reduce((a, b) {
            final sa = a.scores[EQDimension.selfAwareness] ?? 0;
            final sb = b.scores[EQDimension.selfAwareness] ?? 0;
            return sb > sa ? b : a;
          });
          answers[q.id] = best.id;
        }
        final r =
            repo.calculateResult(answers: answers, questions: questions);
        // With the 80/20 blend, picking the best SA option on every
        // question should still yield a very high SA score (primary
        // component is 100, cross component is also high).
        expect(r.dimensionScores[EQDimension.selfAwareness],
            greaterThanOrEqualTo(90.0));
      });

      test('worst self-awareness option each question yields a low score',
          () {
        final answers = <String, String>{};
        for (final q in questions) {
          final worst = q.options.reduce((a, b) {
            final sa = a.scores[EQDimension.selfAwareness] ?? 0;
            final sb = b.scores[EQDimension.selfAwareness] ?? 0;
            return sb < sa ? b : a;
          });
          answers[q.id] = worst.id;
        }
        final r =
            repo.calculateResult(answers: answers, questions: questions);
        expect(
            r.dimensionScores[EQDimension.selfAwareness]!, lessThan(50.0));
      });

      test('dimension scores stay within 0–100', () {
        final answers = <String, String>{
          for (final q in questions) q.id: q.options.last.id,
        };
        final r =
            repo.calculateResult(answers: answers, questions: questions);
        for (final d in EQDimension.values) {
          final v = r.dimensionScores[d]!;
          expect(v, inInclusiveRange(0.0, 100.0));
        }
      });

      test(
          'picking best primary option gives balanced scores across all dimensions',
          () {
        // For each question, pick the option that scores highest on that
        // question's PRIMARY dimension.  All four dimension scores should
        // be high and reasonably balanced — no single dimension should be
        // artificially suppressed by cross-scoring ceiling asymmetry.
        final answers = <String, String>{};
        for (final q in questions) {
          final best = q.options.reduce((a, b) {
            final sa = a.scores[q.primaryDimension] ?? 0;
            final sb = b.scores[q.primaryDimension] ?? 0;
            return sb > sa ? b : a;
          });
          answers[q.id] = best.id;
        }
        final r =
            repo.calculateResult(answers: answers, questions: questions);

        for (final d in EQDimension.values) {
          final v = r.dimensionScores[d]!;
          // Each dimension should score ≥ 75 when the user picks the best
          // primary answer for every question — the old scoring would often
          // produce scores < 70 on dimensions with large cross-ceilings.
          expect(
            v,
            greaterThanOrEqualTo(75.0),
            reason: '${d.displayName} should be ≥ 75 when picking best '
                'primary options, got ${v.toStringAsFixed(1)}',
          );
        }

        // The spread between max and min dimension should be < 25 points.
        final scores = r.dimensionScores.values.toList();
        final spread = scores.reduce((a, b) => a > b ? a : b) -
            scores.reduce((a, b) => a < b ? a : b);
        expect(
          spread,
          lessThan(25.0),
          reason:
              'Dimension spread should be < 25 when picking best primary '
              'options, got ${spread.toStringAsFixed(1)}',
        );
      });

      test('overall score is the mean of the four dimension scores', () {
        final answers = <String, String>{
          for (final q in questions) q.id: q.options[1].id,
        };
        final r =
            repo.calculateResult(answers: answers, questions: questions);
        final expectedOverall =
            r.dimensionScores.values.reduce((a, b) => a + b) / 4;
        expect(r.overallScore, closeTo(expectedOverall, 0.01));
      });
    });
  }

  // Run the suite against legacy bank and all four intent packs.
  scoringSuite(
    'legacy 16-question bank',
    LocalQuestionDataSource.defaultAssetPath,
  );
  scoringSuite(
    'work pack',
    'packages/emvo_assessment/lib/src/data/work.json',
  );
  scoringSuite(
    'reactions pack',
    'packages/emvo_assessment/lib/src/data/reactions.json',
  );
  scoringSuite(
    'leadership pack',
    'packages/emvo_assessment/lib/src/data/leadership.json',
  );
  scoringSuite(
    'growth pack',
    'packages/emvo_assessment/lib/src/data/growth.json',
  );
}
