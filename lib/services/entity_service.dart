import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// const String entityServiceKey = 'emoapp';

/// allows model to use basic read update delete
extension EntityCrudExtension<TEntity extends EntityBase> on EntityBase {
  /// creates or saves (updates) the entity by its id
  Future<void> save() async {
    await GetIt.instance
        .get<EntityService<TEntity, TypeAdapter<TEntity>>>()
        .save(this as TEntity);
  }

  /// destroys an entity by its id
  Future<void> delete() async {
    await GetIt.instance
        .get<EntityService<TEntity, TypeAdapter<TEntity>>>()
        .destroy((this as TEntity).id);
  }

  /// changes all values in the entity, matching the ones from hive
  Future<void> readById() async {
    await GetIt.instance
        .get<EntityService<TEntity, TypeAdapter<TEntity>>>()
        .getById((this as TEntity).id);
  }
}

/// generic specification of a basic CRUD hive thing
class EntityService<TEntity extends EntityBase,
    TEntityTypeAdapter extends TypeAdapter<TEntity>> {
  /// creates a basic entity handler stored inside of hive with basic CRUD
  EntityService(
    TEntityTypeAdapter adapter,
    this._entityValidation,
  ) {
    Hive.registerAdapter<TEntity>(
      adapter,
    );
  }
  final (bool, Exception?) Function(TEntity entity) _entityValidation;

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

    return Hive.openBox<TEntity>(
      TEntity.runtimeType.toString(),
      // path: GetIt.instance.get<String>(
      //     instanceName: ServiceLocatorRegistrar
      //         .hivePathKey,), //TEntity.runtimeType.toString(),
    ).then(
      (modelBox) async => Future.sync(() => const Uuid().v4()).then(
        (id) => modelBox
            .put(
              id,
              entity..id = id,
            )
            .then((value) => modelBox.get(id))
            .then(
              (value) async => modelBox.close().then((nothing) => id),
            ),
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

    await Hive.openBox<TEntity>(
      TEntity.runtimeType.toString(),
      // path: GetIt.instance
      //     .get<String>(
      //       instanceName: ServiceLocatorRegistrar
      //       .hivePathKey,),
    ).then((modelBox) async {
      final model = modelBox.get(entity.id);
      if (model == null) {
        await modelBox.put(entity.id, entity);
      } else {
        await modelBox.put(entity.id, entity);
      }
      return modelBox;
    }).then((modelBox) async => modelBox.close());
  }

  /// gets all entities from the database
  Future<Iterable<TEntity>> getAll() async => Hive.openBox<TEntity>(
        TEntity.runtimeType.toString(),
        // path: GetIt.instance
        //     .get<String>(instanceName: ServiceLocatorRegistrar
        //     .hivePathKey),
      ).then((modelBox) => modelBox.values);

  /// returns an entity by id
  Future<TEntity> getById(String id) async => Hive.openBox<TEntity>(
        TEntity.runtimeType.toString(),
        // path: GetIt.instance
        //     .get<String>(instanceName: ServiceLocatorRegistrar
        //     .hivePathKey),
      ).then((modelBox) {
        final model = modelBox.get(id);
        if (model == null) {
          throw Exception(
            'Model of type ${TEntity.runtimeType} with id $id not found',
          );
        }
        return model;
      });

  /// destroys an entity by id
  Future<bool> destroy(String id) async {
    if (await Hive.boxExists(TEntity.runtimeType.toString())) {
      Box<TEntity> box;
      if (Hive.isBoxOpen(TEntity.runtimeType.toString())) {
        box = await Future.sync(
          () => Hive.box<TEntity>(TEntity.runtimeType.toString()),
        );
      } else {
        box = await Hive.openBox<TEntity>(
          TEntity.runtimeType.toString(),
          // path: GetIt.instance
          //     .get<String>(instanceName: ServiceLocatorRegistrar
          //     .hivePathKey),
        );
      }

      await box.delete(id);
      return box.get(id) == null;
    } else {
      throw Exception('Box for type ${TEntity.runtimeType} does not exist');
    }
  }

  /// destroys all entities in a box
  Future<int> destroyAll() async =>
      await Hive.boxExists(TEntity.runtimeType.toString())
          ? await Hive.openBox<TEntity>(
              TEntity.runtimeType.toString(),
              // path: GetIt.instance.get<String>(
              //   instanceName: ServiceLocatorRegistrar.hivePathKey,
              // ),
            ).then((modelBox) async => modelBox.clear())
          : 0;
  Future<Iterable<TEntity>> where(bool Function(TEntity m) p) async {
    return await GetIt.instance
        .get<EntityService<TEntity, TypeAdapter<TEntity>>>()
        .getAll()
        .then((l) => l.where(p));
  }
}
