import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Existing providers
import 'providers/user_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/forest_provider.dart';

// NEW: Journal providers
import 'providers/journal_provider.dart';

// Existing models
import 'models/tree_model.dart';
import 'models/session_model.dart';

// NEW: Journal models
import 'models/journal_entry_model.dart';
import 'models/activity_model.dart';
import 'models/mood_model.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register EXISTING adapters
  Hive.registerAdapter(TreeModelAdapter());
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(TreeTypeAdapter());
  
  // Register NEW journal adapters
  Hive.registerAdapter(MoodTypeAdapter());
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(JournalEntryAdapter());
  
  // Open EXISTING boxes
  await Hive.openBox<TreeModel>('trees');
  await Hive.openBox<SessionModel>('sessions');
  await Hive.openBox('settings');
  
  // Open NEW journal boxes
  await Hive.openBox<JournalEntry>('journal_entries');
  await Hive.openBox<ActivityModel>('custom_activities');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // EXISTING providers
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => ForestProvider()),
        
        // NEW: Journal provider
        ChangeNotifierProvider(create: (_) => JournalProvider()),
      ],
      child: MaterialApp(
        title: 'Focus Forest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D5016),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}