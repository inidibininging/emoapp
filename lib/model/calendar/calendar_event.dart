import 'package:emoapp/model/calendar/calendar_attendee.dart';
import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:emoapp/model/json_serializable_interface.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calendar_event.g.dart';

@JsonSerializable()
class CalendarEvent extends EntityBase<CalendarEvent> {
  CalendarEvent({
    required super.id,
    required this.title,
    required this.description,
    required this.dateStart,
    required this.dateEnd,
    required this.categories,
    required this.tags,
    required this.timeStamp,
    required this.lastModified,
    required this.attendees,
  });
  String title;

  String description;

  final DateTime dateStart;

  DateTime dateEnd;

  List<String> categories;

  List<String> tags;

  final DateTime timeStamp;

  final DateTime lastModified;

  List<CalendarAttendee> attendees;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  @override
  CalendarEvent fromJson2(Map<String, dynamic> json) {
    return _$CalendarEventFromJson(json);
  }
}
