// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ollama_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaConfig _$OllamaConfigFromJson(Map<String, dynamic> json) => OllamaConfig(
      id: json['id'] as String,
      systemPrompt: json['systemPrompt'] as String? ?? '',
      model: json['model'] as String? ?? 'llama3',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 4096,
    );

Map<String, dynamic> _$OllamaConfigToJson(OllamaConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systemPrompt': instance.systemPrompt,
      'model': instance.model,
      'temperature': instance.temperature,
      'topP': instance.topP,
      'maxTokens': instance.maxTokens,
    };
