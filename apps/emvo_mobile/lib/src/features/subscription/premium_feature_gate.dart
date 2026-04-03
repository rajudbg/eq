import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

/// Shows [child] when the user has access to [feature]; otherwise shows a
/// conversion-focused locked state with a CTA to the paywall.
class PremiumFeatureGate extends ConsumerWidget {
  const PremiumFeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.lockedTitle = 'Premium feature',
    this.lockedSubtitle =
        'Upgrade to unlock this and the rest of your growth toolkit.',
    this.source = 'gate',
  });

  final SubscriptionFeature feature;
  final Widget child;
  final String lockedTitle;
  final String lockedSubtitle;

  /// Passed to `/paywall?source=` for analytics.
  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess = ref.watch(canAccessPremiumFeature(feature));

    if (hasAccess) return child;

    return _LockedPremiumCard(
      title: lockedTitle,
      subtitle: lockedSubtitle,
      onUnlock: () => context.push('/paywall?source=$source'),
    );
  }
}

/// Wraps [builder] with premium access; if locked, [builder] receives `false`
/// and you can still render custom UI.
class PremiumAccessBuilder extends ConsumerWidget {
  const PremiumAccessBuilder({
    super.key,
    required this.feature,
    required this.builder,
  });

  final SubscriptionFeature feature;
  final Widget Function(BuildContext context, bool hasAccess) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess = ref.watch(canAccessPremiumFeature(feature));
    return builder(context, hasAccess);
  }
}

class _LockedPremiumCard extends StatelessWidget {
  const _LockedPremiumCard({
    required this.title,
    required this.subtitle,
    required this.onUnlock,
  });

  final String title;
  final String subtitle;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: EmvoColors.primary, size: 28),
              const SizedBox(width: EmvoDimensions.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EmvoDimensions.sm),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EmvoColors.onBackground.withValues(alpha: 0.75),
                ),
          ),
          const SizedBox(height: EmvoDimensions.md),
          AnimatedButton(
            text: 'See plans',
            onPressed: onUnlock,
            width: double.infinity,
            icon: Icons.workspace_premium_outlined,
          ),
        ],
      ),
    );
  }
}

/// Navigates to the paywall when [feature] is not available. Returns `true` if
/// the user already has access.
Future<bool> ensurePremiumFeature(
  BuildContext context,
  WidgetRef ref, {
  required SubscriptionFeature feature,
  String source = 'inline',
}) async {
  final hasAccess = ref.read(canAccessPremiumFeature(feature));
  if (hasAccess) return true;

  await context.push('/paywall?source=$source');
  return ref.read(canAccessPremiumFeature(feature));
}
