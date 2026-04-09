import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui show ImageByteFormat;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Personalized EQ tagline based on the user's strongest dimension.
String _eqTagline(AssessmentResult result) {
  final sorted = result.dimensionScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = sorted.first.key;
  final score = result.overallScore.toInt();

  final dimLabel = switch (top) {
    EQDimension.selfAwareness => 'Self-Awareness',
    EQDimension.selfRegulation => 'Self-Regulation',
    EQDimension.empathy => 'Empathy',
    EQDimension.socialSkills => 'Social Skills',
  };

  final superpower = switch (top) {
    EQDimension.selfAwareness => 'Knowing Yourself',
    EQDimension.selfRegulation => 'Staying Composed',
    EQDimension.empathy => 'Reading the Room',
    EQDimension.socialSkills => 'Building Bridges',
  };

  final tier = score >= 80
      ? 'Exceptional'
      : score >= 65
          ? 'Strong'
          : score >= 50
              ? 'Growing'
              : 'Emerging';

  return '$tier EQ · Superpower: $superpower';
}

/// A premium, Instagram-story-ready EQ profile card.
///
/// Designed to be rendered offscreen via [RepaintBoundary] → PNG → share.
/// Dimensions: 1080×1920 equivalent (3:5.33 ratio at @3x).
class EqProfileShareCard extends StatelessWidget {
  const EqProfileShareCard({super.key, required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final sa = result.dimensionScores[EQDimension.selfAwareness] ?? 0;
    final sr = result.dimensionScores[EQDimension.selfRegulation] ?? 0;
    final em = result.dimensionScores[EQDimension.empathy] ?? 0;
    final ss = result.dimensionScores[EQDimension.socialSkills] ?? 0;
    final overall = result.overallScore.toInt();
    final tagline = _eqTagline(result);

    // Sort dimensions for display order (highest first).
    final dims = [
      ('Self-Awareness', sa, EmvoColors.primary),
      ('Self-Regulation', sr, EmvoColors.secondary),
      ('Empathy', em, EmvoColors.tertiary),
      ('Social Skills', ss, EmvoColors.success),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    return Container(
      width: 400,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── Decorative circles ──
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    EmvoColors.primary.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    EmvoColors.tertiary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Text(
                        'EMVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'EQ Profile',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Overall score ring ──
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _ScoreRingPainter(
                      score: overall.toDouble(),
                      maxScore: 100,
                      ringColor: EmvoColors.primary,
                      trackColor: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            overall.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'EQ Score',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Tagline ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: EmvoColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: EmvoColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    tagline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Dimension bars ──
                ...dims.map((dim) => _DimensionBar(
                      label: dim.$1,
                      score: dim.$2,
                      color: dim.$3,
                    )),

                const SizedBox(height: 20),

                // ── Mini radar ──
                SizedBox(
                  height: 130,
                  width: 130,
                  child: CustomPaint(
                    painter: _MiniRadarPainter(
                      values: [sa, sr, em, ss],
                      color: EmvoColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Footer ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Discover your EQ at emvo.app',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DimensionBar extends StatelessWidget {
  const _DimensionBar({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                score.toInt().toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (score / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.7),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a circular progress ring around the overall score.
class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
    required this.score,
    required this.maxScore,
    required this.ringColor,
    required this.trackColor,
  });

  final double score;
  final double maxScore;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    final sweep = (score / maxScore) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweep,
          colors: [
            ringColor.withValues(alpha: 0.6),
            ringColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.score != score;
}

/// Draws a tiny 4-axis radar polygon for the share card.
class _MiniRadarPainter extends CustomPainter {
  _MiniRadarPainter({
    required this.values,
    required this.color,
  });

  final List<double> values; // length 4
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 12;

    // Grid lines (3 levels)
    for (var level = 1; level <= 3; level++) {
      final r = maxRadius * level / 3;
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final angle = -pi / 2 + (2 * pi * i / 4);
        final p = Offset(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Spokes
    for (var i = 0; i < 4; i++) {
      final angle = -pi / 2 + (2 * pi * i / 4);
      final p = Offset(
        center.dx + maxRadius * cos(angle),
        center.dy + maxRadius * sin(angle),
      );
      canvas.drawLine(
        center,
        p,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06)
          ..strokeWidth = 0.5,
      );
    }

    // Data polygon
    final dataPath = Path();
    for (var i = 0; i < 4; i++) {
      final angle = -pi / 2 + (2 * pi * i / 4);
      final r = maxRadius * (values[i] / 100).clamp(0.0, 1.0);
      final p = Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();

    // Fill
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Dots
    for (var i = 0; i < 4; i++) {
      final angle = -pi / 2 + (2 * pi * i / 4);
      final r = maxRadius * (values[i] / 100).clamp(0.0, 1.0);
      final p = Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
      canvas.drawCircle(
        p,
        3.5,
        Paint()..color = color,
      );
    }

    // Axis labels
    const labels = ['SA', 'SR', 'E', 'SS'];
    for (var i = 0; i < 4; i++) {
      final angle = -pi / 2 + (2 * pi * i / 4);
      final labelR = maxRadius + 10;
      final p = Offset(
        center.dx + labelR * cos(angle),
        center.dy + labelR * sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _MiniRadarPainter old) => true;
}

/// Builds the offscreen card, captures as PNG, and opens the share sheet.
Future<void> shareEqProfileCard(
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
          child: MediaQuery(
            data: const MediaQueryData(),
            child: RepaintBoundary(
              key: key,
              child: EqProfileShareCard(result: result),
            ),
          ),
        ),
      ),
    ),
  );
  overlayState.insert(entry);
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(const Duration(milliseconds: 120));
  try {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final bd = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) return;
    final bytes = bd.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/emvo_eq_profile.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'My EQ Profile from Emvo — discover your emotional intelligence at emvo.app',
    );
  } finally {
    entry.remove();
  }
}
