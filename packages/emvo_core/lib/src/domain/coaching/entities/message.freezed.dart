// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageSender get sender => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get emotionalTone => throw _privateConstructorUsedError;
  bool? get isRead => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String content,
      MessageSender sender,
      DateTime timestamp,
      MessageType type,
      Map<String, dynamic>? metadata,
      String? emotionalTone,
      bool? isRead});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? sender = null,
    Object? timestamp = null,
    Object? type = null,
    Object? metadata = freezed,
    Object? emotionalTone = freezed,
    Object? isRead = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as MessageSender,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      emotionalTone: freezed == emotionalTone
          ? _value.emotionalTone
          : emotionalTone // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: freezed == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      MessageSender sender,
      DateTime timestamp,
      MessageType type,
      Map<String, dynamic>? metadata,
      String? emotionalTone,
      bool? isRead});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? sender = null,
    Object? timestamp = null,
    Object? type = null,
    Object? metadata = freezed,
    Object? emotionalTone = freezed,
    Object? isRead = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as MessageSender,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      emotionalTone: freezed == emotionalTone
          ? _value.emotionalTone
          : emotionalTone // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: freezed == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.content,
      required this.sender,
      required this.timestamp,
      this.type = MessageType.text,
      final Map<String, dynamic>? metadata,
      this.emotionalTone,
      this.isRead})
      : _metadata = metadata;

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final MessageSender sender;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final MessageType type;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? emotionalTone;
  @override
  final bool? isRead;

  @override
  String toString() {
    return 'Message(id: $id, content: $content, sender: $sender, timestamp: $timestamp, type: $type, metadata: $metadata, emotionalTone: $emotionalTone, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.emotionalTone, emotionalTone) ||
                other.emotionalTone == emotionalTone) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      content,
      sender,
      timestamp,
      type,
      const DeepCollectionEquality().hash(_metadata),
      emotionalTone,
      isRead);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String content,
      required final MessageSender sender,
      required final DateTime timestamp,
      final MessageType type,
      final Map<String, dynamic>? metadata,
      final String? emotionalTone,
      final bool? isRead}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  MessageSender get sender;
  @override
  DateTime get timestamp;
  @override
  MessageType get type;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get emotionalTone;
  @override
  bool? get isRead;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoachingSession _$CoachingSessionFromJson(Map<String, dynamic> json) {
  return _CoachingSession.fromJson(json);
}

/// @nodoc
mixin _$CoachingSession {
  String get id => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  List<Message> get messages => throw _privateConstructorUsedError;
  String? get topic => throw _privateConstructorUsedError;
  Map<String, dynamic>? get context => throw _privateConstructorUsedError;

  /// Serializes this CoachingSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoachingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoachingSessionCopyWith<CoachingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoachingSessionCopyWith<$Res> {
  factory $CoachingSessionCopyWith(
          CoachingSession value, $Res Function(CoachingSession) then) =
      _$CoachingSessionCopyWithImpl<$Res, CoachingSession>;
  @useResult
  $Res call(
      {String id,
      DateTime startedAt,
      DateTime? endedAt,
      List<Message> messages,
      String? topic,
      Map<String, dynamic>? context});
}

/// @nodoc
class _$CoachingSessionCopyWithImpl<$Res, $Val extends CoachingSession>
    implements $CoachingSessionCopyWith<$Res> {
  _$CoachingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoachingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? messages = null,
    Object? topic = freezed,
    Object? context = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<Message>,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoachingSessionImplCopyWith<$Res>
    implements $CoachingSessionCopyWith<$Res> {
  factory _$$CoachingSessionImplCopyWith(_$CoachingSessionImpl value,
          $Res Function(_$CoachingSessionImpl) then) =
      __$$CoachingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime startedAt,
      DateTime? endedAt,
      List<Message> messages,
      String? topic,
      Map<String, dynamic>? context});
}

/// @nodoc
class __$$CoachingSessionImplCopyWithImpl<$Res>
    extends _$CoachingSessionCopyWithImpl<$Res, _$CoachingSessionImpl>
    implements _$$CoachingSessionImplCopyWith<$Res> {
  __$$CoachingSessionImplCopyWithImpl(
      _$CoachingSessionImpl _value, $Res Function(_$CoachingSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoachingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? messages = null,
    Object? topic = freezed,
    Object? context = freezed,
  }) {
    return _then(_$CoachingSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<Message>,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      context: freezed == context
          ? _value._context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoachingSessionImpl implements _CoachingSession {
  const _$CoachingSessionImpl(
      {required this.id,
      required this.startedAt,
      this.endedAt,
      required final List<Message> messages,
      this.topic,
      final Map<String, dynamic>? context})
      : _messages = messages,
        _context = context;

  factory _$CoachingSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoachingSessionImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  final List<Message> _messages;
  @override
  List<Message> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final String? topic;
  final Map<String, dynamic>? _context;
  @override
  Map<String, dynamic>? get context {
    final value = _context;
    if (value == null) return null;
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CoachingSession(id: $id, startedAt: $startedAt, endedAt: $endedAt, messages: $messages, topic: $topic, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoachingSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            const DeepCollectionEquality().equals(other._context, _context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      startedAt,
      endedAt,
      const DeepCollectionEquality().hash(_messages),
      topic,
      const DeepCollectionEquality().hash(_context));

  /// Create a copy of CoachingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoachingSessionImplCopyWith<_$CoachingSessionImpl> get copyWith =>
      __$$CoachingSessionImplCopyWithImpl<_$CoachingSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoachingSessionImplToJson(
      this,
    );
  }
}

abstract class _CoachingSession implements CoachingSession {
  const factory _CoachingSession(
      {required final String id,
      required final DateTime startedAt,
      final DateTime? endedAt,
      required final List<Message> messages,
      final String? topic,
      final Map<String, dynamic>? context}) = _$CoachingSessionImpl;

  factory _CoachingSession.fromJson(Map<String, dynamic> json) =
      _$CoachingSessionImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  List<Message> get messages;
  @override
  String? get topic;
  @override
  Map<String, dynamic>? get context;

  /// Create a copy of CoachingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoachingSessionImplCopyWith<_$CoachingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoachingInsight _$CoachingInsightFromJson(Map<String, dynamic> json) {
  return _CoachingInsight.fromJson(json);
}

/// @nodoc
mixin _$CoachingInsight {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;
  String? get relatedDimension => throw _privateConstructorUsedError;
  List<String>? get actionItems => throw _privateConstructorUsedError;

  /// Serializes this CoachingInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoachingInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoachingInsightCopyWith<CoachingInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoachingInsightCopyWith<$Res> {
  factory $CoachingInsightCopyWith(
          CoachingInsight value, $Res Function(CoachingInsight) then) =
      _$CoachingInsightCopyWithImpl<$Res, CoachingInsight>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      DateTime generatedAt,
      String? relatedDimension,
      List<String>? actionItems});
}

/// @nodoc
class _$CoachingInsightCopyWithImpl<$Res, $Val extends CoachingInsight>
    implements $CoachingInsightCopyWith<$Res> {
  _$CoachingInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoachingInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? generatedAt = null,
    Object? relatedDimension = freezed,
    Object? actionItems = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      relatedDimension: freezed == relatedDimension
          ? _value.relatedDimension
          : relatedDimension // ignore: cast_nullable_to_non_nullable
              as String?,
      actionItems: freezed == actionItems
          ? _value.actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoachingInsightImplCopyWith<$Res>
    implements $CoachingInsightCopyWith<$Res> {
  factory _$$CoachingInsightImplCopyWith(_$CoachingInsightImpl value,
          $Res Function(_$CoachingInsightImpl) then) =
      __$$CoachingInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      DateTime generatedAt,
      String? relatedDimension,
      List<String>? actionItems});
}

/// @nodoc
class __$$CoachingInsightImplCopyWithImpl<$Res>
    extends _$CoachingInsightCopyWithImpl<$Res, _$CoachingInsightImpl>
    implements _$$CoachingInsightImplCopyWith<$Res> {
  __$$CoachingInsightImplCopyWithImpl(
      _$CoachingInsightImpl _value, $Res Function(_$CoachingInsightImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoachingInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? generatedAt = null,
    Object? relatedDimension = freezed,
    Object? actionItems = freezed,
  }) {
    return _then(_$CoachingInsightImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      relatedDimension: freezed == relatedDimension
          ? _value.relatedDimension
          : relatedDimension // ignore: cast_nullable_to_non_nullable
              as String?,
      actionItems: freezed == actionItems
          ? _value._actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoachingInsightImpl implements _CoachingInsight {
  const _$CoachingInsightImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.generatedAt,
      this.relatedDimension,
      final List<String>? actionItems})
      : _actionItems = actionItems;

  factory _$CoachingInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoachingInsightImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime generatedAt;
  @override
  final String? relatedDimension;
  final List<String>? _actionItems;
  @override
  List<String>? get actionItems {
    final value = _actionItems;
    if (value == null) return null;
    if (_actionItems is EqualUnmodifiableListView) return _actionItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CoachingInsight(id: $id, title: $title, description: $description, generatedAt: $generatedAt, relatedDimension: $relatedDimension, actionItems: $actionItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoachingInsightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.relatedDimension, relatedDimension) ||
                other.relatedDimension == relatedDimension) &&
            const DeepCollectionEquality()
                .equals(other._actionItems, _actionItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      generatedAt,
      relatedDimension,
      const DeepCollectionEquality().hash(_actionItems));

  /// Create a copy of CoachingInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoachingInsightImplCopyWith<_$CoachingInsightImpl> get copyWith =>
      __$$CoachingInsightImplCopyWithImpl<_$CoachingInsightImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoachingInsightImplToJson(
      this,
    );
  }
}

abstract class _CoachingInsight implements CoachingInsight {
  const factory _CoachingInsight(
      {required final String id,
      required final String title,
      required final String description,
      required final DateTime generatedAt,
      final String? relatedDimension,
      final List<String>? actionItems}) = _$CoachingInsightImpl;

  factory _CoachingInsight.fromJson(Map<String, dynamic> json) =
      _$CoachingInsightImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get generatedAt;
  @override
  String? get relatedDimension;
  @override
  List<String>? get actionItems;

  /// Create a copy of CoachingInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoachingInsightImplCopyWith<_$CoachingInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
