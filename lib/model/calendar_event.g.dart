// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarEventAdapter extends TypeAdapter<CalendarEvent> {
  @override
  final int typeId = 5;

  @override
  CalendarEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarEvent(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      dateStart: fields[3] as DateTime,
      dateEnd: fields[4] as DateTime,
      categories: (fields[5] as List).cast<String>(),
      tags: (fields[6] as List).cast<String>(),
      timeStamp: fields[7] as DateTime,
      lastModified: fields[8] as DateTime,
      attendees: (fields[9] as List).cast<CalendarAttendee>(),
    );
  }

  @override
  void write(BinaryWriter writer, CalendarEvent obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dateStart)
      ..writeByte(4)
      ..write(obj.dateEnd)
      ..writeByte(5)
      ..write(obj.categories)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.timeStamp)
      ..writeByte(8)
      ..write(obj.lastModified)
      ..writeByte(9)
      ..write(obj.attendees);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
