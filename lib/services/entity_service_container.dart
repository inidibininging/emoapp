import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/services/entity_service.dart';
import 'package:hive/hive.dart';

class EntityServiceContainer<
    TEntity,
    TEntityTypeAdapter,
    TChild extends EntityBase,
    TChildAdapter extends TypeAdapter<TChild>> extends EntityService {
  /// instantiates a container containing entities of base type of TChil.
  /// The
  EntityServiceContainer(
    super.adapter,
    super.entityValidation,
    this.references,
  );

  /// contains the entity service for managing entities referencing the owner
  final EntityService<TChild, TChildAdapter> references;
}
