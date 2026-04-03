// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: $enumDecode(_$MessageSenderEnumMap, json['sender']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      metadata: json['metadata'] as Map<String, dynamic>?,
      emotionalTone: json['emotionalTone'] as String?,
      isRead: json['isRead'] as bool?,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$MessageTypeEnumMap[instance.type]!,
      'metadata': instance.metadata,
      'emotionalTone': instance.emotionalTone,
      'isRead': instance.isRead,
    };

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.coach: 'coach',
  MessageSender.system: 'system',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.exercise: 'exercise',
  MessageType.insight: 'insight',
  MessageType.checkIn: 'checkIn',
};

_$CoachingSessionImpl _$$CoachingSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$CoachingSessionImpl(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      topic: json['topic'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CoachingSessionImplToJson(
        _$CoachingSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'messages': instance.messages,
      'topic': instance.topic,
      'context': instance.context,
    };

_$CoachingInsightImpl _$$CoachingInsightImplFromJson(
        Map<String, dynamic> json) =>
    _$CoachingInsightImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      relatedDimension: json['relatedDimension'] as String?,
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$CoachingInsightImplToJson(
        _$CoachingInsightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'relatedDimension': instance.relatedDimension,
      'actionItems': instance.actionItems,
    };
