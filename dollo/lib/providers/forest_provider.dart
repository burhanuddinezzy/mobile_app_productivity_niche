import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/tree_model.dart';
import '../models/session_model.dart';

class ForestProvider with ChangeNotifier {
  List<TreeModel> _trees = [];
  List<SessionModel> _sessions = [];

  List<TreeModel> get trees => _trees;
  List<TreeModel> get aliveTrees => _trees.where((t) => !t.isDead).toList();
  List<TreeModel> get deadTrees => _trees.where((t) => t.isDead).toList();
  List<SessionModel> get sessions => _sessions;

  int get totalTrees => _trees.length;
  int get aliveTreesCount => aliveTrees.length;
  int get deadTreesCount => deadTrees.length;
  
  int get totalFocusMinutes {
    return _sessions
        .where((s) => s.completed)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get totalCoinsEarned {
    return _trees.where((t) => !t.isDead).fold(0, (sum, t) => sum + t.coinsEarned);
  }

  ForestProvider() {
    loadForest();
  }

  Future<void> loadForest() async {
    final treesBox = Hive.box<TreeModel>('trees');
    final sessionsBox = Hive.box<SessionModel>('sessions');
    
    _trees = treesBox.values.toList()
      ..sort((a, b) => b.plantedAt.compareTo(a.plantedAt));
    
    _sessions = sessionsBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    notifyListeners();
  }

  Future<void> deleteTree(String id) async {
    final treesBox = Hive.box<TreeModel>('trees');
    await treesBox.delete(id);
    await loadForest();
  }

  Future<void> clearDeadTrees() async {
    final treesBox = Hive.box<TreeModel>('trees');
    final deadTreeIds = deadTrees.map((t) => t.id).toList();
    
    for (final id in deadTreeIds) {
      await treesBox.delete(id);
    }
    
    await loadForest();
  }

  Map<TreeType, int> getTreeTypeStats() {
    final stats = <TreeType, int>{};
    for (final tree in aliveTrees) {
      stats[tree.type] = (stats[tree.type] ?? 0) + 1;
    }
    return stats;
  }

  List<SessionModel> getSessionsForDate(DateTime date) {
    return _sessions.where((s) {
      return s.startTime.year == date.year &&
          s.startTime.month == date.month &&
          s.startTime.day == date.day;
    }).toList();
  }

  int getFocusMinutesForDate(DateTime date) {
    return getSessionsForDate(date)
        .where((s) => s.completed)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }
}