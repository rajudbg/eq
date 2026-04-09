import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../routing/routing.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String? source;

  const PaywallScreen({
    super.key,
    this.source,
  });

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int selectedPlanIndex = 1;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      key: ValueKey<String>('paywall-${widget.source ?? 'direct'}'),
      body: SafeArea(
        child: plansAsync.when(
          data: _buildContent,
          loading: () => const Center(
            child: EmvoLoadingIndicator(
              message: 'Loading plans…',
            ),
          ),
          error: (_, __) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load plans'),
                const SizedBox(height: 16),
                AnimatedButton(
                  text: 'Retry',
                  onPressed: () => ref.invalidate(subscriptionPlansProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<SubscriptionPlan> plans) {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No plans available'),
            const SizedBox(height: 16),
            AnimatedButton(
              text: 'Retry',
              onPressed: () => ref.invalidate(subscriptionPlansProvider),
            ),
          ],
        ),
      );
    }

    final safeIndex = selectedPlanIndex.clamp(0, plans.length - 1);

    return Column(
      children: [
        Padding(
          padding: EmvoDimensions.paddingScreen,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: EmvoColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 40,
                ),
              ).animate().scale(
                    duration: EmvoAnimations.slow,
                    curve: EmvoAnimations.spring,
                  ),
              const SizedBox(height: 24),
              Text(
                'Unlock Your Full Potential',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Get personalized AI coaching and deep insights into your emotional intelligence',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.emvoOnSurface(0.72),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: EmvoDimensions.md),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final isSelected = index == safeIndex;

              return GestureDetector(
                onTap: () => setState(() => selectedPlanIndex = index),
                child: AnimatedContainer(
                  duration: EmvoAnimations.normal,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(
                              alpha: 0.12,
                            )
                        : null,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                    padding: const EdgeInsets.all(EmvoDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : context.emvoOnSurface(0.28),
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (plan.period == BillingPeriod.yearly)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: EmvoColors.secondary,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'BEST VALUE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${plan.price.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                Text(
                                  '/${plan.displayPeriod}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: context.emvoOnSurface(0.62),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...plan.features.map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: EmvoColors.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
            },
          ),
        ),
        Padding(
          padding: EmvoDimensions.paddingScreen,
          child: Column(
            children: [
              AnimatedButton(
                text: isLoading ? 'Processing...' : 'Start Free Trial',
                onPressed:
                    isLoading ? () {} : () => _purchase(plans[safeIndex]),
                isLoading: isLoading,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _restorePurchases(),
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(
                    color: context.emvoOnSurface(0.62),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cancel anytime. No commitment.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.emvoOnSurface(0.52),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _purchase(SubscriptionPlan plan) async {
    setState(() => isLoading = true);

    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.purchasePlan(plan);

    if (!mounted) return;
    setState(() => isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: ${failure.message}')),
        );
      },
      (_) {
        context.go(Routes.home);
      },
    );
  }

  Future<void> _restorePurchases() async {
    setState(() => isLoading = true);

    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.restorePurchases();

    if (!mounted) return;
    setState(() => isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: ${failure.message}')),
        );
      },
      (subscription) {
        if (subscription.currentTier != SubscriptionTier.free) {
          context.go(Routes.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active subscriptions found'),
            ),
          );
        }
      },
    );
  }
}
