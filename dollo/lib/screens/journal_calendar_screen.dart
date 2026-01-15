import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/mood_model.dart';
import 'entry_detail_screen.dart';

class JournalCalendarScreen extends StatefulWidget {
  const JournalCalendarScreen({super.key});

  @override
  State<JournalCalendarScreen> createState() => _JournalCalendarScreenState();
}

class _JournalCalendarScreenState extends State<JournalCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, _) {
        return Column(
          children: [
            // Calendar
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, journalProvider);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, journalProvider, isToday: true);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, journalProvider, isSelected: true);
                },
              ),
            ),

            const Divider(),

            // Entries for selected day
            Expanded(
              child: _buildEntriesForSelectedDay(journalProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayCell(DateTime day, JournalProvider provider, {bool isToday = false, bool isSelected = false}) {
    final mood = provider.getMoodForDate(day);
    final moodData = mood != null ? MoodData.getMoodData(mood) : null;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : isToday
                ? Colors.blue[50]
                : null,
        border: Border.all(
          color: isToday ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (moodData != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: Text(
                moodData.emoji,
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntriesForSelectedDay(JournalProvider provider) {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          'Select a day to see entries',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final entries = provider.getEntriesForDate(_selectedDay!);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No entries for ${DateFormat('MMM d').format(_selectedDay!)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final moodData = MoodData.getMoodData(entry.mood);
        final activities = entry.activityIds
            .map((id) => provider.activities[id])
            .where((a) => a != null)
            .toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(
              moodData.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            title: Row(
              children: [
                Text(moodData.label),
                const SizedBox(width: 8),
                Text(
                  entry.formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            subtitle: activities.isNotEmpty
                ? Wrap(
                    spacing: 4,
                    children: activities.take(3).map((activity) {
                      return Text('${activity!.icon} ', style: const TextStyle(fontSize: 14));
                    }).toList(),
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntryDetailScreen(entry: entry),
                ),
              );
            },
          ),
        );
      },
    );
  }
}