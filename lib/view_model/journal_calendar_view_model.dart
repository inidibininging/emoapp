import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class JournalCalendarViewModel extends ChangeNotifier {

  JournalCalendarViewModel(int month) {
    _currentMonth = month;
  }
  late int _currentMonth;
  int get currentMonth => _currentMonth;
  set currentMonth(int value) {
    _currentMonth = value;
    notifyListeners();
  }
  Future<Iterable<JournalEntryExtended>> entries() async =>
      await GetIt.instance.get<JournalEntryExtendedService>().getAll();
  Future<Iterable<JournalEntryExtended>> dayPerspectives(DateTime date) async =>
      (await GetIt.instance.get<JournalEntryExtendedService>().getAll()).where(
          (j) =>
              j.type == JournalType.perspective.index &&
              j.timeStamp.day == date.day &&
              j.timeStamp.month == date.month &&
              j.timeStamp.year == date.year,);

  Future<Iterable<JournalEntryExtended>> dayRetrospectives(
          DateTime date,) async =>
      (await GetIt.instance.get<JournalEntryExtendedService>().getAll()).where(
          (j) =>
              j.type == JournalType.retrospective.index &&
              j.timeStamp.day == date.day &&
              j.timeStamp.month == date.month &&
              j.timeStamp.year == date.year,);

  Future<Iterable<JournalEntryExtended>> dayJournalEntries(
          DateTime date,) async =>
      (await GetIt.instance.get<JournalEntryExtendedService>().getAll()).where(
          (j) =>
              j.type == JournalType.entry.index &&
              j.timeStamp.day == date.day &&
              j.timeStamp.month == date.month &&
              j.timeStamp.year == date.year,);
}
