// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Discussion _$DiscussionFromJson(Map<String, dynamic> json) => Discussion(
      name: json['name'] as String,
      imageKey: json['imageKey'] as String,
      description: json['description'] as String,
      id: json['id'] as String,
      children1: (json['children1'] as List<dynamic>)
          .map((e) => EntityBaseType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DiscussionToJson(Discussion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'children1': instance.children1,
      'name': instance.name,
      'imageKey': instance.imageKey,
      'description': instance.description,
    };
