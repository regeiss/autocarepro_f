import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/repository_providers.dart';

/// Type of activity item in the recent activity feed
enum ActivityType { maintenance, reminder, document }

/// Unified activity item for the recent activity feed
class ActivityItem {
  final ActivityType type;
  final String id;
  final String title;
  final String subtitle;
  final int timestamp;
  final String? vehicleId;

  const ActivityItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.vehicleId,
  });
}

/// Provider for combined recent activity across maintenance, reminders, and documents
final recentActivityProvider = FutureProvider.family<List<ActivityItem>, int>((ref, limit) async {
  final maintenanceRepo = ref.watch(maintenanceRepositoryProvider);
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final documentRepo = ref.watch(documentRepositoryProvider);
  final vehicleRepo = ref.watch(vehicleRepositoryProvider);

  final results = await Future.wait([
    maintenanceRepo.getRecentRecords(limit: limit * 2),
    reminderRepo.getAllReminders(),
    documentRepo.getRecentDocuments(limit: limit * 2),
  ]);

  final maintenanceRecords = results[0] as List<MaintenanceRecord>;
  final reminders = results[1] as List<Reminder>;
  final documents = results[2] as List<Document>;

  // Get recent reminders sorted by createdAt
  reminders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final recentReminders = reminders.take(limit * 2).toList();

  final items = <ActivityItem>[];

  for (final record in maintenanceRecords) {
    final vehicle = await vehicleRepo.getVehicleById(record.vehicleId);
    final vehicleName = vehicle != null ? '${vehicle.year} ${vehicle.make} ${vehicle.model}' : 'Vehicle';
    items.add(ActivityItem(
      type: ActivityType.maintenance,
      id: record.id,
      title: record.serviceType,
      subtitle: vehicleName,
      timestamp: record.createdAt,
      vehicleId: record.vehicleId,
    ));
  }

  for (final reminder in recentReminders) {
    final vehicle = await vehicleRepo.getVehicleById(reminder.vehicleId);
    final vehicleName = vehicle != null ? '${vehicle.year} ${vehicle.make} ${vehicle.model}' : 'Vehicle';
    items.add(ActivityItem(
      type: ActivityType.reminder,
      id: reminder.id,
      title: '${reminder.serviceType} reminder',
      subtitle: vehicleName,
      timestamp: reminder.createdAt,
      vehicleId: reminder.vehicleId,
    ));
  }

  for (final doc in documents) {
    final vehicle = await vehicleRepo.getVehicleById(doc.vehicleId);
    final vehicleName = vehicle != null ? '${vehicle.year} ${vehicle.make} ${vehicle.model}' : 'Vehicle';
    items.add(ActivityItem(
      type: ActivityType.document,
      id: doc.id,
      title: doc.title ?? doc.documentType,
      subtitle: vehicleName,
      timestamp: doc.createdAt,
      vehicleId: doc.vehicleId,
    ));
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items.take(limit).toList();
});
