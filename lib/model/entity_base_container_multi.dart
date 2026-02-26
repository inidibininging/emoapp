import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_base_type.dart';

/// An entity that holds a list of other entites
/// Because of ... reasons.. I will retain the ids only
/// (references)
/// Fetching the entities should be an extra thing.
/// This is not perfomant,
/// but allows to not be specifically bound to an entity
abstract class EntityBaseContainerMulti<T> extends EntityBase<T> {
  EntityBaseContainerMulti(
      {required super.id, required this.children1, required});

  List<EntityBaseType> children1;
}
