// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_base_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityBaseType _$EntityBaseTypeFromJson(Map<String, dynamic> json) =>
    EntityBaseType(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$EntityBaseTypeToJson(EntityBaseType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
    };
