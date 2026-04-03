import 'package:flutter/material.dart';

import '../../routing/routing.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Placeholder onboarding steps.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Continue to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
