import 'package:flutter/material.dart';
import '../models/activity_model.dart';

class ActivitySelector extends StatelessWidget {
  final List<String> selectedActivityIds;
  final Map<String, ActivityModel> allActivities;
  final Function(String) onActivityToggled;

  const ActivitySelector({
    super.key,
    required this.selectedActivityIds,
    required this.allActivities,
    required this.onActivityToggled,
  });

  @override
  Widget build(BuildContext context) {
    final activities = allActivities.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What did you do?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: activities.map((activity) {
            final isSelected = selectedActivityIds.contains(activity.id);
            return GestureDetector(
              onTap: () => onActivityToggled(activity.id),
              child: Chip(
                avatar: Text(
                  activity.icon,
                  style: const TextStyle(fontSize: 18),
                ),
                label: Text(activity.name),
                backgroundColor: isSelected
                    ? Color(activity.colorValue).withOpacity(0.3)
                    : Colors.grey[200],
                side: BorderSide(
                  color: isSelected
                      ? Color(activity.colorValue)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}