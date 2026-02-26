import 'package:emoapp/model/entity_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

//used as an idea for a perspective or view
//this is made in order to respresent or play out a certain perspective or view
//as a functionality, this perspective can be used in a discussion
//the goal is to be able to carve out monologue or dialogue (via ext communication)
//the other goal is to "share" a complete conversation with others
@JsonSerializable()
class Profile extends EntityBase<Profile> {
  Profile({
    required super.id,
    required this.name,
    required this.imageKey,
    required this.description,
    required this.currentDiscussionId,
  });

  String name;
  String imageKey;
  String description;
  String currentDiscussionId;

  @override
  factory Profile.fromJson(Map<String, dynamic> json) {
    return _$ProfileFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  Profile fromJson2(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
