import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/assessment_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/assessment_repository.dart';

const _kAssessmentHistoryKey = 'emvo.assessment_history.v1';

/// Whether a dimension's score contribution comes from a question whose
/// [primaryDimension] matches (primary) or from a different question (cross).
enum _Role { primary, cross }

class AssessmentRepositoryImpl implements AssessmentRepository {
  AssessmentRepositoryImpl();

  final List<AssessmentResult> _history = [];
  bool _loaded = false;
  Future<void>? _loading;

  Future<void> _ensureLoaded() {
    if (_loaded) return Future.value();
    _loading ??= _loadFromPrefs();
    return _loading!;
  }

  Future<void> _loadFromPrefs() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kAssessmentHistoryKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is! Map) continue;
          _history.add(
            AssessmentResult.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    } catch (_) {
      // Corrupt or incompatible payload — start fresh
      _history.clear();
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(_history.map((r) => r.toJson()).toList(growable: false));
    await prefs.setString(_kAssessmentHistoryKey, encoded);
  }

  /// Weight given to primary-dimension questions when computing the final
  /// normalized score.  The remaining `1 - primaryWeight` comes from cross-
  /// dimension contributions.
  ///
  /// An 80/20 split is the sweet-spot recommended by construct-based SJT
  /// literature: it keeps each dimension anchored to its own items while still
  /// rewarding holistic emotional intelligence shown in other scenarios.
  static const double primaryWeight = 0.80;

  @override
  AssessmentResult calculateResult({
    required Map<String, String> answers,
    required List<Question> questions,
  }) {
    // ── 1. Accumulate raw points split by primary vs cross ──────────────
    final primaryRaw = {for (final d in EQDimension.values) d: 0.0};
    final crossRaw = {for (final d in EQDimension.values) d: 0.0};

    for (final entry in answers.entries) {
      final questionMatch = questions.where((q) => q.id == entry.key);
      if (questionMatch.isEmpty) continue;
      final question = questionMatch.first;

      final optionMatch = question.options.where((o) => o.id == entry.value);
      if (optionMatch.isEmpty) continue;
      final selectedOption = optionMatch.first;

      for (final scoreEntry in selectedOption.scores.entries) {
        final dim = scoreEntry.key;
        final pts = scoreEntry.value.toDouble();
        if (dim == question.primaryDimension) {
          primaryRaw[dim] = (primaryRaw[dim] ?? 0) + pts;
        } else {
          crossRaw[dim] = (crossRaw[dim] ?? 0) + pts;
        }
      }
    }

    // ── 2. Compute ceilings (best-achievable) split the same way ────────
    final answeredIds = answers.keys.toSet();
    final primaryMax = _maxRawByRole(questions, answeredIds, _Role.primary);
    final crossMax = _maxRawByRole(questions, answeredIds, _Role.cross);

    // ── 3. Normalize & blend ────────────────────────────────────────────
    final normalizedScores = <EQDimension, double>{};
    for (final d in EQDimension.values) {
      final pMax = primaryMax[d] ?? 0.0;
      final cMax = crossMax[d] ?? 0.0;

      final pNorm =
          pMax > 0 ? ((primaryRaw[d] ?? 0) / pMax * 100).clamp(0.0, 100.0) : 0.0;
      final cNorm =
          cMax > 0 ? ((crossRaw[d] ?? 0) / cMax * 100).clamp(0.0, 100.0) : 0.0;

      // If there are no cross-scored items for this dimension (e.g. a very
      // small question bank), fall back to 100 % primary.
      final blend = cMax > 0
          ? pNorm * primaryWeight + cNorm * (1 - primaryWeight)
          : pNorm;

      normalizedScores[d] = blend.clamp(0.0, 100.0).toDouble();
    }

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

  // ── Helpers for ceiling calculation ──────────────────────────────────────

  /// Sum of best-possible raw points per dimension, split by primary/cross
  /// role, across only the [answeredQuestionIds].
  static Map<EQDimension, double> maxAchievableRawByDimensionForAnswers({
    required List<Question> questions,
    required Set<String> answeredQuestionIds,
  }) {
    // Public API returns the *total* ceiling (primary + cross) for backwards
    // compatibility with any callers that inspect overall headroom.
    final p = _maxRawByRole(questions, answeredQuestionIds, _Role.primary);
    final c = _maxRawByRole(questions, answeredQuestionIds, _Role.cross);
    return {
      for (final d in EQDimension.values) d: (p[d] ?? 0) + (c[d] ?? 0),
    };
  }

  /// Best-achievable score per dimension filtered by [role].
  static Map<EQDimension, double> _maxRawByRole(
    List<Question> questions,
    Set<String> answeredQuestionIds,
    _Role role,
  ) {
    final maxes = {for (final d in EQDimension.values) d: 0.0};
    for (final q in questions) {
      if (!answeredQuestionIds.contains(q.id)) continue;
      for (final d in EQDimension.values) {
        // Skip dimensions that don't match the requested role for this Q.
        final isPrimary = d == q.primaryDimension;
        if (role == _Role.primary && !isPrimary) continue;
        if (role == _Role.cross && isPrimary) continue;

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
    await _ensureLoaded();
    _history.add(result);
    await _persist();
    return right(unit);
  }

  @override
  Future<Either<Failure, List<AssessmentResult>>> getHistory() async {
    await _ensureLoaded();
    return right(List<AssessmentResult>.unmodifiable(_history));
  }

  @override
  Future<Either<Failure, AssessmentResult?>> getLatestResult() async {
    await _ensureLoaded();
    if (_history.isEmpty) return right(null);
    return right(_history.last);
  }
}
