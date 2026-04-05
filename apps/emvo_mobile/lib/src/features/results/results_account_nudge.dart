import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/app_state_providers.dart';
import '../../routing/routing.dart';

const _kLegacyDone = 'results_account_nudge_done_v1';
const _kDoneV2 = 'results_account_nudge.done_v2';
const _kBoundUser = 'results_account_nudge.bound_user_v2';
const _kGuestSentinel = '__guest__';

/// Soft account prompt after first results — guest only, peak motivation.
///
/// Dismiss state is stored with [\_kBoundUser] so a future backend auth id can
/// align with the same key. Reinstall still clears prefs (cloud backup TBD).
class ResultsAccountNudge {
  static Future<void> _migrateLegacy(SharedPreferences prefs) async {
    if (prefs.getBool(_kLegacyDone) == true &&
        prefs.getBool(_kDoneV2) != true) {
      await prefs.setBool(_kDoneV2, true);
      await prefs.setString(_kBoundUser, _kGuestSentinel);
    }
  }

  static Future<void> _persistDismiss(
    SharedPreferences prefs, {
    required String boundUser,
  }) async {
    await prefs.setBool(_kDoneV2, true);
    await prefs.setString(_kBoundUser, boundUser);
  }

  static Future<void> maybeShow(BuildContext context, WidgetRef ref) async {
    if (kIsWeb || !context.mounted) return;
    if (ref.read(authProvider)) return;

    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacy(prefs);

    if (prefs.getBool(_kDoneV2) == true) return;

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GlassContainer(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Save your progress?',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 280.ms, curve: Curves.easeOutCubic)
                      .slideY(
                        begin: 0.05,
                        duration: 320.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in with Google, Apple, Facebook, or email so your EQ results '
                    'and coach history stay with you if you switch phones. You can skip '
                    '— nothing is lost on this device.',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: scheme.onSurface.withValues(alpha: 0.76),
                        ),
                  ).animate().fadeIn(
                        delay: 40.ms,
                        duration: 320.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        context.push('${Routes.login}?mode=register');
                      });
                    },
                    child: const Text('Create account'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      final p = await SharedPreferences.getInstance();
                      await _persistDismiss(p, boundUser: _kGuestSentinel);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Not now'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
