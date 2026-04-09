import 'package:json_annotation/json_annotation.dart';

part 'reference.g.dart';

/// Enum to distinguish reference types
enum ReferenceType {
  idea,
  journalEntry,
}

/// Represents a reference from an idea to another idea or journal entry
@JsonSerializable()
class Reference {
  Reference({
    required this.id,
    required this.text,
    this.ideaUuid = '',
    this.journalEntryUuid = '',
    this.referenceType = ReferenceType.idea,
  });

  /// Unique identifier for this reference
  String id;

  /// Display text for this reference
  String text;

  /// UUID of the idea being referenced (if type is idea)
  String ideaUuid;

  /// UUID of the journal entry being referenced (if type is journalEntry)
  String journalEntryUuid;

  /// Type of reference (idea or journal entry)
  ReferenceType referenceType;

  factory Reference.fromJson(Map<String, dynamic> json) {
    return _$ReferenceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReferenceToJson(this);
}
