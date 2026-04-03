// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AssessmentResult {
  String get id => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  Map<EQDimension, double> get dimensionScores =>
      throw _privateConstructorUsedError; // 0-100
  double get overallScore => throw _privateConstructorUsedError;
  List<DimensionInsight> get insights => throw _privateConstructorUsedError;
  List<String> get recommendations => throw _privateConstructorUsedError;
  Map<String, String> get answers => throw _privateConstructorUsedError;

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssessmentResultCopyWith<AssessmentResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentResultCopyWith<$Res> {
  factory $AssessmentResultCopyWith(
          AssessmentResult value, $Res Function(AssessmentResult) then) =
      _$AssessmentResultCopyWithImpl<$Res, AssessmentResult>;
  @useResult
  $Res call(
      {String id,
      DateTime completedAt,
      Map<EQDimension, double> dimensionScores,
      double overallScore,
      List<DimensionInsight> insights,
      List<String> recommendations,
      Map<String, String> answers});
}

/// @nodoc
class _$AssessmentResultCopyWithImpl<$Res, $Val extends AssessmentResult>
    implements $AssessmentResultCopyWith<$Res> {
  _$AssessmentResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? completedAt = null,
    Object? dimensionScores = null,
    Object? overallScore = null,
    Object? insights = null,
    Object? recommendations = null,
    Object? answers = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dimensionScores: null == dimensionScores
          ? _value.dimensionScores
          : dimensionScores // ignore: cast_nullable_to_non_nullable
              as Map<EQDimension, double>,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<DimensionInsight>,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssessmentResultImplCopyWith<$Res>
    implements $AssessmentResultCopyWith<$Res> {
  factory _$$AssessmentResultImplCopyWith(_$AssessmentResultImpl value,
          $Res Function(_$AssessmentResultImpl) then) =
      __$$AssessmentResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime completedAt,
      Map<EQDimension, double> dimensionScores,
      double overallScore,
      List<DimensionInsight> insights,
      List<String> recommendations,
      Map<String, String> answers});
}

/// @nodoc
class __$$AssessmentResultImplCopyWithImpl<$Res>
    extends _$AssessmentResultCopyWithImpl<$Res, _$AssessmentResultImpl>
    implements _$$AssessmentResultImplCopyWith<$Res> {
  __$$AssessmentResultImplCopyWithImpl(_$AssessmentResultImpl _value,
      $Res Function(_$AssessmentResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? completedAt = null,
    Object? dimensionScores = null,
    Object? overallScore = null,
    Object? insights = null,
    Object? recommendations = null,
    Object? answers = null,
  }) {
    return _then(_$AssessmentResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dimensionScores: null == dimensionScores
          ? _value._dimensionScores
          : dimensionScores // ignore: cast_nullable_to_non_nullable
              as Map<EQDimension, double>,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double,
      insights: null == insights
          ? _value._insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<DimensionInsight>,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc

class _$AssessmentResultImpl implements _AssessmentResult {
  const _$AssessmentResultImpl(
      {required this.id,
      required this.completedAt,
      required final Map<EQDimension, double> dimensionScores,
      required this.overallScore,
      required final List<DimensionInsight> insights,
      required final List<String> recommendations,
      required final Map<String, String> answers})
      : _dimensionScores = dimensionScores,
        _insights = insights,
        _recommendations = recommendations,
        _answers = answers;

  @override
  final String id;
  @override
  final DateTime completedAt;
  final Map<EQDimension, double> _dimensionScores;
  @override
  Map<EQDimension, double> get dimensionScores {
    if (_dimensionScores is EqualUnmodifiableMapView) return _dimensionScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dimensionScores);
  }

// 0-100
  @override
  final double overallScore;
  final List<DimensionInsight> _insights;
  @override
  List<DimensionInsight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  final List<String> _recommendations;
  @override
  List<String> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  final Map<String, String> _answers;
  @override
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  String toString() {
    return 'AssessmentResult(id: $id, completedAt: $completedAt, dimensionScores: $dimensionScores, overallScore: $overallScore, insights: $insights, recommendations: $recommendations, answers: $answers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            const DeepCollectionEquality()
                .equals(other._dimensionScores, _dimensionScores) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations) &&
            const DeepCollectionEquality().equals(other._answers, _answers));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      completedAt,
      const DeepCollectionEquality().hash(_dimensionScores),
      overallScore,
      const DeepCollectionEquality().hash(_insights),
      const DeepCollectionEquality().hash(_recommendations),
      const DeepCollectionEquality().hash(_answers));

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentResultImplCopyWith<_$AssessmentResultImpl> get copyWith =>
      __$$AssessmentResultImplCopyWithImpl<_$AssessmentResultImpl>(
          this, _$identity);
}

abstract class _AssessmentResult implements AssessmentResult {
  const factory _AssessmentResult(
      {required final String id,
      required final DateTime completedAt,
      required final Map<EQDimension, double> dimensionScores,
      required final double overallScore,
      required final List<DimensionInsight> insights,
      required final List<String> recommendations,
      required final Map<String, String> answers}) = _$AssessmentResultImpl;

  @override
  String get id;
  @override
  DateTime get completedAt;
  @override
  Map<EQDimension, double> get dimensionScores; // 0-100
  @override
  double get overallScore;
  @override
  List<DimensionInsight> get insights;
  @override
  List<String> get recommendations;
  @override
  Map<String, String> get answers;

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssessmentResultImplCopyWith<_$AssessmentResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DimensionInsight {
  EQDimension get dimension => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String get level =>
      throw _privateConstructorUsedError; // "Developing", "Proficient", "Advanced"
  String get description => throw _privateConstructorUsedError;
  List<String> get growthAreas => throw _privateConstructorUsedError;

  /// Create a copy of DimensionInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DimensionInsightCopyWith<DimensionInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DimensionInsightCopyWith<$Res> {
  factory $DimensionInsightCopyWith(
          DimensionInsight value, $Res Function(DimensionInsight) then) =
      _$DimensionInsightCopyWithImpl<$Res, DimensionInsight>;
  @useResult
  $Res call(
      {EQDimension dimension,
      double score,
      String level,
      String description,
      List<String> growthAreas});
}

/// @nodoc
class _$DimensionInsightCopyWithImpl<$Res, $Val extends DimensionInsight>
    implements $DimensionInsightCopyWith<$Res> {
  _$DimensionInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DimensionInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dimension = null,
    Object? score = null,
    Object? level = null,
    Object? description = null,
    Object? growthAreas = null,
  }) {
    return _then(_value.copyWith(
      dimension: null == dimension
          ? _value.dimension
          : dimension // ignore: cast_nullable_to_non_nullable
              as EQDimension,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      growthAreas: null == growthAreas
          ? _value.growthAreas
          : growthAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DimensionInsightImplCopyWith<$Res>
    implements $DimensionInsightCopyWith<$Res> {
  factory _$$DimensionInsightImplCopyWith(_$DimensionInsightImpl value,
          $Res Function(_$DimensionInsightImpl) then) =
      __$$DimensionInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {EQDimension dimension,
      double score,
      String level,
      String description,
      List<String> growthAreas});
}

/// @nodoc
class __$$DimensionInsightImplCopyWithImpl<$Res>
    extends _$DimensionInsightCopyWithImpl<$Res, _$DimensionInsightImpl>
    implements _$$DimensionInsightImplCopyWith<$Res> {
  __$$DimensionInsightImplCopyWithImpl(_$DimensionInsightImpl _value,
      $Res Function(_$DimensionInsightImpl) _then)
      : super(_value, _then);

  /// Create a copy of DimensionInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dimension = null,
    Object? score = null,
    Object? level = null,
    Object? description = null,
    Object? growthAreas = null,
  }) {
    return _then(_$DimensionInsightImpl(
      dimension: null == dimension
          ? _value.dimension
          : dimension // ignore: cast_nullable_to_non_nullable
              as EQDimension,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      growthAreas: null == growthAreas
          ? _value._growthAreas
          : growthAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$DimensionInsightImpl implements _DimensionInsight {
  const _$DimensionInsightImpl(
      {required this.dimension,
      required this.score,
      required this.level,
      required this.description,
      required final List<String> growthAreas})
      : _growthAreas = growthAreas;

  @override
  final EQDimension dimension;
  @override
  final double score;
  @override
  final String level;
// "Developing", "Proficient", "Advanced"
  @override
  final String description;
  final List<String> _growthAreas;
  @override
  List<String> get growthAreas {
    if (_growthAreas is EqualUnmodifiableListView) return _growthAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_growthAreas);
  }

  @override
  String toString() {
    return 'DimensionInsight(dimension: $dimension, score: $score, level: $level, description: $description, growthAreas: $growthAreas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DimensionInsightImpl &&
            (identical(other.dimension, dimension) ||
                other.dimension == dimension) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._growthAreas, _growthAreas));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dimension, score, level,
      description, const DeepCollectionEquality().hash(_growthAreas));

  /// Create a copy of DimensionInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DimensionInsightImplCopyWith<_$DimensionInsightImpl> get copyWith =>
      __$$DimensionInsightImplCopyWithImpl<_$DimensionInsightImpl>(
          this, _$identity);
}

abstract class _DimensionInsight implements DimensionInsight {
  const factory _DimensionInsight(
      {required final EQDimension dimension,
      required final double score,
      required final String level,
      required final String description,
      required final List<String> growthAreas}) = _$DimensionInsightImpl;

  @override
  EQDimension get dimension;
  @override
  double get score;
  @override
  String get level; // "Developing", "Proficient", "Advanced"
  @override
  String get description;
  @override
  List<String> get growthAreas;

  /// Create a copy of DimensionInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DimensionInsightImplCopyWith<_$DimensionInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
