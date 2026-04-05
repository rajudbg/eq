import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
import '../../providers/firebase_auth_providers.dart';
import '../../routing/routing.dart'
    show GoRouter, Routes;
import '../../services/firebase_social_auth_service.dart';

/// Firebase sign-in: Google, Apple (iOS/macOS), Facebook, and email/password.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialRegister = false});

  /// When true (e.g. `/login?mode=register`), email flow opens on “Create account”.
  final bool initialRegister;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  late bool _register;

  @override
  void initState() {
    super.initState();
    _register = widget.initialRegister;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _finishSession(User user) async {
    await ref.read(authProvider.notifier).signIn(user.uid);
    if (!mounted) return;
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  Future<void> _run(Future<UserCredential> Function() action) async {
    final svc = ref.read(firebaseSocialAuthServiceProvider);
    if (svc == null) {
      _toast('Sign-in needs Firebase on a mobile build.');
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await action();
      await _finishSession(cred.user!);
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? e.code);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final svc = ref.read(firebaseSocialAuthServiceProvider);
    if (svc == null) {
      _toast('Sign-in needs Firebase on a mobile build.');
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = _register
          ? await svc.registerWithEmail(
              email: _email.text,
              password: _password.text,
            )
          : await svc.signInWithEmail(
              email: _email.text,
              password: _password.text,
            );
      await _finishSession(cred.user!);
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? e.code);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final svc = ref.watch(firebaseSocialAuthServiceProvider);
    final showApple = FirebaseSocialAuthService.appleSignInAvailable;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go(Routes.welcome);
            }
          },
        ),
        title: const Text('Sign in'),
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EmvoDimensions.paddingScreen,
            children: [
              Text(
                'Save your EQ progress across devices',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use Google, Apple, Facebook, or email. Enable each provider '
                'in the Firebase Console and complete the platform setup for '
                'this app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      height: 1.4,
                    ),
              ),
              if (kIsWeb || svc == null) ...[
                const SizedBox(height: 16),
                Text(
                  kIsWeb
                      ? 'Social sign-in from the browser needs extra CORS setup; '
                          'use the iOS or Android app for full Firebase Auth.'
                      : 'Firebase Auth is not available on this target.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                        height: 1.35,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              if (svc != null && !kIsWeb) ...[
                _SocialTile(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  color: scheme.onSurface,
                  onTap: _loading
                      ? null
                      : () => _run(() => svc.signInWithGoogle()),
                ),
                if (showApple) ...[
                  const SizedBox(height: 12),
                  _SocialTile(
                    icon: Icons.apple,
                    label: 'Continue with Apple',
                    color: scheme.onSurface,
                    onTap: _loading
                        ? null
                        : () => _run(() => svc.signInWithApple()),
                  ),
                ],
                const SizedBox(height: 12),
                _SocialTile(
                  icon: Icons.facebook,
                  label: 'Continue with Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: _loading
                      ? null
                      : () => _run(() => svc.signInWithFacebook()),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: Divider(color: scheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or email',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    Expanded(child: Divider(color: scheme.outlineVariant)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              GlassContainer(
                padding: const EdgeInsets.all(EmvoDimensions.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Sign in'),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Create account'),
                          ),
                        ],
                        selected: {_register},
                        onSelectionChanged: (s) {
                          if (_loading) return;
                          setState(() => _register = s.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter your email';
                          }
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter your password';
                          }
                          if (_register && v.length < 6) {
                            return 'At least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AnimatedButton(
                        text: _register ? 'Create account' : 'Sign in with email',
                        isLoading: _loading,
                        onPressed: () {
                          if (svc == null || kIsWeb) return;
                          _submitEmail();
                        },
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
