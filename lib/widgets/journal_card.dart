import 'package:emoapp/model/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry journalEntry;
  JournalCard({required this.journalEntry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amberAccent,
      child: ListTile(
        title: Text(journalEntry.text),
        subtitle: Text(journalEntry.timeStamp.toLocal().toString()),
      ),
    );
  }
}
