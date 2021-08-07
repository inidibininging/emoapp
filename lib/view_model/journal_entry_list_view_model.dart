import 'dart:async';

import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class JournalEntryListViewModel extends ChangeNotifier {
  Future<List<JournalEntry>> entries() async => _updateEntries();

  List<JournalEntry> _cachedEntries = [];

  Future<List<JournalEntry>> _updateEntries() async {
    _cachedEntries =
        (await GetIt.instance.get<JournalEntryService>().getAll()).toList();
    _cachedEntries.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return _cachedEntries;
  }

  Future<List<JournalEntry>> entriesCached() async {
    if (_cachedEntries.isEmpty) _cachedEntries = await entries();
    return _cachedEntries;
  }

  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    // _fire.cancel();
    super.dispose();
  }
}
