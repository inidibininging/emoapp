// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_extended.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalEntryExtended _$JournalEntryExtendedFromJson(
        Map<String, dynamic> json) =>
    JournalEntryExtended(
      id: json['id'] as String,
      text: json['text'] as String,
      timeStamp: DateTime.parse(json['timeStamp'] as String),
      emotionalLevel: (json['emotionalLevel'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      discussionId: json['discussionId'] as String,
      calendarEntryId: json['calendarEntryId'] as String? ?? '',
    );

Map<String, dynamic> _$JournalEntryExtendedToJson(
        JournalEntryExtended instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'emotionalLevel': instance.emotionalLevel,
      'type': instance.type,
      'calendarEntryId': instance.calendarEntryId,
      'discussionId': instance.discussionId,
    };
