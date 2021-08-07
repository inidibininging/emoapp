import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:emoapp/model/journal_entry.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class JournalEntryService {
  final String boxName = 'JournalEntry';
  JournalEntryService() {
    Hive.registerAdapter<JournalEntry>(JournalEntryAdapter());
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

  Future<Iterable<JournalEntry>> getAll() async =>
      await getApplicationDocumentsDirectory().then((path) => path.path).then(
          (path) async => await Hive.openBox<JournalEntry>(boxName, path: path)
              .then((modelBox) => modelBox.values));

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
