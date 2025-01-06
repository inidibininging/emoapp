// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_extended.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntryExtendedAdapter extends TypeAdapter<JournalEntryExtended> {
  @override
  final int typeId = 0;

  @override
  JournalEntryExtended read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntryExtended(
      id: fields[0] as String,
      text: fields[1] as String,
      timeStamp: fields[2] as DateTime,
      emotionalLevel: fields[3] as int,
      type: fields[5] as int,
      discussionId: fields[7] as String,
      hashtags: (fields[4] as List).cast<String>(),
      calendarEntryId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntryExtended obj) {
    writer
      ..writeByte(8)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.timeStamp)
      ..writeByte(3)
      ..write(obj.emotionalLevel)
      ..writeByte(4)
      ..write(obj.hashtags)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.calendarEntryId)
      ..writeByte(7)
      ..write(obj.discussionId)
      ..writeByte(0)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryExtendedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
