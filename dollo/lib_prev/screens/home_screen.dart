import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../models/app_state.dart';
import 'focus_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppState appState;

  @override
  void initState() {
    super.initState();
    appState = AppState(
      plants: [
        Plant(
          name: 'Tomato',
          sprite: 'tomato.png',
          sessionsToGrow: 4,
          goldPerStage: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dollo Farm')),
      body: Column(
        children: [
          Expanded(
            child: _FarmGrid(
              plants: appState.plants,
              rows: 10,
              cols: 10,
              tileSize: 64.0,
            ),
          ),
          _BottomBar(appState: appState),
        ],
      ),
    );
  }
}


class _FarmGrid extends StatelessWidget {
  final List<Plant> plants;
  final int rows;
  final int cols;
  final double tileSize;

  const _FarmGrid({
    required this.plants,
    this.rows = 10,
    this.cols = 10,
    this.tileSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total farm size
    final double farmWidth = cols * tileSize;
    final double farmHeight = rows * tileSize;

    return InteractiveViewer(
      minScale: 1,
      maxScale: 2,
      constrained: true, // let it respect the child size
      child: SizedBox(
        width: farmWidth,
        height: farmHeight,
        child: Stack(
          children: [
            // 1. Farm background tiles
            for (int row = 0; row < rows; row++)
              for (int col = 0; col < cols; col++)
                Positioned(
                  left: col * tileSize,
                  top: row * tileSize,
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: Colors.green[200],
                      border: Border.all(color: Colors.green[400]!, width: 0.5),
                    ),
                  ),
                ),

            // 2. Plant positions
            for (var plant in plants)
              Positioned(
                left: plant.x * tileSize,
                top: plant.y * tileSize,
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[700]!, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '${plant.name}\nStage ${plant.currentStage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final AppState appState;

  const _BottomBar({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FocusScreen(appState: appState),
                ),
              );
            },
            child: const Text('Start Focus'),
          ),
          ElevatedButton(
            onPressed: () {
              final collected = appState.collectGold();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Collected $collected gold')),
              );
            },
            child: const Text('Collect Gold'),
          ),
        ],
      ),
    );
  }
}
