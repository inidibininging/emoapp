import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/kanban.dart';
import 'package:emoapp/model/todo.dart';
import 'package:emoapp/model/topic.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:emoapp/services/flat_file_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class TopicDetailViewModel extends ChangeNotifier {
  TopicDetailViewModel(Topic topic) {
    _topic = topic;
  }

  late Topic _topic;

  Topic get topic => _topic;

  String get id => _topic.id;
  String get title => _topic.title;
  String get description => _topic.description;
  List<String> get tags => _topic.tags;
  String get color => _topic.color;
  List<Todo> get todos => _topic.todos;
  List<Kanban> get kanbans => _topic.kanbans;

  set title(String value) {
    _topic.title = value;
    notifyListeners();
  }

  set description(String value) {
    _topic.description = value;
    notifyListeners();
  }

  set color(String value) {
    _topic.color = value;
    notifyListeners();
  }

  void addTag(String tag) {
    if (!_topic.tags.contains(tag)) {
      _topic.tags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    _topic.tags.remove(tag);
    notifyListeners();
  }

  void editTag(int index, String newTag) {
    if (index < _topic.tags.length) {
      _topic.tags[index] = newTag;
      notifyListeners();
    }
  }

  void addTodo(String title) {
    final todo = Todo.create(title);
    _topic.todos.add(todo);
    notifyListeners();
  }

  void removeTodo(String todoId) {
    _topic.todos.removeWhere((todo) => todo.id == todoId);
    notifyListeners();
  }

  void toggleTodo(String todoId) {
    final todoIndex = _topic.todos.indexWhere((todo) => todo.id == todoId);
    if (todoIndex != -1) {
      _topic.todos[todoIndex].isDone = !_topic.todos[todoIndex].isDone;
      _topic.todos[todoIndex].updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  int getTodoCount() {
    return _topic.todos.length;
  }

  int getCompletedTodoCount() {
    return _topic.todos.where((todo) => todo.isDone).length;
  }

  // -------- Kanban operations (kanban todos are fully independent from topic.todos) --------

  /// Creates a new kanban bound to this topic and appends it to the list.
  void addKanban(String name) {
    final kanban = Kanban.create(name: name, topicId: _topic.id);
    _topic.kanbans.add(kanban);
    notifyListeners();
  }

  /// Removes a kanban by id (and all its todos).
  void removeKanban(String kanbanId) {
    _topic.kanbans.removeWhere((k) => k.id == kanbanId);
    notifyListeners();
  }

  /// Renames a kanban.
  void renameKanban(String kanbanId, String newName) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    k.name = newName;
    k.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Adds a todo to the given kanban.
  void addKanbanTodo(String kanbanId, String title) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    k.todos.add(Todo.create(title));
    k.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Removes a todo from the given kanban.
  void removeKanbanTodo(String kanbanId, String todoId) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    k.todos.removeWhere((t) => t.id == todoId);
    k.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Toggles a todo's done state inside the given kanban.
  void toggleKanbanTodo(String kanbanId, String todoId) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    final idx = k.todos.indexWhere((t) => t.id == todoId);
    if (idx == -1) return;
    k.todos[idx].isDone = !k.todos[idx].isDone;
    k.todos[idx].updatedAt = DateTime.now();
    k.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Updates a todo's state (column) in the given kanban.
  void updateKanbanTodoState(String kanbanId, String todoId, String newState) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    final idx = k.todos.indexWhere((t) => t.id == todoId);
    if (idx == -1) return;
    k.todos[idx].state = newState;
    k.todos[idx].updatedAt = DateTime.now();
    k.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Moves a todo to a different kanban.
  void moveKanbanTodo(String fromKanbanId, String toKanbanId, String todoId) {
    final fromKanban = _findKanban(fromKanbanId);
    final toKanban = _findKanban(toKanbanId);
    if (fromKanban == null || toKanban == null) return;
    final idx = fromKanban.todos.indexWhere((t) => t.id == todoId);
    if (idx == -1) return;
    final todo = fromKanban.todos.removeAt(idx);
    todo.updatedAt = DateTime.now();
    toKanban.todos.add(todo);
    fromKanban.updatedAt = DateTime.now();
    toKanban.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Adds a new state (column) to a kanban.
  /// Persists the change immediately so navigating away doesn't drop it.
  void addKanbanState(String kanbanId, String stateName) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    final name = stateName.trim();
    if (name.isEmpty) return;
    if (!k.states.contains(name)) {
      k.states.add(name);
      k.updatedAt = DateTime.now();
    }
    // Always notify so the view re-evaluates even if nothing structurally
    // changed (e.g. duplicate add was rejected, but caller still wants feedback).
    notifyListeners();
    // Persist the topic so the new state survives navigation/restart.
    // Fire-and-forget; errors are logged by save() if it throws.
    save();
  }

  /// Renames a state (column) in a kanban.
  /// Persists the change immediately so navigating away doesn't drop it.
  void renameKanbanState(String kanbanId, String oldState, String newState) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    final name = newState.trim();
    if (name.isEmpty) return;
    final idx = k.states.indexOf(oldState);
    if (idx == -1) return;
    if (k.states.contains(name) && name != oldState) return;
    k.states[idx] = name;
    // Update todos that were in the old state
    for (final todo in k.todos) {
      if (todo.state == oldState) {
        todo.state = name;
        todo.updatedAt = DateTime.now();
      }
    }
    k.updatedAt = DateTime.now();
    notifyListeners();
    save();
  }

  /// Removes a state (column) from a kanban.
  /// Todos in the deleted state are moved to "no state" (empty string).
  /// Persists the change immediately so navigating away doesn't drop it.
  void removeKanbanState(String kanbanId, String stateToRemove) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    if (!k.states.contains(stateToRemove)) return;
    k.states.remove(stateToRemove);
    // Move todos in the deleted state to "no state" (empty string)
    for (final todo in k.todos) {
      if (todo.state == stateToRemove) {
        todo.state = kTodoNoState;
        todo.updatedAt = DateTime.now();
      }
    }
    k.updatedAt = DateTime.now();
    notifyListeners();
    // Persist the topic so the deletion survives navigation/restart.
    save();
  }

  /// Reorders states (columns) in a kanban.
  void reorderKanbanStates(String kanbanId, List<String> newStateOrder) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    // Validate that the new order contains all existing states
    if (newStateOrder.length != k.states.length) return;
    if (!newStateOrder.toSet().containsAll(k.states.toSet())) return;
    k.states = List.from(newStateOrder);
    k.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Moves a todo to a different state within the same kanban.
  void moveKanbanTodoToState(String kanbanId, String todoId, String newState) {
    final k = _findKanban(kanbanId);
    if (k == null) return;
    final idx = k.todos.indexWhere((t) => t.id == todoId);
    if (idx == -1) return;
    if (newState != kTodoNoState && !k.states.contains(newState)) return;
    k.todos[idx].state = newState;
    k.todos[idx].updatedAt = DateTime.now();
    k.updatedAt = DateTime.now();
    notifyListeners();
  }

  Kanban? _findKanban(String kanbanId) {
    for (final k in _topic.kanbans) {
      if (k.id == kanbanId) return k;
    }
    return null;
  }

  // -------- Persistence --------

  Future<void> save() async {
    _topic.updatedAt = DateTime.now();
    await GetIt.instance
        .get<FlatFileEntityService<Topic>>()
        .save(_topic)
        .then((value) => notifyListeners());
  }

  Future<void> delete() async {
    await GetIt.instance.get<FlatFileEntityService<Topic>>().destroy(id);
  }

  Future<List<JournalEntryExtended>> getAssociatedEntries() async {
    final service = GetIt.instance.get<JournalEntryExtendedService>();
    final allEntries = await service.getAll();
    final filtered =
        allEntries.where((entry) => entry.topicId == _topic.id).toList();
    filtered.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return filtered;
  }
}
