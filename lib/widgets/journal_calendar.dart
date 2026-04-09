import 'package:auto_size_text/auto_size_text.dart';
import 'package:emoapp/model/default_emotions.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/model/topic.dart';
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

  /// Get title or emotion emojis for display
  /// If entry has no title but has emotions, display emotion emojis
  /// Otherwise display title or "(no title)"
  String _getTitleOrEmotions(JournalEntryExtended entry) {
    if (entry.title.isNotEmpty) {
      return entry.title;
    }
    if (entry.emotionIds.isNotEmpty) {
      final emotionEmojis = entry.emotionIds
          .map((id) => DefaultEmotions.findEmotionById(id)?.emoji ?? '')
          .where((emoji) => emoji.isNotEmpty)
          .toList();
      if (emotionEmojis.isNotEmpty) {
        return emotionEmojis.join(' ');
      }
    }
    return '(no title)';
  }

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
                '$perspectiveCount ${pluralizeWordIf('perspective', perspectiveCount)}',
              ),
            ),
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
                '$retrospectiveCount ${pluralizeWordIf('retrospective', retrospectiveCount)}',
              ),
            ),
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
    const txtStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    switch (journalType) {
      case JournalType.entry:
        final filteredEntries = entries
            .where(
              (j) =>
                  j.type == JournalType.entry.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .toList();
        if (filteredEntries.isNotEmpty) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: entryColor,
            ),
            child: Wrap(
              // clipBehavior: Clip.hardEdge,
              children: filteredEntries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Chip(
                          backgroundColor: JournalColors.entry.value,
                          label: Text(
                            _getTitleOrEmotions(entry),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: txtStyle,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ))
                  .toList(),
            ),
          );
        }
        break;
      case JournalType.perspective:
        final filteredEntries = entries
            .where(
              (j) =>
                  j.type == JournalType.perspective.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .toList();
        if (filteredEntries.isNotEmpty) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: perspectiveColor,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filteredEntries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Chip(
                            backgroundColor: JournalColors.perspective.value,
                            label: Text(
                              _getTitleOrEmotions(entry),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: txtStyle,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        }
        break;
      case JournalType.retrospective:
        final filteredEntries = entries
            .where(
              (j) =>
                  j.type == JournalType.retrospective.index &&
                  j.timeStamp.day == currentDate.day &&
                  j.timeStamp.month == currentDate.month &&
                  j.timeStamp.year == currentDate.year,
            )
            .toList();
        if (filteredEntries.isNotEmpty) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: retrospectiveColor,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filteredEntries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Chip(
                            backgroundColor: JournalColors.retrospective.value,
                            label: Text(
                              _getTitleOrEmotions(entry),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: txtStyle,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ))
                    .toList(),
              ),
            ),
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
    final dateForJournal = DateTime(DateTime.now().year, viewModel.currentMonth, 1);
    final daysInMonth =
        DayCreatorService.getDays(dateForJournal.month, dateForJournal.year);

    return GridView(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: daysPerRow,
        mainAxisSpacing: 16,
      ),
      children: DayCreatorService.daysArray(
        daysInMonth,
        viewModel.currentMonth,
        dateForJournal.year,
      ).map((d) {
        final currentDate = DateFormat('dd.MM.yyyy').parse(
          "${d.toString().padLeft(2, '0')}.${viewModel.currentMonth.toString().padLeft(2, '0')}.${dateForJournal.year}",
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
              title: Row(children: [
                AutoSizeText(
                  "${DateFormat.y().format(DateTime(
                        DateTime.now().year,
                        viewModel.currentMonth,
                        1,
                      )) + " " + DateFormat.MMMM().format(
                        DateTime(
                          DateTime.now().year,
                          viewModel.currentMonth,
                          1,
                        ),
                      )}",
                ),
                Padding(padding: const EdgeInsets.fromLTRB(8, 0, 0, 0)),
                TextButton(
                    onPressed: () {
                      viewModel.previousMonth();
                    },
                    child: Text('<')),
                TextButton(
                    onPressed: () {
                      viewModel.nextMonth();
                    },
                    child: Text('>')),
              ]),
            ),
            body: Column(
              children: [
                // Topic filter section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter by Topic:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (viewModel.selectedTopicIds.isNotEmpty)
                            TextButton(
                              onPressed: () => viewModel.clearTopicFilter(),
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      FutureBuilder<List<Topic>>(
                        future: viewModel.getAvailableTopics(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 8,
                              child: CircularProgressIndicator(),
                            );
                          }

                          final topics = snapshot.data ?? [];
                          if (topics.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('No topics available'),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: topics
                                  .map(
                                    (topic) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: FilterChip(
                                        label: Text(topic.title),
                                        selected: viewModel.selectedTopicIds
                                            .contains(topic.id),
                                        onSelected: (selected) {
                                          viewModel.toggleTopic(topic.id);
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Calendar grid
                Expanded(
                  child: journalCalendar(4, viewModel),
                ),
              ],
            ),
          ),
        ),
      );
}
