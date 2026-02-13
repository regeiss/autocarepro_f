// Reminder List Tile Widget - reusable list item for reminders
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';

class ReminderListTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;

  const ReminderListTile({
    super.key,
    required this.reminder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminderType = ReminderType.fromValue(reminder.reminderType);
    final intervalUnit = IntervalUnit.fromValue(reminder.intervalUnit);
    
    // Determine status
    final isOverdue = reminder.isOverdue();
    final isDueSoon = reminder.isDueSoon();
    final isDue = reminder.isDue;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'Overdue';
    } else if (isDue) {
      statusColor = Colors.orange;
      statusIcon = Icons.notification_important;
      statusText = 'Due Now';
    } else if (isDueSoon) {
      statusColor = Colors.amber;
      statusIcon = Icons.schedule;
      statusText = 'Due Soon';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Active';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Service Type and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Type Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getServiceTypeIcon(reminder.serviceType),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Service Type Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.serviceType,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getReminderTypeIcon(reminderType),
                              size: 16,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Every ${reminder.intervalValue} ${intervalUnit.displayName.toLowerCase()}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Due Date/Mileage Info
              Row(
                children: [
                  if (reminderType == ReminderType.time && reminder.nextReminderDate != null) ...[
                    Icon(
                      Icons.event,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDate(reminder.nextReminderDateAsDateTime!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else if (reminderType == ReminderType.mileage && reminder.nextReminderMileage != null) ...[
                    Icon(
                      Icons.speed,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due at: ${_formatNumber(reminder.nextReminderMileage!.toInt())} ${intervalUnit.displayName.toLowerCase()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Last Service Info
                  if (reminder.lastServiceDate != null || reminder.lastServiceMileage != null) ...[
                    Icon(
                      Icons.history,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last: ${_getLastServiceInfo(reminder, reminderType)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              // Notify Before Info
              if (reminder.notifyBefore > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Notify ${reminder.notifyBefore} ${reminderType == ReminderType.time ? 'days' : intervalUnit.displayName.toLowerCase()} before',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceTypeIcon(String serviceType) {
    final lowerType = serviceType.toLowerCase();
    if (lowerType.contains('oil')) return Icons.oil_barrel;
    if (lowerType.contains('tire')) return Icons.tire_repair;
    if (lowerType.contains('brake')) return Icons.motion_photos_pause;
    if (lowerType.contains('battery')) return Icons.battery_charging_full;
    if (lowerType.contains('filter')) return Icons.air;
    if (lowerType.contains('inspection')) return Icons.fact_check;
    if (lowerType.contains('registration')) return Icons.description;
    if (lowerType.contains('insurance')) return Icons.shield;
    return Icons.build;
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.time:
        return Icons.calendar_today;
      case ReminderType.mileage:
        return Icons.speed;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String _formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  String _getLastServiceInfo(Reminder reminder, ReminderType reminderType) {
    if (reminderType == ReminderType.time && reminder.lastServiceDate != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(reminder.lastServiceDate!);
      return DateFormat.yMMMd().format(date);
    } else if (reminderType == ReminderType.mileage && reminder.lastServiceMileage != null) {
      return _formatNumber(reminder.lastServiceMileage!.toInt());
    }
    return 'N/A';
  }
}
