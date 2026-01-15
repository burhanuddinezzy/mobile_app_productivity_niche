import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forest_provider.dart';
import '../providers/user_provider.dart';
import '../models/tree_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer2<ForestProvider, UserProvider>(
        builder: (context, forestProvider, userProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall stats card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          context,
                          '🌳',
                          'Trees Planted',
                          '${forestProvider.totalTrees}',
                        ),
                        _buildStatRow(
                          context,
                          '✨',
                          'Trees Alive',
                          '${forestProvider.aliveTreesCount}',
                        ),
                        _buildStatRow(
                          context,
                          '💀',
                          'Trees Dead',
                          '${forestProvider.deadTreesCount}',
                        ),
                        _buildStatRow(
                          context,
                          '⏱️',
                          'Total Focus Time',
                          '${forestProvider.totalFocusMinutes} min',
                        ),
                        _buildStatRow(
                          context,
                          '💰',
                          'Coins Balance',
                          '${userProvider.coins}',
                        ),
                        _buildStatRow(
                          context,
                          '🏆',
                          'Total Coins Earned',
                          '${forestProvider.totalCoinsEarned}',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Tree species breakdown
                Text(
                  'Tree Species',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildTreeTypeStats(context, forestProvider),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Success rate
                Text(
                  'Success Rate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSuccessRate(context, forestProvider),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recent activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildRecentActivity(context, forestProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String emoji,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeTypeStats(BuildContext context, ForestProvider provider) {
    final stats = provider.getTreeTypeStats();
    
    if (stats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No trees planted yet'),
        ),
      );
    }

    return Column(
      children: stats.entries.map((entry) {
        final species = TreeSpecies.getSpecies(entry.key);
        final percentage = provider.aliveTreesCount > 0
            ? (entry.value / provider.aliveTreesCount * 100).toStringAsFixed(1)
            : '0.0';
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(species.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / provider.aliveTreesCount,
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuccessRate(BuildContext context, ForestProvider provider) {
    final total = provider.totalTrees;
    final alive = provider.aliveTreesCount;
    final successRate = total > 0 ? (alive / total * 100).toStringAsFixed(1) : '0.0';
    
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: total > 0 ? alive / total : 0,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$successRate%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Text('Success Rate'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '$alive',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Text('Completed'),
              ],
            ),
            Column(
              children: [
                Text(
                  '${provider.deadTreesCount}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Text('Failed'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, ForestProvider provider) {
    final recentTrees = provider.trees.take(5).toList();
    
    if (recentTrees.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No activity yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentTrees.map((tree) {
        final species = TreeSpecies.getSpecies(tree.type);
        return Card(
          child: ListTile(
            leading: Text(
              tree.isDead ? '💀' : species.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(species.name),
            subtitle: Text(
              '${tree.durationMinutes} minutes • ${_formatDate(tree.plantedAt)}',
            ),
            trailing: tree.isDead
                ? const Icon(Icons.close, color: Colors.red)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${tree.coinsEarned}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}