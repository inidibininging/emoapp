// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanban.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kanban _$KanbanFromJson(Map<String, dynamic> json) => Kanban(
      id: json['id'] as String,
      name: json['name'] as String,
      topicId: json['topicId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      todos: (json['todos'] as List<dynamic>?)
          ?.map((e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList(),
      states:
          (json['states'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$KanbanToJson(Kanban instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'topicId': instance.topicId,
      'todos': instance.todos,
      'states': instance.states,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
