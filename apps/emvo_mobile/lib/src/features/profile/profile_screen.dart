import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/assessment_providers.dart';
import '../../providers/firebase_auth_providers.dart';
import '../../providers/profile_display_name_provider.dart';
import '../../providers/theme_settings_provider.dart';
import '../../providers/user_intent_provider.dart';
import '../../routing/routing.dart';

/// “You” tab — identity, shortcuts to settings and reminders.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(effectiveProfileDisplayNameProvider);
    final notifications = ref.watch(notificationsEnabledProvider);
    final intentAsync = ref.watch(userIntentProvider);
    final intent = intentAsync.valueOrNull;
    final latest = ref.watch(latestResultProvider).valueOrNull;
    final firebaseLinked = ref.watch(firebaseSignedInWithProviderProvider);
    final scheme = Theme.of(context).colorScheme;

    final scores = latest?.dimensionScores;
    EQDimension? strongest;
    EQDimension? growth;
    if (scores != null && scores.isNotEmpty) {
      var hi = -1.0;
      var lo = double.infinity;
      for (final e in scores.entries) {
        if (e.value > hi) {
          hi = e.value;
          strongest = e.key;
        }
        if (e.value < lo) {
          lo = e.value;
          growth = e.key;
        }
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('You'),
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EmvoDimensions.paddingScreen,
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: scheme.primary.withValues(alpha: 0.18),
                      child: Text(
                        (name != null && name.isNotEmpty)
                            ? name[0].toUpperCase()
                            : 'E',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (name != null && name.isNotEmpty)
                                ? name
                                : 'Emvo member',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your Home dashboard greets you here first.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.65),
                                  height: 1.35,
                                ),
                          ),
                          if (intent != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(intent.icon,
                                    size: 18, color: scheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Focus: ${intent.label}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (strongest != null && growth != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              strongest == growth
                                  ? 'Latest snapshot: ${strongest.displayName} leads — '
                                      'scores are close across dimensions.'
                                  : 'Strongest right now: ${strongest.displayName}. '
                                      'Room to grow: ${growth.displayName}.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.68),
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _section(context, 'Shortcuts'),
              if (!firebaseLinked) ...[
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Icon(Icons.login_rounded, color: scheme.primary),
                    title: const Text('Sign in'),
                    subtitle: const Text(
                      'Google, Apple, Facebook, or email — sync across devices',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.login),
                  ),
                ),
              ],
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.settings_outlined, color: scheme.primary),
                      title: const Text('Settings'),
                      subtitle: const Text(
                          'Theme, greeting name, coach & notifications'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.settings),
                    ),
                    Divider(
                        height: 1,
                        color: scheme.outline.withValues(alpha: 0.2)),
                    ListTile(
                      leading: Icon(
                        notifications
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: scheme.primary,
                      ),
                      title: const Text('Reminders'),
                      subtitle: Text(
                        notifications
                            ? 'On — daily check-in & situation nudges'
                            : 'Off — turn on in Settings when you are ready',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.settings),
                    ),
                    Divider(
                        height: 1,
                        color: scheme.outline.withValues(alpha: 0.2)),
                    ListTile(
                      leading: Icon(Icons.workspace_premium_outlined,
                          color: scheme.primary),
                      title: const Text('Emvo Premium'),
                      subtitle: const Text('Unlimited coaching & full history'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.paywall),
                    ),
                  ],
                ),
              ),
              _section(context, 'Tip'),
              Text(
                'Open Home after a notification to land on your check-in, situations, '
                'and EQ snapshot in the order that matches your day.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: scheme.onSurface.withValues(alpha: 0.72),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
