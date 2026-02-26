// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscussionMessage _$DiscussionMessageFromJson(Map<String, dynamic> json) =>
    DiscussionMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      profileId: json['profileId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DiscussionMessageToJson(DiscussionMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'profileId': instance.profileId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
