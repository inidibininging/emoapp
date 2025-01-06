import 'package:emoapp/model/entity_numbers.dart';
import 'package:hive/hive.dart';

part 'calendar_attendee.g.dart';

@HiveType(typeId: calendarAttendeeTypeId)
class CalendarAttendee {
  // used by retrospective or perspective

  CalendarAttendee({
    required this.id,
    required this.alias,
    required this.email,
    required this.timeStamp,
  });
  @HiveField(0)
  String id;
  @HiveField(1)
  String alias;
  @HiveField(2)
  final DateTime timeStamp;
  @HiveField(3)
  String email;
}
