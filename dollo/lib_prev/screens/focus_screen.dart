import 'dart:async';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../models/app_state.dart';

class FocusScreen extends StatefulWidget {
  final AppState appState;

  const FocusScreen({super.key, required this.appState});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with TickerProviderStateMixin {
  // Tabs: 0 = New Plants, 1 = Existing Plants
  int selectedTab = 0;

  // Hardcoded new plants for MVP
  final List<Plant> newPlants = [
    Plant(name: 'Tomato', sprite: '🍅', sessionsToGrow: 4, goldPerStage: 1),
    Plant(name: 'Sunflower', sprite: '🌻', sessionsToGrow: 3, goldPerStage: 1),
    Plant(name: 'Seedling', sprite: '🌱', sessionsToGrow: 2, goldPerStage: 1),
    Plant(name: 'Flower', sprite: '🌸', sessionsToGrow: 4, goldPerStage: 2),
  ];

  Plant? selectedPlant;
  bool timerRunning = false;
  Duration remainingTime = const Duration(minutes: 25);
  Timer? countdownTimer;

  // For scaling animation
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    scaleController = AnimationController(
      vsync: this,
      duration: remainingTime,
    );
    scaleAnimation =
        Tween<double>(begin: 1.0, end: 2.0).animate(scaleController);
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    scaleController.dispose();
    super.dispose();
  }

  void startTimer() {
    if (selectedPlant == null) return;

    setState(() {
      timerRunning = true;
      remainingTime = const Duration(minutes: 25);
    });

    scaleController.reset();
    scaleController.forward();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final secondsLeft = remainingTime.inSeconds - 1;
        if (secondsLeft <= 0) {
          timer.cancel();
          timerRunning = false;
          remainingTime = Duration.zero;
          onTimerComplete();
        } else {
          remainingTime = Duration(seconds: secondsLeft);
        }
      });
    });
  }

  void cancelTimer() {
    countdownTimer?.cancel();
    scaleController.reset();
    setState(() {
      timerRunning = false;
      remainingTime = const Duration(minutes: 25);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Focus session cancelled.')),
    );
  }

void onTimerComplete() async {
  if (selectedPlant == null) return;

  final continueSession = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Session Complete!'),
      content: const Text(
          'Do you want to continue to the next session or finish?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Finish'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );

  if (!mounted) return; // <-- ADD THIS GUARD

  if (continueSession == true) {
    // Reset timer and keep scaling animation
    startTimer();
  } else {
    // Increment plant sessions
    setState(() {
      selectedPlant!.onSessionComplete();
      if (!widget.appState.plants.contains(selectedPlant)) {
        widget.appState.plants.add(selectedPlant!);
      }
    });

    Navigator.of(context).pop(); // Return to HomeScreen
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        bottom: !timerRunning
            ? TabBar(
                onTap: (index) => setState(() => selectedTab = index),
                tabs: const [
                  Tab(text: 'New Plants'),
                  Tab(text: 'Existing Plants'),
                ],
                controller: TabController(
                  length: 2,
                  vsync: this,
                  initialIndex: selectedTab,
                ),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: timerRunning
            ? buildTimerView()
            : buildSelectionView(), // Show selection or timer
      ),
    );
  }

  Widget buildSelectionView() {
    List<Plant> plantsToShow = selectedTab == 0
        ? newPlants
        : widget.appState.plants
            .where((p) => p.currentStage < 4)
            .toList(); // Existing plants not fully grown

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: plantsToShow.length,
            itemBuilder: (context, index) {
              final plant = plantsToShow[index];
              final isSelected = plant == selectedPlant;
              return GestureDetector(
                onTap: () => setState(() => selectedPlant = plant),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green[300] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected ? Colors.green[800]! : Colors.grey,
                        width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        plant.sprite,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(plant.name),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text('${plant.sessionsToGrow}'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed:
              selectedPlant != null ? startTimer : null, // Only if selected
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Text('Start Timer', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget buildTimerView() {
    final minutes = remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: scaleAnimation,
          child: Text(
            selectedPlant!.sprite,
            style: const TextStyle(fontSize: 80),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '$minutes:$seconds',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: cancelTimer,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(16)),
          child: const Text('Cancel Session'),
        ),
      ],
    );
  }
}
