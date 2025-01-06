import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:emoapp/model/profile.dart';
import 'package:emoapp/services/entity_service.dart';

class JournalEntryExtendedService {
  JournalEntryExtendedService() {
    Hive.registerAdapter<JournalEntryExtended>(JournalEntryExtendedAdapter());
  }
  final String boxName = 'JournalEntryExtended';

  Future<JournalEntryExtended> createLocally(
    String text,
    int emotionalLevel,
    List<String> hashtags,
    int type,
  ) async {
    // if (text.isEmpty) throw Exception('Journal entry is empty');
    if (emotionalLevel < 0) throw Exception('No emotional level given');
    
    final currentProfileSvc = GetIt.instance
        .get<EntityService<Profile, ProfileAdapter>>();

    final profile = await currentProfileSvc
        .where((m) => m.name == 'debug')
        .then((p) => p.firstOrNull);
    
    return JournalEntryExtended(
      id: const Uuid().v4(),
      text: text,
      timeStamp: DateTime.now(),
      emotionalLevel: emotionalLevel,
      hashtags: hashtags,
      type: type,
      discussionId: profile?.currentDiscussionId ?? '',
    );
  }

  String getHivePath() => GetIt.instance
      .get<String>(instanceName: ServiceLocatorRegistrar.hivePathKey);

  Future<String> create(
    String text,
    int emotionalLevel,
    List<String> hashtags,
    int type,
    String discussionId,
  ) async {
    // if (text.isEmpty) throw Exception('Journal entry is empty');
    if (emotionalLevel < 0) throw Exception('No emotional level given');
    return await Hive.openBox<JournalEntryExtended>(
      boxName,
      // path: getHivePath(),
    ).then(
      (modelBox) async => await Future.sync(() => const Uuid().v4()).then(
        (id) => modelBox
            .put(
              id,
              JournalEntryExtended(
                id: id,
                text: text,
                timeStamp: DateTime.now(),
                emotionalLevel: emotionalLevel,
                type: type,
                hashtags: hashtags,
                discussionId: discussionId,
              ),
            )
            .then((value) => modelBox.get(id))
            .then(
              (value) async => await modelBox.close().then((nothing) => id),
            ),
      ),
    );
  }

  Future<void> save(JournalEntryExtended journalEntryExtended) async {
    if (journalEntryExtended.text.isEmpty) {
      throw Exception('Journal entry text is empty');
    }
    if (journalEntryExtended.emotionalLevel < 0) {
      throw Exception('No emotional level given');
    }
    return await Hive.openBox<JournalEntryExtended>(
      boxName,
      // path: getHivePath(),
    ).then((modelBox) async {
      final model = modelBox.get(journalEntryExtended.id);
      if (model == null) {
        await modelBox.put(journalEntryExtended.id, journalEntryExtended);
      } else {
        await modelBox.put(journalEntryExtended.id, journalEntryExtended);
      }
      return modelBox;
    }).then((modelBox) async => await modelBox.close());
  }

  Future<int> destroyAll() async => await Hive.boxExists(boxName)
      ? await Hive.openBox<JournalEntryExtended>(
          boxName,
          // path: getHivePath()
        ).then((modelBox) async => await modelBox.clear())
      : 0;

  Future<bool> destroy(String id) async {
    if (await Hive.boxExists(boxName)) {
      Box<JournalEntryExtended> box;
      if (Hive.isBoxOpen(boxName)) {
        box = await Future.sync(() => Hive.box<JournalEntryExtended>(boxName));
      } else {
        box = await Hive.openBox<JournalEntryExtended>(
          boxName,
          // path: getHivePath(),
        );
      }

      await box.delete(id);
      return box.get(id) == null;
    } else {
      throw Exception('Box does not exist');
    }
  }

  Future<Iterable<JournalEntryExtended>> getAll() async =>
      await Hive.openBox<JournalEntryExtended>(
        boxName,
        // path: getHivePath()
      ).then((modelBox) => modelBox.values);

  Future<JournalEntryExtended> get(String id) async =>
      await Hive.openBox<JournalEntryExtended>(
        boxName,
        // path: getHivePath()
      ).then((modelBox) {
        final leModel = modelBox.get(id);
        if (leModel == null) throw Exception('Oh no!');
        return leModel;
      });
}
