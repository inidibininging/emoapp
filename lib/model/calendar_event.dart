import 'package:emoapp/model/calendar_attendee.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:hive/hive.dart';

part 'calendar_event.g.dart';

@HiveType(typeId: calendarEventTypeId)
class CalendarEvent {
  CalendarEvent({
    required this.id,
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
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  final DateTime dateStart;

  @HiveField(4)
  DateTime dateEnd;

  @HiveField(5)
  List<String> categories;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  final DateTime timeStamp;

  @HiveField(8)
  final DateTime lastModified;

  @HiveField(9)
  List<CalendarAttendee> attendees;
}
