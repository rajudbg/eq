// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
mixin _$Question {
  String get id => throw _privateConstructorUsedError;
  String get scenario => throw _privateConstructorUsedError;
  EQDimension get primaryDimension => throw _privateConstructorUsedError;
  List<AnswerOption> get options => throw _privateConstructorUsedError;
  String? get context =>
      throw _privateConstructorUsedError; // e.g., "workplace", "family", "social"
  int? get difficulty => throw _privateConstructorUsedError;

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionCopyWith<Question> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res, Question>;
  @useResult
  $Res call(
      {String id,
      String scenario,
      EQDimension primaryDimension,
      List<AnswerOption> options,
      String? context,
      int? difficulty});
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res, $Val extends Question>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scenario = null,
    Object? primaryDimension = null,
    Object? options = null,
    Object? context = freezed,
    Object? difficulty = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scenario: null == scenario
          ? _value.scenario
          : scenario // ignore: cast_nullable_to_non_nullable
              as String,
      primaryDimension: null == primaryDimension
          ? _value.primaryDimension
          : primaryDimension // ignore: cast_nullable_to_non_nullable
              as EQDimension,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<AnswerOption>,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionImplCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory _$$QuestionImplCopyWith(
          _$QuestionImpl value, $Res Function(_$QuestionImpl) then) =
      __$$QuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String scenario,
      EQDimension primaryDimension,
      List<AnswerOption> options,
      String? context,
      int? difficulty});
}

/// @nodoc
class __$$QuestionImplCopyWithImpl<$Res>
    extends _$QuestionCopyWithImpl<$Res, _$QuestionImpl>
    implements _$$QuestionImplCopyWith<$Res> {
  __$$QuestionImplCopyWithImpl(
      _$QuestionImpl _value, $Res Function(_$QuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scenario = null,
    Object? primaryDimension = null,
    Object? options = null,
    Object? context = freezed,
    Object? difficulty = freezed,
  }) {
    return _then(_$QuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scenario: null == scenario
          ? _value.scenario
          : scenario // ignore: cast_nullable_to_non_nullable
              as String,
      primaryDimension: null == primaryDimension
          ? _value.primaryDimension
          : primaryDimension // ignore: cast_nullable_to_non_nullable
              as EQDimension,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<AnswerOption>,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionImpl implements _Question {
  const _$QuestionImpl(
      {required this.id,
      required this.scenario,
      required this.primaryDimension,
      required final List<AnswerOption> options,
      this.context,
      this.difficulty})
      : _options = options;

  factory _$QuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String scenario;
  @override
  final EQDimension primaryDimension;
  final List<AnswerOption> _options;
  @override
  List<AnswerOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final String? context;
// e.g., "workplace", "family", "social"
  @override
  final int? difficulty;

  @override
  String toString() {
    return 'Question(id: $id, scenario: $scenario, primaryDimension: $primaryDimension, options: $options, context: $context, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scenario, scenario) ||
                other.scenario == scenario) &&
            (identical(other.primaryDimension, primaryDimension) ||
                other.primaryDimension == primaryDimension) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, scenario, primaryDimension,
      const DeepCollectionEquality().hash(_options), context, difficulty);

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      __$$QuestionImplCopyWithImpl<_$QuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionImplToJson(
      this,
    );
  }
}

abstract class _Question implements Question {
  const factory _Question(
      {required final String id,
      required final String scenario,
      required final EQDimension primaryDimension,
      required final List<AnswerOption> options,
      final String? context,
      final int? difficulty}) = _$QuestionImpl;

  factory _Question.fromJson(Map<String, dynamic> json) =
      _$QuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get scenario;
  @override
  EQDimension get primaryDimension;
  @override
  List<AnswerOption> get options;
  @override
  String? get context; // e.g., "workplace", "family", "social"
  @override
  int? get difficulty;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnswerOption _$AnswerOptionFromJson(Map<String, dynamic> json) {
  return _AnswerOption.fromJson(json);
}

/// @nodoc
mixin _$AnswerOption {
  String get id => throw _privateConstructorUsedError;
  String get text =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target — Freezed factory params map to fields
  @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
  Map<EQDimension, int> get scores =>
      throw _privateConstructorUsedError; // Points per dimension
  String? get emotionalTone => throw _privateConstructorUsedError;

  /// Serializes this AnswerOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnswerOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnswerOptionCopyWith<AnswerOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnswerOptionCopyWith<$Res> {
  factory $AnswerOptionCopyWith(
          AnswerOption value, $Res Function(AnswerOption) then) =
      _$AnswerOptionCopyWithImpl<$Res, AnswerOption>;
  @useResult
  $Res call(
      {String id,
      String text,
      @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
      Map<EQDimension, int> scores,
      String? emotionalTone});
}

/// @nodoc
class _$AnswerOptionCopyWithImpl<$Res, $Val extends AnswerOption>
    implements $AnswerOptionCopyWith<$Res> {
  _$AnswerOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnswerOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? scores = null,
    Object? emotionalTone = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      scores: null == scores
          ? _value.scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<EQDimension, int>,
      emotionalTone: freezed == emotionalTone
          ? _value.emotionalTone
          : emotionalTone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnswerOptionImplCopyWith<$Res>
    implements $AnswerOptionCopyWith<$Res> {
  factory _$$AnswerOptionImplCopyWith(
          _$AnswerOptionImpl value, $Res Function(_$AnswerOptionImpl) then) =
      __$$AnswerOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String text,
      @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
      Map<EQDimension, int> scores,
      String? emotionalTone});
}

/// @nodoc
class __$$AnswerOptionImplCopyWithImpl<$Res>
    extends _$AnswerOptionCopyWithImpl<$Res, _$AnswerOptionImpl>
    implements _$$AnswerOptionImplCopyWith<$Res> {
  __$$AnswerOptionImplCopyWithImpl(
      _$AnswerOptionImpl _value, $Res Function(_$AnswerOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnswerOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? scores = null,
    Object? emotionalTone = freezed,
  }) {
    return _then(_$AnswerOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      scores: null == scores
          ? _value._scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<EQDimension, int>,
      emotionalTone: freezed == emotionalTone
          ? _value.emotionalTone
          : emotionalTone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnswerOptionImpl implements _AnswerOption {
  const _$AnswerOptionImpl(
      {required this.id,
      required this.text,
      @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
      required final Map<EQDimension, int> scores,
      this.emotionalTone})
      : _scores = scores;

  factory _$AnswerOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnswerOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
// ignore: invalid_annotation_target — Freezed factory params map to fields
  final Map<EQDimension, int> _scores;
// ignore: invalid_annotation_target — Freezed factory params map to fields
  @override
  @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
  Map<EQDimension, int> get scores {
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scores);
  }

// Points per dimension
  @override
  final String? emotionalTone;

  @override
  String toString() {
    return 'AnswerOption(id: $id, text: $text, scores: $scores, emotionalTone: $emotionalTone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnswerOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.emotionalTone, emotionalTone) ||
                other.emotionalTone == emotionalTone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text,
      const DeepCollectionEquality().hash(_scores), emotionalTone);

  /// Create a copy of AnswerOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnswerOptionImplCopyWith<_$AnswerOptionImpl> get copyWith =>
      __$$AnswerOptionImplCopyWithImpl<_$AnswerOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnswerOptionImplToJson(
      this,
    );
  }
}

abstract class _AnswerOption implements AnswerOption {
  const factory _AnswerOption(
      {required final String id,
      required final String text,
      @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
      required final Map<EQDimension, int> scores,
      final String? emotionalTone}) = _$AnswerOptionImpl;

  factory _AnswerOption.fromJson(Map<String, dynamic> json) =
      _$AnswerOptionImpl.fromJson;

  @override
  String get id;
  @override
  String
      get text; // ignore: invalid_annotation_target — Freezed factory params map to fields
  @override
  @JsonKey(fromJson: _scoresFromJson, toJson: _scoresToJson)
  Map<EQDimension, int> get scores; // Points per dimension
  @override
  String? get emotionalTone;

  /// Create a copy of AnswerOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnswerOptionImplCopyWith<_$AnswerOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
