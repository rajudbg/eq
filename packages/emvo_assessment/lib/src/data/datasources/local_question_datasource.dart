import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/question.dart';
import '../models/question_model.dart';

/// Loads a bundled assessment JSON (`questions` array). Defaults to
/// [defaultAssetPath]; falls back to embedded scenarios if the asset cannot be read
/// (e.g. tests without assets, misconfigured build).
class LocalQuestionDataSource {
  LocalQuestionDataSource({String? assetPath})
      : _assetPath = assetPath ?? defaultAssetPath;

  /// Standard 16-question bank when no intent-specific pack is selected.
  static const String defaultAssetPath =
      'packages/emvo_assessment/lib/src/data/questions.json';

  final String _assetPath;

  Future<List<Question>> getQuestions() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final questionsJson = jsonMap['questions'] as List<dynamic>;

      return questionsJson
          .map((q) =>
              QuestionModel.fromJson(Map<String, dynamic>.from(q as Map)))
          .toList();
    } on Object {
      return _getFallbackQuestions();
    }
  }

  List<Question> _getFallbackQuestions() {
    final decoded = jsonDecode(_fallbackQuestionsJson) as List<dynamic>;
    return decoded
        .map((q) => QuestionModel.fromJson(Map<String, dynamic>.from(q as Map)))
        .toList();
  }
}

/// First four entries from [questions.json] (sa_001 … sr_002) for offline fallback.
const String _fallbackQuestionsJson = '''
[
  {
    "id": "sa_001",
    "scenario": "You wake up feeling off but cannot name the emotion. You...",
    "primaryDimension": "selfAwareness",
    "context": "personal",
    "difficulty": 1,
    "options": [
      {"id": "a", "text": "Ignore it and start your day", "scores": {"selfAwareness": 1, "selfRegulation": 2}, "emotionalTone": "avoidant"},
      {"id": "b", "text": "Try to push through the feeling", "scores": {"selfAwareness": 2, "selfRegulation": 1}, "emotionalTone": "neutral"},
      {"id": "c", "text": "Pause and scan your body for clues", "scores": {"selfAwareness": 5, "selfRegulation": 3}, "emotionalTone": "positive"},
      {"id": "d", "text": "Journal what might be causing it", "scores": {"selfAwareness": 4, "selfRegulation": 4}, "emotionalTone": "positive"}
    ]
  },
  {
    "id": "sa_002",
    "scenario": "During a meeting, you notice your heart racing. You realize...",
    "primaryDimension": "selfAwareness",
    "context": "workplace",
    "difficulty": 2,
    "options": [
      {"id": "a", "text": "You are anxious about presenting", "scores": {"selfAwareness": 5, "selfRegulation": 3}, "emotionalTone": "positive"},
      {"id": "b", "text": "The room is too hot", "scores": {"selfAwareness": 2, "selfRegulation": 2}, "emotionalTone": "neutral"},
      {"id": "c", "text": "Someone is wrong and you want to correct them", "scores": {"selfAwareness": 3, "selfRegulation": 1}, "emotionalTone": "aggressive"},
      {"id": "d", "text": "You do not notice anything", "scores": {"selfAwareness": 1, "selfRegulation": 1}, "emotionalTone": "avoidant"}
    ]
  },
  {
    "id": "sr_001",
    "scenario": "You receive an angry email from a client. Your first instinct is to fire back. You...",
    "primaryDimension": "selfRegulation",
    "context": "workplace",
    "difficulty": 2,
    "options": [
      {"id": "a", "text": "Write a draft immediately to vent", "scores": {"selfAwareness": 2, "selfRegulation": 1}, "emotionalTone": "aggressive"},
      {"id": "b", "text": "Wait 24 hours before responding", "scores": {"selfAwareness": 3, "selfRegulation": 5}, "emotionalTone": "positive"},
      {"id": "c", "text": "Call them to discuss immediately", "scores": {"selfAwareness": 3, "selfRegulation": 3, "socialSkills": 3}, "emotionalTone": "neutral"},
      {"id": "d", "text": "Forward to your manager to handle", "scores": {"selfAwareness": 2, "selfRegulation": 2}, "emotionalTone": "avoidant"}
    ]
  },
  {
    "id": "sr_002",
    "scenario": "You are stuck in traffic and will be late. You feel frustration rising. You...",
    "primaryDimension": "selfRegulation",
    "context": "personal",
    "difficulty": 1,
    "options": [
      {"id": "a", "text": "Honk and yell at other drivers", "scores": {"selfRegulation": 1, "selfAwareness": 1}, "emotionalTone": "aggressive"},
      {"id": "b", "text": "Accept you cannot control traffic", "scores": {"selfRegulation": 5, "selfAwareness": 4}, "emotionalTone": "positive"},
      {"id": "c", "text": "Complain to someone on the phone", "scores": {"selfRegulation": 2, "socialSkills": 2}, "emotionalTone": "avoidant"},
      {"id": "d", "text": "Take deep breaths and notify who is waiting", "scores": {"selfRegulation": 4, "socialSkills": 4}, "emotionalTone": "positive"}
    ]
  }
]
''';
