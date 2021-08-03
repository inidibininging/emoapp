class JournalEntry {
  String id;
  String text;
  final DateTime timeStamp;
  final int emotionalLevel;
  final List<String> hashtags;
  JournalEntry(
      {required this.id,
      required this.text,
      required this.timeStamp,
      required this.emotionalLevel,
      this.hashtags = const []});
}
