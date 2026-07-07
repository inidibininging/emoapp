import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/ollama_config.dart';
import 'package:emoapp/services/sdb.dart';
import 'package:flutter/material.dart';

class OllamaConfigViewModel extends ChangeNotifier {
  final Sdb<OllamaConfig> _sdb = Sdb<OllamaConfig>();
  OllamaConfig? _currentConfig;
  bool _isLoading = false;

  OllamaConfigViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _sdb.openBox();
    await _loadConfig();
  }

  Future<void> _loadConfig() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final configs = await _sdb.getAll();
      if (configs.isNotEmpty) {
        _currentConfig = configs.values.first;
      } else {
        // Create default config
        _currentConfig = OllamaConfig(id: EntityBase.generateId());
        await _saveConfig();
      }
    } catch (e) {
      _currentConfig = OllamaConfig(id: EntityBase.generateId());
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveConfig() async {
    if (_currentConfig != null) {
      await _sdb.put(_currentConfig!.id, _currentConfig!);
    }
  }

  OllamaConfig? get currentConfig => _currentConfig;
  bool get isLoading => _isLoading;

  Future<void> updateConfig(OllamaConfig config) async {
    _currentConfig = config;
    await _saveConfig();
    notifyListeners();
  }

  Future<void> updateSystemPrompt(String prompt) async {
    if (_currentConfig != null) {
      _currentConfig!.systemPrompt = prompt;
      await _saveConfig();
      notifyListeners();
    }
  }

  Future<void> updateModel(String model) async {
    if (_currentConfig != null) {
      _currentConfig!.model = model;
      await _saveConfig();
      notifyListeners();
    }
  }

  Future<void> updateTemperature(double temperature) async {
    if (_currentConfig != null) {
      _currentConfig!.temperature = temperature;
      await _saveConfig();
      notifyListeners();
    }
  }

  Future<void> updateTopP(double topP) async {
    if (_currentConfig != null) {
      _currentConfig!.topP = topP;
      await _saveConfig();
      notifyListeners();
    }
  }

  Future<void> updateMaxTokens(int maxTokens) async {
    if (_currentConfig != null) {
      _currentConfig!.maxTokens = maxTokens;
      await _saveConfig();
      notifyListeners();
    }
  }
}
