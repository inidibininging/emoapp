import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class JournalEntryListViewModel extends ChangeNotifier {
  Future<Iterable<JournalEntry>> entries() async =>
      await GetIt.instance.get<JournalEntryService>().getAll();

  Iterable<JournalEntry> _cachedEntries = [];

  Future<Iterable<JournalEntry>> entriesCached() async {
    if (_cachedEntries.isEmpty) _cachedEntries = await entries();
    return _cachedEntries;
  }
}
