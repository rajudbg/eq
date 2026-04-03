import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/theme_settings_provider.dart';
import '../../routing/routing.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final concise = ref.watch(coachConciseRepliesProvider);
    final notifications = ref.watch(notificationsEnabledProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EmvoDimensions.paddingScreen.copyWith(top: 8),
            children: [
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/branding/emvo_logo.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: EmvoColors.brandGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emvo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'EQ in motion',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _sectionLabel(context, 'Appearance'),
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode_outlined, color: scheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Theme',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('Auto'),
                            icon: Icon(Icons.brightness_auto, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode, size: 18),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (s) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(s.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _sectionLabel(context, 'AI coach'),
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 20),
                child: SwitchListTile.adaptive(
                  secondary: Icon(Icons.chat_bubble_outline, color: scheme.primary),
                  title: const Text('Concise replies'),
                  subtitle: const Text(
                    'Shorter coach messages when using the AI (preference only for now).',
                  ),
                  value: concise,
                  onChanged: (v) =>
                      ref.read(coachConciseRepliesProvider.notifier).setConcise(v),
                ),
              ),
              _sectionLabel(context, 'Notifications'),
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 20),
                child: SwitchListTile.adaptive(
                  secondary: Icon(Icons.notifications_outlined, color: scheme.primary),
                  title: const Text('Reminders & tips'),
                  subtitle: const Text(
                    'EQ nudges and streak reminders (local only until push is wired).',
                  ),
                  value: notifications,
                  onChanged: (v) => ref
                      .read(notificationsEnabledProvider.notifier)
                      .setEnabled(v),
                ),
              ),
              _sectionLabel(context, 'Account'),
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline, color: scheme.primary),
                      title: const Text('Profile'),
                      subtitle: const Text('Name, goals, and subscription'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.pop();
                        context.go(Routes.profile);
                      },
                    ),
                    Divider(height: 1, color: scheme.outline.withValues(alpha: 0.2)),
                    ListTile(
                      leading: Icon(
                        Icons.workspace_premium_outlined,
                        color: scheme.primary,
                      ),
                      title: const Text('Emvo Premium'),
                      subtitle: const Text('Unlock unlimited coaching'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.paywall),
                    ),
                  ],
                ),
              ),
              _sectionLabel(context, 'Support'),
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.privacy_tip_outlined, color: scheme.primary),
                      title: const Text('Privacy'),
                      subtitle: const Text('How we use your data'),
                      onTap: () => _soon(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: scheme.primary),
                      title: const Text('Help & FAQ'),
                      onTap: () => _soon(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.info_outline, color: scheme.primary),
                      title: const Text('About'),
                      subtitle: const Text('Version 0.1.0'),
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Emvo',
      applicationVersion: '0.1.0',
      applicationLegalese: '© Emvo',
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Emvo helps you build emotional intelligence through assessment and AI coaching.',
          ),
        ),
      ],
    );
  }
}
