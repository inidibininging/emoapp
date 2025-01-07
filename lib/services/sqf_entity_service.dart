import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/json_serializable_interface.dart';
import 'package:emoapp/services/sdb.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

const String entityServiceKey = 'emoapp';

// / allows model to use basic read update delete
extension FlatFileEntityCrudExtension<TEntity extends EntityBase<TEntity>>
    on EntityBase<TEntity> {
  // / creates or saves (updates) the entity by its id
  Future<void> save() async {
    await GetIt.instance
        .get<FlatFileEntityService<TEntity>>()
        .save(this as TEntity);
  }

  // / destroys an entity by its id
  Future<void> delete() async {
    await GetIt.instance
        .get<FlatFileEntityService<TEntity>>()
        .destroy((this as TEntity).id);
  }

  // / changes all values in the entity, matching the ones from hive
  Future<void> readById() async {
    await GetIt.instance
        .get<FlatFileEntityService<TEntity>>()
        .getById((this as TEntity).id);
  }

  Future<FlatFileEntityService<TEntity>> sdb() async =>
      GetIt.instance.get<FlatFileEntityService<TEntity>>();
}

/// generic specification of a basic CRUD hive thing
class FlatFileEntityService<TEntity extends EntityBase<TEntity>> {
  /// creates a basic entity handler stored inside of hive with basic CRUD
  FlatFileEntityService(
    this._entityValidation,
    this._sdb,
  );
  final (bool, Exception?) Function(TEntity entity) _entityValidation;
  final Sdb<TEntity> _sdb;

  /// creates a local entity (not in hive db)
  /// howToInstantiate should be an enum representing all basic methods
  /// on how a basic entity can be instantiated
  /// example:
  /// ```dart
  /// enum PersonInstantiation { employee, manager, janitor }
  /// @HiveType(typeId: someRandomRumber)
  /// class Person extends TEntityBase {
  ///   String name;
  ///   String description;
  /// }
  /// ```
  /// thus follows:
  /// ```dart
  /// myPersonEntityService.createLocally(PersonInstantiaton.manager);
  /// ```
  TEntity createLocally<TProperties>(
    String howToInstantiate,
    TProperties properties,
  ) =>
      ServiceLocatorRegistrar().getSpecificEntityInstance(
        howToInstantiate,
        properties,
      );

  /// creates an entity in the database
  Future<String> create(
    TEntity entity,
    (bool isValid, Exception? error) Function(TEntity entity) entityValidation,
  ) async {
    final validation = entityValidation(entity);
    if (validation.$2 != null) {
      throw validation.$2!;
    }

    return _sdb.openBox().then(
          (modelBox) async =>
              Future.sync(() => const Uuid().v4()).then((id) => _sdb
                      .put(
                        id,
                        entity..id = id,
                      )
                      .then((value) async => id)
                  // .then(
                  //   (value) async => modelBox.close().then((nothing) => id),
                  // ),
                  ),
        );
  }

  /// Saves an entity to the database
  Future<void> save(
    TEntity entity,
  ) async {
    final validation = _entityValidation(entity);
    if (validation.$2 != null) {
      throw validation.$2!;
    }

    await _sdb.openBox().then((_) async {
      final model = await _sdb.get(entity.id).catchError((_) => null);
      await _sdb.put(entity.id, entity);
    });
  }

  /// gets all entities from the database
  Future<Iterable<TEntity>> getAll() async => _sdb
      .openBox()
      .then((_) async => await _sdb.getAll().then((m) => m.values));

  /// returns an entity by id
  Future<TEntity?> getById(String id) async =>
      _sdb.openBox().then((modelBox) async {
        final model = await _sdb.get(id);
        if (model == null) {
          throw Exception(
            'Model of type ${TEntity.runtimeType} with id $id not found',
          );
        }
        return model;
      });

  /// destroys an entity by id
  Future<bool> destroy(String id) async =>
      await _sdb.delete(id).then((_) => true).catchError((_) => false);
  // if (await Hive.boxExists(TEntity.runtimeType.toString())) {
  //   Box<TEntity> box;
  //   if (Hive.isBoxOpen(TEntity.runtimeType.toString())) {
  //     box = await Future.sync(
  //       () => Hive.box<TEntity>(TEntity.runtimeType.toString()),
  //     );
  //   } else {
  //     box = await Hive.openBox<TEntity>(
  //       TEntity.runtimeType.toString(),
  //       // path: GetIt.instance
  //       //     .get<String>(instanceName: ServiceLocatorRegistrar
  //       //     .hivePathKey),
  //     );
  //   }

  //   await box.delete(id);
  //   return box.get(id) == null;
  // } else {
  //   throw Exception('Box for type ${TEntity.runtimeType} does not exist');
  // }

  /// destroys all entities in a box
  Future<int> destroyAll() async => await _sdb.deleteAll();

  Future<Iterable<TEntity>> where(bool Function(TEntity m) p) async {
    return await GetIt.instance
        .get<FlatFileEntityService<TEntity>>()
        .getAll()
        .then((l) => l.where(p));
  }
}
