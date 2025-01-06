import 'package:emoapp/model/entity_base.dart';
import 'package:hive/hive.dart';
import 'package:emoapp/model/entity_numbers.dart';

part 'discussion_message.g.dart';

@HiveType(typeId: discussionMessageTypeId)
class DiscussionMessage extends EntityBase {
  DiscussionMessage({
    required super.id,
    required this.content,
    required this.profileId,
    required this.createdAt,
  });

  @HiveField(1)
  String content;
  @HiveField(2)
  String profileId;
  @HiveField(3)
  DateTime createdAt;
}
