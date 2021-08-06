import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/view_model/journal_entry_list_view_model.dart';
import 'package:emoapp/widgets/journal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class JournalList extends StatefulWidget {
  JournalList();

  @override
  State<StatefulWidget> createState() => _JournalList();
}

class _JournalList extends State<JournalList> {
  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<JournalEntryListViewModel>(
          create: (_) => JournalEntryListViewModel(),
          child: Consumer<JournalEntryListViewModel>(
              builder: (context, viewModel, child) =>
                  FutureBuilder<Iterable<JournalEntry>>(
                      future: viewModel.entries(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();
                        if (snapshot.hasError) return Container();
                        var leList = snapshot.data ?? [];
                        return Container(
                            alignment: AlignmentDirectional.topStart,
                            child: ListView(
                                padding: EdgeInsets.all(10),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: leList
                                    .map<JournalCard>(
                                        (je) => JournalCard(journalEntry: je))
                                    .toList()));
                        // return ListView.builder(itemBuilder: (context, index) =>
                        //   JournalCard(journalEntry: index > (snapshot.data?.length ?? 0) ? snapshot.data?.elementAt(index) : null));
                      })));
}
