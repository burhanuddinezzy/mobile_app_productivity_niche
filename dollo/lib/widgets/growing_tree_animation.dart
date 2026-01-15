import 'package:flutter/material.dart';

class GrowingTreeAnimation extends StatelessWidget {
  final String emoji;
  final double progress;

  const GrowingTreeAnimation({
    super.key,
    required this.emoji,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ground/soil
          Positioned(
            bottom: 0,
            child: Container(
              width: 180,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.brown[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          // Growth stages
          Positioned(
            bottom: 40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: _buildTreeStage(),
            ),
          ),
          
          // Progress indicator
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getProgressColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeStage() {
    // Different growth stages based on progress
    if (progress < 0.1) {
      return const Text('🌱', style: TextStyle(fontSize: 40)); // Seedling
    } else if (progress < 0.25) {
      return const Text('🌿', style: TextStyle(fontSize: 60)); // Small sprout
    } else if (progress < 0.5) {
      return Text(emoji, style: const TextStyle(fontSize: 80)); // Growing
    } else if (progress < 0.75) {
      return Text(emoji, style: const TextStyle(fontSize: 100)); // Almost there
    } else {
      return Text(emoji, style: const TextStyle(fontSize: 120)); // Full grown
    }
  }

  Color _getProgressColor() {
    if (progress < 0.25) {
      return Colors.red[400]!;
    } else if (progress < 0.5) {
      return Colors.orange[400]!;
    } else if (progress < 0.75) {
      return Colors.yellow[700]!;
    } else {
      return Colors.green[400]!;
    }
  }
}