// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisPrompt _$AnalysisPromptFromJson(Map<String, dynamic> json) =>
    AnalysisPrompt(
      id: json['id'] as String,
      name: json['name'] as String,
      promptTemplate: json['promptTemplate'] as String,
      description: json['description'] as String? ?? '',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AnalysisPromptToJson(AnalysisPrompt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'promptTemplate': instance.promptTemplate,
      'description': instance.description,
      'createdAt': instance.createdAt,
    };
