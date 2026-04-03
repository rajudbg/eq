import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';
part 'question.g.dart';

@JsonEnum()
enum EQDimension {
  selfAwareness,
  selfRegulation,
  empathy,
  socialSkills,
}

extension EQDimensionExtension on EQDimension {
  String get displayName {
    switch (this) {
      case EQDimension.selfAwareness:
        return 'Self-Awareness';
      case EQDimension.selfRegulation:
        return 'Self-Regulation';
      case EQDimension.empathy:
        return 'Empathy';
      case EQDimension.socialSkills:
        return 'Social Skills';
    }
  }

  String get description {
    switch (this) {
      case EQDimension.selfAwareness:
        return 'Recognizing your own emotions';
      case EQDimension.selfRegulation:
        return 'Managing your reactions';
      case EQDimension.empathy:
        return 'Understanding others';
      case EQDimension.socialSkills:
        return 'Navigating relationships';
    }
  }
}

@freezed
class Question with _$Question {
  const factory Question({
    required String id,
    required String scenario,
    required EQDimension primaryDimension,
    required List<AnswerOption> options,
    String? context, // e.g., "workplace", "family", "social"
    int? difficulty, // 1-3
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@freezed
class AnswerOption with _$AnswerOption {
  const factory AnswerOption({
    required String id,
    required String text,
    // ignore: invalid_annotation_target — Freezed factory params map to fields
    @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
    required Map<EQDimension, int> scores, // Points per dimension
    String? emotionalTone, // "positive", "neutral", "avoidant", "aggressive"
  }) = _AnswerOption;

  factory AnswerOption.fromJson(Map<String, dynamic> json) =>
      _$AnswerOptionFromJson(json);
}

Map<EQDimension, int> _scoresFromJson(Object? json) {
  if (json is! Map) return {};
  return json.map(
    (key, value) => MapEntry(
      EQDimension.values.byName(key as String),
      (value as num).toInt(),
    ),
  );
}

Map<String, dynamic> _scoresToJson(Map<EQDimension, int> scores) {
  return scores.map((k, v) => MapEntry(k.name, v));
}
