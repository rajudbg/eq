import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/emvo_colors.dart';
import '../../theme/emvo_theme_context.dart';
import '../base/glass_container.dart';

/// Axis order matches [EQDimension.values] in `emvo_assessment` (mobile builds this list):
/// 0 Self-Awareness, 1 Self-Regulation, 2 Empathy, 3 Social Skills.
enum EqRadarChartStyle {
  /// Glass card, header, and glow (dashboard).
  dashboard,

  /// Chart only — for embedding on results / other screens.
  compact,
}

class EqRadarChart extends StatelessWidget {
  /// Length 4: self-awareness, self-regulation, empathy, social skills.
  final List<double> values;

  /// Optional previous assessment (same order as [values]).
  final List<double>? previousValues;

  final EqRadarChartStyle style;

  final double chartHeight;

  /// When true, draws a second polygon at 50 (mid-scale reference), matching results UX.
  final bool showMidpointBaseline;

  const EqRadarChart({
    super.key,
    required this.values,
    this.previousValues,
    this.style = EqRadarChartStyle.dashboard,
    this.chartHeight = 250,
    this.showMidpointBaseline = false,
  })  : assert(values.length == 4),
        assert(previousValues == null || previousValues.length == 4);

  static const List<String> _axisLabels = [
    'Self-Awareness',
    'Self-Regulation',
    'Empathy',
    'Social Skills',
  ];

  static String _axisTitleText(int index) {
    final s = _axisLabels[index];
    return s.contains(' ') ? s.replaceAll(' ', '\n') : s;
  }

  /// fl_chart rotates titles with the spoke; the bottom label (index 2) reads inverted without this.
  static double _titleAngleDegrees(int index, double baseTitleAngleDeg) {
    if (index == 2) return baseTitleAngleDeg + 180;
    return baseTitleAngleDeg;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = EmvoColors.primary;
    final previousColor = isDark ? Colors.white38 : Colors.black26;

    final showPrevious = previousValues != null;

    final dataSets = <RadarDataSet>[
      if (showPrevious)
        RadarDataSet(
          dataEntries: previousValues!
              .map((v) => RadarEntry(value: v))
              .toList(growable: false),
          fillColor: previousColor.withValues(alpha: 0.1),
          borderColor: previousColor,
          entryRadius: 0,
          borderWidth: 1.5,
        ),
      RadarDataSet(
        dataEntries:
            values.map((v) => RadarEntry(value: v)).toList(growable: false),
        fillColor: primaryColor.withValues(alpha: 0.3),
        borderColor: primaryColor,
        entryRadius: style == EqRadarChartStyle.compact ? 5 : 4,
        borderWidth: style == EqRadarChartStyle.compact ? 2 : 2.5,
      ),
      if (showMidpointBaseline)
        RadarDataSet(
          fillColor: Colors.transparent,
          borderColor: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.18),
          entryRadius: 0,
          dataEntries: List.generate(
            4,
            (_) => const RadarEntry(value: 50),
            growable: false,
          ),
          borderWidth: 1,
        ),
    ];

    final chart = SizedBox(
      height: chartHeight,
      child: RadarChart(
        RadarChartData(
          dataSets: dataSets,
          radarBackgroundColor: Colors.transparent,
          radarBorderData: style == EqRadarChartStyle.compact
              ? BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.12),
                )
              : BorderSide.none,
          radarShape: RadarShape.polygon,
          tickCount: style == EqRadarChartStyle.compact ? 4 : 5,
          ticksTextStyle: const TextStyle(
            color: Colors.transparent,
            fontSize: 10,
          ),
          tickBorderData: style == EqRadarChartStyle.compact
              ? BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.06),
                )
              : BorderSide.none,
          gridBorderData: BorderSide(
            color: style == EqRadarChartStyle.compact
                ? Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.12)
                : (isDark ? Colors.white12 : Colors.black12),
            width: 1,
          ),
          borderData: style == EqRadarChartStyle.compact
              ? FlBorderData(show: false)
              : null,
          titleTextStyle: style == EqRadarChartStyle.compact
              ? Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  )
              : Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
          titlePositionPercentageOffset: 0.2,
          getTitle: (index, angle) {
            if (index < 0 || index >= 4) {
              return const RadarChartTitle(text: '', angle: 0);
            }
            return RadarChartTitle(
              text: _axisTitleText(index),
              angle: _titleAngleDegrees(index, angle),
              positionPercentageOffset: 0.2,
            );
          },
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );

    if (style == EqRadarChartStyle.compact) {
      return chart;
    }

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'EQ Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 80,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 3.seconds,
                  )
                  .fade(begin: 0.6, end: 1.0),
              chart
                  .animate()
                  .scale(
                    delay: 200.ms,
                    curve: Curves.easeOutQuart,
                    duration: 800.ms,
                  )
                  .fadeIn(),
            ],
          ),
        ],
      ),
    );
  }
}
