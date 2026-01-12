import 'dart:io'; // Provides File class for reading/writing files
import 'dart:convert'; // Provides json.encode() and json.decode() for JSON conversion
import 'package:path_provider/path_provider.dart'; // Finds where to save files on the device
import '../models/app_state.dart'; // Your AppState model (holds plants, gold, etc.)
import 'package:flutter/foundation.dart'; // Provides debugPrint() for logging


class DataService {
  // SINGLETON PATTERN - ensures only ONE instance exists in the entire app
  static final DataService _instance = DataService._internal(); // Private static variable holds the single instance
  factory DataService() => _instance; // When you call DataService(), it returns the existing instance
  DataService._internal(); // Private constructor - prevents creating new instances from outside

  AppState? _appState; // Stores the current game state in memory (nullable - might not be loaded yet)

  // File name for JSON storage
  final String _fileName = 'dollo_data.json'; // Name of the file where we'll save data

  // Get the app directory
  Future<File> _getLocalFile() async { // Returns a Future because finding the directory takes time
    final dir = await getApplicationDocumentsDirectory(); // Gets the app's private storage folder (e.g., /data/user/0/com.yourapp/)
    return File('${dir.path}/$_fileName'); // Combines the directory path with filename (e.g., /data/.../dollo_data.json)
  }

  /// Load AppState from JSON file
  Future<AppState> loadData() async { // Returns Future<AppState> because reading files takes time
    if (_appState != null) return _appState!; // Already loaded? Return the cached version (fast!)

    try { // Try-catch handles errors gracefully (file corrupted, permission denied, etc.)
      final file = await _getLocalFile(); // Get the File object pointing to our save file
      if (await file.exists()) {  // Check if the file actually exists on the device
        final contents = await file.readAsString(); // Read the entire file as a text string (the JSON)
        final jsonData = json.decode(contents); // Parse the JSON string into a Dart Map (e.g., {"plants": [...], "gold": 100})
        _appState = AppState.fromJson(jsonData); // Convert the Map into an AppState object using the fromJson constructor
        return _appState!; // Return the loaded state (! means "I'm sure it's not null")
      }
    } catch (e) { // If anything goes wrong (corrupt file, no permission, etc.)
      debugPrint('Error loading data: $e'); // Print error to console for debugging (won't crash the app)
    }

    // Return default state if file does not exist
    _appState = AppState(plants: []); // First-time user or error? Create a fresh empty state
    return _appState!; // Return the empty state
  }

  /// Save current AppState to JSON file
  Future<void> saveData() async { // Returns Future<void> because writing files takes time (void = no return value)
    if (_appState == null) return; // Nothing loaded yet? Nothing to save!
    try { // Try-catch to handle write errors (disk full, permission denied, etc.)
      final file = await _getLocalFile(); // Get the File object
      final jsonData = json.encode(_appState!.toJson()); // Convert AppState object → Map → JSON string
      await file.writeAsString(jsonData); // Write the JSON string to the file (overwrites existing content)
    } catch (e) { // If write fails
      debugPrint('Error saving data: $e'); // Log the error but don't crash
    }
  }

  /// Get current AppState
  AppState get appState { // Getter - lets you access like: DataService().appState (no parentheses)
    if (_appState == null) { // Safety check - did you forget to call loadData()?
      throw Exception('AppState not loaded yet. Call loadData() first.'); // Crash with helpful error message
    }
    return _appState!; // Return the loaded state
  }

  /// Reset data (optional)
  Future<void> resetData() async { // For a "Reset Game" feature
    _appState = AppState(plants: []); // Create fresh empty state
    await saveData(); // Write the empty state to the file (deletes all progress)
  }
}