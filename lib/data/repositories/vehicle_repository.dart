import '../models/vehicle_model.dart';
import '../../services/local_database/app_database.dart';

/// Repository for vehicle data operations
/// 
/// This repository provides a clean API for vehicle-related operations,
/// abstracting the database implementation from the rest of the app.
class VehicleRepository {
  final AppDatabase _database;

  VehicleRepository(this._database);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      return await _database.vehicleDao.getAllVehicles();
    } catch (e) {
      throw RepositoryException('Failed to get vehicles: $e');
    }
  }

  /// Get vehicles by profile ID
  Future<List<Vehicle>> getVehiclesByProfile(String profileId) async {
    try {
      return await _database.vehicleDao.getVehiclesByProfileId(profileId);
    } catch (e) {
      throw RepositoryException('Failed to get vehicles: $e');
    }
  }

  /// Watch vehicles by profile (reactive stream)
  Stream<List<Vehicle>> watchVehiclesByProfile(String profileId) {
    return _database.vehicleDao.watchVehiclesByProfileId(profileId);
  }

  /// Watch all vehicles (reactive stream)
  Stream<List<Vehicle>> watchAllVehicles() {
    return _database.vehicleDao.watchAllVehicles();
  }

  /// Get a vehicle by ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      return await _database.vehicleDao.getVehicleById(id);
    } catch (e) {
      throw RepositoryException('Failed to get vehicle: $e');
    }
  }

  /// Watch a vehicle by ID (reactive stream)
  Stream<Vehicle?> watchVehicleById(String id) {
    return _database.vehicleDao.watchVehicleById(id);
  }

  /// Search vehicles by query (make, model, or year) within profile
  Future<List<Vehicle>> searchVehicles(String profileId, String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getVehiclesByProfile(profileId);
      }
      return await _database.vehicleDao.searchVehicles(profileId, query);
    } catch (e) {
      throw RepositoryException('Failed to search vehicles: $e');
    }
  }

  /// Search all vehicles (legacy)
  Future<List<Vehicle>> searchAllVehicles(String query) async {
    try {
      if (query.trim().isEmpty) return await getAllVehicles();
      return await _database.vehicleDao.searchAllVehicles(query);
    } catch (e) {
      throw RepositoryException('Failed to search vehicles: $e');
    }
  }

  /// Get vehicles by year range
  Future<List<Vehicle>> getVehiclesByYearRange(int startYear, int endYear) async {
    try {
      if (startYear > endYear) {
        throw RepositoryException('Start year must be less than or equal to end year');
      }
      return await _database.vehicleDao.getVehiclesByYearRange(startYear, endYear);
    } catch (e) {
      throw RepositoryException('Failed to get vehicles by year range: $e');
    }
  }

  /// Get total count of vehicles
  Future<int> getVehicleCount() async {
    try {
      return await _database.vehicleDao.getVehicleCount() ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get vehicle count: $e');
    }
  }

  /// Check if any vehicles exist
  Future<bool> hasVehicles() async {
    final count = await getVehicleCount();
    return count > 0;
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      // Validate before inserting
      final error = vehicle.validate();
      if (error != null) {
        throw RepositoryException('Invalid vehicle data: $error');
      }
      
      await _database.vehicleDao.insertVehicle(vehicle);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add vehicle: $e');
    }
  }

  /// Add multiple vehicles
  Future<void> addVehicles(List<Vehicle> vehicles) async {
    try {
      // Validate all vehicles
      for (final vehicle in vehicles) {
        final error = vehicle.validate();
        if (error != null) {
          throw RepositoryException('Invalid vehicle data for ${vehicle.displayName}: $error');
        }
      }
      
      await _database.vehicleDao.insertVehicles(vehicles);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add vehicles: $e');
    }
  }

  /// Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      // Validate before updating
      final error = vehicle.validate();
      if (error != null) {
        throw RepositoryException('Invalid vehicle data: $error');
      }

      // Check if vehicle exists
      final existing = await getVehicleById(vehicle.id);
      if (existing == null) {
        throw RepositoryException('Vehicle not found: ${vehicle.id}');
      }
      
      await _database.vehicleDao.updateVehicle(vehicle);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update vehicle: $e');
    }
  }

  /// Update vehicle mileage
  Future<void> updateVehicleMileage(String vehicleId, double mileage) async {
    try {
      if (mileage < 0) {
        throw RepositoryException('Mileage cannot be negative');
      }

      // Check if vehicle exists
      final existing = await getVehicleById(vehicleId);
      if (existing == null) {
        throw RepositoryException('Vehicle not found: $vehicleId');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _database.vehicleDao.updateVehicleMileage(vehicleId, mileage, timestamp);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update mileage: $e');
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a vehicle
  /// Note: This will cascade delete all related maintenance records, reminders, and documents
  Future<void> deleteVehicle(Vehicle vehicle) async {
    try {
      await _database.vehicleDao.deleteVehicle(vehicle);
    } catch (e) {
      throw RepositoryException('Failed to delete vehicle: $e');
    }
  }

  /// Delete a vehicle by ID
  /// Note: This will cascade delete all related maintenance records, reminders, and documents
  Future<void> deleteVehicleById(String id) async {
    try {
      // Check if vehicle exists
      final existing = await getVehicleById(id);
      if (existing == null) {
        throw RepositoryException('Vehicle not found: $id');
      }

      await _database.vehicleDao.deleteVehicleById(id);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to delete vehicle: $e');
    }
  }

  /// Delete all vehicles
  /// WARNING: This will cascade delete ALL maintenance records, reminders, and documents
  Future<void> deleteAllVehicles() async {
    try {
      await _database.vehicleDao.deleteAllVehicles();
    } catch (e) {
      throw RepositoryException('Failed to delete all vehicles: $e');
    }
  }

  // ============================================================================
  // BUSINESS LOGIC METHODS
  // ============================================================================

  /// Get vehicles that need attention (low mileage records, old purchase dates, etc.)
  Future<List<Vehicle>> getVehiclesNeedingAttention() async {
    try {
      final vehicles = await getAllVehicles();
      // Add business logic here to filter vehicles needing attention
      // For now, return all vehicles
      return vehicles;
    } catch (e) {
      throw RepositoryException('Failed to get vehicles needing attention: $e');
    }
  }

  /// Get recently added vehicles (last 10)
  Future<List<Vehicle>> getRecentVehicles({int limit = 10}) async {
    try {
      final vehicles = await getAllVehicles();
      if (vehicles.length <= limit) {
        return vehicles;
      }
      return vehicles.sublist(0, limit);
    } catch (e) {
      throw RepositoryException('Failed to get recent vehicles: $e');
    }
  }

  /// Check if a VIN already exists
  Future<bool> vinExists(String vin) async {
    try {
      if (vin.trim().isEmpty) return false;
      
      final vehicles = await getAllVehicles();
      return vehicles.any((v) => v.vin?.toLowerCase() == vin.toLowerCase());
    } catch (e) {
      throw RepositoryException('Failed to check VIN: $e');
    }
  }

  /// Get vehicles sorted by mileage (highest first)
  Future<List<Vehicle>> getVehiclesSortedByMileage() async {
    try {
      final vehicles = await getAllVehicles();
      vehicles.sort((a, b) {
        final aMileage = a.currentMileage ?? 0;
        final bMileage = b.currentMileage ?? 0;
        return bMileage.compareTo(aMileage);
      });
      return vehicles;
    } catch (e) {
      throw RepositoryException('Failed to sort vehicles: $e');
    }
  }

  /// Get vehicles sorted by year (newest first)
  Future<List<Vehicle>> getVehiclesSortedByYear() async {
    try {
      final vehicles = await getAllVehicles();
      vehicles.sort((a, b) => b.year.compareTo(a.year));
      return vehicles;
    } catch (e) {
      throw RepositoryException('Failed to sort vehicles: $e');
    }
  }
}

/// Exception thrown by repository operations
class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
