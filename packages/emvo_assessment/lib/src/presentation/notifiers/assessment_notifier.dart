import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/assessment_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../domain/repositories/question_repository.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  throw UnimplementedError('Override in main.dart');
});

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  throw UnimplementedError('Override in main.dart');
});

final assessmentNotifierProvider =
    StateNotifierProvider<AssessmentNotifier, AssessmentState>((ref) {
  return AssessmentNotifier(
    ref.watch(questionRepositoryProvider),
    ref.watch(assessmentRepositoryProvider),
  );
});

enum AssessmentStatus { initial, loading, inProgress, completed, error }

class AssessmentState {
  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.result,
    this.errorMessage,
  });

  final AssessmentStatus status;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, String> answers;
  final AssessmentResult? result;
  final String? errorMessage;

  AssessmentState copyWith({
    AssessmentStatus? status,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, String>? answers,
    AssessmentResult? result,
    String? errorMessage,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get isLastQuestion =>
      questions.isNotEmpty && currentQuestionIndex >= questions.length - 1;
  Question? get currentQuestion =>
      questions.isEmpty ? null : questions[currentQuestionIndex];
  double get progress => questions.isEmpty
      ? 0
      : (currentQuestionIndex + 1) / questions.length;
}

class AssessmentNotifier extends StateNotifier<AssessmentState> {
  AssessmentNotifier(this._questionRepository, this._assessmentRepository)
      : super(const AssessmentState());

  final QuestionRepository _questionRepository;
  final AssessmentRepository _assessmentRepository;

  Future<void> loadQuestions() async {
    state = state.copyWith(status: AssessmentStatus.loading);

    final result = await _questionRepository.getQuestions();

    result.fold(
      (failure) => state = state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: failure.message,
      ),
      (questions) => state = state.copyWith(
        status: AssessmentStatus.inProgress,
        questions: questions,
        currentQuestionIndex: 0,
      ),
    );
  }

  void answerQuestion(String optionId) {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return;

    final newAnswers = Map<String, String>.from(state.answers)
      ..[currentQuestion.id] = optionId;

    state = state.copyWith(answers: newAnswers);
  }

  void nextQuestion() {
    if (!state.isLastQuestion) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  void previousQuestion() {
    if (!state.isFirstQuestion) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  Future<AssessmentResult?> calculateResult() async {
    final result = _assessmentRepository.calculateResult(
      answers: state.answers,
      questions: state.questions,
    );

    state = state.copyWith(
      status: AssessmentStatus.completed,
      result: result,
    );

    final saveOutcome = await _assessmentRepository.saveResult(result);
    saveOutcome.fold(
      (failure) => state = state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: failure.message,
      ),
      (_) {},
    );

    return result;
  }

  void reset() {
    state = const AssessmentState();
  }
}
