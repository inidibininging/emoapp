import 'package:emoapp/model/entity_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'journal_entry_extended.g.dart';

/// A journal entry. This can be either a thought, emotion, random, anything...
/// Because the main purpouse of this app is
/// tracking emotions and using reflection as a powerful tool
/// some basic properties concerning written thoughts are included are
@JsonSerializable()
class JournalEntryExtended extends EntityBase<JournalEntryExtended> {
  // used by retrospective or perspective

  ///Creates a local journal entry
  JournalEntryExtended({
    required super.id,
    required this.text,
    required this.timeStamp,
    required this.emotionalLevel,
    required this.type,
    required this.discussionId,
    this.calendarEntryId = '',
  });

  /// contains the information stored in a journal entry
  String text;

  /// date the journal entry was created
  DateTime timeStamp;

  /// the rate of emotional level (0 low to x)
  int emotionalLevel;

  /// includes the type of journal entry.
  /// ```markdown
  /// it can be:
  /// - a retrospective (past)
  ///   - this means the journal entry makes a remark
  ///     about something that happened in the past
  /// - an entry (present)
  ///   - this means it represents
  ///     an entry talking about current events, thoughts etc
  /// - a perspective (future)
  ///   - this means it represents
  ///     an entry talking about some event, goal etc happening in the future
  ///     *one example: I want to learn how to play basic chords with a guitar*
  ///
  /// ```
  int type;

  /// reference id for a calendar entry
  /// reason behind this was a to add CalDav functionality to the project
  String calendarEntryId;

  String discussionId;

  @override
  factory JournalEntryExtended.fromJson(Map<String, dynamic> json) {
    return _$JournalEntryExtendedFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  @override
  Map<String, dynamic> toJson() => _$JournalEntryExtendedToJson(this);

  @override
  JournalEntryExtended fromJson2(Map<String, dynamic> json) {
    return _$JournalEntryExtendedFromJson(json);
  }
}
