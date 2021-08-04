// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmotionTypeAdapter extends TypeAdapter<EmotionType> {
  @override
  final int typeId = 1;

  @override
  EmotionType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionType(
      emotion: fields[0] as String,
      icon: fields[1] as String,
      minEmotionalLevel: fields[2] as int,
      maxEmotionalLevel: fields[3] as int,
      emotionalLevel: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionType obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.emotion)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.minEmotionalLevel)
      ..writeByte(3)
      ..write(obj.maxEmotionalLevel)
      ..writeByte(4)
      ..write(obj.emotionalLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
