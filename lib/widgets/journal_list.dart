import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:emoapp/view_model/journal_entry_list_view_model.dart';
import 'package:emoapp/widgets/journal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class JournalList extends StatefulWidget {
  JournalList(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => _JournalList();
}

class _JournalList extends State<JournalList> {
  final key = GlobalKey();

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
                        var leList = (snapshot.data ?? []).toList();
                        return Container(
                            alignment: AlignmentDirectional.topStart,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: EdgeInsets.all(10),
                                shrinkWrap: true,
                                itemCount: leList.length,
                                itemBuilder: (context, index) {
                                  return Dismissible(
                                    key: GlobalKey(),
                                    child: JournalCard(
                                        key: GlobalKey(),
                                        journalEntry: leList.elementAt(index)),
                                    onDismissed:
                                        (DismissDirection direction) async {
                                      await GetIt.instance
                                          .get<JournalEntryService>()
                                          .destroy(leList.elementAt(index).id)
                                          .then(
                                              (value) => leList.removeAt(index))
                                          .then((value) => viewModel.refresh());
                                    },
                                  );
                                }));
                        // return ListView.builder(itemBuilder: (context, index) =>
                        //   JournalCard(journalEntry: index > (snapshot.data?.length ?? 0) ? snapshot.data?.elementAt(index) : null));
                      })));
}
