import 'plant.dart';

class AppState {
  List<Plant> plants;
  int goldBalance;
  int streakCount;
  bool notificationsEnabled;

  AppState({
    required this.plants,
    this.goldBalance = 0,
    this.streakCount = 0,
    this.notificationsEnabled = true,
  });

  /// Collect all pending gold from plants since lastCollected
  /// Returns the total gold collected
  int collectGold() {
    final now = DateTime.now();
    int totalCollected = 0;

    for (var plant in plants) {
      // Calculate days passed since last collection
      final daysElapsed = now.difference(plant.lastCollected).inDays;

      // If at least 1 day has passed, accumulate gold
      if (daysElapsed > 0) {
        totalCollected += daysElapsed * plant.dailyGold();
        plant.lastCollected = now;
      }
    }

    goldBalance += totalCollected;
    return totalCollected;
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'plants': plants.map((p) => p.toJson()).toList(),
        'goldBalance': goldBalance,
        'streakCount': streakCount,
        'notificationsEnabled': notificationsEnabled,
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    var plantList = <Plant>[];
    if (json['plants'] != null) {
      plantList =
          List<Plant>.from(json['plants'].map((p) => Plant.fromJson(p)));
    }
    return AppState(
      plants: plantList,
      goldBalance: json['goldBalance'] ?? 0,
      streakCount: json['streakCount'] ?? 0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }
}
