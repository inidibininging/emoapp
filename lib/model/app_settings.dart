import 'package:emoapp/model/entity_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

enum BackendType {
  localStorage,
  pocketbase,
  firebase,
  custom
}

@JsonSerializable()
class AppSettings extends EntityBase<AppSettings> {
  AppSettings({
    required super.id,
    this.backendType = BackendType.localStorage,
    this.pocketbaseUrl = '',
    this.pocketbaseEmail = '',
    this.pocketbasePassword = '',
    this.storageLocation = '',
    this.enableAutoBackup = false,
    this.backupFrequencyDays = 7,
    this.lastBackupTimestamp = 0,
    this.enableAnalytics = false,
    this.themeMode = 'system',
    this.enableOllamaIntegration = false,
    this.ollamaBaseUrl = 'http://localhost:11434',
    this.defaultOllamaModel = 'llama3',
    this.showAdvancedSettings = false,
  });

  BackendType backendType;
  String pocketbaseUrl;
  String pocketbaseEmail;
  String pocketbasePassword;
  String storageLocation;
  bool enableAutoBackup;
  int backupFrequencyDays;
  int lastBackupTimestamp;
  bool enableAnalytics;
  String themeMode;
  bool enableOllamaIntegration;
  String ollamaBaseUrl;
  String defaultOllamaModel;
  bool showAdvancedSettings;

  @override
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return _$AppSettingsFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  @override
  AppSettings fromJson2(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
