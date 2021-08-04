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
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(labelText: 'When'),
            initialValue: widget.journalEntry.timeStamp.toLocal().toString(),
            readOnly: true,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(labelText: 'How are you today?'),
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
                      onPressed: () => myMoodFunction(1), child: Text('😩')),
                  TextButton(
                      onPressed: () => myMoodFunction(2), child: Text('☹️')),
                  TextButton(
                      onPressed: () => myMoodFunction(3), child: Text('😐')),
                  TextButton(
                      onPressed: () => myMoodFunction(4), child: Text('😃')),
                  TextButton(
                      onPressed: () => myMoodFunction(5), child: Text('😁')),
                ],
              )
            ],
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () async => await GetIt.instance
              .get<JournalEntryService>()
              .save(widget.journalEntry)
              .then((value) => Navigator.of(context).pop())));
}
