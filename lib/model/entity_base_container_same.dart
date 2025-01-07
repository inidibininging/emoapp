import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_base_type.dart';
import 'package:emoapp/model/entity_numbers.dart';

/// An entity that holds a list of other entites
/// Because of ... reasons.. I will retain the ids only
/// (references)
/// Fetching the entities should be an extra thing.
/// This is not perfomant,
/// but allows to not be specifically bound to an entity
///
/// don't need to specify the type, since this is extended,
/// so if a discussion extends from this, the type is already there
/// type is a number. the number is the hive type number
abstract class EntityBaseContainerSame extends EntityBase {
  EntityBaseContainerSame({required super.id, required this.children1});

  List<EntityBase> children1;
}
