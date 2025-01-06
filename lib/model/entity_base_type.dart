import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:hive/hive.dart';

/// Contains a id + type
/// the type is a number. the number should be the hive type number
class EntityBaseType extends EntityBase {
  EntityBaseType({
    required super.id,
    required this.type,
  });

  @HiveField(typeFieldId)
  int type;
}
