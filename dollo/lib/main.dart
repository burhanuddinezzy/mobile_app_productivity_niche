import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/user_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/forest_provider.dart';
import 'screens/home_screen.dart';
import 'models/tree_model.dart';
import 'models/session_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(TreeModelAdapter());
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(TreeTypeAdapter());
  
  // Open boxes
  await Hive.openBox<TreeModel>('trees');
  await Hive.openBox<SessionModel>('sessions');
  await Hive.openBox('settings');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => ForestProvider()),
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