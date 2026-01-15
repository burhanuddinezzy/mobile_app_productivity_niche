import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../models/mood_model.dart';

class YearInPixelsScreen extends StatefulWidget {
  const YearInPixelsScreen({super.key});

  @override
  State<YearInPixelsScreen> createState() => _YearInPixelsScreenState();
}

class _YearInPixelsScreenState extends State<YearInPixelsScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Year in Pixels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedYear--;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '$_selectedYear',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedYear++;
              });
            },
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, _) {
          return Column(
            children: [
              // Legend
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildLegend(),
              ),
              
              const Divider(),
              
              // Pixel grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildPixelGrid(journalProvider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: MoodData.allMoods.map((moodData) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getMoodColor(moodData.type),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Text(moodData.label, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList()
        ..add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              const Text('No entry', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
    );
  }

  Widget _buildPixelGrid(JournalProvider provider) {
    final startDate = DateTime(_selectedYear, 1, 1);
    final endDate = DateTime(_selectedYear, 12, 31);
    final days = endDate.difference(startDate).inDays + 1;

    // Group by month
    final monthlyDays = <int, List<DateTime>>{};
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      monthlyDays.putIfAbsent(date.month, () => []).add(date);
    }

    return Column(
      children: monthlyDays.entries.map((entry) {
        final month = entry.key;
        final daysInMonth = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month label
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _getMonthName(month),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Days in month
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: daysInMonth.map((date) {
                final mood = provider.getMoodForDate(date);
                final color = mood != null ? _getMoodColor(mood) : Colors.grey[300]!;
                final isToday = _isToday(date);

                return GestureDetector(
                  onTap: () => _showDayDetails(context, date, mood, provider),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      border: isToday
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showDayDetails(BuildContext context, DateTime date, MoodType? mood, JournalProvider provider) {
    final entries = provider.getEntriesForDate(date);
    final dateStr = '${_getMonthName(date.month)} ${date.day}, ${date.year}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dateStr),
        content: entries.isEmpty
            ? const Text('No entries for this day')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mood != null) ...[
                    Text(
                      'Mood: ${MoodData.getMoodData(mood).label}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text('${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}'),
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
}