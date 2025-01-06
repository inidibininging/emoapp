import 'package:hive/hive.dart';
import 'package:emoapp/model/entity_numbers.dart';
import 'package:emoapp/model/entity_base.dart';

part 'profile.g.dart';

//used as an idea for a perspective or view
//this is made in order to respresent or play out a certain perspective or view
//as a functionality, this perspective can be used in a discussion
//the goal is to be able to carve out monologue or dialogue (via ext communication)
//the other goal is to "share" a complete conversation with others
@HiveType(typeId: profileTypeId)
class Profile extends EntityBase {
  Profile({
    required super.id,
    required this.name,
    required this.imageKey,
    required this.description,
    required this.currentDiscussionId,
  });
  @HiveField(1)
  String name;
  @HiveField(2)
  String imageKey;
  @HiveField(3)
  String description;
  @HiveField(4)
  String currentDiscussionId;
}
