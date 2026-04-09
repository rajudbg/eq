import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/eq_pulse_provider.dart';

/// Full-screen bottom sheet for the weekly 3-question EQ pulse.
///
/// self-contained: loads questions, collects answers, scores, and reports back.
Future<EqPulseResult?> showEqPulseSheet(BuildContext context) async {
  return showModalBottomSheet<EqPulseResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EqPulseSheet(),
  );
}

class _EqPulseSheet extends ConsumerStatefulWidget {
  const _EqPulseSheet();

  @override
  ConsumerState<_EqPulseSheet> createState() => _EqPulseSheetState();
}

class _EqPulseSheetState extends ConsumerState<_EqPulseSheet> {
  int _currentQ = 0;
  final _answers = <String, String>{};
  bool _isLoading = true;
  bool _isScoring = false;
  EqPulseResult? _result;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuestions());
  }

  Future<void> _loadQuestions() async {
    try {
      // Load directly from the question repository to avoid resetting
      // the main assessment notifier's state (which clears answers).
      final questionRepo = ref.read(questionRepositoryProvider);
      final result = await questionRepo.getQuestions();

      if (!mounted) return;

      final allQuestions = result.fold(
        (_) => <Question>[],
        (questions) => questions,
      );

      if (allQuestions.isEmpty) {
        Navigator.of(context).pop();
        return;
      }

      final pulse = ref.read(eqPulseProvider.notifier);
      final selected = pulse.selectPulseQuestions(allQuestions);

      setState(() {
        _questions = selected;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load pulse: $e')),
        );
      }
    }
  }

  Future<void> _selectOption(String questionId, String optionId) async {
    _answers[questionId] = optionId;

    if (_currentQ < _questions.length - 1) {
      setState(() => _currentQ++);
    } else {
      // All answered — score.
      setState(() => _isScoring = true);
      try {
        final result =
            await ref.read(eqPulseProvider.notifier).completePulse(_answers);
        if (mounted) {
          setState(() {
            _result = result;
            _isScoring = false;
          });
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scoring failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? EmvoColors.surfaceDark : EmvoColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(EmvoDimensions.lg),
          child: _isLoading
              ? _buildLoading()
              : _isScoring
                  ? _buildScoring()
                  : _result != null
                      ? _buildResult(scheme)
                      : _buildQuestion(scheme),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: EmvoLoadingIndicator(message: 'Preparing your pulse…'),
      ),
    );
  }

  Widget _buildScoring() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: EmvoLoadingIndicator(message: 'Calculating…'),
      ),
    );
  }

  Widget _buildQuestion(ColorScheme scheme) {
    final q = _questions[_currentQ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Progress ──
        Row(
          children: [
            Text(
              'WEEKLY PULSE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
            ),
            const Spacer(),
            Text(
              '${_currentQ + 1} / ${_questions.length}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.emvoOnSurface(0.5),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentQ + 1) / _questions.length,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(scheme.primary),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 24),

        // ── Scenario ──
        Text(
          q.scenario,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
        )
            .animate(key: ValueKey('q_$_currentQ'))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.03, duration: 300.ms),
        const SizedBox(height: 20),

        // ── Options ──
        ...q.options.asMap().entries.map((entry) {
          final i = entry.key;
          final opt = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PulseOptionTile(
              label: opt.text,
              onTap: () => _selectOption(q.id, opt.id),
            )
                .animate(key: ValueKey('q${_currentQ}_o$i'))
                .fadeIn(
                  duration: 250.ms,
                  delay: Duration(milliseconds: 60 * i),
                )
                .slideX(
                  begin: 0.04,
                  duration: 280.ms,
                  delay: Duration(milliseconds: 60 * i),
                  curve: Curves.easeOutCubic,
                ),
          );
        }),
      ],
    );
  }

  Widget _buildResult(ColorScheme scheme) {
    final r = _result!;
    final dims = r.dimensionScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: EmvoColors.success, size: 48)
            .animate()
            .scale(begin: const Offset(0.5, 0.5), duration: 400.ms,
                curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          'Pulse complete!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s your quick snapshot for this week:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.emvoOnSurface(0.65),
              ),
        ),
        const SizedBox(height: 20),
        ...dims.asMap().entries.map((entry) {
          final i = entry.key;
          final dim = entry.value;
          final displayName = dim.key
              .replaceAllMapped(
                RegExp(r'([A-Z])'),
                (m) => ' ${m.group(1)}',
              )
              .trim();
          final capitalName =
              displayName[0].toUpperCase() + displayName.substring(1);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    capitalName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: dim.value / 100,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        _dimColor(dim.key),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text(
                    dim.value.toInt().toString(),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(
                  duration: 300.ms,
                  delay: Duration(milliseconds: 80 * i),
                ),
          );
        }),
        const SizedBox(height: 24),
        AnimatedButton(
          text: 'Done',
          onPressed: () => Navigator.of(context).pop(r),
          width: double.infinity,
        ),
      ],
    );
  }

  Color _dimColor(String key) {
    return switch (key) {
      'selfAwareness' => EmvoColors.primary,
      'selfRegulation' => EmvoColors.secondary,
      'empathy' => EmvoColors.tertiary,
      'socialSkills' => EmvoColors.success,
      _ => EmvoColors.primary,
    };
  }
}

class _PulseOptionTile extends StatelessWidget {
  const _PulseOptionTile({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: EmvoDimensions.radiusMd,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.emvoOnSurface(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
