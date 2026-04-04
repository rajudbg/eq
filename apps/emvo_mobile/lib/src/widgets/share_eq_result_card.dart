import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Compact snapshot for PNG sharing.
class EqResultShareSnapshot extends StatelessWidget {
  const EqResultShareSnapshot({super.key, required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final sa = result.dimensionScores[EQDimension.selfAwareness] ?? 0;
    final sr = result.dimensionScores[EQDimension.selfRegulation] ?? 0;
    final em = result.dimensionScores[EQDimension.empathy] ?? 0;
    final ss = result.dimensionScores[EQDimension.socialSkills] ?? 0;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        gradient: EmvoColors.primaryGradient,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emvo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'EQ snapshot',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              result.overallScore.toInt().toString(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
            ),
          ),
          Center(
            child: Text(
              'Overall EQ',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ),
          const SizedBox(height: 24),
          _dimRow('Self-Awareness', sa),
          _dimRow('Self-Regulation', sr),
          _dimRow('Empathy', em),
          _dimRow('Social skills', ss),
        ],
      ),
    );
  }

  Widget _dimRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            score.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _writePngFromBoundary(GlobalKey key) async {
  final ctx = key.currentContext;
  if (ctx == null) return;
  final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;
  final image = await boundary.toImage(pixelRatio: 3);
  final bd = await image.toByteData(format: ImageByteFormat.png);
  if (bd == null) return;
  final bytes = bd.buffer.asUint8List();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/emvo_eq_result.png');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'My EQ snapshot from Emvo',
  );
}

/// Builds a short-lived off-screen [RepaintBoundary], captures PNG, opens share sheet.
Future<void> shareEqResultAsPng(
    BuildContext context, AssessmentResult result) async {
  if (kIsWeb) return;
  final overlayState = Overlay.maybeOf(context);
  if (overlayState == null) return;

  final theme = Theme.of(context);
  final key = GlobalKey();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: -2400,
      top: 0,
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: theme,
          child: RepaintBoundary(
            key: key,
            child: EqResultShareSnapshot(result: result),
          ),
        ),
      ),
    ),
  );
  overlayState.insert(entry);
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(const Duration(milliseconds: 80));
  try {
    await _writePngFromBoundary(key);
  } finally {
    entry.remove();
  }
}
