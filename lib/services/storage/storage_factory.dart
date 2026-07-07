import 'storage_interface.dart';
import 'shared_preferences_storage.dart';
import 'package:emoapp/services/flat_file_entity_service.dart';

enum StorageType { sharedPreferences, sdb }

class StorageFactory {
  static StorageInterface<T> getStorage<T>({required StorageType type, String prefix = ''}) {
    switch (type) {
      case StorageType.sharedPreferences:
        return SharedPreferencesStorage<T>(prefix) as StorageInterface<T>;
      case StorageType.sdb:
        // This will need to be adjusted based on how we actually instantiate the existing storage
        return FlatFileEntityService<T>(null, null) as StorageInterface<T>;
      default:
        throw Exception('Unknown storage type');
    }
  }
}