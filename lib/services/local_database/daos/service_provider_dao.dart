import 'package:floor/floor.dart';
import '../../../data/models/service_provider_model.dart';

/// Data Access Object for ServiceProvider operations
@dao
abstract class ServiceProviderDao {
  /// Get all service providers ordered by name
  @Query('SELECT * FROM service_providers ORDER BY name ASC')
  Future<List<ServiceProvider>> getAllProviders();

  /// Get service providers by profile ID
  @Query('SELECT * FROM service_providers WHERE profileId = :profileId ORDER BY name ASC')
  Future<List<ServiceProvider>> getProvidersByProfileId(String profileId);

  /// Watch service providers by profile ID
  @Query('SELECT * FROM service_providers WHERE profileId = :profileId ORDER BY name ASC')
  Stream<List<ServiceProvider>> watchProvidersByProfileId(String profileId);

  /// Get all service providers as a stream
  @Query('SELECT * FROM service_providers ORDER BY name ASC')
  Stream<List<ServiceProvider>> watchAllProviders();

  /// Get a service provider by ID
  @Query('SELECT * FROM service_providers WHERE id = :id')
  Future<ServiceProvider?> getProviderById(String id);

  /// Get a service provider by ID as a stream
  @Query('SELECT * FROM service_providers WHERE id = :id')
  Stream<ServiceProvider?> watchProviderById(String id);

  /// Search service providers by name
  @Query('''
    SELECT * FROM service_providers 
    WHERE name LIKE '%' || :query || '%'
    ORDER BY name ASC
  ''')
  Future<List<ServiceProvider>> searchProviders(String query);

  /// Get service providers with rating above threshold
  @Query('''
    SELECT * FROM service_providers 
    WHERE rating IS NOT NULL 
    AND rating >= :minRating
    ORDER BY rating DESC, name ASC
  ''')
  Future<List<ServiceProvider>> getProvidersByMinRating(double minRating);

  /// Get top rated service providers
  @Query('''
    SELECT * FROM service_providers 
    WHERE rating IS NOT NULL 
    ORDER BY rating DESC, name ASC
    LIMIT :limit
  ''')
  Future<List<ServiceProvider>> getTopRatedProviders(int limit);

  /// Get top rated providers by profile
  @Query('''
    SELECT * FROM service_providers 
    WHERE profileId = :profileId AND rating IS NOT NULL 
    ORDER BY rating DESC, name ASC
    LIMIT :limit
  ''')
  Future<List<ServiceProvider>> getTopRatedProvidersByProfile(String profileId, int limit);

  /// Get service providers with no rating
  @Query('''
    SELECT * FROM service_providers 
    WHERE rating IS NULL
    ORDER BY name ASC
  ''')
  Future<List<ServiceProvider>> getUnratedProviders();

  /// Get count of service providers
  @Query('SELECT COUNT(*) FROM service_providers')
  Future<int?> getProviderCount();

  /// Get average rating of all providers
  @Query('SELECT AVG(rating) FROM service_providers WHERE rating IS NOT NULL')
  Future<double?> getAverageRating();

  /// Insert a new service provider
  @insert
  Future<void> insertProvider(ServiceProvider provider);

  /// Insert multiple service providers
  @insert
  Future<void> insertProviders(List<ServiceProvider> providers);

  /// Update an existing service provider
  @update
  Future<void> updateProvider(ServiceProvider provider);

  /// Update provider rating
  @Query('UPDATE service_providers SET rating = :rating, updatedAt = :timestamp WHERE id = :id')
  Future<void> updateProviderRating(String id, double rating, int timestamp);

  /// Delete a service provider
  @delete
  Future<void> deleteProvider(ServiceProvider provider);

  /// Delete service provider by ID
  @Query('DELETE FROM service_providers WHERE id = :id')
  Future<void> deleteProviderById(String id);

  /// Delete all service providers
  @Query('DELETE FROM service_providers')
  Future<void> deleteAllProviders();

  /// Delete service providers by profile ID
  @Query('DELETE FROM service_providers WHERE profileId = :profileId')
  Future<void> deleteByProfileId(String profileId);
}
