import 'package:emoapp/model/journal_entry_extended.dart';
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

  Future<void> deleteJournalEntry(String entryId) async {
    await GetIt.instance.get<JournalEntryExtendedService>().destroy(entryId);
  }
}
