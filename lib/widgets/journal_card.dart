import 'package:emoapp/model/journal_colors.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:emoapp/view_model/journal_entry_extended_view_model.dart';
import 'package:emoapp/widgets/journal_edit_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JournalCard extends StatefulWidget {
  const JournalCard({required this.journalEntry, Key? key}) : super(key: key);
  final JournalEntryExtended journalEntry;

  @override
  State<StatefulWidget> createState() => _JournalCard();
}

class _JournalCard extends State<JournalCard> {
  final key = GlobalKey();
  final serviceLocator = ServiceLocatorRegistrar();
  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<JournalEntryExtendedViewModel>(
        create: (_) => JournalEntryExtendedViewModel(widget.journalEntry),
        child: Consumer<JournalEntryExtendedViewModel>(
          builder: (context, viewModel, nullableWidget) => Card(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: primaryColor),
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: viewModel.rawType.color.gradient,
                ),
              ),
              child: ListTile(
                tileColor: Colors.transparent,
                title: Text(
                  '${viewModel.emotionalLevelAsIcon} ${viewModel.text}',
                ),
                subtitle: Text(viewModel.timeStamp),
                onTap: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => JournalEditCard(
                          journalEntry: widget.journalEntry,
                        ),
                      ),
                    )
                    .then((value) async => viewModel.refresh()),
              ),
            ),
          ),
        ),
      );
}
