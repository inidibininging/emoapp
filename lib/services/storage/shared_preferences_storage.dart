import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'storage_interface.dart';

class SharedPreferencesStorage<T> implements StorageInterface<T> {
  final String _prefix;

  SharedPreferencesStorage(this._prefix);

  @override
  Future<String> create(T item) async {
    final prefs = await SharedPreferences.getInstance();
    final id = '${_prefix}_">${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(id, jsonEncode(item));
    return id;
  }

  @override
  Future<T?> read(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(id);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as T;
  }

  @override
  Future<List<T>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getKeys().where((key) => key.startsWith(_prefix)).toList();
    return Future.wait(
      all.map((id) async => jsonDecode(prefs.getString(id)!) as T).toList()
    ).then((values) => values.whereType<T>().toList());
  }

  @override
  Future<bool> update(String id, T item) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(id, jsonEncode(item));
  }

  @override
  Future<bool> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(id);
  }

  @override
  Future<bool> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getKeys().where((key) => key.startsWith(_prefix)).toList();
    return Future.wait(all.map((id) => prefs.remove(id))).then((_) => true);
  }
}