// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionImpl _$$QuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionImpl(
      id: json['id'] as String,
      scenario: json['scenario'] as String,
      primaryDimension:
          $enumDecode(_$EQDimensionEnumMap, json['primaryDimension']),
      options: (json['options'] as List<dynamic>)
          .map((e) => AnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      context: json['context'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$QuestionImplToJson(_$QuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scenario': instance.scenario,
      'primaryDimension': _$EQDimensionEnumMap[instance.primaryDimension]!,
      'options': instance.options,
      'context': instance.context,
      'difficulty': instance.difficulty,
    };

const _$EQDimensionEnumMap = {
  EQDimension.selfAwareness: 'selfAwareness',
  EQDimension.selfRegulation: 'selfRegulation',
  EQDimension.empathy: 'empathy',
  EQDimension.socialSkills: 'socialSkills',
};

_$AnswerOptionImpl _$$AnswerOptionImplFromJson(Map<String, dynamic> json) =>
    _$AnswerOptionImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      scores: _scoresFromJson(json['scores']),
      emotionalTone: json['emotionalTone'] as String?,
    );

Map<String, dynamic> _$$AnswerOptionImplToJson(_$AnswerOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'scores': _scoresToJson(instance.scores),
      'emotionalTone': instance.emotionalTone,
    };
