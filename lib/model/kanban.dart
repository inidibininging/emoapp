import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/todo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'kanban.g.dart';

/// Default state/column names used when a kanban is created without
/// an explicit list of states.
const List<String> kDefaultKanbanStates = ['To Do', 'In Progress', 'Done'];

/// Represents a kanban board that belongs to a Topic.
/// A kanban is a named collection of [Todo] items that are
/// fully separate from the topic's flat todos list. Each kanban
/// defines its own ordered list of states (columns).
@JsonSerializable()
class Kanban extends EntityBase<Kanban> {
  Kanban({
    required super.id,
    required this.name,
    required this.topicId,
    required this.createdAt,
    required this.updatedAt,
    List<Todo>? todos,
    List<String>? states,
  })  : todos = todos ?? [],
        states = states ?? List<String>.from(kDefaultKanbanStates);

  /// Display name of the kanban.
  String name;

  /// The id of the [Topic] this kanban belongs to.
  String topicId;

  /// Todos living inside this kanban. Independent from `Topic.todos`.
  /// Each todo's [Todo.state] matches one entry in [states] (or is
  /// the empty string meaning "no state").
  List<Todo> todos;

  /// Ordered list of state names (columns). At least one should exist
  /// for the UI to make sense, but the model accepts an empty list.
  List<String> states;

  DateTime createdAt;
  DateTime updatedAt;

  @override
  factory Kanban.fromJson(Map<String, dynamic> json) {
    if (json['todos'] != null && json['todos'] is List) {
      json['todos'] = (json['todos'] as List)
          .map((e) => e is Todo ? e : Todo.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Migration: old saved kanbans won't have a `states` field.
    // Default to the standard 3-state workflow.
    if (json['states'] == null) {
      json['states'] = List<String>.from(kDefaultKanbanStates);
    }
    return _$KanbanFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$KanbanToJson(this);

  @override
  Kanban fromJson2(Map<String, dynamic> json) {
    return _$KanbanFromJson(json);
  }

  /// Convenience factory: empty kanban bound to a topic.
  /// If [states] is omitted, the default 3-state workflow is used.
  factory Kanban.create({
    required String name,
    required String topicId,
    List<String>? states,
  }) {
    final now = DateTime.now();
    return Kanban(
      id: EntityBase.generateId(),
      name: name,
      topicId: topicId,
      createdAt: now,
      updatedAt: now,
      states: states,
    );
  }
}
