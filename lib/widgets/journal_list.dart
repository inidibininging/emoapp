import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/widgets/journal_card.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class JournalList extends StatelessWidget {
  final Iterable<JournalEntry> entries;

  JournalList({required this.entries});

  @override
  Widget build(BuildContext context) => Consumer<ListView>(
      builder: (context, leCard, whoot) => ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: entries
              .map((journalEntry) => JournalCard(journalEntry: journalEntry))
              .toList()));
}
