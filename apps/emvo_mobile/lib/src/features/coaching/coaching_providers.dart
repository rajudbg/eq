import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';

/// Shown when suggested-prompt API fails or returns empty.
const kDefaultSuggestedPrompts = <String>[
  "I'm feeling overwhelmed today",
  'Help me prepare for a difficult conversation',
  'Why do I react so strongly to criticism?',
  'Teach me a quick calming technique',
];

/// Loads starter prompts from the active coaching backend (OpenRouter or mock).
/// Times out quickly so the coach screen never sits on a spinner for starters.
final suggestedPromptsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(coachingRepositoryProvider);
  try {
    final result = await repo.getSuggestedPrompts().timeout(
          const Duration(seconds: 12),
        );
    return result.fold(
      (_) => kDefaultSuggestedPrompts,
      (prompts) => prompts.isEmpty ? kDefaultSuggestedPrompts : prompts,
    );
  } on TimeoutException {
    return kDefaultSuggestedPrompts;
  }
});

final coachingSessionProvider = FutureProvider<CoachingSession>((ref) async {
  final repo = ref.watch(coachingRepositoryProvider);
  final result = await repo.getActiveSession();
  return result.getOrElse((f) => throw Exception(f.message));
});

final sendMessageProvider = Provider<Future<void> Function(String)>((ref) {
  return (String content) async {
    final repo = ref.read(coachingRepositoryProvider);
    final result = await repo.sendMessage(content);
    result.fold(
      (f) => throw Exception(f.message),
      (_) {},
    );
    ref.invalidate(coachingSessionProvider);
  };
});
