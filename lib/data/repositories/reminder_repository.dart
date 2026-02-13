import '../models/reminder_model.dart';
import '../../services/local_database/app_database.dart';
import 'vehicle_repository.dart';

/// Repository for reminder data operations
/// 
/// This repository provides a clean API for reminder-related operations,
/// including time-based and mileage-based reminders, due detection, and activation management.
class ReminderRepository {
  final AppDatabase _database;

  ReminderRepository(this._database);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    try {
      return await _database.reminderDao.getAllReminders();
    } catch (e) {
      throw RepositoryException('Failed to get reminders: $e');
    }
  }

  /// Watch all reminders (reactive stream)
  Stream<List<Reminder>> watchAllReminders() {
    return _database.reminderDao.watchAllReminders();
  }

  /// Get a reminder by ID
  Future<Reminder?> getReminderById(String id) async {
    try {
      return await _database.reminderDao.getReminderById(id);
    } catch (e) {
      throw RepositoryException('Failed to get reminder: $e');
    }
  }

  /// Get reminders for a specific vehicle
  Future<List<Reminder>> getRemindersByVehicle(String vehicleId) async {
    try {
      return await _database.reminderDao.getRemindersByVehicleId(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to get reminders for vehicle: $e');
    }
  }

  /// Watch reminders for a specific vehicle (reactive stream)
  Stream<List<Reminder>> watchRemindersByVehicle(String vehicleId) {
    return _database.reminderDao.watchRemindersByVehicleId(vehicleId);
  }

  /// Get all active reminders
  Future<List<Reminder>> getActiveReminders() async {
    try {
      return await _database.reminderDao.getActiveReminders();
    } catch (e) {
      throw RepositoryException('Failed to get active reminders: $e');
    }
  }

  /// Watch active reminders (reactive stream)
  Stream<List<Reminder>> watchActiveReminders() {
    return _database.reminderDao.watchActiveReminders();
  }

  /// Get active reminders for a specific vehicle
  Future<List<Reminder>> getActiveRemindersByVehicle(String vehicleId) async {
    try {
      return await _database.reminderDao.getActiveRemindersByVehicleId(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to get active reminders for vehicle: $e');
    }
  }

  /// Get time-based reminders
  Future<List<Reminder>> getTimeBasedReminders() async {
    try {
      return await _database.reminderDao.getTimeBasedReminders();
    } catch (e) {
      throw RepositoryException('Failed to get time-based reminders: $e');
    }
  }

  /// Get mileage-based reminders
  Future<List<Reminder>> getMileageBasedReminders() async {
    try {
      return await _database.reminderDao.getMileageBasedReminders();
    } catch (e) {
      throw RepositoryException('Failed to get mileage-based reminders: $e');
    }
  }

  /// Get mileage-based reminders for a vehicle
  Future<List<Reminder>> getMileageBasedRemindersByVehicle(String vehicleId) async {
    try {
      return await _database.reminderDao.getMileageBasedRemindersByVehicle(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to get mileage reminders for vehicle: $e');
    }
  }

  /// Get due time-based reminders
  Future<List<Reminder>> getDueTimeReminders() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      return await _database.reminderDao.getDueTimeReminders(currentTime);
    } catch (e) {
      throw RepositoryException('Failed to get due reminders: $e');
    }
  }

  /// Get upcoming time-based reminders (due within X days)
  Future<List<Reminder>> getUpcomingTimeReminders({int daysAhead = 7}) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final futureTime = DateTime.now()
          .add(Duration(days: daysAhead))
          .millisecondsSinceEpoch;
      
      return await _database.reminderDao.getUpcomingTimeReminders(
        currentTime,
        futureTime,
      );
    } catch (e) {
      throw RepositoryException('Failed to get upcoming reminders: $e');
    }
  }

  /// Get reminders by service type
  Future<List<Reminder>> getRemindersByServiceType(String serviceType) async {
    try {
      return await _database.reminderDao.getRemindersByServiceType(serviceType);
    } catch (e) {
      throw RepositoryException('Failed to get reminders by service type: $e');
    }
  }

  /// Get count of active reminders
  Future<int> getActiveReminderCount() async {
    try {
      return await _database.reminderDao.getActiveReminderCount() ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get active reminder count: $e');
    }
  }

  /// Get count of active reminders for a vehicle
  Future<int> getActiveReminderCountByVehicle(String vehicleId) async {
    try {
      return await _database.reminderDao.getActiveReminderCountByVehicle(vehicleId) ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get reminder count for vehicle: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Add a new reminder
  Future<void> addReminder(Reminder reminder) async {
    try {
      // Validate before inserting
      final error = reminder.validate();
      if (error != null) {
        throw RepositoryException('Invalid reminder: $error');
      }
      
      await _database.reminderDao.insertReminder(reminder);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add reminder: $e');
    }
  }

  /// Add multiple reminders
  Future<void> addReminders(List<Reminder> reminders) async {
    try {
      // Validate all reminders
      for (final reminder in reminders) {
        final error = reminder.validate();
        if (error != null) {
          throw RepositoryException('Invalid reminder: $error');
        }
      }
      
      await _database.reminderDao.insertReminders(reminders);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add reminders: $e');
    }
  }

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    try {
      // Validate before updating
      final error = reminder.validate();
      if (error != null) {
        throw RepositoryException('Invalid reminder: $error');
      }

      // Check if reminder exists
      final existing = await getReminderById(reminder.id);
      if (existing == null) {
        throw RepositoryException('Reminder not found: ${reminder.id}');
      }
      
      await _database.reminderDao.updateReminder(reminder);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update reminder: $e');
    }
  }

  /// Activate a reminder
  Future<void> activateReminder(String id) async {
    try {
      // Check if reminder exists
      final existing = await getReminderById(id);
      if (existing == null) {
        throw RepositoryException('Reminder not found: $id');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _database.reminderDao.activateReminder(id, timestamp);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to activate reminder: $e');
    }
  }

  /// Deactivate a reminder
  Future<void> deactivateReminder(String id) async {
    try {
      // Check if reminder exists
      final existing = await getReminderById(id);
      if (existing == null) {
        throw RepositoryException('Reminder not found: $id');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _database.reminderDao.deactivateReminder(id, timestamp);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to deactivate reminder: $e');
    }
  }

  /// Toggle reminder active status
  Future<void> toggleReminderStatus(String id) async {
    try {
      final reminder = await getReminderById(id);
      if (reminder == null) {
        throw RepositoryException('Reminder not found: $id');
      }

      if (reminder.isActive) {
        await deactivateReminder(id);
      } else {
        await activateReminder(id);
      }
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to toggle reminder status: $e');
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a reminder
  Future<void> deleteReminder(Reminder reminder) async {
    try {
      await _database.reminderDao.deleteReminder(reminder);
    } catch (e) {
      throw RepositoryException('Failed to delete reminder: $e');
    }
  }

  /// Delete a reminder by ID
  Future<void> deleteReminderById(String id) async {
    try {
      // Check if reminder exists
      final existing = await getReminderById(id);
      if (existing == null) {
        throw RepositoryException('Reminder not found: $id');
      }

      await _database.reminderDao.deleteReminderById(id);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to delete reminder: $e');
    }
  }

  /// Delete all reminders for a vehicle
  Future<void> deleteRemindersByVehicle(String vehicleId) async {
    try {
      await _database.reminderDao.deleteRemindersByVehicleId(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to delete reminders for vehicle: $e');
    }
  }

  /// Delete all reminders
  Future<void> deleteAllReminders() async {
    try {
      await _database.reminderDao.deleteAllReminders();
    } catch (e) {
      throw RepositoryException('Failed to delete all reminders: $e');
    }
  }

  // ============================================================================
  // BUSINESS LOGIC METHODS
  // ============================================================================

  /// Get due mileage-based reminders for a vehicle
  Future<List<Reminder>> getDueMileageReminders(String vehicleId, double currentMileage) async {
    try {
      final mileageReminders = await getMileageBasedRemindersByVehicle(vehicleId);
      
      return mileageReminders.where((reminder) {
        return reminder.isDueMileage(currentMileage);
      }).toList();
    } catch (e) {
      throw RepositoryException('Failed to get due mileage reminders: $e');
    }
  }

  /// Get all due reminders for a vehicle (time and mileage)
  Future<List<Reminder>> getAllDueReminders(String vehicleId, double currentMileage) async {
    try {
      final reminders = await getActiveRemindersByVehicle(vehicleId);
      
      return reminders.where((reminder) {
        if (reminder.reminderType == 'time') {
          return reminder.isDue;
        } else {
          return reminder.isDueMileage(currentMileage);
        }
      }).toList();
    } catch (e) {
      throw RepositoryException('Failed to get all due reminders: $e');
    }
  }

  /// Get reminders that should notify soon
  Future<List<Reminder>> getRemindersNeedingNotification(
    String vehicleId,
    double currentMileage,
  ) async {
    try {
      final reminders = await getActiveRemindersByVehicle(vehicleId);
      
      return reminders.where((reminder) {
        if (reminder.reminderType == 'time') {
          return reminder.shouldNotifySoon;
        } else {
          return reminder.shouldNotifySoonMileage(currentMileage);
        }
      }).toList();
    } catch (e) {
      throw RepositoryException('Failed to get reminders needing notification: $e');
    }
  }

  /// Update reminder after service completion
  Future<void> updateReminderAfterService(
    String reminderId,
    DateTime serviceDate,
    double? serviceMileage,
  ) async {
    try {
      final reminder = await getReminderById(reminderId);
      if (reminder == null) {
        throw RepositoryException('Reminder not found: $reminderId');
      }

      final updated = reminder.updateAfterService(
        serviceDate: serviceDate,
        serviceMileage: serviceMileage,
      );

      await updateReminder(updated);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update reminder after service: $e');
    }
  }

  /// Get reminder summary for a vehicle
  Future<ReminderSummary> getVehicleSummary(String vehicleId, double currentMileage) async {
    try {
      final allReminders = await getRemindersByVehicle(vehicleId);
      final activeReminders = await getActiveRemindersByVehicle(vehicleId);
      final dueReminders = await getAllDueReminders(vehicleId, currentMileage);
      final upcomingReminders = await getRemindersNeedingNotification(vehicleId, currentMileage);

      return ReminderSummary(
        totalReminders: allReminders.length,
        activeReminders: activeReminders.length,
        dueReminders: dueReminders.length,
        upcomingReminders: upcomingReminders.length,
      );
    } catch (e) {
      throw RepositoryException('Failed to get reminder summary: $e');
    }
  }

  /// Check if vehicle has any active reminders
  Future<bool> vehicleHasActiveReminders(String vehicleId) async {
    final count = await getActiveReminderCountByVehicle(vehicleId);
    return count > 0;
  }

  /// Create default reminders for a new vehicle
  Future<void> createDefaultRemindersForVehicle(
    String vehicleId,
    double? currentMileage,
  ) async {
    try {
      final defaultReminders = <Reminder>[
        // Oil change reminder (every 5000 miles or 6 months)
        Reminder.create(
          vehicleId: vehicleId,
          serviceType: 'Oil Change',
          reminderType: currentMileage != null 
              ? ReminderType.mileage 
              : ReminderType.time,
          intervalValue: currentMileage != null ? 5000 : 6,
          intervalUnit: currentMileage != null 
              ? IntervalUnit.miles 
              : IntervalUnit.months,
          lastServiceMileage: currentMileage,
        ),
        // Tire rotation (every 6000 miles or 6 months)
        Reminder.create(
          vehicleId: vehicleId,
          serviceType: 'Tire Rotation',
          reminderType: currentMileage != null 
              ? ReminderType.mileage 
              : ReminderType.time,
          intervalValue: currentMileage != null ? 6000 : 6,
          intervalUnit: currentMileage != null 
              ? IntervalUnit.miles 
              : IntervalUnit.months,
          lastServiceMileage: currentMileage,
        ),
      ];

      await addReminders(defaultReminders);
    } catch (e) {
      throw RepositoryException('Failed to create default reminders: $e');
    }
  }
}

/// Reminder summary data class
class ReminderSummary {
  final int totalReminders;
  final int activeReminders;
  final int dueReminders;
  final int upcomingReminders;

  ReminderSummary({
    required this.totalReminders,
    required this.activeReminders,
    required this.dueReminders,
    required this.upcomingReminders,
  });

  @override
  String toString() {
    return 'ReminderSummary(total: $totalReminders, active: $activeReminders, due: $dueReminders, upcoming: $upcomingReminders)';
  }
}
