import 'package:hive/hive.dart';

part 'emotion_type.g.dart';

@HiveType(typeId: 1)
class EmotionType {
  EmotionType(
      {required this.emotion,
      required this.icon,
      required this.minEmotionalLevel,
      required this.maxEmotionalLevel,
      required this.emotionalLevel,});
  @HiveField(0)
  final String emotion;
  @HiveField(1)
  final String icon;
  @HiveField(2)
  final int minEmotionalLevel;
  @HiveField(3)
  final int maxEmotionalLevel;
  @HiveField(4)
  final int emotionalLevel;
}
