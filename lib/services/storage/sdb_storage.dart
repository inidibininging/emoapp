import 'package:emoapp/services/sdb.dart';
import 'package:emoapp/model/json_serializable_interface.dart';
import 'storage_interface.dart';

class SdbStorage<T extends JsonSerializableInterface<T>> implements StorageInterface<T> {
  final Sdb<T> _sdb;

  SdbStorage() : _sdb = Sdb<T>();

  @override
  Future<String> create(T item) async {
    await _sdb.create(item);
    return item.id;
  }

  @override
  Future<T?> read(String id) async {
    return await _sdb.read(id);
  }

  @override
  Future<List<T>> readAll() async {
    return await _sdb.readAll();
  }

  @override
  Future<bool> update(String id, T item) async {
    return await _sdb.update(id, item);
  }

  @override
  Future<bool> delete(String id) async {
    return await _sdb.delete(id);
  }

  @override
  Future<bool> deleteAll() async {
    return await _sdb.deleteAll();
  }
}