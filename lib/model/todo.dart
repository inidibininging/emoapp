import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

/// Empty string = the todo has no state (lives in the "No State" column).
const String kTodoNoState = '';

@JsonSerializable()
class Todo {
  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.state = kTodoNoState,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;
  String title;
  bool isDone;

  /// Which kanban state/column this todo belongs to.
  /// [kTodoNoState] (empty string) means no state assigned.
  String state;

  DateTime createdAt;
  DateTime updatedAt;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return _$TodoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TodoToJson(this);

  factory Todo.create(String title, {String state = kTodoNoState}) {
    return Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isDone: false,
      state: state,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
