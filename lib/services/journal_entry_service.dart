import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:emoapp/model/journal_entry.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:llama_cpp_dart/src/chatml_format.dart';

class JournalEntryService {
  final String boxName = 'JournalEntry';
  JournalEntryService() {
    Hive.registerAdapter<JournalEntry>(JournalEntryAdapter());

    print('load command');
    final loadCommand = LlamaLoad(
      path: "/media/develop/d/models/Llama-3.2-3B-Instruct-Q4_K_M.gguf",
      modelParams: ModelParams(),
      contextParams: ContextParams(),
      samplingParams: SamplerParams(),
      format: ChatMLFormat(),
    );
    print('llama parent');
    final llamaParent = LlamaParent(loadCommand);

    print('init...');
    llamaParent.init().catchError((Object ex) {
      print(ex);
    }).then((_) {
      llamaParent.stream.listen((response) => print(response));
      llamaParent.sendPrompt("2 * 2 = ?");
    });
  }

  Future<JournalEntry> createLocally(
      String text, int emotionalLevel, List<String> hashtags) async {
    // if (text.isEmpty) throw Exception('Journal entry is empty');
    if (emotionalLevel < 0) throw Exception('No emotional level given');

    return JournalEntry(
        id: Uuid().v4(),
        text: text,
        timeStamp: DateTime.now(),
        emotionalLevel: emotionalLevel,
        hashtags: hashtags);
  }

  Future<String> create(
      String text, int emotionalLevel, List<String> hashtags) async {
    // if (text.isEmpty) throw Exception('Journal entry is empty');
    if (emotionalLevel < 0) throw Exception('No emotional level given');
    return await Hive.openBox<JournalEntry>(boxName).then((modelBox) async =>
        await Future.sync(() => Uuid().v4()).then((id) => modelBox
            .put(
                id,
                JournalEntry(
                    id: id,
                    text: text,
                    timeStamp: DateTime.now(),
                    emotionalLevel: emotionalLevel,
                    hashtags: hashtags))
            .then((value) => modelBox.get(id))
            .then((value) async =>
                await modelBox.close().then((nothing) => id))));
  }

  Future<void> save(JournalEntry journalEntry) async {
    if (journalEntry.text.isEmpty)
      throw Exception('Journal entry text is empty');
    if (journalEntry.emotionalLevel < 0)
      throw Exception('No emotional level given');
    return await Hive.openBox<JournalEntry>(boxName).then((modelBox) async {
      var model = modelBox.get(journalEntry.id);
      if (model == null)
        await modelBox.put(journalEntry.id, journalEntry);
      else
        await modelBox.put(journalEntry.id, journalEntry);
      return modelBox;
    }).then((modelBox) async => await modelBox.close());
  }

  Future<int> destroyAll() async => await Hive.boxExists(boxName)
      ? await Hive.openBox<JournalEntry>(boxName)
          .then((modelBox) async => await modelBox.clear())
      : 0;

  Future<bool> destroy(String id) async {
    if (await Hive.boxExists(boxName)) {
      Box<JournalEntry> box;
      if (Hive.isBoxOpen(boxName))
        box = await Future.sync(() => Hive.box<JournalEntry>(boxName));
      else
        box = await Hive.openBox<JournalEntry>(boxName);

      await box.delete(id);
      return box.get(id) == null;
    } else {
      throw Exception('Box does not exist');
    }
  }

  Future<Iterable<JournalEntry>> getAll() async => [
        JournalEntry(
            id: '1234',
            text: 'hello',
            timeStamp: DateTime.now(),
            emotionalLevel: 0)
      ];

  Future<Iterable<JournalEntry>> _getAll() async =>
      await getApplicationDocumentsDirectory()
          .catchError((Object ex) => [
                JournalEntry(
                    id: UniqueKey().toString(),
                    text: ex.toString(),
                    timeStamp: DateTime.now(),
                    emotionalLevel: 0)
              ])
          .then((path) async =>
              await Hive.openBox<JournalEntry>(boxName).then((modelBox) {
                debugPrint(
                    modelBox.values.map((t) => "${t.text} ${t.id}").join('\n'));
                return modelBox.values;
              }));

  Future<JournalEntry> get(String id) async =>
      await Hive.openBox<JournalEntry>(boxName).then((modelBox) {
        modelBox.keys.forEach((element) {
          print(element);
        });
        var leModel = modelBox.get(id);
        if (leModel == null) throw Exception('FUCK!');
        return leModel;
      });
}
