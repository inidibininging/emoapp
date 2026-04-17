import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ollama_dart/ollama_dart.dart';

/// ViewModel for managing app settings
class SettingsViewModel extends ChangeNotifier {
  String _currentStoragePath = '';
  bool _isLoading = false;
  String _statusMessage = '';
  bool _autoReloadDatabaseOnFolderChange = true;

  // Ollama configuration
  String _ollamaHost = 'http://localhost';
  int _ollamaPort = 11434;
  String _ollamaModel = '';
  List<String> _availableModels = [];

  String get currentStoragePath => _currentStoragePath;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  bool get autoReloadDatabaseOnFolderChange =>
      _autoReloadDatabaseOnFolderChange;

  // Ollama getters
  String get ollamaHost => _ollamaHost;
  int get ollamaPort => _ollamaPort;
  String get ollamaModel => _ollamaModel;
  List<String> get availableModels => _availableModels;

  SettingsViewModel() {
    _initializeSettings();
  }

  /// Initialize all settings from storage
  Future<void> _initializeSettings() async {
    await _initializeStoragePath();
    await _loadAutoReloadSetting();
    await _loadOllamaSettings();
  }

  /// Initialize the current storage path from SharedPreferences or use default
  Future<void> _initializeStoragePath() async {
    if (kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('storage_path');

      if (savedPath != null && await Directory(savedPath).exists()) {
        _currentStoragePath = savedPath;
      } else {
        // Use default app documents directory if no saved path or path doesn't exist
        final appDir = await getApplicationDocumentsDirectory();
        _currentStoragePath = appDir.path;
      }
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error initializing storage path: $e';
      notifyListeners();
    }
  }

  /// Check if directory is readable and writable
  Future<bool> _checkDirectoryPermissions(String path) async {
    if (kIsWeb) return true;

    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        _statusMessage = 'Directory does not exist: $path';
        return false;
      }

      // Try to create a test file to verify write permissions
      final testFile = File('${path}/.emoapp_test');
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        return true;
      } catch (e) {
        _statusMessage = 'No write permission for directory: $path';
        return false;
      }
    } catch (e) {
      _statusMessage = 'Error checking directory permissions: $e';
      return false;
    }
  }

  /// Request storage permissions from the system
  Future<bool> _requestStoragePermissions() async {
    if (kIsWeb) return true;

    if (!Platform.isAndroid && !Platform.isIOS) {
      // For desktop platforms, permissions are handled differently
      return true;
    }

    try {
      // Request storage permissions
      PermissionStatus status;

      if (Platform.isAndroid) {
        // Request MANAGE_EXTERNAL_STORAGE for file access
        status = await Permission.manageExternalStorage.request();

        if (status.isDenied) {
          _statusMessage =
              'Storage permission denied. Please allow access to files and media.';
          notifyListeners();

          // Fallback to storage permission for older Android versions
          status = await Permission.storage.request();
          if (status.isDenied) {
            return false;
          }
        }

        if (status.isPermanentlyDenied) {
          _statusMessage =
              'Storage permission permanently denied. Open app settings to enable it.';
          notifyListeners();
          openAppSettings();
          return false;
        }

        if (status.isRestricted) {
          _statusMessage = 'Storage permission is restricted by system policy.';
          notifyListeners();
          return false;
        }
      } else if (Platform.isIOS) {
        status = await Permission.storage.request();
        if (status.isDenied) {
          _statusMessage = 'Storage permission denied';
          notifyListeners();
          return false;
        }

        if (status.isPermanentlyDenied) {
          _statusMessage =
              'Storage permission permanently denied. Open app settings.';
          notifyListeners();
          openAppSettings();
          return false;
        }
      }

      // All permissions granted
      return true;
    } catch (e) {
      _statusMessage = 'Error requesting permissions: $e';
      notifyListeners();
      return false;
    }
  }

  /// Pick a directory for storing YAML files
  Future<void> selectStorageDirectory() async {
    if (kIsWeb) {
      _statusMessage = 'Directory selection is not available on web';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _statusMessage = 'Checking permissions...';
    notifyListeners();

    // Request permissions
    final hasPermission = await _requestStoragePermissions();
    if (!hasPermission) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _statusMessage = 'Selecting directory...';
      notifyListeners();

      final selectedDirectory = await FilePicker.getDirectoryPath(
        initialDirectory: _currentStoragePath,
      );

      if (selectedDirectory == null) {
        _statusMessage = 'Directory selection cancelled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Verify the directory exists
      final dir = Directory(selectedDirectory);
      if (!await dir.exists()) {
        _statusMessage = 'Selected directory does not exist';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if we have read/write permissions for the directory
      final hasAccess = await _checkDirectoryPermissions(selectedDirectory);
      if (!hasAccess) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Save the path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('storage_path', selectedDirectory);

      _currentStoragePath = selectedDirectory;
      _statusMessage = 'Storage directory updated successfully';
      _isLoading = false;
      notifyListeners();

      // Automatically reload database if setting is enabled
      if (_autoReloadDatabaseOnFolderChange) {
        await reloadDatabaseFromDirectory();
      }
    } catch (e) {
      _statusMessage = 'Error selecting directory: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload database entries from the selected directory
  Future<void> reloadDatabaseFromDirectory() async {
    if (kIsWeb) {
      _statusMessage = 'Database reload is not available on web';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _statusMessage = 'Reloading database entries...';
    notifyListeners();

    try {
      final dir = Directory(_currentStoragePath);

      if (!await dir.exists()) {
        _statusMessage =
            'Storage directory does not exist: $_currentStoragePath';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get all subdirectories (entity types)
      final entities = dir.listSync();
      int totalFilesLoaded = 0;
      final List<String> loadedTypes = [];

      for (final entity in entities) {
        if (entity is Directory) {
          final entityType = entity.path.split(Platform.pathSeparator).last;
          final files = entity.listSync(recursive: false);
          final jsonFiles = files
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              .length;

          if (jsonFiles > 0) {
            loadedTypes.add('$entityType ($jsonFiles files)');
            totalFilesLoaded += jsonFiles;
          }
        }
      }

      if (totalFilesLoaded == 0) {
        _statusMessage =
            'No database files found in directory: $_currentStoragePath';
      } else {
        _statusMessage =
            'Successfully reloaded $totalFilesLoaded database entries\nEntityTypes loaded:\n${loadedTypes.join('\n')}';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error reloading database: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear status message
  void clearStatusMessage() {
    _statusMessage = '';
    notifyListeners();
  }

  /// Get applications documents directory (default storage)
  Future<String> getDefaultStoragePath() async {
    if (kIsWeb) return '';
    final appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  }

  /// Reset to default storage directory
  Future<void> resetToDefaultDirectory() async {
    if (kIsWeb) return;

    _isLoading = true;
    _statusMessage = 'Resetting to default directory...';
    notifyListeners();

    try {
      final defaultPath = await getDefaultStoragePath();
      _currentStoragePath = defaultPath;

      // Save the default path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('storage_path', defaultPath);

      _statusMessage = 'Reset to default storage directory';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error resetting directory: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load auto-reload database setting from shared preferences
  Future<void> _loadAutoReloadSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoReloadDatabaseOnFolderChange =
          prefs.getBool('auto_reload_database_on_folder_change') ?? true;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error loading auto-reload setting: $e';
      notifyListeners();
    }
  }

  /// Save auto-reload database setting to shared preferences
  Future<void> setAutoReloadDatabaseOnFolderChange(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoReloadDatabaseOnFolderChange = value;
      await prefs.setBool('auto_reload_database_on_folder_change', value);
      _statusMessage = value
          ? 'Auto-reload enabled when changing folder'
          : 'Auto-reload disabled';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error saving auto-reload setting: $e';
      notifyListeners();
    }
  }

  /// Load Ollama settings from shared preferences
  Future<void> _loadOllamaSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ollamaHost = prefs.getString('ollama_host') ?? 'http://localhost';
      _ollamaPort = prefs.getInt('ollama_port') ?? 11434;
      _ollamaModel = prefs.getString('ollama_model') ?? '';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error loading Ollama settings: $e';
      notifyListeners();
    }
  }

  /// Save Ollama host setting
  Future<void> setOllamaHost(String host) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ollamaHost = host;
      await prefs.setString('ollama_host', host);
      _statusMessage = 'Ollama host updated: $host';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error saving Ollama host: $e';
      notifyListeners();
    }
  }

  /// Save Ollama port setting
  Future<void> setOllamaPort(int port) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ollamaPort = port;
      await prefs.setInt('ollama_port', port);
      _statusMessage = 'Ollama port updated: $port';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error saving Ollama port: $e';
      notifyListeners();
    }
  }

  /// Save Ollama model setting
  Future<void> setOllamaModel(String model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ollamaModel = model;
      await prefs.setString('ollama_model', model);
      _statusMessage = 'Ollama model updated: $model';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error saving Ollama model: $e';
      notifyListeners();
    }
  }

  /// Fetch available models from Ollama server
  Future<void> fetchAvailableModels() async {
    _isLoading = true;
    _statusMessage = 'Fetching available models...';
    notifyListeners();

    try {
      final client = OllamaClient.withBaseUrl('$_ollamaHost:$_ollamaPort');
      // final models = await client.listModels();

      _availableModels = (await client.models.list())
              .models
              ?.map((m) => m.name ?? 'unknown')
              .toList() ??
          [];

      if (_availableModels.isEmpty) {
        _statusMessage =
            'No models found on Ollama server. Make sure Ollama is running.';
      } else {
        _statusMessage =
            'Successfully fetched ${_availableModels.length} model(s)';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _statusMessage =
          'Error fetching models: $e\nMake sure Ollama is running at $_ollamaHost:$_ollamaPort';
      _availableModels = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Test connection to Ollama server
  Future<bool> testOllamaConnection() async {
    _isLoading = true;
    _statusMessage = 'Testing Ollama connection...';
    notifyListeners();

    try {
      final client = OllamaClient.withBaseUrl('$_ollamaHost:$_ollamaPort');
      await client.models.list();

      _statusMessage =
          'Successfully connected to Ollama at $_ollamaHost:$_ollamaPort';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _statusMessage =
          'Connection failed: Unable to reach Ollama at $_ollamaHost:$_ollamaPort\n$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
