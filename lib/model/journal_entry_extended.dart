import 'package:emoapp/model/entity_numbers.dart';
import 'package:hive/hive.dart';

import 'package:emoapp/model/entity_base.dart';

part 'journal_entry_extended.g.dart';

/// A journal entry. This can be either a thought, emotion, random, anything...
/// Because the main purpouse of this app is
/// tracking emotions and using reflection as a powerful tool
/// some basic properties concerning written thoughts are included are
@HiveType(typeId: journalTypeId)
class JournalEntryExtended extends EntityBase {
  // used by retrospective or perspective

  ///Creates a local journal entry
  JournalEntryExtended({
    required super.id,
    required this.text,
    required this.timeStamp,
    required this.emotionalLevel,
    required this.type,
    required this.discussionId,
    this.hashtags = const [],
    this.calendarEntryId = '',
  });

  /// contains the information stored in a journal entry
  @HiveField(1)
  String text;

  /// date the journal entry was created
  @HiveField(2)
  DateTime timeStamp;

  /// the rate of emotional level (0 low to x)
  @HiveField(3)
  int emotionalLevel;

  /// includes tags for this piece of information
  @HiveField(4)
  List<String> hashtags;

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
  @HiveField(5)
  int type;

  /// reference id for a calendar entry
  /// reason behind this was a to add CalDav functionality to the project
  @HiveField(6)
  String calendarEntryId;

  @HiveField(7)
  String discussionId;
}
