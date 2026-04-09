import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
import '../../providers/user_intent_provider.dart';
import '../../routing/routing.dart';

/// Single question before the EQ assessment — fast, one tap to continue.
class IntentScreen extends ConsumerStatefulWidget {
  const IntentScreen({super.key});

  @override
  ConsumerState<IntentScreen> createState() => _IntentScreenState();
}

class _IntentScreenState extends ConsumerState<IntentScreen> {
  UserIntent? _selected;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.emvoScheme;

    ref.listen<bool>(assessmentCompletionProvider, (prev, next) {
      if (next == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go(Routes.home);
        });
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: scheme.primary),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.welcome),
        ),
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EmvoDimensions.paddingScreen,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'What brings you here?',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                ),
                      )
                          .animate()
                          .fadeIn(
                            duration: 380.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.06,
                            duration: 420.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 10),
                      Text(
                        'Pick what matters most — we’ll tailor your coach and tips around it.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              color: context.emvoOnSurface(
                                Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.82
                                    : 0.68,
                              ),
                            ),
                      )
                          .animate()
                          .fadeIn(
                            delay: 70.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.05,
                            delay: 70.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 28),
                      ...UserIntent.values.asMap().entries.map((e) {
                        final intent = e.value;
                        final i = e.key;
                        final isSelected = _selected == intent;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedOptionCard(
                            text: intent.label,
                            icon: intent.icon,
                            isSelected: isSelected,
                            onTap: () => _onSelect(intent),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 120 + i * 55),
                                duration: 340.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideX(
                                begin: 0.04,
                                delay: Duration(milliseconds: 120 + i * 55),
                                duration: 380.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        );
                      }),
                      SizedBox(
                        height: (constraints.maxHeight * 0.06).clamp(
                          16,
                          48,
                        ),
                      ),
                      Text(
                        'Takes about 10 minutes · No account required',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.emvoOnSurface(
                                Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.65
                                    : 0.52,
                              ),
                            ),
                      ).animate().fadeIn(
                            delay: 450.ms,
                            duration: 500.ms,
                          ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onSelect(UserIntent intent) async {
    if (_busy) return;
    _busy = true;
    setState(() => _selected = intent);
    HapticFeedback.selectionClick();

    await ref.read(userIntentProvider.notifier).setIntent(intent);
    ref.read(coachingRepositoryProvider).applyCoachingContext({
      'userIntent': intent.id,
      'userIntentLabel': intent.label,
    });
    // [completeOnboarding] runs in AssessmentScreen once questions load — avoids
    // "onboarding done but no assessment" if the app dies before /assessment mounts.

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    context.go(Routes.assessment);
  }
}
