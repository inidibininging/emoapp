import 'dart:async';
import 'dart:io';
import 'package:emoapp/widgets/floating_action_button_workaround.dart';
import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/view_model/journal_entry_view_model.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:emoapp/widgets/journal_edit_card.dart';
import 'package:emoapp/widgets/journal_entry_stats.dart';
// import 'package:emoapp/widgets/journal_entry_chart.dart';
import 'package:get_it/get_it.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:emoapp/widgets/journal_list.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Map<Permission, PermissionStatus> statuses = await [
  //  Permission.storage,
  //].request();

  // await Hive.initFlutter('emo');
  //Directory? appDocDir = await getApplicationDocumentsDirectory();
  //String appDocPath = appDocDir.path;

  await Hive.initFlutter();
  ServiceLocatorRegistrar().register();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMO APP',
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          secondaryHeaderColor: Colors.deepPurple,
          //accentColor: Colors.deepPurpleAccent,
          primaryColorDark: Colors.deepPurple,
          brightness: Brightness.dark),
      //backgroundColor: Colors.black),
      home: MyHomePage(title: 'EMO APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(child: JournalList(GlobalKey())),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButtonWorkaround(
              onPressed: () async {
                await GetIt.instance.get<JournalEntryService>().destroyAll();
                setState(() {});
              },
              child: Icon(Icons.delete_forever)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButtonWorkaround(
              onPressed: () async {
                setState(() {});
              },
              child: Icon(Icons.refresh)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButtonWorkaround(
            onPressed: () async {
              var journalEntry = await GetIt.instance
                  .get<JournalEntryService>()
                  .createLocally('', 5, []);
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => JournalEditCard(
                          key: Key(journalEntry.id),
                          journalEntry: journalEntry)))
                  .then((value) {
                setState(() {});
              });
            },
            tooltip: 'Add',
            child: Icon(Icons.add),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButtonWorkaround(
            onPressed: () async {
              var entries =
                  (await GetIt.instance.get<JournalEntryService>().getAll())
                      .toList();
              entries.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => JournalEntryStats(entries: entries)));
            },
            tooltip: 'Stats',
            child: Icon(Icons.query_stats),
          ),
        ),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
