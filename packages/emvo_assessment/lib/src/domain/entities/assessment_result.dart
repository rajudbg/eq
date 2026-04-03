import 'package:freezed_annotation/freezed_annotation.dart';

import 'question.dart';

part 'assessment_result.freezed.dart';

@freezed
class AssessmentResult with _$AssessmentResult {
  const factory AssessmentResult({
    required String id,
    required DateTime completedAt,
    required Map<EQDimension, double> dimensionScores, // 0-100
    required double overallScore,
    required List<DimensionInsight> insights,
    required List<String> recommendations,
    required Map<String, String> answers, // questionId -> optionId
  }) = _AssessmentResult;
}

@freezed
class DimensionInsight with _$DimensionInsight {
  const factory DimensionInsight({
    required EQDimension dimension,
    required double score,
    required String level, // "Developing", "Proficient", "Advanced"
    required String description,
    required List<String> growthAreas,
  }) = _DimensionInsight;
}
