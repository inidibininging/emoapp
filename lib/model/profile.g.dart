// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      imageKey: json['imageKey'] as String,
      description: json['description'] as String,
      currentDiscussionId: json['currentDiscussionId'] as String,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageKey': instance.imageKey,
      'description': instance.description,
      'currentDiscussionId': instance.currentDiscussionId,
    };
