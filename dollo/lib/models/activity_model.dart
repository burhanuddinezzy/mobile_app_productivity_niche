import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 5)
class ActivityModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon; // Emoji

  @HiveField(3)
  int colorValue; // Color as int

  @HiveField(4)
  bool isCustom;

  ActivityModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.isCustom = false,
  });
}

// Default activities that come pre-loaded
class DefaultActivities {
  static final List<ActivityModel> defaults = [
    // Work/Productivity
    ActivityModel(id: 'work', name: 'Work', icon: '💼', colorValue: 0xFF2196F3),
    ActivityModel(id: 'study', name: 'Study', icon: '📚', colorValue: 0xFF9C27B0),
    ActivityModel(id: 'coding', name: 'Coding', icon: '💻', colorValue: 0xFF00BCD4),
    ActivityModel(id: 'writing', name: 'Writing', icon: '📝', colorValue: 0xFF607D8B),
    
    // Social
    ActivityModel(id: 'family', name: 'Family', icon: '👨‍👩‍👧‍👦', colorValue: 0xFFE91E63),
    ActivityModel(id: 'friends', name: 'Friends', icon: '👥', colorValue: 0xFFF44336),
    ActivityModel(id: 'date', name: 'Date', icon: '❤️', colorValue: 0xFFE91E63),
    ActivityModel(id: 'call', name: 'Phone Call', icon: '📞', colorValue: 0xFF3F51B5),
    
    // Health
    ActivityModel(id: 'exercise', name: 'Exercise', icon: '🏃', colorValue: 0xFF4CAF50),
    ActivityModel(id: 'meditation', name: 'Meditation', icon: '🧘', colorValue: 0xFF9C27B0),
    ActivityModel(id: 'sleep', name: 'Good Sleep', icon: '😴', colorValue: 0xFF3F51B5),
    ActivityModel(id: 'healthy_eating', name: 'Healthy Eating', icon: '🍎', colorValue: 0xFF8BC34A),
    
    // Hobbies
    ActivityModel(id: 'reading', name: 'Reading', icon: '📖', colorValue: 0xFF795548),
    ActivityModel(id: 'gaming', name: 'Gaming', icon: '🎮', colorValue: 0xFF9C27B0),
    ActivityModel(id: 'music', name: 'Music', icon: '🎵', colorValue: 0xFFFF9800),
    ActivityModel(id: 'creative', name: 'Creative', icon: '🎨', colorValue: 0xFFFF5722),
    
    // Life
    ActivityModel(id: 'cleaning', name: 'Cleaning', icon: '🏠', colorValue: 0xFF607D8B),
    ActivityModel(id: 'shopping', name: 'Shopping', icon: '🛒', colorValue: 0xFF00BCD4),
    ActivityModel(id: 'travel', name: 'Travel', icon: '🚗', colorValue: 0xFFFF9800),
    ActivityModel(id: 'movies', name: 'Movies', icon: '🎬', colorValue: 0xFF9C27B0),
    
    // Self-care
    ActivityModel(id: 'relax', name: 'Relax', icon: '🌸', colorValue: 0xFFE91E63),
    ActivityModel(id: 'nature', name: 'Nature', icon: '🌳', colorValue: 0xFF4CAF50),
    ActivityModel(id: 'pet', name: 'Pet Time', icon: '🐕', colorValue: 0xFFFF9800),
    ActivityModel(id: 'hobby', name: 'Hobby', icon: '⚡', colorValue: 0xFFFFC107),
  ];
}