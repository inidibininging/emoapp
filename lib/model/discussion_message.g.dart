// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscussionMessageAdapter extends TypeAdapter<DiscussionMessage> {
  @override
  final int typeId = 2;

  @override
  DiscussionMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscussionMessage(
      id: fields[0] as String,
      content: fields[1] as String,
      profileId: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DiscussionMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.profileId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(0)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscussionMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
