import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:emoapp/view_model/journal_entry_extended_list_view_model.dart';
import 'package:emoapp/widgets/journal_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class JournalList extends StatefulWidget {
  const JournalList(Key key, {this.month = 0, this.day = 0}) : super(key: key);
  final int month;
  final int day;

  @override
  State<StatefulWidget> createState() => _JournalList();
}

class _JournalList extends State<JournalList> {
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<JournalEntryExtendedListViewModel>(
        create: (_) => JournalEntryExtendedListViewModel(),
        child: Consumer<JournalEntryExtendedListViewModel>(
          builder: (context, viewModel, child) =>
              FutureBuilder<Iterable<JournalEntryExtended>>(
            future: widget.month == 0
                ? viewModel.entries(null)
                : viewModel.entries(
                    (j) {
                      if (widget.day > 0) {
                        return j.timeStamp.day == widget.day &&
                            j.timeStamp.month == widget.month;
                      } else {
                        return j.timeStamp.month == widget.month;
                      }
                    },
                  ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) return Container();
              final leList = (snapshot.data ?? []).toList();
              return Container(
                alignment: AlignmentDirectional.topStart,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  itemCount: leList.length,
                  itemBuilder: (context, index) => Dismissible(
                    key: GlobalKey(),
                    child: JournalCard(
                      key: GlobalKey(),
                      journalEntry: leList.elementAt(index),
                    ),
                    onDismissed: (direction) async {
                      await GetIt.instance
                          .get<JournalEntryExtendedService>()
                          .destroy(leList.elementAt(index).id)
                          .then(
                            (value) => leList.removeAt(index),
                          )
                          .then((value) => viewModel.refresh());
                    },
                  ),
                ),
              );
              // return ListView.builder(itemBuilder: (context, index) =>
              //   JournalCard(journalEntry: index > (snapshot.data?.length ?? 0) ? snapshot.data?.elementAt(index) : null));
            },
          ),
        ),
      );
}
