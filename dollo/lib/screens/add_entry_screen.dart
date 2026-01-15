import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../models/mood_model.dart';
import '../widgets/mood_selector.dart';
import '../widgets/activity_selector.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  MoodType _selectedMood = MoodType.good;
  final Set<String> _selectedActivityIds = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleActivity(String activityId) {
    setState(() {
      if (_selectedActivityIds.contains(activityId)) {
        _selectedActivityIds.remove(activityId);
      } else {
        _selectedActivityIds.add(activityId);
      }
    });
  }

  Future<void> _saveEntry() async {
    if (_selectedActivityIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one activity'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    
    await journalProvider.addEntry(
      mood: _selectedMood,
      activityIds: _selectedActivityIds.toList(),
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Selector
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),

            const SizedBox(height: 32),

            // Activity Selector
            ActivitySelector(
              selectedActivityIds: _selectedActivityIds.toList(),
              allActivities: journalProvider.activities,
              onActivityToggled: _toggleActivity,
            ),

            const SizedBox(height: 32),

            // Note (Optional)
            Text(
              'Add a note (optional)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'How was your day? What happened?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button (bottom)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}