import 'package:floor/floor.dart';
import '../../../data/models/maintenance_record_model.dart';

/// Data Access Object for MaintenanceRecord operations
@dao
abstract class MaintenanceRecordDao {
  /// Get all maintenance records ordered by service date (newest first)
  @Query('SELECT * FROM maintenance_records ORDER BY serviceDate DESC')
  Future<List<MaintenanceRecord>> getAllRecords();

  /// Get all maintenance records as a stream
  @Query('SELECT * FROM maintenance_records ORDER BY serviceDate DESC')
  Stream<List<MaintenanceRecord>> watchAllRecords();

  /// Get a maintenance record by ID
  @Query('SELECT * FROM maintenance_records WHERE id = :id')
  Future<MaintenanceRecord?> getRecordById(String id);

  /// Get maintenance records by vehicle ID
  @Query('SELECT * FROM maintenance_records WHERE vehicleId = :vehicleId ORDER BY serviceDate DESC')
  Future<List<MaintenanceRecord>> getRecordsByVehicleId(String vehicleId);

  /// Get maintenance records by vehicle ID as a stream
  @Query('SELECT * FROM maintenance_records WHERE vehicleId = :vehicleId ORDER BY serviceDate DESC')
  Stream<List<MaintenanceRecord>> watchRecordsByVehicleId(String vehicleId);

  /// Get recent maintenance records (last N records)
  @Query('SELECT * FROM maintenance_records ORDER BY serviceDate DESC LIMIT :limit')
  Future<List<MaintenanceRecord>> getRecentRecords(int limit);

  /// Get maintenance records by service type
  @Query('SELECT * FROM maintenance_records WHERE serviceType = :serviceType ORDER BY serviceDate DESC')
  Future<List<MaintenanceRecord>> getRecordsByServiceType(String serviceType);

  /// Get maintenance records by date range
  @Query('''
    SELECT * FROM maintenance_records 
    WHERE serviceDate BETWEEN :startDate AND :endDate
    ORDER BY serviceDate DESC
  ''')
  Future<List<MaintenanceRecord>> getRecordsByDateRange(int startDate, int endDate);

  /// Get maintenance records by vehicle and date range
  @Query('''
    SELECT * FROM maintenance_records 
    WHERE vehicleId = :vehicleId 
    AND serviceDate BETWEEN :startDate AND :endDate
    ORDER BY serviceDate DESC
  ''')
  Future<List<MaintenanceRecord>> getRecordsByVehicleAndDateRange(
    String vehicleId,
    int startDate,
    int endDate,
  );

  /// Get total cost for a vehicle
  @Query('SELECT SUM(cost) FROM maintenance_records WHERE vehicleId = :vehicleId')
  Future<double?> getTotalCostByVehicle(String vehicleId);

  /// Get total cost for all vehicles
  @Query('SELECT SUM(cost) FROM maintenance_records')
  Future<double?> getTotalCost();

  /// Get total cost by date range
  @Query('''
    SELECT SUM(cost) FROM maintenance_records 
    WHERE serviceDate BETWEEN :startDate AND :endDate
  ''')
  Future<double?> getTotalCostByDateRange(int startDate, int endDate);

  /// Get count of maintenance records by vehicle
  @Query('SELECT COUNT(*) FROM maintenance_records WHERE vehicleId = :vehicleId')
  Future<int?> getRecordCountByVehicle(String vehicleId);

  /// Get latest maintenance record for a vehicle
  @Query('''
    SELECT * FROM maintenance_records 
    WHERE vehicleId = :vehicleId 
    ORDER BY serviceDate DESC 
    LIMIT 1
  ''')
  Future<MaintenanceRecord?> getLatestRecordByVehicle(String vehicleId);

  /// Get upcoming service due (records with nextServiceDue)
  @Query('''
    SELECT * FROM maintenance_records 
    WHERE nextServiceDue IS NOT NULL 
    AND nextServiceDue > 0
    ORDER BY nextServiceDue ASC
  ''')
  Future<List<MaintenanceRecord>> getUpcomingServices();

  /// Get overdue services (nextServiceDue in the past)
  @Query('''
    SELECT * FROM maintenance_records 
    WHERE nextServiceDue IS NOT NULL 
    AND nextServiceDue < :currentTime
    ORDER BY nextServiceDue ASC
  ''')
  Future<List<MaintenanceRecord>> getOverdueServices(int currentTime);

  /// Insert a new maintenance record
  @insert
  Future<void> insertRecord(MaintenanceRecord record);

  /// Insert multiple maintenance records
  @insert
  Future<void> insertRecords(List<MaintenanceRecord> records);

  /// Update an existing maintenance record
  @update
  Future<void> updateRecord(MaintenanceRecord record);

  /// Delete a maintenance record
  @delete
  Future<void> deleteRecord(MaintenanceRecord record);

  /// Delete maintenance record by ID
  @Query('DELETE FROM maintenance_records WHERE id = :id')
  Future<void> deleteRecordById(String id);

  /// Delete all maintenance records for a vehicle
  @Query('DELETE FROM maintenance_records WHERE vehicleId = :vehicleId')
  Future<void> deleteRecordsByVehicleId(String vehicleId);

  /// Delete all maintenance records
  @Query('DELETE FROM maintenance_records')
  Future<void> deleteAllRecords();
}
