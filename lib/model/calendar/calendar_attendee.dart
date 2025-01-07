import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:emoapp/model/json_serializable_interface.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calendar_attendee.g.dart';

@JsonSerializable()
class CalendarAttendee extends EntityBase<CalendarAttendee> {
  // used by retrospective or perspective

  CalendarAttendee({
    required super.id,
    required this.alias,
    required this.email,
    required this.timeStamp,
  });

  final String alias;
  final DateTime timeStamp;
  final String email;

  factory CalendarAttendee.fromJson(Map<String, dynamic> json) =>
      _$CalendarAttendeeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CalendarAttendeeToJson(this);

  @override
  CalendarAttendee fromJson2(Map<String, dynamic> json) {
    return _$CalendarAttendeeFromJson(json);
  }
}
