import 'package:emoapp/model/entity_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_prompt.g.dart';

@JsonSerializable()
class AnalysisPrompt extends EntityBase<AnalysisPrompt> {
  AnalysisPrompt({
    required super.id,
    required this.name,
    required this.promptTemplate,
    this.description = '',
    this.createdAt = 0,
  });

  String name;
  String promptTemplate;
  String description;
  int createdAt;

  @override
  factory AnalysisPrompt.fromJson(Map<String, dynamic> json) {
    return _$AnalysisPromptFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$AnalysisPromptToJson(this);

  @override
  AnalysisPrompt fromJson2(Map<String, dynamic> json) => _$AnalysisPromptFromJson(json);
}
