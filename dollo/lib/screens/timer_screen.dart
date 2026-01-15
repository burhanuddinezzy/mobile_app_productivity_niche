import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/user_provider.dart';
import '../providers/forest_provider.dart';
import '../models/tree_model.dart';
import '../widgets/tree_selector.dart';
import '../widgets/growing_tree_animation.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${userProvider.coins}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, _) {
          if (timerProvider.state == TimerState.idle) {
            return _buildSetupView(context, timerProvider);
          } else if (timerProvider.state == TimerState.running) {
            return _buildRunningView(context, timerProvider);
          } else if (timerProvider.state == TimerState.completed) {
            return _buildCompletedView(context, timerProvider);
          } else {
            return _buildFailedView(context, timerProvider);
          }
        },
      ),
    );
  }

  Widget _buildSetupView(BuildContext context, TimerProvider timerProvider) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Plant a tree',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay focused and grow your forest',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 60),
          
          // Duration selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Duration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [10, 15, 25, 30, 45, 60, 90, 120].map((minutes) {
                      final isSelected = timerProvider.totalSeconds == minutes * 60;
                      return ChoiceChip(
                        label: Text('$minutes min'),
                        selected: isSelected,
                        onSelected: (_) {
                          timerProvider.setDuration(minutes);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tree selector
          TreeSelector(
            selectedTree: userProvider.selectedTree,
            onTreeSelected: (type) {
              userProvider.selectTree(type);
              timerProvider.setTreeType(type);
            },
          ),
          
          const SizedBox(height: 40),
          
          // Start button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                timerProvider.startTimer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Start Focus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningView(BuildContext context, TimerProvider timerProvider) {
    final species = TreeSpecies.getSpecies(timerProvider.currentTreeType);
    
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Growing tree animation
                GrowingTreeAnimation(
                  emoji: species.emoji,
                  progress: timerProvider.progress,
                ),
                
                const SizedBox(height: 40),
                
                // Timer display
                Text(
                  timerProvider.formattedTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 72,
                      ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Stay focused!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Your ${species.name.toLowerCase()} is growing',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        
        // Give up button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Leaving will kill your tree',
                style: TextStyle(color: Colors.red[300]),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _showGiveUpDialog(context, timerProvider);
                },
                child: const Text(
                  'Give Up',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedView(BuildContext context, TimerProvider timerProvider) {
    final species = TreeSpecies.getSpecies(timerProvider.currentTreeType);
    final coins = timerProvider.getCoinsForCurrentSession();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              species.emoji,
              style: const TextStyle(fontSize: 120),
            ),
            const SizedBox(height: 24),
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'You grew a ${species.name.toLowerCase()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    '+$coins coins',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false)
                      .addCoins(coins);
                  Provider.of<ForestProvider>(context, listen: false)
                      .loadForest();
                  timerProvider.reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedView(BuildContext context, TimerProvider timerProvider) {
    final species = TreeSpecies.getSpecies(timerProvider.currentTreeType);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '💀',
              style: const TextStyle(fontSize: 120),
            ),
            const SizedBox(height: 24),
            Text(
              'Tree Died',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your ${species.name.toLowerCase()} didn\'t make it',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try again and stay focused!',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<ForestProvider>(context, listen: false)
                      .loadForest();
                  timerProvider.reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGiveUpDialog(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Give Up?'),
        content: const Text(
          'Are you sure you want to give up? Your tree will die and you won\'t earn any coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              timerProvider.giveUp();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Give Up'),
          ),
        ],
      ),
    );
  }
}