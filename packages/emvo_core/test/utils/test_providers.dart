import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockQuestionRepository extends Mock implements QuestionRepository {}

class MockAssessmentRepository extends Mock implements AssessmentRepository {}

class MockCoachingRepository extends Mock implements CoachingRepository {}

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

/// Creates a [ProviderContainer] with mocked dependencies.
ProviderContainer createMockContainer({
  QuestionRepository? questionRepo,
  AssessmentRepository? assessmentRepo,
  CoachingRepository? coachingRepo,
  SubscriptionRepository? subscriptionRepo,
}) {
  return ProviderContainer(
    overrides: [
      if (questionRepo != null)
        questionRepositoryProvider.overrideWithValue(questionRepo),
      if (assessmentRepo != null)
        assessmentRepositoryProvider.overrideWithValue(assessmentRepo),
      if (coachingRepo != null)
        coachingRepositoryProvider.overrideWithValue(coachingRepo),
      if (subscriptionRepo != null)
        subscriptionRepositoryProvider.overrideWithValue(subscriptionRepo),
    ],
  );
}
