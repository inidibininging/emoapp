import 'dart:async';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class JournalEntryExtendedListViewModel extends ChangeNotifier {
  Future<List<JournalEntryExtended>> entries() async => _updateEntries();

  List<JournalEntryExtended> _cachedEntries = [];

  Future<List<JournalEntryExtended>> _updateEntries() async {
    _cachedEntries =
        (await GetIt.instance.get<JournalEntryExtendedService>().getAll())
            .toList();
    _cachedEntries.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return _cachedEntries;
  }

  Future<List<JournalEntryExtended>> entriesCached() async {
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
