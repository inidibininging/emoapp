import 'package:emoapp/model/json_serializable_interface.dart';
import 'package:emoapp/services/sqf_entity_service.dart';
import 'package:get_it/get_it.dart';

///represents the basic common inherited type for all flutter hive instances
abstract class EntityBase<T> extends JsonSerializableInterface<T> {
  /// instantiates the base class containing basic information
  /// inside of hive db
  EntityBase({required this.id});

  /// internal identification of a class (mainly a guid)
  String id;

  // Map<String, dynamic> toJson();
  // factory T.fromJson(Map<String, dynamic> json) => _$TFromJson(json);
}
