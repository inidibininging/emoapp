import 'package:emoapp/model/journal_colors.dart';

/// constant data concerning journal types
enum JournalType {
  /// journal entry constant data
  /// see JournalEntry - types
  entry(
    value: 0,
    color: JournalColors.entry,
    stringRepresentation: 'Journal Entry',
  ),

  /// perspective constant data
  /// see JournalEntry - types
  perspective(
    value: 1,
    color: JournalColors.perspective,
    stringRepresentation: 'Perspective',
  ),

  /// retrospective constant data
  /// see JournalEntry - types
  retrospective(
    value: 2,
    color: JournalColors.retrospective,
    stringRepresentation: 'Retrospective',
  );

  const JournalType({
    required this.value,
    required this.color,
    required this.stringRepresentation,
  });

  final int value;
  final JournalColors color;
  final String stringRepresentation;
}
