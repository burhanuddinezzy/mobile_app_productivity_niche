import 'package:flutter/material.dart';
import '../models/plant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TEMP plant list (we will make this persistent later)
  final List<Plant> plants = [
    Plant(
      name: 'Tomato',
      sprite: 'tomato.png',
      sessionsToGrow: 4,
      goldPerStage: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dollo Farm')),
      body: Column(
        children: [
          Expanded(child: _FarmGrid(
              plants: plants,
              rows: 10,
              cols: 10,
              tileSize: 64.0,
            )),
          _BottomBar(),
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
    this.rows = 10, // initial rows
    this.cols = 10, // initial columns
    this.tileSize = 64.0, // size of each tile
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 2,
      constrained: false,
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
                  color: Colors.red[300], // placeholder color for plant
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
    );
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('Start Focus'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Collect Gold'),
          ),
        ],
      ),
    );
  }
}
