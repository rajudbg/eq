import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../providers/upcoming_situations_provider.dart';
import '../routing/routing.dart';

/// Home / sheet: log upcoming situations for reminders + coach follow-ups.
class UpcomingSituationsCard extends ConsumerWidget {
  const UpcomingSituationsCard({
    super.key,
    this.emphasizeEmptyGuidance = false,
  });

  /// When true and the list is empty, show a stronger day-one discovery CTA.
  final bool emphasizeEmptyGuidance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(upcomingSituationsProvider);
    final scheme = Theme.of(context).colorScheme;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_rounded, color: scheme.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'What’s coming up?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => _openEditor(context, ref),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Log a meeting or hard conversation — we’ll nudge you before and ask how it went.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  height: 1.35,
                ),
          ),
          if (list.isEmpty) ...[
            const SizedBox(height: 12),
            if (emphasizeEmptyGuidance) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add your first upcoming situation',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Get personalised coaching before it happens — we’ll nudge you '
                      'and prep you with the Coach tab.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => _openEditor(context, ref),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text('Add a situation'),
                    ),
                  ],
                ),
              ),
            ] else
              Text(
                'Nothing scheduled yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
              ),
          ] else ...[
            const SizedBox(height: 12),
            for (final s in list)
              _SituationTile(
                situation: s,
                onReflect: () => _openFollowUp(context, ref, s),
                onDelete: () =>
                    ref.read(upcomingSituationsProvider.notifier).remove(s.id),
              ),
          ],
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SituationEditorSheet(
        onSave: (title, at, note) async {
          await ref.read(upcomingSituationsProvider.notifier).add(
                title: title,
                at: at,
                note: note,
              );
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _openFollowUp(
    BuildContext context,
    WidgetRef ref,
    UpcomingSituation s,
  ) {
    final controller = TextEditingController(text: s.followUpNote ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How did “${s.title}” go?',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'A sentence or two is enough…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(upcomingSituationsProvider.notifier)
                    .setFollowUp(s.id, controller.text);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('Save for coach'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SituationTile extends ConsumerWidget {
  const _SituationTile({
    required this.situation,
    required this.onReflect,
    required this.onDelete,
  });

  final UpcomingSituation situation;
  final VoidCallback onReflect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final needsFollowUp = situation.isPast &&
        (situation.followUpNote == null ||
            situation.followUpNote!.trim().isEmpty);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          situation.title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fmtWhen(situation.at),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Remove',
                  ),
                ],
              ),
              if (situation.note != null && situation.note!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  situation.note!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (needsFollowUp) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onReflect,
                  child: const Text('Add quick reflection'),
                ),
              ] else if (situation.followUpNote != null &&
                  situation.followUpNote!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Reflection: ${situation.followUpNote}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                ),
              ],
              if (!situation.isPast) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ref
                            .read(coachingRepositoryProvider)
                            .applyCoachingContext({
                          'situationPrep': {
                            'title': situation.title,
                            'at': situation.at.toIso8601String(),
                            if (situation.note != null &&
                                situation.note!.isNotEmpty)
                              'note': situation.note,
                          },
                        });
                        context.go(Routes.coach);
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Coach me'),
                    ),
                    TextButton.icon(
                      onPressed: situation.preparedAtIso != null
                          ? null
                          : () => ref
                              .read(upcomingSituationsProvider.notifier)
                              .markPrepared(situation.id),
                      icon: Icon(
                        situation.preparedAtIso != null
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        situation.preparedAtIso != null
                            ? 'Prepared'
                            : 'I am prepared',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _fmtWhen(DateTime at) {
    final l = at.toLocal();
    final m = l.month.toString().padLeft(2, '0');
    final d = l.day.toString().padLeft(2, '0');
    final h = l.hour.toString().padLeft(2, '0');
    final min = l.minute.toString().padLeft(2, '0');
    return '${l.year}-$m-$d · $h:$min';
  }
}

class _SituationEditorSheet extends StatefulWidget {
  const _SituationEditorSheet({required this.onSave});

  final Future<void> Function(String title, DateTime at, String? note) onSave;

  @override
  State<_SituationEditorSheet> createState() => _SituationEditorSheetState();
}

class _SituationEditorSheetState extends State<_SituationEditorSheet> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  DateTime _at = DateTime.now().add(const Duration(hours: 2));

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log a situation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. 1:1 with my manager',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('When'),
            subtitle: Text(_fmtAt(_at)),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _at,
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d == null || !context.mounted) return;
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_at),
              );
              if (t == null || !context.mounted) return;
              setState(() {
                _at = DateTime(d.year, d.month, d.day, t.hour, t.minute);
              });
            },
          ),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              final title = _title.text.trim();
              if (title.isEmpty) return;
              await widget.onSave(
                title,
                _at,
                _note.text.trim().isEmpty ? null : _note.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _fmtAt(DateTime at) {
    final l = at.toLocal();
    final m = l.month.toString().padLeft(2, '0');
    final d = l.day.toString().padLeft(2, '0');
    final h = l.hour.toString().padLeft(2, '0');
    final min = l.minute.toString().padLeft(2, '0');
    return '${l.year}-$m-$d $h:$min';
  }
}
