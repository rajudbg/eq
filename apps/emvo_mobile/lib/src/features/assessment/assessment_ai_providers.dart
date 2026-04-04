import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';

import '../../providers/assessment_providers.dart';
import 'assessment_ai_bridge.dart';

/// `true` only if you intentionally want the web build to call OpenRouter from the
/// browser (requires a CORS proxy or similar; default is off because it fails in Chrome).
const _kOpenRouterAllowBrowser = bool.fromEnvironment(
  'OPENROUTER_ALLOW_BROWSER',
  defaultValue: false,
);

/// Personalized headline + story + actions (OpenRouter on mobile/desktop when key set).
///
/// Web/Chrome cannot reach OpenRouter directly (CORS), so we use the same rich
/// built-in template there unless [OPENROUTER_ALLOW_BROWSER] is enabled.
final assessmentNarrativeProvider =
    FutureProvider.autoDispose<AssessmentAiNarrative?>((ref) async {
  ref.watch(assessmentNotifierProvider);
  var result = ref.read(assessmentNotifierProvider).result;

  // Fall back to repository latest when notifier has no in-memory result (rare timing / navigation).
  if (result == null) {
    ref.watch(latestResultProvider);
    result = ref.read(latestResultProvider).valueOrNull;
  }

  if (result == null) return null;

  // Avoid autoDispose dropping an in-flight request when the widget tree flickers
  // after `context.go('/results')`, which previously left a blank analysis section.
  ref.keepAlive();

  final payload = assessmentToNarrativePayload(result);

  Future<AssessmentAiNarrative> builtInSummary() async {
    final either = await AssessmentAiNarrativeService.localOnly().generate(
      payload,
    );
    return either.getOrElse(
      (_) => const AssessmentAiNarrative(
        headline: 'Thanks for completing your assessment',
        narrative:
            'Your scores reflect how you tend to respond in the scenarios you saw. '
            'Use the strengths and plan below to guide practice—small, steady habits add up.',
        actions: [
          'Name one emotion out loud before your next stressful moment',
          'After a tough chat, jot one line: what you felt vs. what you needed',
          'Open coaching and rehearse your first sentence before a hard conversation',
        ],
        usedLlm: false,
      ),
    );
  }

  try {
    final skipRemote = kIsWeb && !_kOpenRouterAllowBrowser;
    if (skipRemote) {
      return await builtInSummary();
    }

    final remoteFuture = createAssessmentAiNarrativeService().generate(payload);
    final either = await remoteFuture.timeout(
      const Duration(seconds: 22),
      onTimeout: () => throw TimeoutException('assessment narrative'),
    );
    return either.fold<AssessmentAiNarrative?>(
          (_) => null,
          (n) => n,
        ) ??
        await builtInSummary();
  } catch (_) {
    return await builtInSummary();
  }
});
