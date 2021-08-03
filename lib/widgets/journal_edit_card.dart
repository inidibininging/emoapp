import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:emoapp/widgets/journal_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class JournalEditCard extends StatefulWidget {
  final JournalEntry journalEntry;

  const JournalEditCard({Key? key, required this.journalEntry})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _JournalEditCard();
}

class _JournalEditCard extends State<JournalEditCard> {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Padding(
              padding: EdgeInsetsDirectional.all(10),
              child: Text(widget.journalEntry.timeStamp.toLocal().toString())),
          Padding(
              padding: EdgeInsetsDirectional.all(10),
              child: JournalTextWidget(journalEntry: widget.journalEntry)),
          FloatingActionButton(
              onPressed: () async => GetIt.instance
                  .get<JournalEntryService>()
                  .save(widget.journalEntry))
        ],
      );
}
