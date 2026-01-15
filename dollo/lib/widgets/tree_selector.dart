import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tree_model.dart';
import '../providers/user_provider.dart';

class TreeSelector extends StatelessWidget {
  final TreeType selectedTree;
  final Function(TreeType) onTreeSelected;

  const TreeSelector({
    super.key,
    required this.selectedTree,
    required this.onTreeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final unlockedTrees = TreeSpecies.allSpecies
            .where((s) => userProvider.isUnlocked(s.type))
            .toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Tree',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () => _showAllSpecies(context, userProvider),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Unlock More'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: unlockedTrees.map((species) {
                    final isSelected = species.type == selectedTree;
                    return GestureDetector(
                      onTap: () => onTreeSelected(species.type),
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(species.emoji, style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 4),
                            Text(
                              species.name.split(' ')[0],
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllSpecies(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tree Species',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${userProvider.coins}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: TreeSpecies.allSpecies.length,
                  itemBuilder: (context, index) {
                    final species = TreeSpecies.allSpecies[index];
                    final isUnlocked = userProvider.isUnlocked(species.type);
                    final canUnlock = userProvider.canUnlock(species.type);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Text(
                          species.emoji,
                          style: TextStyle(
                            fontSize: 48,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                        title: Text(
                          species.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(species.description),
                            if (!isUnlocked && species.unlockCost > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${species.unlockCost} coins',
                                      style: TextStyle(
                                        color: canUnlock
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: isUnlocked
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : canUnlock && species.unlockCost > 0
                                ? ElevatedButton(
                                    onPressed: () async {
                                      final success =
                                          await userProvider.unlockTree(species.type);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Unlocked ${species.name}!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Unlock'),
                                  )
                                : const Icon(Icons.lock, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}