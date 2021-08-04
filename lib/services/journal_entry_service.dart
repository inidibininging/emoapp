import 'dart:math';

import 'package:emoapp/model/journal_entry.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class JournalEntryService {
  final String boxName = 'JournalEntry';
  JournalEntryService() {
    Hive.registerAdapter<JournalEntry>(JournalEntryAdapter());
  }

  Future<String> create(
      String text, int emotionalLevel, List<String> hashtags) async {
    if (text.isEmpty) throw Exception('Journal entry is empty');
    if (emotionalLevel < 0) throw Exception('No emotional level given');
    return await Hive.openBox<JournalEntry>(boxName).then((modelBox) async =>
        await Future.sync(() => Random().nextInt(666).toString()).then((id) =>
            modelBox
                .put(
                    id,
                    JournalEntry(
                        id: id,
                        text: text,
                        timeStamp: DateTime.now(),
                        emotionalLevel: emotionalLevel,
                        hashtags: hashtags))
                .then((value) => modelBox.get(id))
                // .then((newModel) async {
                //       if (newModel == null)
                //         throw Exception('Error, cannot get model');
                //       newModel.id = newModel.id.toString();
                //       await modelBox.put(id, newModel);
                //       return id;
                //     })
                .then((value) async =>
                    await modelBox.close().then((nothing) => id))));
  }

  Future<void> save(JournalEntry journalEntry) async {
    if (journalEntry.text.isEmpty)
      throw Exception('Journal entry text is empty');
    if (journalEntry.emotionalLevel < 0)
      throw Exception('No emotional level given');
    return await Hive.openBox<JournalEntry>(boxName).then((modelBox) => modelBox
        .put(journalEntry.id, journalEntry)
        .then((value) async => await modelBox.close()));
  }

  Future<bool> destroy(int id) async => await Hive.boxExists(boxName)
      ? await Hive.openBox(boxName)
          .then((modelBox) => modelBox.deleteAt(id))
          .then((value) => true)
      : false;

  Future<Iterable<JournalEntry>> getAll() async =>
      await Hive.openBox<JournalEntry>(boxName, path: 'emo')
          .then((modelBox) => modelBox.values);

  Future<JournalEntry> get(String id) async =>
      await Hive.openBox<JournalEntry>(boxName).then((modelBox) {
        var leModel = modelBox.get(id);
        if (leModel == null) throw Exception('FUCK!');
        return leModel;
      });
}
