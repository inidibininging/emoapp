import 'package:emoapp/model/journal_entry.dart';
import 'package:flutter/widgets.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry journalEntry;
  JournalCard({required this.journalEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Container(
                  child: Text(journalEntry.timeStamp.toLocal().toString())),
              Container(
                width: 12,
              ),
              Container(child: Text(journalEntry.text))
            ])));
  }
}
