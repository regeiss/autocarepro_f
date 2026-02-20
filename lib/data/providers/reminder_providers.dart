// Riverpod providers for reminders
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'profile_providers.dart';
import 'repository_providers.dart';

// ============================================================================
// List Providers
// ============================================================================

/// Provider for all active reminders of a specific vehicle
final remindersListProvider = FutureProvider.family<List<Reminder>, String>((ref, vehicleId) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return await repository.getActiveRemindersByVehicle(vehicleId);
});

/// Stream provider for real-time reminder updates
final remindersStreamProvider = StreamProvider.family<List<Reminder>, String>((ref, vehicleId) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.watchRemindersByVehicle(vehicleId);
});

/// Provider for upcoming reminders (profile-scoped)
final upcomingRemindersProvider = FutureProvider.family<List<Reminder>, int>((ref, limit) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return [];
  final vehicleRepo = ref.watch(vehicleRepositoryProvider);
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final vehicles = await vehicleRepo.getVehiclesByProfile(profileId);
  final vehicleIds = vehicles.map((v) => v.id).toSet();
  final reminders = await reminderRepo.getUpcomingTimeReminders(daysAhead: limit * 7);
  return reminders.where((r) => vehicleIds.contains(r.vehicleId)).take(limit).toList();
});

/// Provider for all active reminders across all vehicles
final allActiveRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return await repository.getActiveReminders();
});

/// Provider for recently created reminders across all vehicles
final recentRemindersProvider = FutureProvider.family<List<Reminder>, int>((ref, limit) async {
  final repository = ref.watch(reminderRepositoryProvider);
  final reminders = await repository.getAllReminders();
  reminders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return reminders.take(limit).toList();
});

// ============================================================================
// Single Reminder Providers
// ============================================================================

/// Provider for a single reminder by ID
final reminderDetailProvider = FutureProvider.family<Reminder?, String>((ref, id) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return await repository.getReminderById(id);
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for reminder count for a vehicle
final reminderCountProvider = FutureProvider.family<int, String>((ref, vehicleId) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return await repository.getActiveReminderCountByVehicle(vehicleId);
});

/// Provider for total active reminders count
final totalActiveRemindersCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return await repository.getActiveReminderCount();
});

// ============================================================================
// UI State Providers
// ============================================================================

/// State provider for selected reminder (for editing)
final selectedReminderProvider = StateProvider<Reminder?>((ref) => null);

/// State provider for reminder filter (all, due soon, overdue, active, inactive)
enum ReminderFilter { all, dueSoon, overdue, active, inactive }

final reminderFilterProvider = StateProvider<ReminderFilter>((ref) => ReminderFilter.all);
