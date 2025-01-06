// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscussionAdapter extends TypeAdapter<Discussion> {
  @override
  final int typeId = 1;

  @override
  Discussion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Discussion(
      name: fields[2] as String,
      imageKey: fields[3] as String,
      description: fields[4] as String,
      id: fields[0] as String,
      children1: (fields[102] as List).cast<EntityBaseType>(),
    );
  }

  @override
  void write(BinaryWriter writer, Discussion obj) {
    writer
      ..writeByte(5)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.imageKey)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(102)
      ..write(obj.children1)
      ..writeByte(0)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscussionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
