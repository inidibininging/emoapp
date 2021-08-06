import 'dart:io';

import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/view_model/journal_entry_view_model.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:emoapp/widgets/journal_edit_card.dart';
import 'package:get_it/get_it.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:emoapp/widgets/journal_list.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  // await Hive.initFlutter('emo');
  Directory? appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;

  await Hive.initFlutter(appDocPath);
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
          accentColor: Colors.deepPurpleAccent,
          primaryColorDark: Colors.deepPurple,
          brightness: Brightness.dark,
          backgroundColor: Colors.black),
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(child: JournalList()
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          // child: Column(
          //   // Column is also a layout widget. It takes a list of children and
          //   // arranges them vertically. By default, it sizes itself to fit its
          //   // children horizontally, and tries to be as tall as its parent.
          //   //
          //   // Invoke "debug painting" (press "p" in the console, choose the
          //   // "Toggle Debug Paint" action from the Flutter Inspector in Android
          //   // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          //   // to see the wireframe for each widget.
          //   //
          //   // Column has various properties to control how it sizes itself and
          //   // how it positions its children. Here we use mainAxisAlignment to
          //   // center the children vertically; the main axis here is the vertical
          //   // axis because Columns are vertical (the cross axis would be
          //   // horizontal).
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: <Widget>[JournalList()],
          // ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var journalEntryId =
              await GetIt.instance.get<JournalEntryService>().create('', 5, []);
          await GetIt.instance
              .get<JournalEntryService>()
              .get(journalEntryId)
              .then((journalEntry) async => await Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => JournalEditCard(
                              key: Key(journalEntry.id),
                              journalEntry:
                                  JournalEntryViewModel(journalEntry))))
                      .then((value) {
                    setState(() {});
                  }));
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
