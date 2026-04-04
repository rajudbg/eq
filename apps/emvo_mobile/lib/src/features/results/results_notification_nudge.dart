import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/theme_settings_provider.dart';

const _kResultsNotifNudgeDone = 'results_notif_nudge_done_v1';

/// Ask for notification permission after results — higher intent than onboarding.
class ResultsNotificationNudge {
  static Future<void> maybeShow(BuildContext context, WidgetRef ref) async {
    if (kIsWeb || !context.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kResultsNotifNudgeDone) == true) return;

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Stay on track?',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Turn on gentle reminders for your daily check-in and situations '
                'you log — we cap how many you get per day so it stays helpful, '
                'not noisy.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.78),
                    ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  await prefs.setBool(_kResultsNotifNudgeDone, true);
                  await ref
                      .read(notificationsEnabledProvider.notifier)
                      .setEnabled(true);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Turn on reminders'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await prefs.setBool(_kResultsNotifNudgeDone, true);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
