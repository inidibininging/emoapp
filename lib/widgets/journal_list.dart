import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/widgets/journal_card.dart';
import 'package:flutter/widgets.dart';

class JournalList extends StatelessWidget {
  final Iterable<JournalEntry> entries;

  JournalList({required this.entries});

  @override
  Widget build(BuildContext context) => ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: entries
          .map((journalEntry) => JournalCard(journalEntry: journalEntry))
          .toList());
}
