import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/forest_provider.dart';
import '../providers/user_provider.dart';
import '../providers/journal_provider.dart';
import '../models/tree_model.dart';
import '../models/mood_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Focus Stats'),
              Tab(text: 'Journal Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFocusStatsTab(),
            _buildJournalStatsTab(),
          ],
        ),
      ),
    );
  }

  // EXISTING: Focus Stats Tab (unchanged)
  Widget _buildFocusStatsTab() {
    return Consumer2<ForestProvider, UserProvider>(
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
                      _buildStatRow(context, '🌳', 'Trees Planted', '${forestProvider.totalTrees}'),
                      _buildStatRow(context, '✨', 'Trees Alive', '${forestProvider.aliveTreesCount}'),
                      _buildStatRow(context, '💀', 'Trees Dead', '${forestProvider.deadTreesCount}'),
                      _buildStatRow(context, '⏱️', 'Total Focus Time', '${forestProvider.totalFocusMinutes} min'),
                      _buildStatRow(context, '💰', 'Coins Balance', '${userProvider.coins}'),
                      _buildStatRow(context, '🏆', 'Total Coins Earned', '${forestProvider.totalCoinsEarned}'),
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
    );
  }

  // NEW: Journal Stats Tab
  Widget _buildJournalStatsTab() {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, _) {
        if (journalProvider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No journal entries yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start journaling to see statistics',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journal Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(context, '📝', 'Total Entries', '${journalProvider.entries.length}'),
                      _buildStatRow(context, '😊', 'Average Mood', _getAverageMoodText(journalProvider.getAverageMood())),
                      _buildStatRow(context, '🔥', 'Current Streak', '${journalProvider.getCurrentStreak()} days'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Mood distribution
              Text(
                'Mood Distribution',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildMoodDistribution(context, journalProvider),
                ),
              ),

              const SizedBox(height: 24),

              // Top activities
              Text(
                'Top Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildTopActivities(context, journalProvider),
                ),
              ),

              const SizedBox(height: 24),

              // Mood timeline (last 7 days)
              Text(
                'Mood Trend (Last 7 Days)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildMoodTimeline(context, journalProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // EXISTING: Helper widgets (unchanged)
  Widget _buildStatRow(BuildContext context, String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
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
                    Text(species.name, style: Theme.of(context).textTheme.bodyLarge),
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
                  Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('$percentage%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
                Text('$alive', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                const Text('Completed'),
              ],
            ),
            Column(
              children: [
                Text('${provider.deadTreesCount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
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
          child: Center(child: Text('No activity yet', style: TextStyle(color: Colors.grey[600]))),
        ),
      );
    }

    return Column(
      children: recentTrees.map((tree) {
        final species = TreeSpecies.getSpecies(tree.type);
        return Card(
          child: ListTile(
            leading: Text(tree.isDead ? '💀' : species.emoji, style: const TextStyle(fontSize: 32)),
            title: Text(species.name),
            subtitle: Text('${tree.durationMinutes} minutes • ${_formatDate(tree.plantedAt)}'),
            trailing: tree.isDead
                ? const Icon(Icons.close, color: Colors.red)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('+${tree.coinsEarned}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }

  // NEW: Journal stat widgets
  Widget _buildMoodDistribution(BuildContext context, JournalProvider provider) {
    final distribution = provider.getMoodDistribution();
    final total = distribution.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return const Text('No mood data yet');
    }

    return Column(
      children: MoodData.allMoods.map((moodData) {
        final count = distribution[moodData.type] ?? 0;
        final percentage = (count / total * 100).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(moodData.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(moodData.label),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: count / total,
                      backgroundColor: Colors.grey[200],
                      color: _getMoodColor(moodData.type),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('$percentage%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopActivities(BuildContext context, JournalProvider provider) {
    final frequency = provider.getActivityFrequency();
    final sortedActivities = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top5 = sortedActivities.take(5).toList();

    if (top5.isEmpty) {
      return const Text('No activities logged yet');
    }

    return Column(
      children: top5.map((entry) {
        final activity = provider.activities[entry.key];
        if (activity == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(activity.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Text(activity.name)),
              Text(
                '${entry.value}x',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodTimeline(BuildContext context, JournalProvider provider) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    
    final moodValues = {
      MoodType.awful: 1.0,
      MoodType.bad: 2.0,
      MoodType.meh: 3.0,
      MoodType.good: 4.0,
      MoodType.rad: 5.0,
    };

    final spots = <FlSpot>[];
    for (int i = 0; i < last7Days.length; i++) {
      final mood = provider.getMoodForDate(last7Days[i]);
      if (mood != null) {
        spots.add(FlSpot(i.toDouble(), moodValues[mood]!));
      }
    }

    if (spots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Not enough data yet'),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  const moods = ['', 'Awful', 'Bad', 'Meh', 'Good', 'Rad'];
                  if (value >= 1 && value <= 5) {
                    return Text(moods[value.toInt()], style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                    final date = last7Days[value.toInt()];
                    return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minY: 0.5,
          maxY: 5.5,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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

  String _getAverageMoodText(double avg) {
    if (avg <= 1.5) return 'Awful';
    if (avg <= 2.5) return 'Bad';
    if (avg <= 3.5) return 'Meh';
    if (avg <= 4.5) return 'Good';
    return 'Rad';
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.awful:
        return Colors.red[400]!;
      case MoodType.bad:
        return Colors.orange[400]!;
      case MoodType.meh:
        return Colors.yellow[600]!;
      case MoodType.good:
        return Colors.lightGreen[400]!;
      case MoodType.rad:
        return Colors.green[500]!;
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

    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, bgPaint);

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