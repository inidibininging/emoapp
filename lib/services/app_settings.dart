import 'package:shared_preferences/shared_preferences.dart';
import '../storage/storage_type.dart';

class AppSettings extends ChangeNotifier {
  static const String _storageTypeKey = 'storage_type';

  StorageType _storageType = StorageType.sdb;

  StorageType get storageType => _storageType;

  set storageType(StorageType value) {
    _storageType = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageTypeKey, _storageType.toString());
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final storageTypeString = prefs.getString(_storageTypeKey);
    if (storageTypeString != null) {
      _storageType = StorageType.values.firstWhere(
        (e) => e.toString() == storageTypeString,
        orElse: () => StorageType.sdb,
      );
    }
    notifyListeners();
  }
}