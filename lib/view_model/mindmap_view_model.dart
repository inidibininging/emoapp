import 'package:emoapp/model/idea.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/services/idea_service.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// ViewModel for managing the collaborative mindmap interface
class MindmapViewModel extends ChangeNotifier {
  MindmapViewModel() {
    _ideaService = GetIt.instance.get<IdeaService>();
    _journalEntryService = GetIt.instance.get<JournalEntryExtendedService>();
    _suggestions = <Idea>[];
    _journalEntrySuggestions = <JournalEntryExtended>[];
  }

  late final IdeaService _ideaService;
  late final JournalEntryExtendedService _journalEntryService;
  late List<Idea> _suggestions;
  late List<JournalEntryExtended> _journalEntrySuggestions;

  // Zoom and pan state
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  // Selected idea and editing state
  Idea? _selectedIdea;
  bool _isEditingIdea = false;

  // List of all ideas for the current user
  List<Idea> _ideas = [];

  // Search filter
  String _searchQuery = '';

  // Currently moving idea
  Idea? _movingIdea;

  // Getters
  double get zoomLevel => _zoomLevel;
  Offset get panOffset => _panOffset;
  Idea? get selectedIdea => _selectedIdea;
  bool get isEditingIdea => _isEditingIdea;
  List<Idea> get ideas => _ideas;
  List<Idea> get filteredIdeas {
    if (_searchQuery.isEmpty) return _ideas;
    return _ideas
        .where((idea) =>
            idea.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            idea.content.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Idea> get suggestions => _suggestions;
  List<JournalEntryExtended> get journalEntrySuggestions =>
      _journalEntrySuggestions;
  Idea? get movingIdea => _movingIdea;

  // Setters with notifyListeners()
  set zoomLevel(double value) {
    _zoomLevel = (value).clamp(0.1, 3.0);
    notifyListeners();
  }

  set panOffset(Offset value) {
    _panOffset = value;
    notifyListeners();
  }

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  // Load all ideas for the current user
  Future<void> loadIdeas({String? ownerUuid}) async {
    try {
      if (ownerUuid != null && ownerUuid.isNotEmpty) {
        _ideas = (await _ideaService.getByOwner(ownerUuid)).toList();
      } else {
        _ideas = (await _ideaService.getAll()).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading ideas: $e');
    }
  }

  // Zoom in and out
  void zoomIn() {
    zoomLevel = _zoomLevel + 0.1;
  }

  void zoomOut() {
    zoomLevel = _zoomLevel - 0.1;
  }

  void resetZoom() {
    zoomLevel = 1.0;
  }

  // Pan the canvas
  void pan(Offset delta) {
    panOffset = _panOffset + delta;
  }

  void resetPan() {
    panOffset = Offset.zero;
  }

  // Create a new idea
  Future<Idea?> createIdea({
    required String title,
    required String content,
    required double positionX,
    required double positionY,
    String ownerUuid = '',
    String groupUuid = '',
  }) async {
    try {
      final idea = Idea.create(
        title: title,
        content: content,
        positionX: positionX,
        positionY: positionY,
      );
      idea.ownerUuid = ownerUuid;
      idea.groupUuid = groupUuid;

      await _ideaService.save(idea);
      _ideas.add(idea);
      notifyListeners();
      return idea;
    } catch (e) {
      debugPrint('Error creating idea: $e');
      return null;
    }
  }

  // Update an idea (title, content, etc.)
  Future<void> updateIdea(Idea idea) async {
    try {
      await _ideaService.save(idea);
      final index = _ideas.indexWhere((i) => i.id == idea.id);
      if (index != -1) {
        _ideas[index] = idea;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating idea: $e');
    }
  }

  // Delete an idea
  Future<void> deleteIdea(String ideaId) async {
    try {
      await _ideaService.destroy(ideaId);
      _ideas.removeWhere((idea) => idea.id == ideaId);
      if (_selectedIdea?.id == ideaId) {
        _selectedIdea = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting idea: $e');
    }
  }

  // Select an idea
  void selectIdea(Idea idea) {
    _selectedIdea = idea;
    notifyListeners();
  }

  // Deselect the current idea
  void deselectIdea() {
    _selectedIdea = null;
    notifyListeners();
  }

  // Start editing the selected idea
  void startEditing() {
    _isEditingIdea = true;
    notifyListeners();
  }

  // Stop editing
  void stopEditing() {
    _isEditingIdea = false;
    notifyListeners();
  }

  // Start moving an idea (long press)
  void startMovingIdea(Idea idea) {
    _movingIdea = idea;
    notifyListeners();
  }

  // Update the position of the moving idea
  void updateMovingIdeaPosition(double x, double y) {
    if (_movingIdea != null) {
      _movingIdea!.updatePosition(x, y);
      notifyListeners();
    }
  }

  // Stop moving the idea and save
  Future<void> stopMovingIdea() async {
    if (_movingIdea != null) {
      await updateIdea(_movingIdea!);
      _movingIdea = null;
      notifyListeners();
    }
  }

  // Get suggestions for references (other ideas)
  Future<void> getReferenceSuggestions({String? query}) async {
    try {
      if (query == null || query.isEmpty) {
        _suggestions =
            _ideas.where((idea) => idea.id != _selectedIdea?.id).toList();
      } else {
        _suggestions = _ideas
            .where((idea) =>
                idea.id != _selectedIdea?.id &&
                (idea.title.toLowerCase().contains(query.toLowerCase()) ||
                    idea.content.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting reference suggestions: $e');
    }
  }

  // Get suggestions for journal entry references
  Future<void> getJournalEntrySuggestions({String? query}) async {
    try {
      final allEntries = await _journalEntryService.getAll();
      if (query == null || query.isEmpty) {
        _journalEntrySuggestions = allEntries.toList();
      } else {
        _journalEntrySuggestions = allEntries
            .where((entry) =>
                entry.title.toLowerCase().contains(query.toLowerCase()) ||
                entry.text.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting journal entry suggestions: $e');
    }
  }

  // Get ideas in the visible area (bounding box for performance)
  Future<List<Idea>> getVisibleIdeas({
    required double screenWidth,
    required double screenHeight,
  }) async {
    final minX = -_panOffset.dx / _zoomLevel;
    final maxX = minX + screenWidth / _zoomLevel;
    final minY = -_panOffset.dy / _zoomLevel;
    final maxY = minY + screenHeight / _zoomLevel;

    return (await _ideaService.getIdeasInArea(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    ))
        .toList();
  }

  // Transfer idea ownership
  Future<void> transferOwnership(String ideaId, String newOwnerUuid) async {
    try {
      final idea = _ideas.firstWhere((i) => i.id == ideaId);
      idea.transferOwnership(newOwnerUuid);
      await _ideaService.save(idea);
      notifyListeners();
    } catch (e) {
      debugPrint('Error transferring ownership: $e');
    }
  }

  // Change idea visibility group
  Future<void> changeGroup(String ideaId, String newGroupUuid) async {
    try {
      final idea = _ideas.firstWhere((i) => i.id == ideaId);
      idea.changeGroup(newGroupUuid);
      await _ideaService.save(idea);
      notifyListeners();
    } catch (e) {
      debugPrint('Error changing group: $e');
    }
  }
}
