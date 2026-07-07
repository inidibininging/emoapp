// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      id: json['id'] as String,
      backendType:
          $enumDecodeNullable(_$BackendTypeEnumMap, json['backendType']) ??
              BackendType.localStorage,
      pocketbaseUrl: json['pocketbaseUrl'] as String? ?? '',
      pocketbaseEmail: json['pocketbaseEmail'] as String? ?? '',
      pocketbasePassword: json['pocketbasePassword'] as String? ?? '',
      storageLocation: json['storageLocation'] as String? ?? '',
      enableAutoBackup: json['enableAutoBackup'] as bool? ?? false,
      backupFrequencyDays: (json['backupFrequencyDays'] as num?)?.toInt() ?? 7,
      lastBackupTimestamp: (json['lastBackupTimestamp'] as num?)?.toInt() ?? 0,
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
      enableOllamaIntegration:
          json['enableOllamaIntegration'] as bool? ?? false,
      ollamaBaseUrl:
          json['ollamaBaseUrl'] as String? ?? 'http://localhost:11434',
      defaultOllamaModel: json['defaultOllamaModel'] as String? ?? 'llama3',
      showAdvancedSettings: json['showAdvancedSettings'] as bool? ?? false,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'backendType': _$BackendTypeEnumMap[instance.backendType]!,
      'pocketbaseUrl': instance.pocketbaseUrl,
      'pocketbaseEmail': instance.pocketbaseEmail,
      'pocketbasePassword': instance.pocketbasePassword,
      'storageLocation': instance.storageLocation,
      'enableAutoBackup': instance.enableAutoBackup,
      'backupFrequencyDays': instance.backupFrequencyDays,
      'lastBackupTimestamp': instance.lastBackupTimestamp,
      'enableAnalytics': instance.enableAnalytics,
      'themeMode': instance.themeMode,
      'enableOllamaIntegration': instance.enableOllamaIntegration,
      'ollamaBaseUrl': instance.ollamaBaseUrl,
      'defaultOllamaModel': instance.defaultOllamaModel,
      'showAdvancedSettings': instance.showAdvancedSettings,
    };

const _$BackendTypeEnumMap = {
  BackendType.localStorage: 'localStorage',
  BackendType.pocketbase: 'pocketbase',
  BackendType.firebase: 'firebase',
  BackendType.custom: 'custom',
};
