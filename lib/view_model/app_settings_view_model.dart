import 'package:emoapp/model/app_settings.dart';
import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/services/sdb.dart';
import 'package:flutter/material.dart';

class AppSettingsViewModel extends ChangeNotifier {
  final Sdb<AppSettings> _sdb = Sdb<AppSettings>();
  AppSettings? _currentSettings;
  bool _isLoading = false;

  AppSettingsViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _sdb.openBox();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final settings = await _sdb.getAll();
      if (settings.isNotEmpty) {
        _currentSettings = settings.values.first;
      } else {
        // Create default settings
        _currentSettings = AppSettings(id: EntityBase.generateId());
        await _saveSettings();
      }
    } catch (e) {
      _currentSettings = AppSettings(id: EntityBase.generateId());
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    if (_currentSettings != null) {
      await _sdb.put(_currentSettings!.id, _currentSettings!);
    }
  }

  AppSettings? get currentSettings => _currentSettings;
  bool get isLoading => _isLoading;

  Future<void> updateSettings(AppSettings settings) async {
    _currentSettings = settings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateBackendType(BackendType backendType) async {
    if (_currentSettings != null) {
      _currentSettings!.backendType = backendType;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updatePocketbaseUrl(String url) async {
    if (_currentSettings != null) {
      _currentSettings!.pocketbaseUrl = url;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updatePocketbaseCredentials(String email, String password) async {
    if (_currentSettings != null) {
      _currentSettings!.pocketbaseEmail = email;
      _currentSettings!.pocketbasePassword = password;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updateStorageLocation(String location) async {
    if (_currentSettings != null) {
      _currentSettings!.storageLocation = location;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updateOllamaSettings(bool enabled, String baseUrl, String defaultModel) async {
    if (_currentSettings != null) {
      _currentSettings!.enableOllamaIntegration = enabled;
      _currentSettings!.ollamaBaseUrl = baseUrl;
      _currentSettings!.defaultOllamaModel = defaultModel;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    if (_currentSettings != null) {
      _currentSettings!.themeMode = themeMode;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updateBackupSettings(bool enableAutoBackup, int frequencyDays) async {
    if (_currentSettings != null) {
      _currentSettings!.enableAutoBackup = enableAutoBackup;
      _currentSettings!.backupFrequencyDays = frequencyDays;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updateLastBackupTimestamp() async {
    if (_currentSettings != null) {
      _currentSettings!.lastBackupTimestamp = DateTime.now().millisecondsSinceEpoch;
      await _saveSettings();
      notifyListeners();
    }
  }
}
