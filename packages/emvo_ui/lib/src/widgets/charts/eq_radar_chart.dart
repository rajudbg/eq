import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/emvo_colors.dart';
import '../../theme/emvo_text_theme.dart';
import '../../theme/emvo_theme_context.dart';
import '../base/glass_container.dart';

class EqRadarChart extends StatelessWidget {
  final double selfAwareness;
  final double selfManagement;
  final double socialAwareness;
  final double relationshipManagement;
  final double? prevSelfAwareness;
  final double? prevSelfManagement;
  final double? prevSocialAwareness;
  final double? prevRelationshipManagement;

  const EqRadarChart({
    Key? key,
    required this.selfAwareness,
    required this.selfManagement,
    required this.socialAwareness,
    required this.relationshipManagement,
    this.prevSelfAwareness,
    this.prevSelfManagement,
    this.prevSocialAwareness,
    this.prevRelationshipManagement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = EmvoColors.primary;
    final previousColor = isDark ? Colors.white38 : Colors.black26;

    final showPrevious = prevSelfAwareness != null &&
        prevSelfManagement != null &&
        prevSocialAwareness != null &&
        prevRelationshipManagement != null;

    final dataSets = <RadarDataSet>[
      if (showPrevious)
        RadarDataSet(
          dataEntries: [
            RadarEntry(value: prevSelfAwareness!),
            RadarEntry(value: prevSelfManagement!),
            RadarEntry(value: prevSocialAwareness!),
            RadarEntry(value: prevRelationshipManagement!),
          ],
          fillColor: previousColor.withOpacity(0.1),
          borderColor: previousColor,
          entryRadius: 0,
          borderWidth: 1.5,
        ),
      RadarDataSet(
        dataEntries: [
          RadarEntry(value: selfAwareness),
          RadarEntry(value: selfManagement),
          RadarEntry(value: socialAwareness),
          RadarEntry(value: relationshipManagement),
        ],
        fillColor: primaryColor.withOpacity(0.3),
        borderColor: primaryColor,
        entryRadius: 4,
        borderWidth: 2.5,
      ),
    ];

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'EQ Profile',
            style: EmvoTextTheme.get(context).headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                dataSets: dataSets,
                radarBackgroundColor: Colors.transparent,
                radarBorderData: const BorderData(show: false),
                radarShape: RadarShape.polygon,
                titlePositionMultiplier: 1.3,
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                tickBorderData: BorderData(show: false),
                gridBorderData: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
                titleTextStyle: EmvoTextTheme.get(context).labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                getTitle: (index, angle) {
                  switch (index) {
                    case 0:
                      return const RadarChartTitle(text: 'Self-Awareness', angle: 0);
                    case 1:
                      return const RadarChartTitle(text: 'Self-Management', angle: 0);
                    case 2:
                      return const RadarChartTitle(text: 'Social Awareness', angle: 0);
                    case 3:
                      return const RadarChartTitle(text: 'Relationship Mgmt', angle: 0);
                    default:
                      return const RadarChartTitle(text: '', angle: 0);
                  }
                },
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}
