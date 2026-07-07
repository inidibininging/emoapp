import 'package:emoapp/model/entity_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'journal_analysis.g.dart';

@JsonSerializable()
class JournalAnalysis extends EntityBase<JournalAnalysis> {
  JournalAnalysis({
    required super.id,
    required this.promptId,
    required this.entryIds,
    required this.analysisResult,
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  String promptId;
  List<String> entryIds;
  String analysisResult;
  int createdAt;
  int updatedAt;

  @override
  factory JournalAnalysis.fromJson(Map<String, dynamic> json) {
    return _$JournalAnalysisFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$JournalAnalysisToJson(this);

  @override
  JournalAnalysis fromJson2(Map<String, dynamic> json) => _$JournalAnalysisFromJson(json);
}
