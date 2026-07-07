import 'package:emoapp/model/analysis_prompt.dart';
import 'package:emoapp/services/sdb.dart';
import 'package:flutter/material.dart';

class AnalysisPromptViewModel extends ChangeNotifier {
  final Sdb<AnalysisPrompt> _sdb = Sdb<AnalysisPrompt>();
  List<AnalysisPrompt> _prompts = [];
  bool _isLoading = false;

  AnalysisPromptViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _sdb.openBox();
    await _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final promptsMap = await _sdb.getAll();
      _prompts = promptsMap.values.toList();
      _prompts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _prompts = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  List<AnalysisPrompt> get prompts => _prompts;
  bool get isLoading => _isLoading;

  Future<void> addPrompt(AnalysisPrompt prompt) async {
    await _sdb.put(prompt.id, prompt);
    await _loadPrompts();
  }

  Future<void> updatePrompt(AnalysisPrompt prompt) async {
    await _sdb.put(prompt.id, prompt);
    await _loadPrompts();
  }

  Future<void> deletePrompt(String promptId) async {
    await _sdb.delete(promptId);
    await _loadPrompts();
  }

  Future<AnalysisPrompt?> getPromptById(String promptId) async {
    return await _sdb.get(promptId);
  }
}
