import 'package:emoapp/view_model/journal_entry_view_model.dart';
import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/widgets/journal_edit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class JournalCard extends StatefulWidget {
  final JournalEntry journalEntry;
  JournalCard({Key? key, required this.journalEntry}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _JournalCard();
}

class _JournalCard extends State<JournalCard> {
  final key = GlobalKey();
  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<JournalEntryViewModel>(
          create: (_) => JournalEntryViewModel(widget.journalEntry),
          child: Consumer<JournalEntryViewModel>(
              builder: (context, viewModel, nullableWidget) => Card(
                    color: Colors.deepPurple,
                    child: ListTile(
                      title: Text(viewModel.emotionalLevelAsIcon +
                          ' ' +
                          viewModel.text),
                      subtitle: Text(viewModel.timeStamp),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => JournalEditCard(
                                  journalEntry: widget.journalEntry)))
                          .then((value) async => await viewModel.refresh()),
                    ),
                  )));
}
