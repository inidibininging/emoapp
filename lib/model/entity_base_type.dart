import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:emoapp/model/json_serializable_interface.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entity_base_type.g.dart';

/// Contains a id + type
/// the type is a number. the number should be the hive type number
@JsonSerializable()
class EntityBaseType extends EntityBase<EntityBaseType> {
  EntityBaseType({
    required super.id,
    required this.type,
  });

  int type;

  @override
  factory EntityBaseType.fromJson(Map<String, dynamic> json) {
    return _$EntityBaseTypeFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  @override
  Map<String, dynamic> toJson() => _$EntityBaseTypeToJson(this);

  @override
  EntityBaseType fromJson2(Map<String, dynamic> json) {
    return _$EntityBaseTypeFromJson(json);
  }
}
