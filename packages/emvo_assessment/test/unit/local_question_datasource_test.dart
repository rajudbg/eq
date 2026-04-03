import 'package:flutter_test/flutter_test.dart';

import 'package:emvo_assessment/emvo_assessment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads 16 questions from bundled questions.json', () async {
    final ds = LocalQuestionDataSource();
    final questions = await ds.getQuestions();

    expect(questions, isNotEmpty);
    expect(questions.length, 16);
    expect(questions.first.id, 'sa_001');
    expect(questions.first.options, hasLength(4));
  });
}
