import 'package:emoapp/model/entity_base_container_multi.dart';
import 'package:emoapp/model/entity_base_type.dart';
import 'package:hive/hive.dart';
import 'package:emoapp/model/entity_numbers.dart';

part 'discussion.g.dart';

@HiveType(typeId: discussionTypeId)
class Discussion extends EntityBaseContainerMulti {
  Discussion({
    required this.name,
    required this.imageKey,
    required this.description,
    required super.id,
    required super.children1,
  });

  @HiveField(2)
  String name;

  @HiveField(3)
  String imageKey;

  @HiveField(4)
  String description;
}
