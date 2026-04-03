// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserSubscription {
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  SubscriptionTier get currentTier => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  String? get receiptId => throw _privateConstructorUsedError;
  bool? get willRenew => throw _privateConstructorUsedError;

  /// Create a copy of UserSubscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSubscriptionCopyWith<UserSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSubscriptionCopyWith<$Res> {
  factory $UserSubscriptionCopyWith(
          UserSubscription value, $Res Function(UserSubscription) then) =
      _$UserSubscriptionCopyWithImpl<$Res, UserSubscription>;
  @useResult
  $Res call(
      {SubscriptionStatus status,
      SubscriptionTier currentTier,
      DateTime? expiryDate,
      DateTime? purchaseDate,
      String? receiptId,
      bool? willRenew});
}

/// @nodoc
class _$UserSubscriptionCopyWithImpl<$Res, $Val extends UserSubscription>
    implements $UserSubscriptionCopyWith<$Res> {
  _$UserSubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSubscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentTier = null,
    Object? expiryDate = freezed,
    Object? purchaseDate = freezed,
    Object? receiptId = freezed,
    Object? willRenew = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      currentTier: null == currentTier
          ? _value.currentTier
          : currentTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receiptId: freezed == receiptId
          ? _value.receiptId
          : receiptId // ignore: cast_nullable_to_non_nullable
              as String?,
      willRenew: freezed == willRenew
          ? _value.willRenew
          : willRenew // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSubscriptionImplCopyWith<$Res>
    implements $UserSubscriptionCopyWith<$Res> {
  factory _$$UserSubscriptionImplCopyWith(_$UserSubscriptionImpl value,
          $Res Function(_$UserSubscriptionImpl) then) =
      __$$UserSubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SubscriptionStatus status,
      SubscriptionTier currentTier,
      DateTime? expiryDate,
      DateTime? purchaseDate,
      String? receiptId,
      bool? willRenew});
}

/// @nodoc
class __$$UserSubscriptionImplCopyWithImpl<$Res>
    extends _$UserSubscriptionCopyWithImpl<$Res, _$UserSubscriptionImpl>
    implements _$$UserSubscriptionImplCopyWith<$Res> {
  __$$UserSubscriptionImplCopyWithImpl(_$UserSubscriptionImpl _value,
      $Res Function(_$UserSubscriptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSubscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentTier = null,
    Object? expiryDate = freezed,
    Object? purchaseDate = freezed,
    Object? receiptId = freezed,
    Object? willRenew = freezed,
  }) {
    return _then(_$UserSubscriptionImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      currentTier: null == currentTier
          ? _value.currentTier
          : currentTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receiptId: freezed == receiptId
          ? _value.receiptId
          : receiptId // ignore: cast_nullable_to_non_nullable
              as String?,
      willRenew: freezed == willRenew
          ? _value.willRenew
          : willRenew // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$UserSubscriptionImpl implements _UserSubscription {
  const _$UserSubscriptionImpl(
      {required this.status,
      required this.currentTier,
      this.expiryDate,
      this.purchaseDate,
      this.receiptId,
      this.willRenew});

  @override
  final SubscriptionStatus status;
  @override
  final SubscriptionTier currentTier;
  @override
  final DateTime? expiryDate;
  @override
  final DateTime? purchaseDate;
  @override
  final String? receiptId;
  @override
  final bool? willRenew;

  @override
  String toString() {
    return 'UserSubscription(status: $status, currentTier: $currentTier, expiryDate: $expiryDate, purchaseDate: $purchaseDate, receiptId: $receiptId, willRenew: $willRenew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSubscriptionImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentTier, currentTier) ||
                other.currentTier == currentTier) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.receiptId, receiptId) ||
                other.receiptId == receiptId) &&
            (identical(other.willRenew, willRenew) ||
                other.willRenew == willRenew));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, currentTier, expiryDate,
      purchaseDate, receiptId, willRenew);

  /// Create a copy of UserSubscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSubscriptionImplCopyWith<_$UserSubscriptionImpl> get copyWith =>
      __$$UserSubscriptionImplCopyWithImpl<_$UserSubscriptionImpl>(
          this, _$identity);
}

abstract class _UserSubscription implements UserSubscription {
  const factory _UserSubscription(
      {required final SubscriptionStatus status,
      required final SubscriptionTier currentTier,
      final DateTime? expiryDate,
      final DateTime? purchaseDate,
      final String? receiptId,
      final bool? willRenew}) = _$UserSubscriptionImpl;

  @override
  SubscriptionStatus get status;
  @override
  SubscriptionTier get currentTier;
  @override
  DateTime? get expiryDate;
  @override
  DateTime? get purchaseDate;
  @override
  String? get receiptId;
  @override
  bool? get willRenew;

  /// Create a copy of UserSubscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSubscriptionImplCopyWith<_$UserSubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
