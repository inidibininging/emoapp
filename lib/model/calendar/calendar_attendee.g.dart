// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_attendee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarAttendee _$CalendarAttendeeFromJson(Map<String, dynamic> json) =>
    CalendarAttendee(
      id: json['id'] as String,
      alias: json['alias'] as String,
      email: json['email'] as String,
      timeStamp: DateTime.parse(json['timeStamp'] as String),
    );

Map<String, dynamic> _$CalendarAttendeeToJson(CalendarAttendee instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alias': instance.alias,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'email': instance.email,
    };
