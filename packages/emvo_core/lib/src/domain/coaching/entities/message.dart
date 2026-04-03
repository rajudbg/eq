import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@JsonEnum()
enum MessageSender {
  user,
  coach,
  system,
}

@JsonEnum()
enum MessageType {
  text,
  exercise,
  insight,
  checkIn,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String content,
    required MessageSender sender,
    required DateTime timestamp,
    @Default(MessageType.text) MessageType type,
    Map<String, dynamic>? metadata,
    String? emotionalTone,
    bool? isRead,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
class CoachingSession with _$CoachingSession {
  const factory CoachingSession({
    required String id,
    required DateTime startedAt,
    DateTime? endedAt,
    required List<Message> messages,
    String? topic,
    Map<String, dynamic>? context,
  }) = _CoachingSession;

  factory CoachingSession.fromJson(Map<String, dynamic> json) =>
      _$CoachingSessionFromJson(json);
}

@freezed
class CoachingInsight with _$CoachingInsight {
  const factory CoachingInsight({
    required String id,
    required String title,
    required String description,
    required DateTime generatedAt,
    String? relatedDimension,
    List<String>? actionItems,
  }) = _CoachingInsight;

  factory CoachingInsight.fromJson(Map<String, dynamic> json) =>
      _$CoachingInsightFromJson(json);
}
