import 'package:fpdart/fpdart.dart';
import 'package:emvo_core/emvo_core.dart';

import '../../domain/entities/assessment_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/assessment_repository.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  AssessmentRepositoryImpl();

  // In-memory storage for now - replace with Hive/SQLite later
  final List<AssessmentResult> _history = [];

  @override
  AssessmentResult calculateResult({
    required Map<String, String> answers,
    required List<Question> questions,
  }) {
    final Map<EQDimension, double> dimensionScores = {
      EQDimension.selfAwareness: 0,
      EQDimension.selfRegulation: 0,
      EQDimension.empathy: 0,
      EQDimension.socialSkills: 0,
    };

    for (final entry in answers.entries) {
      final questionMatch = questions.where((q) => q.id == entry.key);
      if (questionMatch.isEmpty) continue;
      final question = questionMatch.first;

      final optionMatch = question.options.where((o) => o.id == entry.value);
      if (optionMatch.isEmpty) continue;
      final selectedOption = optionMatch.first;

      for (final scoreEntry in selectedOption.scores.entries) {
        dimensionScores[scoreEntry.key] =
            (dimensionScores[scoreEntry.key] ?? 0) + scoreEntry.value;
      }
    }

    final maxRawByDimension = _maxAchievableRawByDimension(
      questions,
      answers.keys.toSet(),
    );
    final normalizedScores = dimensionScores.map((dimension, raw) {
      final maxRaw = maxRawByDimension[dimension] ?? 0.0;
      if (maxRaw <= 0) {
        return MapEntry(dimension, 0.0);
      }
      return MapEntry(
        dimension,
        (raw / maxRaw * 100).clamp(0.0, 100.0).toDouble(),
      );
    });

    final overallScore = normalizedScores.values.reduce((a, b) => a + b) / 4;

    final insights = _generateInsights(normalizedScores);
    final recommendations = _generateRecommendations(normalizedScores);

    return AssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      completedAt: DateTime.now(),
      dimensionScores: normalizedScores,
      overallScore: overallScore,
      insights: insights,
      recommendations: recommendations,
      answers: Map<String, String>.from(answers),
    );
  }

  /// Sum of best-possible raw points per dimension across answered questions.
  static Map<EQDimension, double> maxAchievableRawByDimensionForAnswers({
    required List<Question> questions,
    required Set<String> answeredQuestionIds,
  }) {
    return _maxAchievableRawByDimension(questions, answeredQuestionIds);
  }

  static Map<EQDimension, double> _maxAchievableRawByDimension(
    List<Question> questions,
    Set<String> answeredQuestionIds,
  ) {
    final maxes = {
      for (final d in EQDimension.values) d: 0.0,
    };
    for (final q in questions) {
      if (!answeredQuestionIds.contains(q.id)) continue;
      for (final d in EQDimension.values) {
        var best = 0.0;
        for (final o in q.options) {
          final v = (o.scores[d] ?? 0).toDouble();
          if (v > best) best = v;
        }
        maxes[d] = (maxes[d] ?? 0) + best;
      }
    }
    return maxes;
  }

  List<DimensionInsight> _generateInsights(Map<EQDimension, double> scores) {
    return scores.entries.map((entry) {
      final level = entry.value >= 80
          ? 'Advanced'
          : entry.value >= 60
              ? 'Proficient'
              : 'Developing';

      return DimensionInsight(
        dimension: entry.key,
        score: entry.value,
        level: level,
        description: _getInsightDescription(entry.key, entry.value),
        growthAreas: _getGrowthAreas(entry.key, entry.value),
      );
    }).toList();
  }

  String _getInsightDescription(EQDimension dimension, double score) {
    if (score >= 80) {
      switch (dimension) {
        case EQDimension.selfAwareness:
          return 'You have exceptional clarity about your emotional landscape';
        case EQDimension.selfRegulation:
          return 'You navigate intense emotions with remarkable poise';
        case EQDimension.empathy:
          return 'You naturally tune into others emotional experiences';
        case EQDimension.socialSkills:
          return 'You build and maintain relationships with ease';
      }
    } else if (score >= 60) {
      switch (dimension) {
        case EQDimension.selfAwareness:
          return 'You generally understand your emotions but miss subtle cues';
        case EQDimension.selfRegulation:
          return 'You manage emotions well but struggle under extreme pressure';
        case EQDimension.empathy:
          return 'You understand others but sometimes miss unspoken signals';
        case EQDimension.socialSkills:
          return 'You connect well but may avoid difficult conversations';
      }
    } else {
      switch (dimension) {
        case EQDimension.selfAwareness:
          return 'Emotions often surprise you - building awareness is key';
        case EQDimension.selfRegulation:
          return 'Reactive patterns emerge - pause techniques will help';
        case EQDimension.empathy:
          return 'You focus more on facts than feelings in interactions';
        case EQDimension.socialSkills:
          return 'Social situations may feel draining or confusing';
      }
    }
  }

  List<String> _getGrowthAreas(EQDimension dimension, double score) {
    if (score >= 80) return ['Maintain your practice', 'Mentor others'];
    if (score >= 60) return ['Deepen your practice', 'Expand to new contexts'];
    return ['Build foundational skills', 'Practice daily micro-habits'];
  }

  List<String> _generateRecommendations(Map<EQDimension, double> scores) {
    final lowestDimension =
        scores.entries.reduce((a, b) => a.value < b.value ? a : b).key;

    return [
      'Focus on ${lowestDimension.displayName} this week',
      'Practice the 3-breath technique when triggered',
      'Journal one emotional moment daily',
      'Ask "How do you feel?" before giving advice',
    ];
  }

  @override
  Future<Either<Failure, Unit>> saveResult(AssessmentResult result) async {
    _history.add(result);
    return right(unit);
  }

  @override
  Future<Either<Failure, List<AssessmentResult>>> getHistory() async {
    return right(List<AssessmentResult>.unmodifiable(_history));
  }

  @override
  Future<Either<Failure, AssessmentResult?>> getLatestResult() async {
    if (_history.isEmpty) return right(null);
    return right(_history.last);
  }
}
