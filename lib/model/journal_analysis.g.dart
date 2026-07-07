// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalAnalysis _$JournalAnalysisFromJson(Map<String, dynamic> json) =>
    JournalAnalysis(
      id: json['id'] as String,
      promptId: json['promptId'] as String,
      entryIds:
          (json['entryIds'] as List<dynamic>).map((e) => e as String).toList(),
      analysisResult: json['analysisResult'] as String,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$JournalAnalysisToJson(JournalAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'promptId': instance.promptId,
      'entryIds': instance.entryIds,
      'analysisResult': instance.analysisResult,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
