import 'package:floor/floor.dart';
import '../../../data/models/reminder_model.dart';

/// Data Access Object for Reminder operations
@dao
abstract class ReminderDao {
  /// Get all reminders ordered by creation date
  @Query('SELECT * FROM reminders ORDER BY createdAt DESC')
  Future<List<Reminder>> getAllReminders();

  /// Get all reminders as a stream
  @Query('SELECT * FROM reminders ORDER BY createdAt DESC')
  Stream<List<Reminder>> watchAllReminders();

  /// Get a reminder by ID
  @Query('SELECT * FROM reminders WHERE id = :id')
  Future<Reminder?> getReminderById(String id);

  /// Get reminders by vehicle ID
  @Query('SELECT * FROM reminders WHERE vehicleId = :vehicleId ORDER BY createdAt DESC')
  Future<List<Reminder>> getRemindersByVehicleId(String vehicleId);

  /// Get reminders by vehicle ID as a stream
  @Query('SELECT * FROM reminders WHERE vehicleId = :vehicleId ORDER BY createdAt DESC')
  Stream<List<Reminder>> watchRemindersByVehicleId(String vehicleId);

  /// Get all active reminders
  @Query('SELECT * FROM reminders WHERE isActive = 1 ORDER BY createdAt DESC')
  Future<List<Reminder>> getActiveReminders();

  /// Get active reminders as a stream
  @Query('SELECT * FROM reminders WHERE isActive = 1 ORDER BY createdAt DESC')
  Stream<List<Reminder>> watchActiveReminders();

  /// Get active reminders by vehicle ID
  @Query('SELECT * FROM reminders WHERE vehicleId = :vehicleId AND isActive = 1 ORDER BY createdAt DESC')
  Future<List<Reminder>> getActiveRemindersByVehicleId(String vehicleId);

  /// Get time-based reminders
  @Query('SELECT * FROM reminders WHERE reminderType = "time" AND isActive = 1 ORDER BY nextReminderDate ASC')
  Future<List<Reminder>> getTimeBasedReminders();

  /// Get mileage-based reminders
  @Query('SELECT * FROM reminders WHERE reminderType = "mileage" AND isActive = 1 ORDER BY nextReminderMileage ASC')
  Future<List<Reminder>> getMileageBasedReminders();

  /// Get mileage-based reminders by vehicle
  @Query('''
    SELECT * FROM reminders 
    WHERE vehicleId = :vehicleId 
    AND reminderType = "mileage" 
    AND isActive = 1 
    ORDER BY nextReminderMileage ASC
  ''')
  Future<List<Reminder>> getMileageBasedRemindersByVehicle(String vehicleId);

  /// Get due time-based reminders (nextReminderDate is in the past)
  @Query('''
    SELECT * FROM reminders 
    WHERE reminderType = "time" 
    AND isActive = 1 
    AND nextReminderDate IS NOT NULL 
    AND nextReminderDate <= :currentTime
    ORDER BY nextReminderDate ASC
  ''')
  Future<List<Reminder>> getDueTimeReminders(int currentTime);

  /// Get upcoming time-based reminders (due within X days)
  @Query('''
    SELECT * FROM reminders 
    WHERE reminderType = "time" 
    AND isActive = 1 
    AND nextReminderDate IS NOT NULL 
    AND nextReminderDate BETWEEN :currentTime AND :futureTime
    ORDER BY nextReminderDate ASC
  ''')
  Future<List<Reminder>> getUpcomingTimeReminders(int currentTime, int futureTime);

  /// Get reminders by service type
  @Query('SELECT * FROM reminders WHERE serviceType = :serviceType ORDER BY createdAt DESC')
  Future<List<Reminder>> getRemindersByServiceType(String serviceType);

  /// Get count of active reminders
  @Query('SELECT COUNT(*) FROM reminders WHERE isActive = 1')
  Future<int?> getActiveReminderCount();

  /// Get count of active reminders by vehicle
  @Query('SELECT COUNT(*) FROM reminders WHERE vehicleId = :vehicleId AND isActive = 1')
  Future<int?> getActiveReminderCountByVehicle(String vehicleId);

  /// Insert a new reminder
  @insert
  Future<void> insertReminder(Reminder reminder);

  /// Insert multiple reminders
  @insert
  Future<void> insertReminders(List<Reminder> reminders);

  /// Update an existing reminder
  @update
  Future<void> updateReminder(Reminder reminder);

  /// Activate a reminder
  @Query('UPDATE reminders SET isActive = 1, updatedAt = :timestamp WHERE id = :id')
  Future<void> activateReminder(String id, int timestamp);

  /// Deactivate a reminder
  @Query('UPDATE reminders SET isActive = 0, updatedAt = :timestamp WHERE id = :id')
  Future<void> deactivateReminder(String id, int timestamp);

  /// Update next reminder date
  @Query('UPDATE reminders SET nextReminderDate = :nextDate, updatedAt = :timestamp WHERE id = :id')
  Future<void> updateNextReminderDate(String id, int nextDate, int timestamp);

  /// Update next reminder mileage
  @Query('UPDATE reminders SET nextReminderMileage = :nextMileage, updatedAt = :timestamp WHERE id = :id')
  Future<void> updateNextReminderMileage(String id, double nextMileage, int timestamp);

  /// Delete a reminder
  @delete
  Future<void> deleteReminder(Reminder reminder);

  /// Delete reminder by ID
  @Query('DELETE FROM reminders WHERE id = :id')
  Future<void> deleteReminderById(String id);

  /// Delete all reminders for a vehicle
  @Query('DELETE FROM reminders WHERE vehicleId = :vehicleId')
  Future<void> deleteRemindersByVehicleId(String vehicleId);

  /// Delete all reminders
  @Query('DELETE FROM reminders')
  Future<void> deleteAllReminders();
}
