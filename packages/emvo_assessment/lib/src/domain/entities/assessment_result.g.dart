// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssessmentResultImpl _$$AssessmentResultImplFromJson(
        Map<String, dynamic> json) =>
    _$AssessmentResultImpl(
      id: json['id'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      dimensionScores: _dimensionScoresFromJson(json['dimensionScores']),
      overallScore: (json['overallScore'] as num).toDouble(),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => DimensionInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      answers: Map<String, String>.from(json['answers'] as Map),
    );

Map<String, dynamic> _$$AssessmentResultImplToJson(
        _$AssessmentResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'completedAt': instance.completedAt.toIso8601String(),
      'dimensionScores': _dimensionScoresToJson(instance.dimensionScores),
      'overallScore': instance.overallScore,
      'insights': instance.insights.map((e) => e.toJson()).toList(),
      'recommendations': instance.recommendations,
      'answers': instance.answers,
    };

_$DimensionInsightImpl _$$DimensionInsightImplFromJson(
        Map<String, dynamic> json) =>
    _$DimensionInsightImpl(
      dimension: $enumDecode(_$EQDimensionEnumMap, json['dimension']),
      score: (json['score'] as num).toDouble(),
      level: json['level'] as String,
      description: json['description'] as String,
      growthAreas: (json['growthAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$DimensionInsightImplToJson(
        _$DimensionInsightImpl instance) =>
    <String, dynamic>{
      'dimension': _$EQDimensionEnumMap[instance.dimension]!,
      'score': instance.score,
      'level': instance.level,
      'description': instance.description,
      'growthAreas': instance.growthAreas,
    };

const _$EQDimensionEnumMap = {
  EQDimension.selfAwareness: 'selfAwareness',
  EQDimension.selfRegulation: 'selfRegulation',
  EQDimension.empathy: 'empathy',
  EQDimension.socialSkills: 'socialSkills',
};
