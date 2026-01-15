class Plant {
  final String name;
  final String sprite;
  final int sessionsToGrow;
  final int goldPerStage;

  int completedSessions;
  int currentStage;
  int x; // column position on the farm grid
  int y; // row position on the farm grid
  DateTime lastCollected;

  Plant({
    required this.name,
    required this.sprite,
    required this.sessionsToGrow,
    required this.goldPerStage,
    this.completedSessions = 0,
    this.currentStage = 0,
    this.x = 0, // default starting position
    this.y = 0, // default starting position
    DateTime? lastCollected,
  }) : lastCollected = lastCollected ?? DateTime.now();

  void onSessionComplete() {
    completedSessions++;
    final sessionsPerStage = sessionsToGrow / 4;
    currentStage = (completedSessions / sessionsPerStage).floor();
    if (currentStage > 4) currentStage = 4;
  }

  int dailyGold() {
    return currentStage * goldPerStage;
  }

  // JSON serialization including position
  Map<String, dynamic> toJson() => {
        'name': name,
        'sprite': sprite,
        'sessionsToGrow': sessionsToGrow,
        'goldPerStage': goldPerStage,
        'completedSessions': completedSessions,
        'currentStage': currentStage,
        'x': x,
        'y': y,
        'lastCollected': lastCollected.toIso8601String(),
      };

  // JSON deserialization including position
  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
        name: json['name'],
        sprite: json['sprite'],
        sessionsToGrow: json['sessionsToGrow'],
        goldPerStage: json['goldPerStage'],
        completedSessions: json['completedSessions'] ?? 0,
        currentStage: json['currentStage'] ?? 0,
        x: json['x'] ?? 0,
        y: json['y'] ?? 0,
        lastCollected: json['lastCollected'] != null
            ? DateTime.parse(json['lastCollected'])
            : null,
      );
}
