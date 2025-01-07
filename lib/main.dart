import 'package:emoapp/model/discussion/discussion.dart';
import 'package:emoapp/model/journal_colors.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:emoapp/services/sqf_entity_service.dart';
import 'package:emoapp/widgets/discussion_lobby.dart';
import 'package:emoapp/widgets/journal_calendar.dart';
import 'package:emoapp/widgets/journal_edit_card.dart';
import 'package:emoapp/widgets/journal_entry_stats.dart';
import 'package:emoapp/widgets/journal_list.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocatorRegistrar().register();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // const defaultTextStyle = TextStyle(color: primaryColor);
    final themeData = ThemeData(
      primarySwatch: getMaterialColor(primaryColor),
      secondaryHeaderColor: secondaryColor,
      primaryColorDark: primaryDarkenedColor,
      brightness: secondaryColor.computeLuminance() > 0.5
          ? Brightness.light
          : Brightness.dark,
      // backgroundColor: Colors.black,
      scaffoldBackgroundColor: gradientColor,
      // textTheme: TextTheme(),
      // IconButtonTheme: IconButtonThemeData(
      //   style: ButtonStyle(
      //     backgroundColor: MaterialStateProperty.resolveWith((states) {
      //       // If the button is pressed, return green, otherwise blue
      //       if (states.contains(MaterialState.pressed)) {
      //         return secondaryColor;
      //       }
      //       return secondaryColor;
      //     }),
      //     textStyle: MaterialStateProperty.resolveWith((states) {
      //       // If the button is pressed, return green, otherwise blue
      //       if (states.contains(MaterialState.pressed)) {
      //         return defaultTextStyle;
      //       }
      //       return defaultTextStyle;
      //     }),
      //     overlayColor: MaterialStateProperty.resolveWith((states) {
      //       // If the button is pressed, return green, otherwise blue
      //       if (states.contains(MaterialState.pressed)) {
      //         return secondaryVariant1Color;
      //       }
      //       return secondaryColor;
      //     }),
      //   ),
      // ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        splashColor: secondaryColor,
        hoverColor: secondaryColor,
        backgroundColor: secondaryColor,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: secondaryColor),
      fontFamily: 'Swansea',
      fontFamilyFallback: const ['Swansea'],
    );

    return MaterialApp(
      title: 'EMO APP',
      theme: themeData,
      home: const MyHomePage(title: 'EMO APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: DiscussionLobby(
            discussions:
                GetIt.instance.get<FlatFileEntityService<Discussion>>()),
        body: Center(child: JournalList(GlobalKey())),

        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              // padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  await GetIt.instance
                      .get<JournalEntryExtendedService>()
                      .destroyAll();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.delete_forever,
                  size: 48,
                ),
              ),
            ),
            Expanded(
              // padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  setState(() {});
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 48,
                ),
              ),
            ),
            Expanded(
              // padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  final journalEntry = await GetIt.instance
                      .get<JournalEntryExtendedService>()
                      .createLocally(JournalType.entry.name,
                          ('Start writing your amazing thoughts here', 3));
                  await Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => JournalEditCard(
                        key: Key(journalEntry.id),
                        journalEntry: journalEntry,
                      ),
                    ),
                  )
                      .then((value) {
                    setState(() {});
                  });
                },
                // tooltip: 'Add',
                icon: const Icon(
                  Icons.add,
                  size: 48,
                ),
              ),
            ),
            Expanded(
              // padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  final journalEntriesOld = await GetIt.instance
                      .get<JournalEntryExtendedService>()
                      .getAll();

                  final journalEntryExtendedService =
                      GetIt.instance.get<JournalEntryExtendedService>();

                  for (final journal in journalEntriesOld) {
                    final extended = JournalEntryExtended(
                      id: journal.id,
                      text: journal.text,
                      timeStamp: journal.timeStamp,
                      emotionalLevel: journal.emotionalLevel,
                      type: JournalType.entry.index,
                      discussionId: journal.discussionId,
                    );

                    await journalEntryExtendedService.save(extended);
                  }
                },
                // tooltip: 'Migrate',
                icon: const Icon(
                  Icons.arrow_circle_right,
                  size: 48,
                ),
              ),
            ),
            Expanded(
              // padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  final entries = (await GetIt.instance
                          .get<JournalEntryExtendedService>()
                          .getAll())
                      .toList();
                  entries.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => JournalEntryStats(entries: entries),
                    ),
                  );
                },
                // tooltip: 'Stats',
                icon: const Icon(
                  Icons.query_stats,
                  size: 48,
                ),
              ),
            ),
            Expanded(
              // padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  final entries = (await GetIt.instance
                          .get<JournalEntryExtendedService>()
                          .getAll())
                      .toList();
                  entries.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
                  await Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => const JournalCalendar(),
                        ),
                      )
                      .then((value) => setState(() {}));
                },
                // tooltip: 'Calendar',
                icon: const Icon(
                  Icons.calendar_month,
                  size: 48,
                ),
              ),
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
}
