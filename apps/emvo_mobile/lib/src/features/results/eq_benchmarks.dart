/// Offline percentile lookup tables for EQ benchmarks.
///
/// Since Emvo is local-first, we ship static percentile distributions
/// derived from published EQ research norms (Bar-On EQ-i 2.0 general
/// population norms, adapted to our 0–100 scale).
///
/// These tables give users social-comparison context ("Your Empathy is
/// in the top 23% of Emvo users") without requiring server-side aggregation.
///
/// Tables can be updated via JSON asset in future versions when we have
/// enough real-user data to build our own distribution.
library;

import 'package:emvo_assessment/emvo_assessment.dart';

/// A benchmark result for a single dimension or overall score.
class EqBenchmark {
  const EqBenchmark({
    required this.percentile,
    required this.label,
    required this.description,
  });

  /// 0–100: what percentage of the reference population scored lower.
  final int percentile;

  /// Human-readable label: "Top 15%", "Above Average", etc.
  final String label;

  /// One-line description with context.
  final String description;
}

/// Percentile breakpoints: score → percentile.
/// Linear interpolation between anchors.
const _overallPercentiles = <int, int>{
  0: 1,
  30: 5,
  40: 15,
  50: 35,
  55: 45,
  60: 55,
  65: 65,
  70: 75,
  75: 83,
  80: 89,
  85: 94,
  90: 97,
  95: 99,
  100: 99,
};

const _dimensionPercentiles = <int, int>{
  0: 1,
  25: 5,
  35: 12,
  45: 28,
  50: 38,
  55: 48,
  60: 58,
  65: 68,
  70: 76,
  75: 84,
  80: 90,
  85: 95,
  90: 98,
  95: 99,
  100: 99,
};

/// Interpolate percentile from a lookup table.
int _lookupPercentile(double score, Map<int, int> table) {
  final keys = table.keys.toList()..sort();
  if (score <= keys.first) return table[keys.first]!;
  if (score >= keys.last) return table[keys.last]!;

  for (var i = 0; i < keys.length - 1; i++) {
    final lo = keys[i];
    final hi = keys[i + 1];
    if (score >= lo && score <= hi) {
      final t = (score - lo) / (hi - lo);
      final pLo = table[lo]!;
      final pHi = table[hi]!;
      return (pLo + t * (pHi - pLo)).round().clamp(1, 99);
    }
  }
  return 50; // fallback
}

String _percentileLabel(int p) {
  if (p >= 90) return 'Top ${100 - p}%';
  if (p >= 75) return 'Above Average';
  if (p >= 50) return 'Average';
  if (p >= 25) return 'Below Average';
  return 'Developing';
}

String _percentileDescription(int p, String dimName) {
  if (p >= 90) {
    return 'Your $dimName is exceptionally strong — you\'re ahead of ${p}% of people.';
  }
  if (p >= 75) {
    return 'Your $dimName is above average — stronger than ${p}% of the population.';
  }
  if (p >= 50) {
    return 'Your $dimName is right around the middle — plenty of room to grow.';
  }
  if (p >= 25) {
    return 'Your $dimName has real growth potential — focus here for the biggest gains.';
  }
  return 'Your $dimName is an area for development — even small effort will show big results.';
}

/// Compute benchmarks for an assessment result.
class EqBenchmarks {
  EqBenchmarks(this.result)
      : overall = _computeOverall(result),
        dimensions = _computeDimensions(result);

  final AssessmentResult result;
  final EqBenchmark overall;
  final Map<EQDimension, EqBenchmark> dimensions;

  static EqBenchmark _computeOverall(AssessmentResult r) {
    final p = _lookupPercentile(r.overallScore, _overallPercentiles);
    return EqBenchmark(
      percentile: p,
      label: _percentileLabel(p),
      description: _percentileDescription(p, 'overall EQ'),
    );
  }

  static Map<EQDimension, EqBenchmark> _computeDimensions(
      AssessmentResult r) {
    return r.dimensionScores.map((dim, score) {
      final p = _lookupPercentile(score, _dimensionPercentiles);
      return MapEntry(
        dim,
        EqBenchmark(
          percentile: p,
          label: _percentileLabel(p),
          description: _percentileDescription(p, dim.displayName),
        ),
      );
    });
  }

  /// The user's single strongest benchmark.
  MapEntry<EQDimension, EqBenchmark> get strongestBenchmark {
    final sorted = dimensions.entries.toList()
      ..sort((a, b) => b.value.percentile.compareTo(a.value.percentile));
    return sorted.first;
  }
}
