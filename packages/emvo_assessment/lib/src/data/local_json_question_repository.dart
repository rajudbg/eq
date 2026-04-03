import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:emvo_core/emvo_core.dart';

import '../domain/entities/question.dart';
import '../domain/repositories/question_repository.dart';
import 'models/question_model.dart';

/// Loads the bundled [questions.json] asset (16 swappable scenarios).
///
/// Asset path must match [pubspec.yaml] `flutter.assets` and the consuming
/// app must depend on this package so the asset is included in the build.
class LocalJsonQuestionRepository implements QuestionRepository {
  LocalJsonQuestionRepository({
    this.assetPath = 'packages/emvo_assessment/lib/src/data/questions.json',
  });

  final String assetPath;

  List<Question>? _cache;

  Future<Either<Failure, List<Question>>> _loadAll() async {
    if (_cache != null) {
      return right(_cache!);
    }
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = decoded['questions'] as List<dynamic>;
      _cache = list
          .map(
            (e) => QuestionModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      return right(_cache!);
    } on Object catch (e) {
      return left(GenericFailure('Failed to load assessment questions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestions() => _loadAll();

  @override
  Future<Either<Failure, List<Question>>> getQuestionsByDimension(
    EQDimension dimension,
  ) async {
    final result = await _loadAll();
    return result.map(
      (questions) => questions
          .where((q) => q.primaryDimension == dimension)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) async {
    final result = await _loadAll();
    return result.flatMap((questions) {
      for (final q in questions) {
        if (q.id == id) {
          return right(q);
        }
      }
      return left(
        GenericFailure('Question not found: $id'),
      );
    });
  }

  @override
  Future<Either<Failure, Unit>> refreshQuestions() async {
    _cache = null;
    final result = await _loadAll();
    return result.map((_) => unit);
  }
}
