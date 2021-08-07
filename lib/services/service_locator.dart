import 'dart:async';

import 'package:emoapp/services/journal_entry_service.dart';
import 'package:get_it/get_it.dart';

class ServiceLocatorRegistrar {
  void register() {
    GetIt.instance
        .registerSingleton<JournalEntryService>(JournalEntryService());
  }
}
