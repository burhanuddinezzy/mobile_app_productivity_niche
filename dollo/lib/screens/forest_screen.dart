import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/forest_provider.dart';
import '../models/tree_model.dart';

class ForestScreen extends StatefulWidget {
  const ForestScreen({super.key});

  @override
  State<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends State<ForestScreen> {
  bool _showDeadTrees = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Forest'),
        actions: [
          IconButton(
            icon: Icon(_showDeadTrees ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showDeadTrees = !_showDeadTrees;
              });
            },
            tooltip: _showDeadTrees ? 'Hide dead trees' : 'Show dead trees',
          ),
          if (_showDeadTrees)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearDeadTreesDialog(context),
              tooltip: 'Clear dead trees',
            ),
        ],
      ),
      body: Consumer<ForestProvider>(
        builder: (context, forestProvider, _) {
          final trees = _showDeadTrees
              ? forestProvider.trees
              : forestProvider.aliveTrees;

          if (trees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.park_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showDeadTrees
                        ? 'No dead trees'
                        : 'Your forest is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete focus sessions to grow trees',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats summary
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      '🌳',
                      '${forestProvider.aliveTreesCount}',
                      'Alive',
                    ),
                    _buildStatItem(
                      context,
                      '💀',
                      '${forestProvider.deadTreesCount}',
                      'Dead',
                    ),
                    _buildStatItem(
                      context,
                      '⏱️',
                      '${forestProvider.totalFocusMinutes}m',
                      'Focus Time',
                    ),
                  ],
                ),
              ),

              // Tree grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: trees.length,
                  itemBuilder: (context, index) {
                    return _buildTreeCard(context, trees[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTreeCard(BuildContext context, TreeModel tree) {
    final species = TreeSpecies.getSpecies(tree.type);
    final dateFormat = DateFormat('MMM d, HH:mm');

    return GestureDetector(
      onTap: () => _showTreeDetails(context, tree),
      child: Card(
        elevation: tree.isDead ? 1 : 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tree.isDead ? '💀' : species.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              species.name,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${tree.durationMinutes} min',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tree.isDead ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              dateFormat.format(tree.plantedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTreeDetails(BuildContext context, TreeModel tree) {
    final species = TreeSpecies.getSpecies(tree.type);
    final dateFormat = DateFormat('MMMM d, yyyy \'at\' HH:mm');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(tree.isDead ? '💀' : species.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Text(species.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status', tree.isDead ? 'Dead ☠️' : 'Alive 🌱'),
            _buildDetailRow('Duration', '${tree.durationMinutes} minutes'),
            _buildDetailRow('Planted', dateFormat.format(tree.plantedAt)),
            _buildDetailRow('Coins Earned', '${tree.coinsEarned}'),
            if (tree.note != null) _buildDetailRow('Note', tree.note!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ForestProvider>(context, listen: false)
                  .deleteTree(tree.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showClearDeadTreesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Dead Trees'),
        content: const Text(
          'Are you sure you want to delete all dead trees? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ForestProvider>(context, listen: false)
                  .clearDeadTrees();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}