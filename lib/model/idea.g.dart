// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Idea _$IdeaFromJson(Map<String, dynamic> json) => Idea(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => e is Reference
                  ? e
                  : Reference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      ownerUuid: json['ownerUuid'] as String? ?? '',
      groupUuid: json['groupUuid'] as String? ?? '',
      positionX: (json['positionX'] as num).toDouble(),
      positionY: (json['positionY'] as num).toDouble(),
      referencedTopic: json['referencedTopic'] as String? ?? '',
    );

Map<String, dynamic> _$IdeaToJson(Idea instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'references': instance.references,
      'ownerUuid': instance.ownerUuid,
      'groupUuid': instance.groupUuid,
      'positionX': instance.positionX,
      'positionY': instance.positionY,
      'referencedTopic': instance.referencedTopic,
    };
