// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_attendee.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarAttendeeAdapter extends TypeAdapter<CalendarAttendee> {
  @override
  final int typeId = 4;

  @override
  CalendarAttendee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarAttendee(
      id: fields[0] as String,
      alias: fields[1] as String,
      email: fields[3] as String,
      timeStamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CalendarAttendee obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alias)
      ..writeByte(2)
      ..write(obj.timeStamp)
      ..writeByte(3)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarAttendeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
