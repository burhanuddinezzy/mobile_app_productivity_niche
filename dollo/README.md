# Focus Forest - Setup Instructions

A full-featured focus/productivity app inspired by Forest, built with Flutter.

## Features ✨

- ⏱️ **Focus Timer** - Set duration from 10-120 minutes
- 🌳 **Tree Growth System** - Trees grow as you focus
- 💀 **Failure Mechanic** - Leave the app = dead tree
- 💰 **Coin System** - Earn coins for completed sessions
- 🎋 **Multiple Tree Species** - 8 unlockable species
- 📊 **Statistics** - Track your progress and success rate
- 🌲 **Forest Gallery** - View all your planted trees
- 💾 **Persistent Storage** - All data saved locally

## Installation Steps

### 1. Create Your Flutter Project
```bash
flutter create focus_forest
cd focus_forest
```

### 2. Replace pubspec.yaml
Copy the provided `pubspec.yaml` to your project root.

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Generate Hive Adapters
Since we're using Hive for local storage, you need to generate the type adapters:

```bash
flutter packages pub run build_runner build
```

This will generate:
- `lib/models/tree_model.g.dart`
- `lib/models/session_model.g.dart`

**IMPORTANT**: If build_runner fails, you can manually copy the adapter code from the provided `models/tree_model.g.dart` file into your project.

### 5. Create Directory Structure
```
lib/
├── main.dart
├── models/
│   ├── tree_model.dart
│   ├── tree_model.g.dart
│   ├── session_model.dart
│   └── session_model.g.dart
├── providers/
│   ├── user_provider.dart
│   ├── timer_provider.dart
│   └── forest_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── timer_screen.dart
│   ├── forest_screen.dart
│   ├── stats_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── tree_selector.dart
    └── growing_tree_animation.dart
```

### 6. Copy All Files
Copy all the provided Dart files into their respective directories.

### 7. Add intl Package (For Date Formatting)
The forest screen uses the `intl` package. Add it to `pubspec.yaml`:

```yaml
dependencies:
  intl: ^0.18.1
```

Then run:
```bash
flutter pub get
```

### 8. Run the App
```bash
flutter run
```

## How It Works 🎮

### Timer Flow
1. **Setup Phase** - User selects duration and tree type
2. **Running Phase** - Timer counts down, tree grows
3. **Completion** - User earns coins, tree is saved
4. **Failure** - If user gives up, tree dies (no coins)

### Coin Economy
- Coins earned = `duration_minutes / 5`
- Example: 30 min session = 6 coins
- Use coins to unlock new tree species

### Tree Species
1. 🌳 Oak (Free)
2. 🌲 Pine (50 coins)
3. 🌸 Cherry (100 coins)
4. 🍁 Maple (150 coins)
5. 🌿 Willow (200 coins)
6. 🎋 Bamboo (250 coins)
7. 🌵 Cactus (300 coins)
8. 🌴 Palm (400 coins)

## Customization Ideas 💡

### Easy Customizations
- **Change colors**: Modify `ColorScheme.fromSeed` in `main.dart`
- **Add more trees**: Add entries to `TreeSpecies.allSpecies` in `tree_model.dart`
- **Adjust coin rates**: Change formula in `tree_model.dart` and `timer_provider.dart`
- **Modify durations**: Edit the duration chips in `timer_screen.dart`

### Medium Customizations
- **Add sounds**: Use `audioplayers` package for success/failure sounds
- **Add animations**: Use `flutter_animate` for enhanced tree growth
- **Add themes**: Implement dark mode with ThemeData
- **Add achievements**: Create new provider for badges/achievements

### Advanced Customizations
- **Real tree planting**: Integrate with real tree planting APIs
- **Social features**: Add Firebase for leaderboards
- **Reminders**: Use `flutter_local_notifications` for focus reminders
- **Focus mode**: Use `screen_wakelock` to prevent screen from sleeping
- **Background service**: Detect app leaving with `WidgetsBindingObserver`

## Common Issues & Solutions 🔧

### Build Runner Fails
If `build_runner` fails, manually create the `.g.dart` files using the provided code.

### Hive Box Errors
If you get Hive box errors, clear app data or uninstall/reinstall the app during development.

### Layout Overflow
If you see overflow errors, wrap scrollable content in `SingleChildScrollView`.

## Project Structure Explained

### Models
- `TreeModel` - Represents a planted tree (completed session)
- `SessionModel` - Records focus session details
- `TreeType` - Enum for different tree species

### Providers (State Management)
- `UserProvider` - Manages coins and unlocked species
- `TimerProvider` - Handles timer logic and session state
- `ForestProvider` - Manages tree collection and stats

### Screens
- `HomeScreen` - Main navigation with bottom tabs
- `TimerScreen` - Focus timer interface
- `ForestScreen` - Gallery of planted trees
- `StatsScreen` - Statistics and progress
- `SettingsScreen` - App settings and species management

### Widgets
- `TreeSelector` - Tree species picker
- `GrowingTreeAnimation` - Animated tree growth visual

## Next Steps 🚀

1. Test the app thoroughly
2. Add your own branding and styling
3. Implement additional features you want
4. Deploy to App Store / Play Store

## Need Help?

Common modifications:
- **Change app name**: Update in `pubspec.yaml` and platform-specific files
- **Change app icon**: Use `flutter_launcher_icons` package
- **Add splash screen**: Use `flutter_native_splash` package

Enjoy building your focus app! 🌲