import 'package:hive/hive.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 4)
enum MoodType {
  @HiveField(0)
  awful,
  @HiveField(1)
  bad,
  @HiveField(2)
  meh,
  @HiveField(3)
  good,
  @HiveField(4)
  rad,
}

class MoodData {
  final MoodType type;
  final String emoji;
  final String label;
  final int value; // For calculations

  const MoodData({
    required this.type,
    required this.emoji,
    required this.label,
    required this.value,
  });

  static const List<MoodData> allMoods = [
    MoodData(type: MoodType.awful, emoji: '😞', label: 'Awful', value: 1),
    MoodData(type: MoodType.bad, emoji: '😕', label: 'Bad', value: 2),
    MoodData(type: MoodType.meh, emoji: '😐', label: 'Meh', value: 3),
    MoodData(type: MoodType.good, emoji: '🙂', label: 'Good', value: 4),
    MoodData(type: MoodType.rad, emoji: '😄', label: 'Rad', value: 5),
  ];

  static MoodData getMoodData(MoodType type) {
    return allMoods.firstWhere((m) => m.type == type);
  }
}