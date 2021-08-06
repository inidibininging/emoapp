import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry {
  @HiveField(0)
  String id;
  @HiveField(1)
  String text;
  @HiveField(2)
  final DateTime timeStamp;
  @HiveField(3)
  int emotionalLevel;
  @HiveField(4)
  List<String> hashtags;
  JournalEntry(
      {required this.id,
      required this.text,
      required this.timeStamp,
      required this.emotionalLevel,
      this.hashtags = const []});
}
