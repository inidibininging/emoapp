import 'dart:async';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class JournalEntryExtendedListViewModel extends ChangeNotifier {
  Future<List<JournalEntryExtended>> entries(
    bool Function(JournalEntryExtended)? predicate,
  ) async =>
      _updateEntries(predicate);

  List<JournalEntryExtended> _cachedEntries = [];

  Future<List<JournalEntryExtended>> _updateEntries(
    bool Function(JournalEntryExtended)? predicate,
  ) async {
    if (predicate == null) {
      _cachedEntries =
          (await GetIt.instance.get<JournalEntryExtendedService>().getAll())
              .toList();
    } else {
      _cachedEntries =
          (await GetIt.instance.get<JournalEntryExtendedService>().getAll())
              .where((element) => predicate(element))
              .toList();
    }
    _cachedEntries.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    return _cachedEntries;
  }

  Future<List<JournalEntryExtended>> entriesCached(
    bool Function(JournalEntryExtended)? predicate,
  ) async {
    if (_cachedEntries.isEmpty) _cachedEntries = await entries(predicate);
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
