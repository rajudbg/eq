import 'package:emvo_assessment/emvo_assessment.dart';

/// JSON-safe map for the coach (no emvo_assessment types in emvo_core).
Map<String, dynamic> assessmentToCoachingContext(AssessmentResult result) {
  final byScore = List<DimensionInsight>.from(result.insights)
    ..sort((a, b) => a.score.compareTo(b.score));
  final growthDimensions =
      byScore.take(2).map((i) => i.dimension.name).toList();

  return {
    'overallScore': result.overallScore,
    'dimensionScores': {
      for (final e in result.dimensionScores.entries) e.key.name: e.value,
    },
    'growthDimensions': growthDimensions,
    'completedAt': result.completedAt.toIso8601String(),
  };
}

/// Rich payload for results-screen LLM narrative.
Map<String, dynamic> assessmentToNarrativePayload(AssessmentResult result) {
  return {
    'overallScore': result.overallScore,
    'dimensionScores': {
      for (final e in result.dimensionScores.entries) e.key.name: e.value,
    },
    'insights': result.insights
        .map(
          (i) => {
            'dimension': i.dimension.name,
            'score': i.score,
            'level': i.level,
            'description': i.description,
            'growthAreas': i.growthAreas,
          },
        )
        .toList(),
    'recommendations': result.recommendations,
  };
}
