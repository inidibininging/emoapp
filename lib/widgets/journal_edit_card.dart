import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/view_model/journal_entry_view_model.dart';
import 'package:emojis_null_safe/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:hashtagable/functions.dart';
// import 'package:hashtagable/widgets/hashtag_text_field.dart';
import 'package:provider/provider.dart';

class JournalEditCard extends StatefulWidget {
  final JournalEntry journalEntry;

  const JournalEditCard({Key? key, required this.journalEntry})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _JournalEditCard();
}

class _JournalEditCard extends State<JournalEditCard> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.journalEntry.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<
          JournalEntryViewModel>(
      create: (_) => JournalEntryViewModel(widget.journalEntry),
      child: Consumer<JournalEntryViewModel>(
          builder: (context, viewModel, nullableWidget) => Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(widget.journalEntry.id),
              ),
              body: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'When'),
                            initialValue: viewModel.timeStamp,
                            readOnly: true,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            maxLines: 30,
                            decoration: InputDecoration(
                                labelText: 'How are you today?'),
                            // initialValue: widget.journalEntry.text,
                            readOnly: false,
                            controller: _controller,

                            onChanged: (value) {
                              viewModel.text = value;
                            },

                            //onDetectionTyped: (text) {
                            //  print(text);
                            //},
                            //onDetectionFinished: () {
                            //  print('finished');
                            //},
                          ),
                          Row(children: [
                            Container(
                                width: 32,
                                child: TextButton(
                                    onPressed: () =>
                                        viewModel.emotionalLevel = 1,
                                    child: Text(Emojis.frowningFace))),
                            Container(
                                width: 32,
                                child: TextButton(
                                    onPressed: () =>
                                        viewModel.emotionalLevel = 2,
                                    child: Text(Emojis.slightlyFrowningFace))),
                            Container(
                                width: 32,
                                child: TextButton(
                                    onPressed: () =>
                                        viewModel.emotionalLevel = 3,
                                    child: Text(Emojis.neutralFace))),
                            Container(
                                width: 32,
                                child: TextButton(
                                    onPressed: () =>
                                        viewModel.emotionalLevel = 4,
                                    child: Text(Emojis.slightlySmilingFace))),
                            Container(
                                width: 32,
                                child: TextButton(
                                    onPressed: () =>
                                        viewModel.emotionalLevel = 5,
                                    child: Text(Emojis.smilingFace))),
                          ])
                        ],
                      ))),
              floatingActionButton: FloatingActionButton(
                  heroTag: UniqueKey(),
                  key: UniqueKey(),
                  child: Icon(Icons.save),
                  onPressed: () async => Future.sync(() {
                        viewModel.hashtags = [];
                            //extractHashTags(viewModel.text).toList();
                      }).then((value) async => await viewModel
                          .save()
                          .then((value) => Navigator.of(context).pop()))))));
}
