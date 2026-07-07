// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reference _$ReferenceFromJson(Map<String, dynamic> json) => Reference(
      id: json['id'] as String,
      text: json['text'] as String,
      ideaUuid: json['ideaUuid'] as String,
    );

Map<String, dynamic> _$ReferenceToJson(Reference instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'ideaUuid': instance.ideaUuid,
    };
