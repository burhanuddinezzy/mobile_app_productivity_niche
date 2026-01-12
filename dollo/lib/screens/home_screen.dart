import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dollo Farm')),
      body: Column(
        children: [
          Expanded(child: _FarmGrid()),
          _BottomBar(),
        ],
      ),
    );
  }
}

class _FarmGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.green[200],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
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
