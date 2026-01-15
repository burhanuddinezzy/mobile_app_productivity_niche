import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_entry_model.dart';
import '../models/activity_model.dart';
import '../models/mood_model.dart';

class JournalProvider with ChangeNotifier {
  List<JournalEntry> _entries = [];
  Map<String, ActivityModel> _activities = {};

  List<JournalEntry> get entries => _entries;
  List<JournalEntry> get entriesReversed => _entries.reversed.toList();
  Map<String, ActivityModel> get activities => _activities;
  List<ActivityModel> get activitiesList => _activities.values.toList();

  JournalProvider() {
    _initializeActivities();
    loadEntries();
  }

  // Initialize with default activities
  Future<void> _initializeActivities() async {
    final activitiesBox = Hive.box<ActivityModel>('custom_activities');
    
    // If empty, load defaults
    if (activitiesBox.isEmpty) {
      for (var activity in DefaultActivities.defaults) {
        await activitiesBox.put(activity.id, activity);
      }
    }
    
    // Load all activities into map
    _activities = Map.fromEntries(
      activitiesBox.values.map((a) => MapEntry(a.id, a)),
    );
    notifyListeners();
  }

  // Load all journal entries
  Future<void> loadEntries() async {
    final entriesBox = Hive.box<JournalEntry>('journal_entries');
    _entries = entriesBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  // Add new entry
  Future<void> addEntry({
    required MoodType mood,
    required List<String> activityIds,
    String? note,
    List<String>? photoUrls,
  }) async {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      mood: mood,
      activityIds: activityIds,
      note: note,
      photoUrls: photoUrls ?? [],
    );

    final entriesBox = Hive.box<JournalEntry>('journal_entries');
    await entriesBox.put(entry.id, entry);
    await loadEntries();
  }

  // Update existing entry
  Future<void> updateEntry({
    required String id,
    MoodType? mood,
    List<String>? activityIds,
    String? note,
    List<String>? photoUrls,
  }) async {
    final entriesBox = Hive.box<JournalEntry>('journal_entries');
    final entry = entriesBox.get(id);

    if (entry != null) {
      if (mood != null) entry.mood = mood;
      if (activityIds != null) entry.activityIds = activityIds;
      if (note != null) entry.note = note;
      if (photoUrls != null) entry.photoUrls = photoUrls;
      
      await entry.save();
      await loadEntries();
    }
  }

  // Delete entry
  Future<void> deleteEntry(String id) async {
    final entriesBox = Hive.box<JournalEntry>('journal_entries');
    await entriesBox.delete(id);
    await loadEntries();
  }

  // Get entries for specific date
  List<JournalEntry> getEntriesForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _entries.where((e) {
      final entryDate = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      return entryDate == targetDate;
    }).toList();
  }

  // Get entries for date range
  List<JournalEntry> getEntriesInRange(DateTime start, DateTime end) {
    return _entries.where((e) {
      return e.timestamp.isAfter(start) && e.timestamp.isBefore(end);
    }).toList();
  }

  // Add custom activity
  Future<void> addCustomActivity({
    required String name,
    required String icon,
    required int colorValue,
  }) async {
    final activity = ActivityModel(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      colorValue: colorValue,
      isCustom: true,
    );

    final activitiesBox = Hive.box<ActivityModel>('custom_activities');
    await activitiesBox.put(activity.id, activity);
    
    _activities[activity.id] = activity;
    notifyListeners();
  }

  // Delete custom activity
  Future<void> deleteCustomActivity(String id) async {
    final activity = _activities[id];
    if (activity != null && activity.isCustom) {
      final activitiesBox = Hive.box<ActivityModel>('custom_activities');
      await activitiesBox.delete(id);
      _activities.remove(id);
      notifyListeners();
    }
  }

  // Statistics methods
  Map<MoodType, int> getMoodDistribution() {
    final counts = <MoodType, int>{
      MoodType.awful: 0,
      MoodType.bad: 0,
      MoodType.meh: 0,
      MoodType.good: 0,
      MoodType.rad: 0,
    };

    for (var entry in _entries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, int> getActivityFrequency() {
    final counts = <String, int>{};
    for (var entry in _entries) {
      for (var activityId in entry.activityIds) {
        counts[activityId] = (counts[activityId] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<JournalEntry> getEntriesLast30Days() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _entries.where((e) => e.timestamp.isAfter(thirtyDaysAgo)).toList();
  }

  double getAverageMood() {
    if (_entries.isEmpty) return 3.0;

    final moodValues = {
      MoodType.awful: 1.0,
      MoodType.bad: 2.0,
      MoodType.meh: 3.0,
      MoodType.good: 4.0,
      MoodType.rad: 5.0,
    };

    final sum = _entries.fold(0.0, (sum, e) => sum + (moodValues[e.mood] ?? 3.0));
    return sum / _entries.length;
  }

  int getCurrentStreak() {
    if (_entries.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    while (true) {
      final dateEntries = getEntriesForDate(currentDate);
      if (dateEntries.isEmpty) break;
      
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Get mood for a specific day (for calendar/pixels view)
  MoodType? getMoodForDate(DateTime date) {
    final entries = getEntriesForDate(date);
    if (entries.isEmpty) return null;

    // Return average mood for the day
    final moodValues = {
      MoodType.awful: 1,
      MoodType.bad: 2,
      MoodType.meh: 3,
      MoodType.good: 4,
      MoodType.rad: 5,
    };

    final sum = entries.fold(0, (sum, e) => sum + (moodValues[e.mood] ?? 3));
    final avg = sum / entries.length;

    if (avg <= 1.5) return MoodType.awful;
    if (avg <= 2.5) return MoodType.bad;
    if (avg <= 3.5) return MoodType.meh;
    if (avg <= 4.5) return MoodType.good;
    return MoodType.rad;
  }
}