import '../../domain/entities/question.dart';

extension QuestionModel on Question {
  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      scenario: json['scenario'] as String,
      primaryDimension: EQDimension.values.firstWhere(
        (e) => e.name == json['primaryDimension'],
      ),
      options: (json['options'] as List<dynamic>)
          .map(
            (o) => AnswerOptionModel.fromJson(
              Map<String, dynamic>.from(o as Map),
            ),
          )
          .toList(),
      context: json['context'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt(),
    );
  }
}

extension AnswerOptionModel on AnswerOption {
  static AnswerOption fromJson(Map<String, dynamic> json) {
    final scoresMap = (json['scores'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        EQDimension.values.firstWhere((e) => e.name == key),
        (value as num).toInt(),
      ),
    );

    return AnswerOption(
      id: json['id'] as String,
      text: json['text'] as String,
      scores: scoresMap,
      emotionalTone: json['emotionalTone'] as String?,
    );
  }
}
