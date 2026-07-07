abstract class StorageInterface<T> {
  Future<String> create(T item);
  Future<T?> get(String id);
  Future<List<T>> getAll();
  Future<bool> update(T item);
  Future<bool> delete(String id);
  Future<bool> deleteAll();
}