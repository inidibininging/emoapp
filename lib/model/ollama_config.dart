import 'package:emoapp/model/entity_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ollama_config.g.dart';

@JsonSerializable()
class OllamaConfig extends EntityBase<OllamaConfig> {
  OllamaConfig({
    required super.id,
    this.systemPrompt = '',
    this.model = 'llama3',
    this.temperature = 0.7,
    this.topP = 0.9,
    this.maxTokens = 4096,
  });

  String systemPrompt;
  String model;
  double temperature;
  double topP;
  int maxTokens;

  @override
  factory OllamaConfig.fromJson(Map<String, dynamic> json) {
    return _$OllamaConfigFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$OllamaConfigToJson(this);

  @override
  OllamaConfig fromJson2(Map<String, dynamic> json) => _$OllamaConfigFromJson(json);
}
