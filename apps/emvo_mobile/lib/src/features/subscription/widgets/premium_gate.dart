import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../../routing/routing.dart';

/// Wraps a premium feature with a gate that shows paywall if not subscribed
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.child,
    required this.feature,
    this.featureName,
  });

  final Widget child;
  final SubscriptionFeature feature;
  final String? featureName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess = ref.watch(canAccessPremiumFeature(feature));

    if (hasAccess) {
      return child;
    }

    return _LockedFeatureOverlay(
      featureName: featureName ?? 'Premium Feature',
      child: child,
      onUpgrade: () => context.push(Routes.paywall),
    );
  }
}

class _LockedFeatureOverlay extends StatelessWidget {
  const _LockedFeatureOverlay({
    required this.featureName,
    required this.child,
    required this.onUpgrade,
  });

  final String featureName;
  final Widget child;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scrim = isDark
        ? Colors.black.withValues(alpha: 0.58)
        : scheme.surface.withValues(alpha: 0.82);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        AbsorbPointer(
          child: Opacity(
            opacity: 0.35,
            child: child,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: scrim,
          ),
        ),
        Center(
          child: GlassContainer(
            margin: const EdgeInsets.all(EmvoDimensions.lg),
            padding: const EdgeInsets.all(EmvoDimensions.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: scheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Premium Feature',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upgrade to access $featureName and unlock your full EQ potential',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.85),
                      ),
                ),
                const SizedBox(height: 24),
                AnimatedButton(
                  text: 'Upgrade Now',
                  onPressed: onUpgrade,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Badge to show on premium features
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: EmvoColors.primaryGradient,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
