import 'dart:convert';
import 'dart:io';

import 'package:emoapp/model/json_serializable_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

/// Stupid database
/// stores everything as files
/// in a folder "sdb" in your documents
class Sdb<T extends JsonSerializableInterface<T>> {
  Directory? _tableDir;
  bool _opened = false;

  Future<void> openBox() async {
    if (_opened) return;
    final rootDir = Directory((await getApplicationDocumentsDirectory()).path);
    final rootDbPath = "${rootDir.path}/sdb";
    final sdbDir = Directory(rootDbPath);
    //nice lets move on
    if (!sdbDir.existsSync()) {
      sdbDir.createSync();
    }
    final tablePath = "${rootDir.path}/sdb/${T.toString()}";
    final dTableDir = Directory(tablePath);
    if (!dTableDir.existsSync()) {
      dTableDir.createSync();
    }
    _tableDir = dTableDir;
    _opened = dTableDir.existsSync();
  }

  Future<bool> boxExists() async {
    final rootDir = Directory((await getApplicationDocumentsDirectory()).path);
    final rootDbPath = "${rootDir.path}/sdb";
    final sdbDir = Directory(rootDbPath);
    //nice lets move on
    if (!sdbDir.existsSync()) {
      sdbDir.createSync();
    }
    final tablePath = "${rootDir.path}/sdb/${T.runtimeType.toString()}";
    final dTableDir = Directory(tablePath);
    return !dTableDir.existsSync();
  }

  Future<T?> get(String key) async {
    if (!_opened) {
      throw Exception('Database ${T.runtimeType.toString()} not opened');
    }
    // final f = File("${_tableDir!.path}/${key}");
    // f.writeAsStringSync(jsonEncode(entity.toJson()), mode: FileMode.write);
    final fpath = _tableDir!
        .listSync()
        .where((fse) => fse.uri.pathSegments.last == key)
        .firstOrNull
        ?.path;
    if (fpath == null) {
      return null;
    }
    final f = File(fpath);
    if (!f.existsSync()) Exception('Key $key not found');
    return GetIt.instance.get<T>(
        instanceName: "${T.toString()}Json",
        param1: jsonDecode(utf8.decode(f.readAsBytesSync())),
        param2: null);
  }

  Future<Map<String, T>> getAll() async {
    if (!_opened) {
      throw Exception('Database ${T.runtimeType.toString()} not opened');
    }
    // final f = File("${_tableDir!.path}/${key}");
    // f.writeAsStringSync(jsonEncode(entity.toJson()), mode: FileMode.write);
    return Map.fromEntries(_tableDir!.listSync().map((fse) {
      final f = File("${fse.path}");
      return MapEntry(
          fse.path,
          GetIt.instance.get(
              instanceName: "${T.toString()}Json",
              param1: jsonDecode(utf8.decode(f.readAsBytesSync()))));
    }));
  }

  Future<void> put(String key, T entity) async {
    if (!_opened) {
      throw Exception('Database ${T.runtimeType.toString()} not opened');
    }
    final f = File("${_tableDir!.path}/${key}");
    f.writeAsStringSync(jsonEncode(entity.toJson()), mode: FileMode.write);
  }

  Future<void> delete(String key) async {
    if (!_opened) {
      throw Exception('Database ${T.runtimeType.toString()} not opened');
    }
    // final f = File("${_tableDir!.path}/${key}");
    // f.writeAsStringSync(jsonEncode(entity.toJson()), mode: FileMode.write);
    _tableDir!
        .listSync()
        .where((fse) => fse.path == key)
        .forEach((fse) => fse.deleteSync());
  }

  Future<int> deleteAll() async {
    if (!_opened) {
      throw Exception('Database ${T.runtimeType.toString()} not opened');
    }
    // final f = File("${_tableDir!.path}/${key}");
    // f.writeAsStringSync(jsonEncode(entity.toJson()), mode: FileMode.write);
    int deleted = 0;
    _tableDir!.listSync().forEach((fse) {
      fse.deleteSync();
      deleted++;
    });
    return deleted;
  }
}
