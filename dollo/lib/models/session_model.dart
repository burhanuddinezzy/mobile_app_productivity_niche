import 'package:hive/hive.dart';
import 'tree_model.dart';
part 'session_model.g.dart';

@HiveType(typeId: 2)
class SessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  int plannedDuration; // in seconds

  @HiveField(4)
  int actualDuration; // in seconds

  @HiveField(5)
  bool completed;

  @HiveField(6)
  TreeType treeType;

  @HiveField(7)
  int coinsEarned;

  SessionModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration = 0,
    this.completed = false,
    required this.treeType,
    this.coinsEarned = 0,
  });

  int get durationMinutes => (actualDuration / 60).floor();
}