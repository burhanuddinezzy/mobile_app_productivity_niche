import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tree_model.dart';

class UserProvider with ChangeNotifier {
  int _coins = 0;
  Set<TreeType> _unlockedTrees = {TreeType.oak}; // Oak is free
  TreeType _selectedTree = TreeType.oak;

  int get coins => _coins;
  Set<TreeType> get unlockedTrees => _unlockedTrees;
  TreeType get selectedTree => _selectedTree;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    
    final unlockedList = prefs.getStringList('unlockedTrees') ?? ['oak'];
    _unlockedTrees = unlockedList
        .map((name) => TreeType.values.firstWhere(
              (t) => t.toString().split('.').last == name,
              orElse: () => TreeType.oak,
            ))
        .toSet();
    
    final selectedName = prefs.getString('selectedTree') ?? 'oak';
    _selectedTree = TreeType.values.firstWhere(
      (t) => t.toString().split('.').last == selectedName,
      orElse: () => TreeType.oak,
    );
    
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setStringList(
      'unlockedTrees',
      _unlockedTrees.map((t) => t.toString().split('.').last).toList(),
    );
    await prefs.setString(
      'selectedTree',
      _selectedTree.toString().split('.').last,
    );
  }

  void addCoins(int amount) {
    _coins += amount;
    _saveUserData();
    notifyListeners();
  }

  bool canUnlock(TreeType type) {
    if (_unlockedTrees.contains(type)) return false;
    final species = TreeSpecies.getSpecies(type);
    return _coins >= species.unlockCost;
  }

  Future<bool> unlockTree(TreeType type) async {
    if (!canUnlock(type)) return false;
    
    final species = TreeSpecies.getSpecies(type);
    _coins -= species.unlockCost;
    _unlockedTrees.add(type);
    await _saveUserData();
    notifyListeners();
    return true;
  }

  void selectTree(TreeType type) {
    if (_unlockedTrees.contains(type)) {
      _selectedTree = type;
      _saveUserData();
      notifyListeners();
    }
  }

  bool isUnlocked(TreeType type) {
    return _unlockedTrees.contains(type);
  }
}