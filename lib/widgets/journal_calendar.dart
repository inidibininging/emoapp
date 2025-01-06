import 'package:auto_size_text/auto_size_text.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/services/calendar/day_creator_service.dart';
import 'package:emoapp/view_model/journal_calendar_view_model.dart';
import 'package:emoapp/widgets/journal_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:emoapp/model/journal_colors.dart';

class JournalCalendar extends StatefulWidget {
  const JournalCalendar({super.key});

  @override
  State<StatefulWidget> createState() => _JournalCalendar();
}

class _JournalCalendar extends State<JournalCalendar> {
  List<Color> calendarDayColorOnTypes(
    final DateTime currentDate,
    final Iterable<JournalEntryExtended> entries,
  ) {
    final colors = <Color>[];
    final journalEntriesCount = entries
        .where(
          (j) =>
              j.type == JournalType.entry.index &&
              j.timeStamp.day == currentDate.day &&
              j.timeStamp.month == currentDate.month &&
              j.timeStamp.year == currentDate.year,
        )
        .length;
    final perspectiveCount = entries
        .where(
          (j) =>
              j.type == JournalType.perspective.index &&
              j.timeStamp.day == currentDate.day &&
              j.timeStamp.month == currentDate.month &&
              j.timeStamp.year == currentDate.year,
        )
        .length;
    final retrospectiveCount = entries
        .where(
          (j) =>
              j.type == JournalType.retrospective.index &&
              j.timeStamp.day == currentDate.day &&
              j.timeStamp.month == currentDate.month &&
              j.timeStamp.year == currentDate.year,
        )
        .length;
    if (journalEntriesCount > 0) {
      colors.addAll([const Color.fromARGB(56, 108, 9, 174)]);
    }
    if (perspectiveCount > 0) {
      colors.addAll([const Color.fromARGB(255, 166, 149, 2)]);
    }
    if (retrospectiveCount > 0) {
      colors.addAll([
        const Color.fromARGB(255, 29, 135, 124),
      ]);
    }

    if (journalEntriesCount == 0 &&
        perspectiveCount == 0 &&
        retrospectiveCount == 0) {
      colors.add(const Color.fromARGB(255, 28, 28, 28));
    }
    colors.add(const Color.fromARGB(255, 26, 26, 26));
    return colors;
  }

  String pluralizeWordIf(
    String word,
    int count,
  ) =>
      count > 1 ? '${word}s' : word;
  String singularOrPluralIf(String singular, String plural, int count) =>
      count > 1 ? plural : singular;

  Widget calendarDayTypeIndicatorOld(
    final DateTime currentDate,
    Iterable<JournalEntryExtended> entries,
    JournalType journalType,
  ) {
    switch (journalType) {
      case JournalType.entry:
        final journalEntriesCount = entries
            .where(
              (j) =>
                  j.type == JournalType.entry.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .length;
        if (journalEntriesCount > 0) {
          return DecoratedBox(
            // width: 24,
            // height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(56, 108, 9, 174),
            ),
            // width: 24,
            // height: 24,
            child: Center(
              child: Text(
                '$journalEntriesCount ${singularOrPluralIf('entry', 'entries', journalEntriesCount)}',
              ),
            ),
          );
        }
        break;
      case JournalType.perspective:
        final perspectiveCount = entries
            .where(
              (j) =>
                  j.type == JournalType.perspective.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .length;
        if (perspectiveCount > 0) {
          return DecoratedBox(
            // width: 24,
            // height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 166, 149, 2),
            ),
            // width: 24,
            // height: 24,
            child: Center(
                child: Text(
                    '$perspectiveCount ${pluralizeWordIf('perspective', perspectiveCount)}',),),
          );
        }
        break;
      case JournalType.retrospective:
        final retrospectiveCount = entries
            .where(
              (j) =>
                  j.type == JournalType.retrospective.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .length;
        if (retrospectiveCount > 0) {
          return DecoratedBox(
            // width: 24,
            // height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 29, 135, 124),
            ),
            // width: 24,
            // height: 24,
            child: Center(
                child: Text(
                    '$retrospectiveCount ${pluralizeWordIf('retrospective', retrospectiveCount)}',),),
          );
        }
        break;
      default:
    }
    return Container();
  }

  Widget calendarDayTypeIndicator(
    final DateTime currentDate,
    Iterable<JournalEntryExtended> entries,
    JournalType journalType,
  ) {
    switch (journalType) {
      case JournalType.entry:
        final journalEntriesCount = entries
            .where(
              (j) =>
                  j.type == JournalType.entry.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .length;
        if (journalEntriesCount > 0) {
          return DecoratedBox(
            // width: 24,
            // height: 24,
            decoration: const BoxDecoration(
              color: entryColor,
            ),
            // width: 24,
            // height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$journalEntriesCount ${singularOrPluralIf('entry', 'entries', journalEntriesCount)}',
              ),
            ),
          );
        }
        break;
      case JournalType.perspective:
        final perspectiveCount = entries
            .where(
              (j) =>
                  j.type == JournalType.perspective.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .length;
        if (perspectiveCount > 0) {
          return DecoratedBox(
            // width: 24,
            // height: 24,
            decoration: const BoxDecoration(
              color: perspectiveColor,
            ),
            // width: 24,
            // height: 24,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    '$perspectiveCount ${pluralizeWordIf('perspective', perspectiveCount)}',),),
          );
        }
        break;
      case JournalType.retrospective:
        final retrospectiveCount = entries
            .where(
              (j) =>
                  j.type == JournalType.retrospective.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .length;
        if (retrospectiveCount > 0) {
          return DecoratedBox(
            // width: 24,
            // height: 24,
            decoration: const BoxDecoration(
              color: retrospectiveColor,
            ),
            // width: 24,
            // height: 24,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    '$retrospectiveCount ${pluralizeWordIf('retrospective', retrospectiveCount)}',),),
          );
        }
        break;
      default:
    }
    return Container();
  }

  List<Color> calendarDayColorOnEmoLevels(
    final DateTime currentDate,
    final Iterable<JournalEntryExtended> entries,
  ) {
    final colors = <Color>[];
    final emoLevels = entries.where(
      (j) =>
          j.timeStamp.day == currentDate.day &&
          j.timeStamp.month == currentDate.month &&
          j.timeStamp.year == currentDate.year,
    );
    if (emoLevels.isNotEmpty) {
      final averageEmotionalLevel = emoLevels
              .map((j) => j.emotionalLevel)
              .reduce((value, element) => value + element) /
          emoLevels.length;

      if (averageEmotionalLevel > 3) {
        colors.addAll([const Color.fromARGB(108, 0, 185, 92)]);
      }
      if (averageEmotionalLevel.round() == 3) {
        colors.addAll([const Color.fromARGB(255, 166, 149, 2)]);
      }
      if (averageEmotionalLevel.round() < 3) {
        colors.addAll([
          const Color.fromARGB(255, 115, 18, 18),
        ]);
      }
    } else {
      colors.add(const Color.fromARGB(255, 28, 28, 28));
    }

    colors.add(const Color.fromARGB(255, 26, 26, 26));
    return colors;
  }

  List<Color> calendarDayColorOnEmoLevelTimeline(
    final DateTime currentDate,
    final Iterable<JournalEntryExtended> entries,
  ) {
    final colors = <Color>[];
    final emoLevels = entries
        .where(
          (j) =>
              j.timeStamp.day == currentDate.day &&
              j.timeStamp.month == currentDate.month &&
              j.timeStamp.year == currentDate.year,
        )
        .toList();
    emoLevels.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    if (emoLevels.isNotEmpty) {
      for (final j in emoLevels) {
        if (j.emotionalLevel > 3) {
          colors.addAll([const Color.fromARGB(255, 0, 185, 92)]);
        }
        if (j.emotionalLevel == 3) {
          colors.addAll([const Color.fromARGB(255, 244, 219, 0)]);
        }
        if (j.emotionalLevel < 3) {
          colors.addAll([
            const Color.fromARGB(255, 251, 0, 0),
          ]);
        }
      }
    } else {
      colors.add(secondaryColor);
    }

    colors.add(secondaryColor);
    return colors;
  }

  GridView journalCalendar(int daysPerRow, JournalCalendarViewModel viewModel) {
    if (daysPerRow < 1) {
      throw 'daysPerRow < 1';
    }
    final dateForJournal = DateTime.now();
    final daysInMonth =
        DayCreatorService.getDays(dateForJournal.month, dateForJournal.year);

    return GridView(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: daysPerRow,
        mainAxisSpacing: 16,
      ),
      children: DayCreatorService.daysArray(
        daysInMonth,
        dateForJournal.month,
        dateForJournal.year,
      ).map((d) {
        final currentDate = DateFormat('dd.MM.yyyy').parse(
          "${d.toString().padLeft(2, '0')}.${dateForJournal.month.toString().padLeft(2, '0')}.${dateForJournal.year}",
        );

        return FutureBuilder<Iterable<JournalEntryExtended>?>(
          future: viewModel.entries(),
          builder: (context, snapshot) => snapshot.error != null ||
                  !snapshot.hasData
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentDate.weekday <= 5
                          ? Colors.transparent
                          : secondaryColor,
                      shadowColor: Colors.transparent,
                    ),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 30),
                          child: AutoSizeText(
                            "${d.toString().padLeft(2, '0')} ${DateFormat.E().format(currentDate)}",
                            // style: TextStyle(fontSize: 12.0),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        Expanded(
                          child: calendarDayTypeIndicator(
                            currentDate,
                            snapshot.data ?? [],
                            JournalType.entry,
                          ),
                        ),
                        Expanded(
                          child: calendarDayTypeIndicator(
                            currentDate,
                            snapshot.data ?? [],
                            JournalType.perspective,
                          ),
                        ),
                        Expanded(
                          child: calendarDayTypeIndicator(
                            currentDate,
                            snapshot.data ?? [],
                            JournalType.retrospective,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(1, 8, 1, 5),
                          child: Container(),
                        ),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: 0.2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: calendarDayColorOnEmoLevelTimeline(
                                    currentDate,
                                    snapshot.data ?? [],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => Center(
                          child: JournalList(
                            GlobalKey(),
                            month: currentDate.month,
                            day: currentDate.day,
                          ),
                        ),
                      ).then(
                        (value) => setState(
                          () {},
                        ),
                      );
                    },
                  ),
                ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<JournalCalendarViewModel>(
        create: (_) => JournalCalendarViewModel(DateTime.now().month),
        child: Consumer<JournalCalendarViewModel>(
          builder: (context, viewModel, nullableWidget) => Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: AutoSizeText(
                DateFormat.MMMM().format(DateTime.now()),
              ),
            ),
            body: journalCalendar(4, viewModel),
          ),
        ),
      );
}
