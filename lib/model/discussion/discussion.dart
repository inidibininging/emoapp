import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_base_container_multi.dart';
import 'package:emoapp/model/entity_base_type.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:json_annotation/json_annotation.dart';
part 'discussion.g.dart';

@JsonSerializable()
class Discussion extends EntityBaseContainerMulti<Discussion> {
  Discussion({
    required this.name,
    required this.imageKey,
    required this.description,
    required super.id,
    required super.children1,
  });

  String name;

  String imageKey;

  String description;

  @override
  factory Discussion.fromJson(Map<String, dynamic> json) {
    return _$DiscussionFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  @override
  Map<String, dynamic> toJson() => _$DiscussionToJson(this);

  @override
  Discussion fromJson2(Map<String, dynamic> json) {
    return _$DiscussionFromJson(json);
  }
}
