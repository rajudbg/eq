import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
import '../../routing/routing.dart';

/// Short, skippable explanation of the four EQ dimensions before intent/assessment.
///
/// Open with `?review=1` from Settings — back pops without changing “seen” state.
class EqDimensionsIntroScreen extends ConsumerWidget {
  const EqDimensionsIntroScreen({super.key});

  static bool _isReviewMode(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters['review'] == '1';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final review = _isReviewMode(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            review ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
            color: scheme.primary,
          ),
          tooltip: review ? 'Close' : 'Back',
          onPressed: () {
            if (review && GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(Routes.welcome);
            }
          },
        ),
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EmvoDimensions.paddingScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'How Emvo measures EQ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You’ll answer realistic scenarios. We map your choices to four '
                  'skills — no right-or-wrong personality labels, just a snapshot '
                  'of how you tend to respond today.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                        color: context.emvoOnSurface(0.72),
                      ),
                ),
                const SizedBox(height: 24),
                for (final d in EQDimension.values) ...[
                  _DimensionLessonCard(dimension: d),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                if (!review) ...[
                  AnimatedButton(
                    text: 'Continue',
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await ref
                          .read(eqDimensionsIntroSeenProvider.notifier)
                          .markSeen();
                      if (context.mounted) context.go(Routes.intent);
                    },
                    width: double.infinity,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      HapticFeedback.selectionClick();
                      await ref
                          .read(eqDimensionsIntroSeenProvider.notifier)
                          .markSeen();
                      if (context.mounted) context.go(Routes.intent);
                    },
                    child: const Text('Skip intro'),
                  ),
                ] else ...[
                  AnimatedButton(
                    text: 'Done',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (GoRouter.of(context).canPop()) context.pop();
                    },
                    width: double.infinity,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DimensionLessonCard extends StatelessWidget {
  const _DimensionLessonCard({required this.dimension});

  final EQDimension dimension;

  @override
  Widget build(BuildContext context) {
    final (icon, accent) = _styleFor(dimension);
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dimension.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dimension.description,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: context.emvoOnSurface(0.55),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _longBlurb(dimension),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: context.emvoOnSurface(0.78),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (IconData, Color) _styleFor(EQDimension d) {
    switch (d) {
      case EQDimension.selfAwareness:
        return (Icons.psychology_outlined, EmvoColors.primary);
      case EQDimension.selfRegulation:
        return (Icons.spa_outlined, EmvoColors.secondary);
      case EQDimension.empathy:
        return (Icons.favorite_border_rounded, EmvoColors.tertiary);
      case EQDimension.socialSkills:
        return (Icons.groups_2_outlined, EmvoColors.success);
    }
  }

  static String _longBlurb(EQDimension d) {
    switch (d) {
      case EQDimension.selfAwareness:
        return 'Noticing feelings as they show up — in your body and thoughts — '
            'so you can name them before you act.';
      case EQDimension.selfRegulation:
        return 'Staying steady under pressure: short pauses, calmer words, and '
            'choices you won’t regret ten minutes later.';
      case EQDimension.empathy:
        return 'Imagining the other person’s view without losing your own — '
            'curiosity instead of snap judgments.';
      case EQDimension.socialSkills:
        return 'Clear communication, repair after friction, and small habits '
            'that keep relationships working day to day.';
    }
  }
}
