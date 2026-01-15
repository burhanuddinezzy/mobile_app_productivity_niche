import 'package:hive/hive.dart';
import 'mood_model.dart';

part 'journal_entry_model.g.dart';

@HiveType(typeId: 6)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  MoodType mood;

  @HiveField(3)
  List<String> activityIds;

  @HiveField(4)
  String? note;

  @HiveField(5)
  List<String> photoUrls;

  JournalEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.activityIds,
    this.note,
    this.photoUrls = const [],
  });

  // Get just the date (no time) for grouping
  DateTime get dateOnly {
    return DateTime(timestamp.year, timestamp.month, timestamp.day);
  }

  // Format time as "3:45 PM"
  String get formattedTime {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}