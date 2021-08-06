import 'package:emoapp/model/journal_entry.dart';
import 'package:emoapp/services/journal_entry_service.dart';
import 'package:emoapp/view_model/journal_entry_view_model.dart';
import 'package:emojis_null_safe/emojis.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class JournalEntryViewModel extends ChangeNotifier {
  late JournalEntry _model;
  late JournalEntry _unchangedModel;

  String get id => _model.id;

  String get text => _model.text;
  set text(String value) {
    _model.text = value;
    notifyListeners();
  }

  String get timeStamp => _model.timeStamp.toLocal().toString();
  int get emotionalLevel => _model.emotionalLevel;
  set emotionalLevel(int level) {
    _model.emotionalLevel = level;
  }

  String get emotionalLevelAsIcon {
    switch (emotionalLevel) {
      case 1:
        return Emojis.frowningFace;
      case 2:
        return Emojis.slightlyFrowningFace;
      case 3:
        return Emojis.neutralFace;
      case 4:
        return Emojis.slightlySmilingFace;
      case 5:
        return Emojis.smilingFace;
      default:
        return "?";
    }
  }

  JournalEntryViewModel(JournalEntry model) {
    _unchangedModel = model;
    _model = JournalEntry(
        id: _unchangedModel.id,
        text: _unchangedModel.text,
        timeStamp: _unchangedModel.timeStamp,
        emotionalLevel: _unchangedModel.emotionalLevel);
  }

  Future<void> save() async {
    _unchangedModel.text = _model.text;
    _unchangedModel.emotionalLevel = _model.emotionalLevel;
    _unchangedModel.hashtags = _model.hashtags;

    await GetIt.instance
        .get<JournalEntryService>()
        .save(_unchangedModel)
        .then((value) => notifyListeners());
  }
}
