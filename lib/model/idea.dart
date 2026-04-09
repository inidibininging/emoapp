import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/reference.dart';
import 'package:json_annotation/json_annotation.dart';

part 'idea.g.dart';

/// Represents an idea in the collaborative mindmap
/// Ideas are nodes that can be linked to other ideas through references
@JsonSerializable()
class Idea extends EntityBase<Idea> {
  Idea({
    required super.id,
    required this.title,
    required this.content,
    this.references = const [],
    this.ownerUuid = '',
    this.groupUuid = '',
    required this.positionX,
    required this.positionY,
    this.referencedTopic = '',
  });

  /// Title of the idea
  String title;

  /// Detailed content of the idea
  String content;

  /// List of references to other ideas
  List<Reference> references;

  /// UUID of the user who owns this idea
  /// Empty string if no owner assigned (optional)
  String ownerUuid;

  /// UUID of the visibility group this idea belongs to
  /// Empty string if not in any group (optional)
  String groupUuid;

  /// X position of the idea node on the canvas
  double positionX;

  /// Y position of the idea node on the canvas
  double positionY;

  /// Optional topic that this idea references
  String referencedTopic;

  @override
  factory Idea.fromJson(Map<String, dynamic> json) {
    return _$IdeaFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$IdeaToJson(this);

  @override
  Idea fromJson2(Map<String, dynamic> json) {
    return _$IdeaFromJson(json);
  }

  /// Creates a new idea with default values
  factory Idea.create({
    required String title,
    required String content,
    required double positionX,
    required double positionY,
  }) {
    return Idea(
      id: EntityBase.generateId(),
      title: title,
      content: content,
      positionX: positionX,
      positionY: positionY,
      references: [],
      ownerUuid: '',
      groupUuid: '',
      referencedTopic: '',
    );
  }

  /// Checks if the current user (optional) can edit this idea
  /// For now, returns true since user management is optional
  bool canEdit(String? currentUserUuid) {
    if (ownerUuid.isEmpty) return true;
    if (currentUserUuid == null) return false;
    return ownerUuid == currentUserUuid;
  }

  /// Adds a reference to another idea
  void addReference({
    required String text,
    required String ideaUuid,
  }) {
    final reference = Reference(
      id: EntityBase.generateId(),
      text: text,
      ideaUuid: ideaUuid,
      referenceType: ReferenceType.idea,
    );
    references.add(reference);
  }

  /// Adds a reference to a journal entry
  void addJournalEntryReference({
    required String text,
    required String journalEntryUuid,
  }) {
    final reference = Reference(
      id: EntityBase.generateId(),
      text: text,
      journalEntryUuid: journalEntryUuid,
      referenceType: ReferenceType.journalEntry,
    );
    references.add(reference);
  }

  /// Removes a reference by its id
  void removeReference(String referenceId) {
    references.removeWhere((ref) => ref.id == referenceId);
  }

  /// Updates the position of the idea on the canvas
  void updatePosition(double x, double y) {
    positionX = x;
    positionY = y;
  }

  /// Transfers ownership to another user
  void transferOwnership(String newOwnerUuid) {
    ownerUuid = newOwnerUuid;
  }

  /// Changes the visibility group
  void changeGroup(String newGroupUuid) {
    groupUuid = newGroupUuid;
  }
}
