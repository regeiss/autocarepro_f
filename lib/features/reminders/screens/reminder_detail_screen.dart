// Reminder Detail Screen - view full reminder details
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/reminder_providers.dart';
import '../../../data/providers/repository_providers.dart';
import 'reminder_form_screen.dart';

class ReminderDetailScreen extends ConsumerWidget {
  final String reminderId;

  const ReminderDetailScreen({
    super.key,
    required this.reminderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(reminderDetailProvider(reminderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Details'),
        actions: [
          reminderAsync.when(
            data: (reminder) {
              if (reminder == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEdit(context, reminder);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref, reminder);
                  } else if (value == 'toggle') {
                    _toggleActive(context, ref, reminder);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(reminder.isActive ? Icons.pause : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(reminder.isActive ? 'Pause' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: reminderAsync.when(
        data: (reminder) {
          if (reminder == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Reminder not found'),
                ],
              ),
            );
          }
          return _buildContent(context, reminder);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(reminderDetailProvider(reminderId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Reminder reminder) {
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
    
    if (!reminder.isActive) {
      statusColor = Colors.grey;
      statusIcon = Icons.pause_circle;
      statusText = 'Paused';
    } else if (isOverdue) {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      reminder.serviceType,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reminder Details Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailTile(
                  icon: reminderType == ReminderType.time ? Icons.calendar_today : Icons.speed,
                  label: 'Type',
                  value: reminderType.displayName,
                ),
                _DetailTile(
                  icon: Icons.event_repeat,
                  label: 'Frequency',
                  value: 'Every ${reminder.intervalValue} ${intervalUnit.displayName.toLowerCase()}',
                ),
                _DetailTile(
                  icon: Icons.notifications_active,
                  label: 'Notify Before',
                  value: '${reminder.notifyBefore} ${reminderType == ReminderType.time ? 'days' : intervalUnit.displayName.toLowerCase()}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Next Due Card
        if (reminder.nextReminderDate != null || reminder.nextReminderMileage != null)
          Card(
            color: statusColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    reminderType == ReminderType.time ? Icons.event : Icons.speed,
                    color: statusColor,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Next Service Due',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (reminderType == ReminderType.time && reminder.nextReminderDate != null)
                    Text(
                      DateFormat.yMMMd().format(reminder.nextReminderDateAsDateTime!),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    )
                  else if (reminderType == ReminderType.mileage && reminder.nextReminderMileage != null)
                    Text(
                      '${NumberFormat('#,###').format(reminder.nextReminderMileage!.toInt())} ${intervalUnit.displayName.toLowerCase()}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Last Service Card
        if (reminder.lastServiceDate != null || reminder.lastServiceMileage != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 8),
                      Text(
                        'Last Service',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (reminderType == ReminderType.time && reminder.lastServiceDate != null)
                    _DetailTile(
                      icon: Icons.event,
                      label: 'Date',
                      value: DateFormat.yMMMd().format(
                        DateTime.fromMillisecondsSinceEpoch(reminder.lastServiceDate!),
                      ),
                    )
                  else if (reminderType == ReminderType.mileage && reminder.lastServiceMileage != null)
                    _DetailTile(
                      icon: Icons.speed,
                      label: 'Mileage',
                      value: '${NumberFormat('#,###').format(reminder.lastServiceMileage!.toInt())} ${intervalUnit.displayName.toLowerCase()}',
                    ),
                ],
              ),
            ),
          ),

        // Metadata Card
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Info',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(reminder.createdAt))}',
                  style: theme.textTheme.bodySmall,
                ),
                if (reminder.updatedAt != reminder.createdAt)
                  Text(
                    'Updated: ${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(reminder.updatedAt))}',
                    style: theme.textTheme.bodySmall,
                  ),
                Text(
                  'Status: ${reminder.isActive ? 'Active' : 'Paused'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  void _navigateToEdit(BuildContext context, Reminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReminderFormScreen(
          vehicleId: reminder.vehicleId,
          reminder: reminder,
        ),
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, Reminder reminder) async {
    try {
      final repository = ref.read(reminderRepositoryProvider);
      final updated = Reminder(
        id: reminder.id,
        vehicleId: reminder.vehicleId,
        serviceType: reminder.serviceType,
        reminderType: reminder.reminderType,
        intervalValue: reminder.intervalValue,
        intervalUnit: reminder.intervalUnit,
        lastServiceDate: reminder.lastServiceDate,
        lastServiceMileage: reminder.lastServiceMileage,
        nextReminderDate: reminder.nextReminderDate,
        nextReminderMileage: reminder.nextReminderMileage,
        isActive: !reminder.isActive,
        notifyBefore: reminder.notifyBefore,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await repository.updateReminder(updated);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updated.isActive ? 'Reminder activated' : 'Reminder paused'),
          ),
        );
        // Refresh the detail view
        ref.invalidate(reminderDetailProvider(reminder.id));
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update reminder: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(reminderRepositoryProvider);
        await repository.deleteReminderById(reminder.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
