import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/kanban.dart';
import 'package:emoapp/model/todo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic extends EntityBase<Topic> {
  Topic({
    required super.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
    this.color = '0xFF1976D2', // Default blue color
    List<Todo>? todos,
    List<Kanban>? kanbans,
  })  : tags = tags ?? [],
        todos = todos ?? [],
        kanbans = kanbans ?? [];

  String title;
  String description;
  List<String> tags;
  String color; // Hex color code stored as string
  List<Todo> todos;

  /// Kanbans attached to this topic. Each kanban has its own independent todos
  /// and lives as a separate entity (see [Kanban]).
  List<Kanban> kanbans;

  DateTime createdAt;
  DateTime updatedAt;

  @override
  factory Topic.fromJson(Map<String, dynamic> json) {
    if (json['todos'] != null && json['todos'] is List<Todo>) {
      json['todos'] = (json['todos'] as List)
          .map((e) => e is Todo ? e : Todo.fromJson(e))
          .toList();
    }
    return _$TopicFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$TopicToJson(this);

  @override
  Topic fromJson2(Map<String, dynamic> json) {
    return _$TopicFromJson(json);
  }

  factory Topic.emptyTopic() {
    return Topic(
      id: '',
      title: '',
      description: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: '0xFF1976D2',
    );
  }
}
