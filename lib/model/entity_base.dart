import 'package:emoapp/model/entity_numbers.dart';
import 'package:hive_flutter/hive_flutter.dart';

///represents the basic common inherited type for all flutter hive instances
abstract class EntityBase {
  /// instantiates the base class containing basic information
  /// inside of hive db
  EntityBase({required this.id});

  /// internal identification of a class (mainly a guid)
  @HiveField(idFieldId)
  String id;
}
