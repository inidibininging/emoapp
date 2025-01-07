import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discussion_message.g.dart';

@JsonSerializable()
class DiscussionMessage extends EntityBase<DiscussionMessage> {
  DiscussionMessage({
    required super.id,
    required this.content,
    required this.profileId,
    required this.createdAt,
  });

  String content;
  String profileId;
  DateTime createdAt;

  @override
  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return _$DiscussionMessageFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  @override
  Map<String, dynamic> toJson() => _$DiscussionMessageToJson(this);

  @override
  DiscussionMessage fromJson2(Map<String, dynamic> json) {
    return _$DiscussionMessageFromJson(json);
  }
}
