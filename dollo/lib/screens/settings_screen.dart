import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/tree_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tree Species section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tree Species',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const _TreeSpeciesSection(),
            
            const Divider(height: 32),
            
            // App Settings
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'App Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Focus Forest v1.0.0'),
              onTap: () => _showAboutDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('How to Use'),
              onTap: () => _showHowToUseDialog(context),
            ),
            
            const Divider(height: 32),
            
            // Danger Zone
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Danger Zone',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset All Data'),
              subtitle: const Text('Delete all trees, sessions, and progress'),
              onTap: () => _showResetDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Focus Forest'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'A productivity app that helps you stay focused by growing virtual trees.',
            ),
            SizedBox(height: 16),
            Text(
              'Stay focused during your session to grow a tree. Leave the app and your tree dies!',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHowToUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Set Your Timer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Choose how long you want to focus (10-120 minutes)'),
              SizedBox(height: 12),
              Text(
                '2. Select a Tree',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Pick a tree species to plant'),
              SizedBox(height: 12),
              Text(
                '3. Start Focusing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Tap "Start Focus" and stay in the app'),
              SizedBox(height: 12),
              Text(
                '4. Grow Your Forest',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Complete sessions to earn coins and unlock new species'),
              SizedBox(height: 12),
              Text(
                '⚠️ Warning',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Text('Leaving the app during a session will kill your tree!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your trees, sessions, coins, and unlocked species. This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement reset functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset functionality coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _TreeSpeciesSection extends StatelessWidget {
  const _TreeSpeciesSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: TreeSpecies.allSpecies.length,
          itemBuilder: (context, index) {
            final species = TreeSpecies.allSpecies[index];
            final isUnlocked = userProvider.isUnlocked(species.type);
            final canUnlock = userProvider.canUnlock(species.type);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Text(
                  species.emoji,
                  style: TextStyle(
                    fontSize: 32,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                title: Text(species.name),
                subtitle: Text(species.description),
                trailing: _buildTrailing(
                  context,
                  species,
                  isUnlocked,
                  canUnlock,
                  userProvider,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    TreeSpecies species,
    bool isUnlocked,
    bool canUnlock,
    UserProvider userProvider,
  ) {
    if (isUnlocked) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (species.unlockCost == 0) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: canUnlock
          ? () async {
              final success = await userProvider.unlockTree(species.type);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unlocked ${species.name}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          : null,
      icon: const Icon(Icons.monetization_on, size: 16),
      label: Text('${species.unlockCost}'),
      style: ElevatedButton.styleFrom(
        backgroundColor: canUnlock ? Colors.amber : null,
        foregroundColor: canUnlock ? Colors.black : null,
      ),
    );
  }
}