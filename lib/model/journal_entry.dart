// import 'package:hive/hive.dart';

// import 'package:emoapp/model/entity_base.dart';
// import 'package:emoapp/model/entity_numbers.dart';
// part 'journal_entry.g.dart';

// @HiveType(typeId: journalTypeId)
// class JournalEntry extends EntityBase {
//   /// creates a journal entry
//   JournalEntry({
//     required String id,
//     required this.text,
//     required this.timeStamp,
//     required this.emotionalLevel,
//     this.hashtags = const [],
//   }) : super(id: id);

//   @HiveField(1)
//   String text;
//   @HiveField(2)
//   final DateTime timeStamp;
//   @HiveField(3)
//   int emotionalLevel;
//   @HiveField(4)
//   List<String> hashtags;
// }
