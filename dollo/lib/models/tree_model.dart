import 'package:hive/hive.dart';
part 'tree_model.g.dart';

@HiveType(typeId: 0)
enum TreeType {
  @HiveField(0)
  oak,
  @HiveField(1)
  pine,
  @HiveField(2)
  cherry,
  @HiveField(3)
  maple,
  @HiveField(4)
  willow,
  @HiveField(5)
  bamboo,
  @HiveField(6)
  cactus,
  @HiveField(7)
  palm,
}

@HiveType(typeId: 1)
class TreeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TreeType type;

  @HiveField(2)
  DateTime plantedAt;

  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  bool isDead;

  @HiveField(5)
  String? note;

  TreeModel({
    required this.id,
    required this.type,
    required this.plantedAt,
    required this.durationMinutes,
    this.isDead = false,
    this.note,
  });

  int get coinsEarned => isDead ? 0 : (durationMinutes / 5).floor();
}

// Tree species data
class TreeSpecies {
  final TreeType type;
  final String name;
  final String emoji;
  final int unlockCost;
  final String description;

  const TreeSpecies({
    required this.type,
    required this.name,
    required this.emoji,
    required this.unlockCost,
    required this.description,
  });

  static const List<TreeSpecies> allSpecies = [
    TreeSpecies(
      type: TreeType.oak,
      name: 'Oak Tree',
      emoji: '🌳',
      unlockCost: 0,
      description: 'A classic, sturdy tree',
    ),
    TreeSpecies(
      type: TreeType.pine,
      name: 'Pine Tree',
      emoji: '🌲',
      unlockCost: 50,
      description: 'Evergreen and resilient',
    ),
    TreeSpecies(
      type: TreeType.cherry,
      name: 'Cherry Blossom',
      emoji: '🌸',
      unlockCost: 100,
      description: 'Beautiful pink blossoms',
    ),
    TreeSpecies(
      type: TreeType.maple,
      name: 'Maple Tree',
      emoji: '🍁',
      unlockCost: 150,
      description: 'Vibrant autumn colors',
    ),
    TreeSpecies(
      type: TreeType.willow,
      name: 'Willow Tree',
      emoji: '🌿',
      unlockCost: 200,
      description: 'Graceful and flowing',
    ),
    TreeSpecies(
      type: TreeType.bamboo,
      name: 'Bamboo',
      emoji: '🎋',
      unlockCost: 250,
      description: 'Fast-growing and strong',
    ),
    TreeSpecies(
      type: TreeType.cactus,
      name: 'Cactus',
      emoji: '🌵',
      unlockCost: 300,
      description: 'Desert survivor',
    ),
    TreeSpecies(
      type: TreeType.palm,
      name: 'Palm Tree',
      emoji: '🌴',
      unlockCost: 400,
      description: 'Tropical paradise',
    ),
  ];

  static TreeSpecies getSpecies(TreeType type) {
    return allSpecies.firstWhere((s) => s.type == type);
  }
}