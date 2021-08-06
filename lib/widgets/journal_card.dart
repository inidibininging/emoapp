import 'package:emoapp/view_model/journal_entry_view_model.dart';
import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/widgets/journal_edit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry journalEntry;
  JournalCard({required this.journalEntry});

  @override
  Widget build(BuildContext context) => Consumer<Card>(
      builder: (context, widget, nullableWidget) => Card(
            color: Colors.amberAccent,
            child: ListTile(
              title: Text(journalEntry.text),
              subtitle: Text(journalEntry.timeStamp.toLocal().toString()),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => JournalEditCard(
                      journalEntry: JournalEntryViewModel(journalEntry)))),
            ),
          ));
}
