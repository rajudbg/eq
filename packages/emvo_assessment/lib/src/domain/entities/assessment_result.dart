import 'package:freezed_annotation/freezed_annotation.dart';

import 'question.dart';

part 'assessment_result.freezed.dart';
part 'assessment_result.g.dart';

Map<EQDimension, double> _dimensionScoresFromJson(Object? json) {
  if (json is! Map) return {};
  return json.map(
    (key, value) => MapEntry(
      EQDimension.values.byName(key as String),
      (value as num).toDouble(),
    ),
  );
}

Map<String, dynamic> _dimensionScoresToJson(Map<EQDimension, double> scores) {
  return scores.map((k, v) => MapEntry(k.name, v));
}

@freezed
class AssessmentResult with _$AssessmentResult {
  @JsonSerializable(explicitToJson: true)
  const factory AssessmentResult({
    required String id,
    required DateTime completedAt,
    @JsonKey(fromJson: _dimensionScoresFromJson, toJson: _dimensionScoresToJson)
    required Map<EQDimension, double> dimensionScores,
    required double overallScore,
    required List<DimensionInsight> insights,
    required List<String> recommendations,
    required Map<String, String> answers,
  }) = _AssessmentResult;

  factory AssessmentResult.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResultFromJson(json);
}

@freezed
class DimensionInsight with _$DimensionInsight {
  @JsonSerializable(explicitToJson: true)
  const factory DimensionInsight({
    required EQDimension dimension,
    required double score,
    required String level,
    required String description,
    required List<String> growthAreas,
  }) = _DimensionInsight;

  factory DimensionInsight.fromJson(Map<String, dynamic> json) =>
      _$DimensionInsightFromJson(json);
}
