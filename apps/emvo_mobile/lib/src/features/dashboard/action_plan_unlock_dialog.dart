import 'package:flutter/material.dart';

/// One-shot celebration when a new weekly habit becomes visible.
Future<void> showActionPlanUnlockDialog(
  BuildContext context, {
  required int visibleHabitCount,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        visibleHabitCount >= 3 ? 'Full plan unlocked' : 'New habit unlocked',
        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      content: Text(
        visibleHabitCount >= 3
            ? 'All three weekly habits are open. Keep stacking small wins.'
            : 'You unlocked another focus habit for this week. Open your action plan to see what is next.',
        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Nice'),
        ),
      ],
    ),
  );
}
