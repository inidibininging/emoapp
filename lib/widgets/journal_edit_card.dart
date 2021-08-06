import 'package:emoapp/view_model/journal_entry_view_model.dart';
import 'package:emojis_null_safe/emojis.dart';
import 'package:emojis_null_safe/emoji.dart';
import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:emoapp/widgets/journal_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class JournalEditCard extends StatefulWidget {
  final JournalEntryViewModel journalEntry;

  const JournalEditCard({Key? key, required this.journalEntry})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _JournalEditCard();
}

class _JournalEditCard extends State<JournalEditCard> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  void myMoodFunction(int moodLevel) {
    widget.journalEntry.emotionalLevel = moodLevel;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.journalEntry.id),
      ),
      body: Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'When'),
                    initialValue: widget.journalEntry.timeStamp,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: 'How are you today?'),
                    initialValue: widget.journalEntry.text,
                    readOnly: false,
                    onChanged: (value) {
                      widget.journalEntry.text = value;
                    },
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                              onPressed: () =>
                                  widget.journalEntry.emotionalLevel = 1,
                              child: Text(Emojis.frowningFace)),
                          TextButton(
                              onPressed: () =>
                                  widget.journalEntry.emotionalLevel = 2,
                              child: Text(Emojis.slightlyFrowningFace)),
                          TextButton(
                              onPressed: () =>
                                  widget.journalEntry.emotionalLevel = 3,
                              child: Text(Emojis.neutralFace)),
                          TextButton(
                              onPressed: () =>
                                  widget.journalEntry.emotionalLevel = 4,
                              child: Text(Emojis.slightlySmilingFace)),
                          TextButton(
                              onPressed: () =>
                                  widget.journalEntry.emotionalLevel = 5,
                              child: Text(Emojis.smilingFace)),
                        ],
                      )
                    ],
                  )
                ],
              ))),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () async => await widget.journalEntry
              .save()
              .then((value) => Navigator.of(context).pop())));
}
