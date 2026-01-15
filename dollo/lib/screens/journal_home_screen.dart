import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/mood_model.dart';
import 'add_entry_screen.dart';
import 'entry_detail_screen.dart';
import 'journal_calendar_screen.dart';
import 'year_in_pixels_screen.dart';

class JournalHomeScreen extends StatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  State<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends State<JournalHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Calendar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YearInPixelsScreen(),
                ),
              );
            },
            tooltip: 'Year in Pixels',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineView(),
          const JournalCalendarScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimelineView() {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, _) {
        if (journalProvider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No journal entries yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first entry',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Group entries by date
        final groupedEntries = <String, List>{};
        for (var entry in journalProvider.entriesReversed) {
          final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
          groupedEntries.putIfAbsent(dateKey, () => []).add(entry);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedEntries.length,
          itemBuilder: (context, index) {
            final dateKey = groupedEntries.keys.elementAt(index);
            final entries = groupedEntries[dateKey]!;
            final date = DateTime.parse(dateKey);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _formatDateHeader(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Entries for this date
                ...entries.map((entry) => _buildEntryCard(context, entry, journalProvider)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEntryCard(BuildContext context, entry, JournalProvider provider) {
    final moodData = MoodData.getMoodData(entry.mood);
    final activities = entry.activityIds
        .map((id) => provider.activities[id])
        .where((a) => a != null)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntryDetailScreen(entry: entry),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    moodData.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moodData.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.formattedTime,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (activities.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: activities.map((activity) {
                    return Chip(
                      avatar: Text(activity!.icon, style: const TextStyle(fontSize: 14)),
                      label: Text(
                        activity.name,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Color(activity.colorValue).withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
              if (entry.note != null && entry.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  entry.note!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    }
  }
}