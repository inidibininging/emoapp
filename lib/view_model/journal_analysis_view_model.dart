import 'package:emoapp/model/journal_analysis.dart';
import 'package:emoapp/services/sdb.dart';
import 'package:flutter/material.dart';

class JournalAnalysisViewModel extends ChangeNotifier {
  final Sdb<JournalAnalysis> _sdb = Sdb<JournalAnalysis>();
  List<JournalAnalysis> _analyses = [];
  bool _isLoading = false;

  JournalAnalysisViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _sdb.openBox();
    await _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final analysesMap = await _sdb.getAll();
      _analyses = analysesMap.values.toList();
      _analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _analyses = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  List<JournalAnalysis> get analyses => _analyses;
  bool get isLoading => _isLoading;

  Future<void> addAnalysis(JournalAnalysis analysis) async {
    await _sdb.put(analysis.id, analysis);
    await _loadAnalyses();
  }

  Future<void> updateAnalysis(JournalAnalysis analysis) async {
    analysis.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await _sdb.put(analysis.id, analysis);
    await _loadAnalyses();
  }

  Future<void> deleteAnalysis(String analysisId) async {
    await _sdb.delete(analysisId);
    await _loadAnalyses();
  }

  Future<JournalAnalysis?> getAnalysisById(String analysisId) async {
    return await _sdb.get(analysisId);
  }

  Future<List<JournalAnalysis>> getAnalysesByPromptId(String promptId) async {
    final allAnalyses = await _sdb.getAll();
    return allAnalyses.values
        .where((analysis) => analysis.promptId == promptId)
        .toList();
  }

  Future<List<JournalAnalysis>> getAnalysesByEntryId(String entryId) async {
    final allAnalyses = await _sdb.getAll();
    return allAnalyses.values
        .where((analysis) => analysis.entryIds.contains(entryId))
        .toList();
  }
}
