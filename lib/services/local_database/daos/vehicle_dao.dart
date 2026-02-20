import 'package:floor/floor.dart';
import '../../../data/models/vehicle_model.dart';

/// Data Access Object for Vehicle operations
@dao
abstract class VehicleDao {
  /// Get all vehicles ordered by creation date (newest first)
  @Query('SELECT * FROM vehicles ORDER BY createdAt DESC')
  Future<List<Vehicle>> getAllVehicles();

  /// Get vehicles by profile ID
  @Query('SELECT * FROM vehicles WHERE profileId = :profileId ORDER BY createdAt DESC')
  Future<List<Vehicle>> getVehiclesByProfileId(String profileId);

  /// Watch vehicles by profile ID (reactive)
  @Query('SELECT * FROM vehicles WHERE profileId = :profileId ORDER BY createdAt DESC')
  Stream<List<Vehicle>> watchVehiclesByProfileId(String profileId);

  /// Get all vehicles as a stream for reactive updates
  @Query('SELECT * FROM vehicles ORDER BY createdAt DESC')
  Stream<List<Vehicle>> watchAllVehicles();

  /// Get a vehicle by ID
  @Query('SELECT * FROM vehicles WHERE id = :id')
  Future<Vehicle?> getVehicleById(String id);

  /// Get a vehicle by ID as a stream
  @Query('SELECT * FROM vehicles WHERE id = :id')
  Stream<Vehicle?> watchVehicleById(String id);

  /// Search vehicles by make, model, or year (within profile)
  @Query('''
    SELECT * FROM vehicles 
    WHERE profileId = :profileId
    AND (make LIKE '%' || :query || '%' 
    OR model LIKE '%' || :query || '%' 
    OR CAST(year AS TEXT) LIKE '%' || :query || '%')
    ORDER BY createdAt DESC
  ''')
  Future<List<Vehicle>> searchVehicles(String profileId, String query);

  /// Search all vehicles (legacy)
  @Query('''
    SELECT * FROM vehicles 
    WHERE make LIKE '%' || :query || '%' 
    OR model LIKE '%' || :query || '%' 
    OR CAST(year AS TEXT) LIKE '%' || :query || '%'
    ORDER BY createdAt DESC
  ''')
  Future<List<Vehicle>> searchAllVehicles(String query);

  /// Get vehicles by year range
  @Query('''
    SELECT * FROM vehicles 
    WHERE year BETWEEN :startYear AND :endYear
    ORDER BY year DESC
  ''')
  Future<List<Vehicle>> getVehiclesByYearRange(int startYear, int endYear);

  /// Get total count of vehicles
  @Query('SELECT COUNT(*) FROM vehicles')
  Future<int?> getVehicleCount();

  /// Get vehicle count by profile
  @Query('SELECT COUNT(*) FROM vehicles WHERE profileId = :profileId')
  Future<int?> getVehicleCountByProfile(String profileId);

  /// Insert a new vehicle
  @insert
  Future<void> insertVehicle(Vehicle vehicle);

  /// Insert multiple vehicles
  @insert
  Future<void> insertVehicles(List<Vehicle> vehicles);

  /// Update an existing vehicle
  @update
  Future<void> updateVehicle(Vehicle vehicle);

  /// Update vehicle mileage
  @Query('UPDATE vehicles SET currentMileage = :mileage, updatedAt = :timestamp WHERE id = :id')
  Future<void> updateVehicleMileage(String id, double mileage, int timestamp);

  /// Delete a vehicle
  @delete
  Future<void> deleteVehicle(Vehicle vehicle);

  /// Delete vehicle by ID
  @Query('DELETE FROM vehicles WHERE id = :id')
  Future<void> deleteVehicleById(String id);

  /// Delete all vehicles
  @Query('DELETE FROM vehicles')
  Future<void> deleteAllVehicles();
}
