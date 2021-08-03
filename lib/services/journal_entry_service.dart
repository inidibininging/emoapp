import 'package:emoapp/model/journal_entry.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class JournalEntryService {
  final String boxName = 'JournalEntry';
  JournalEntryService();

  Future<String> create(
      String text, int emotionalLevel, List<String> hashtags) async {
    if (text.isEmpty) throw Exception('Journal entry is empty');
    if (emotionalLevel < 0) throw Exception('No emotional level given');
    return await Hive.openBox<JournalEntry>(boxName).then((modelBox) async =>
        await modelBox
            .add(JournalEntry(
                id: 'new',
                text: text,
                timeStamp: DateTime.now(),
                emotionalLevel: emotionalLevel,
                hashtags: hashtags))
            .then((id) async => await Future.sync(() => modelBox.get(id))
                .then((value) async {
                  if (value == null) throw Exception('Error, cannot get model');
                  value.id = value.toString();
                  await modelBox.putAt(id, value);
                })
                .then((value) => value ?? '')
                .then((value) async => await modelBox
                    .close()
                    .then((nothing) => value.toString()))));
  }

  Future<void> save(JournalEntry journalEntry) async {
    if (journalEntry.text.isEmpty)
      throw Exception('Journal entry text is empty');
    if (journalEntry.emotionalLevel < 0)
      throw Exception('No emotional level given');
    return await Hive.openBox<JournalEntry>(boxName).then((modelBox) => modelBox
        .putAt(int.parse(journalEntry.id), journalEntry)
        .then((value) async => await modelBox.close()));
  }

  Future<bool> destroy(String id) async => await Hive.boxExists(id)
      ? await Hive.deleteBoxFromDisk(id).then((value) => true)
      : false;

  Future<Iterable<JournalEntry>> getAll() async =>
      await Hive.openBox<JournalEntry>(boxName, path: 'emo')
          .then((modelBox) => modelBox.values);

  Future<JournalEntry> get(String id) async =>
      await Hive.openBox<JournalEntry>(boxName).then((modelBox) {
        if (modelBox.containsKey(id)) throw Exception('No key by $id assigned');
        final model = modelBox.get(id);
        if (model == null) throw Exception('Cannot access model by $id');
        return model;
      });
}
