import '../models/maintenance_record_model.dart';
import '../../services/local_database/app_database.dart';
import 'vehicle_repository.dart';

/// Repository for maintenance record data operations
/// 
/// This repository provides a clean API for maintenance-related operations,
/// including service history, cost tracking, and due service management.
class MaintenanceRepository {
  final AppDatabase _database;

  MaintenanceRepository(this._database);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all maintenance records
  Future<List<MaintenanceRecord>> getAllRecords() async {
    try {
      return await _database.maintenanceRecordDao.getAllRecords();
    } catch (e) {
      throw RepositoryException('Failed to get maintenance records: $e');
    }
  }

  /// Watch all maintenance records (reactive stream)
  Stream<List<MaintenanceRecord>> watchAllRecords() {
    return _database.maintenanceRecordDao.watchAllRecords();
  }

  /// Get a maintenance record by ID
  Future<MaintenanceRecord?> getRecordById(String id) async {
    try {
      return await _database.maintenanceRecordDao.getRecordById(id);
    } catch (e) {
      throw RepositoryException('Failed to get maintenance record: $e');
    }
  }

  /// Get maintenance records for a specific vehicle
  Future<List<MaintenanceRecord>> getRecordsByVehicle(String vehicleId) async {
    try {
      return await _database.maintenanceRecordDao.getRecordsByVehicleId(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to get maintenance records for vehicle: $e');
    }
  }

  /// Watch maintenance records for a specific vehicle (reactive stream)
  Stream<List<MaintenanceRecord>> watchRecordsByVehicle(String vehicleId) {
    return _database.maintenanceRecordDao.watchRecordsByVehicleId(vehicleId);
  }

  /// Get recent maintenance records
  Future<List<MaintenanceRecord>> getRecentRecords({int limit = 10}) async {
    try {
      return await _database.maintenanceRecordDao.getRecentRecords(limit);
    } catch (e) {
      throw RepositoryException('Failed to get recent records: $e');
    }
  }

  /// Get maintenance records by service type
  Future<List<MaintenanceRecord>> getRecordsByServiceType(String serviceType) async {
    try {
      return await _database.maintenanceRecordDao.getRecordsByServiceType(serviceType);
    } catch (e) {
      throw RepositoryException('Failed to get records by service type: $e');
    }
  }

  /// Get maintenance records by date range
  Future<List<MaintenanceRecord>> getRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (startDate.isAfter(endDate)) {
        throw RepositoryException('Start date must be before or equal to end date');
      }

      return await _database.maintenanceRecordDao.getRecordsByDateRange(
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to get records by date range: $e');
    }
  }

  /// Get maintenance records for a vehicle within a date range
  Future<List<MaintenanceRecord>> getRecordsByVehicleAndDateRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (startDate.isAfter(endDate)) {
        throw RepositoryException('Start date must be before or equal to end date');
      }

      return await _database.maintenanceRecordDao.getRecordsByVehicleAndDateRange(
        vehicleId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to get records: $e');
    }
  }

  /// Get the latest maintenance record for a vehicle
  Future<MaintenanceRecord?> getLatestRecordForVehicle(String vehicleId) async {
    try {
      return await _database.maintenanceRecordDao.getLatestRecordByVehicle(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to get latest record: $e');
    }
  }

  /// Get upcoming service due records
  Future<List<MaintenanceRecord>> getUpcomingServices() async {
    try {
      return await _database.maintenanceRecordDao.getUpcomingServices();
    } catch (e) {
      throw RepositoryException('Failed to get upcoming services: $e');
    }
  }

  /// Get overdue services
  Future<List<MaintenanceRecord>> getOverdueServices() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      return await _database.maintenanceRecordDao.getOverdueServices(currentTime);
    } catch (e) {
      throw RepositoryException('Failed to get overdue services: $e');
    }
  }

  // ============================================================================
  // COST ANALYTICS
  // ============================================================================

  /// Get total cost for a vehicle
  Future<double> getTotalCostByVehicle(String vehicleId) async {
    try {
      return await _database.maintenanceRecordDao.getTotalCostByVehicle(vehicleId) ?? 0.0;
    } catch (e) {
      throw RepositoryException('Failed to get total cost: $e');
    }
  }

  /// Get total cost across all vehicles
  Future<double> getTotalCost() async {
    try {
      return await _database.maintenanceRecordDao.getTotalCost() ?? 0.0;
    } catch (e) {
      throw RepositoryException('Failed to get total cost: $e');
    }
  }

  /// Get total cost by date range
  Future<double> getTotalCostByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      if (startDate.isAfter(endDate)) {
        throw RepositoryException('Start date must be before or equal to end date');
      }

      return await _database.maintenanceRecordDao.getTotalCostByDateRange(
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ) ?? 0.0;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to get cost by date range: $e');
    }
  }

  /// Get record count for a vehicle
  Future<int> getRecordCountByVehicle(String vehicleId) async {
    try {
      return await _database.maintenanceRecordDao.getRecordCountByVehicle(vehicleId) ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get record count: $e');
    }
  }

  /// Get average cost per service for a vehicle
  Future<double> getAverageCostByVehicle(String vehicleId) async {
    try {
      final totalCost = await getTotalCostByVehicle(vehicleId);
      final count = await getRecordCountByVehicle(vehicleId);
      
      if (count == 0) return 0.0;
      return totalCost / count;
    } catch (e) {
      throw RepositoryException('Failed to calculate average cost: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Add a new maintenance record
  Future<void> addRecord(MaintenanceRecord record) async {
    try {
      // Validate before inserting
      final error = record.validate();
      if (error != null) {
        throw RepositoryException('Invalid maintenance record: $error');
      }
      
      await _database.maintenanceRecordDao.insertRecord(record);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add maintenance record: $e');
    }
  }

  /// Add multiple maintenance records
  Future<void> addRecords(List<MaintenanceRecord> records) async {
    try {
      // Validate all records
      for (final record in records) {
        final error = record.validate();
        if (error != null) {
          throw RepositoryException('Invalid maintenance record: $error');
        }
      }
      
      await _database.maintenanceRecordDao.insertRecords(records);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add maintenance records: $e');
    }
  }

  /// Update an existing maintenance record
  Future<void> updateRecord(MaintenanceRecord record) async {
    try {
      // Validate before updating
      final error = record.validate();
      if (error != null) {
        throw RepositoryException('Invalid maintenance record: $error');
      }

      // Check if record exists
      final existing = await getRecordById(record.id);
      if (existing == null) {
        throw RepositoryException('Maintenance record not found: ${record.id}');
      }
      
      await _database.maintenanceRecordDao.updateRecord(record);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update maintenance record: $e');
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a maintenance record
  Future<void> deleteRecord(MaintenanceRecord record) async {
    try {
      await _database.maintenanceRecordDao.deleteRecord(record);
    } catch (e) {
      throw RepositoryException('Failed to delete maintenance record: $e');
    }
  }

  /// Delete a maintenance record by ID
  Future<void> deleteRecordById(String id) async {
    try {
      // Check if record exists
      final existing = await getRecordById(id);
      if (existing == null) {
        throw RepositoryException('Maintenance record not found: $id');
      }

      await _database.maintenanceRecordDao.deleteRecordById(id);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to delete maintenance record: $e');
    }
  }

  /// Delete all maintenance records for a vehicle
  Future<void> deleteRecordsByVehicle(String vehicleId) async {
    try {
      await _database.maintenanceRecordDao.deleteRecordsByVehicleId(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to delete records for vehicle: $e');
    }
  }

  /// Delete all maintenance records
  Future<void> deleteAllRecords() async {
    try {
      await _database.maintenanceRecordDao.deleteAllRecords();
    } catch (e) {
      throw RepositoryException('Failed to delete all records: $e');
    }
  }

  // ============================================================================
  // BUSINESS LOGIC METHODS
  // ============================================================================

  /// Get maintenance summary for a vehicle
  Future<MaintenanceSummary> getVehicleSummary(String vehicleId) async {
    try {
      final records = await getRecordsByVehicle(vehicleId);
      final totalCost = await getTotalCostByVehicle(vehicleId);
      final latestRecord = await getLatestRecordForVehicle(vehicleId);

      return MaintenanceSummary(
        totalRecords: records.length,
        totalCost: totalCost,
        averageCost: records.isNotEmpty ? totalCost / records.length : 0.0,
        lastServiceDate: latestRecord?.serviceDateAsDateTime,
        lastServiceType: latestRecord?.serviceType,
      );
    } catch (e) {
      throw RepositoryException('Failed to get maintenance summary: $e');
    }
  }

  /// Get records for the current month
  Future<List<MaintenanceRecord>> getRecordsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return await getRecordsByDateRange(startOfMonth, endOfMonth);
  }

  /// Get records for the current year
  Future<List<MaintenanceRecord>> getRecordsThisYear() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return await getRecordsByDateRange(startOfYear, endOfYear);
  }

  /// Get cost for the current month
  Future<double> getCostThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return await getTotalCostByDateRange(startOfMonth, endOfMonth);
  }

  /// Get cost for the current year
  Future<double> getCostThisYear() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return await getTotalCostByDateRange(startOfYear, endOfYear);
  }

  /// Check if a vehicle has any maintenance records
  Future<bool> vehicleHasRecords(String vehicleId) async {
    final count = await getRecordCountByVehicle(vehicleId);
    return count > 0;
  }
}

/// Maintenance summary data class
class MaintenanceSummary {
  final int totalRecords;
  final double totalCost;
  final double averageCost;
  final DateTime? lastServiceDate;
  final String? lastServiceType;

  MaintenanceSummary({
    required this.totalRecords,
    required this.totalCost,
    required this.averageCost,
    this.lastServiceDate,
    this.lastServiceType,
  });

  @override
  String toString() {
    return 'MaintenanceSummary(records: $totalRecords, totalCost: \$$totalCost, avgCost: \$$averageCost)';
  }
}
