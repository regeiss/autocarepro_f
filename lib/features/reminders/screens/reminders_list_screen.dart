// Reminders List Screen - displays all reminders for a vehicle
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/reminder_providers.dart';
import '../widgets/reminder_list_tile.dart';
import '../../dashboard/widgets/empty_state.dart';
import 'reminder_form_screen.dart';
import 'reminder_detail_screen.dart';

class RemindersListScreen extends ConsumerWidget {
  final String vehicleId;

  const RemindersListScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersStreamProvider(vehicleId));
    final filter = ref.watch(reminderFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          PopupMenuButton<ReminderFilter>(
            icon: Icon(
              filter != ReminderFilter.all ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filter reminders',
            onSelected: (value) {
              ref.read(reminderFilterProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ReminderFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ReminderFilter.dueSoon,
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Due Soon'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ReminderFilter.overdue,
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Overdue'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: remindersAsync.when(
        data: (reminders) {
          // Apply filter
          var filteredReminders = reminders;
          switch (filter) {
            case ReminderFilter.dueSoon:
              filteredReminders = reminders.where((r) => r.isDueSoon()).toList();
              break;
            case ReminderFilter.overdue:
              filteredReminders = reminders.where((r) => r.isOverdue()).toList();
              break;
            case ReminderFilter.active:
              filteredReminders = reminders.where((r) => r.isActive).toList();
              break;
            case ReminderFilter.inactive:
              filteredReminders = reminders.where((r) => !r.isActive).toList();
              break;
            case ReminderFilter.all:
              break;
          }

          if (filteredReminders.isEmpty && reminders.isNotEmpty) {
            return EmptyState(
              icon: Icons.filter_alt_off,
              title: 'No reminders match filter',
              message: 'Try adjusting your filter selection',
              actionLabel: 'Clear Filter',
              onAction: () {
                ref.read(reminderFilterProvider.notifier).state = ReminderFilter.all;
              },
            );
          }

          if (filteredReminders.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none,
              title: 'No Reminders Set',
              message: 'Create reminders to track maintenance schedules',
              actionLabel: 'Add Reminder',
              onAction: () => _navigateToAddReminder(context),
            );
          }

          // Sort by due date/mileage
          filteredReminders.sort((a, b) {
            if (a.nextReminderDate != null && b.nextReminderDate != null) {
              return a.nextReminderDate!.compareTo(b.nextReminderDate!);
            }
            return 0;
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(remindersStreamProvider(vehicleId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredReminders.length,
              itemBuilder: (context, index) {
                final reminder = filteredReminders[index];
                return ReminderListTile(
                  reminder: reminder,
                  onTap: () => _navigateToDetail(context, reminder.id),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(remindersStreamProvider(vehicleId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddReminder(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }

  void _navigateToAddReminder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReminderFormScreen(
          vehicleId: vehicleId,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String reminderId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReminderDetailScreen(
          reminderId: reminderId,
        ),
      ),
    );
  }
}
