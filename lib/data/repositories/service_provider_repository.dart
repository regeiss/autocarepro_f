import '../models/service_provider_model.dart';
import '../../services/local_database/app_database.dart';
import 'vehicle_repository.dart';

/// Repository for service provider data operations
/// 
/// This repository provides a clean API for service provider-related operations,
/// including shop management, rating tracking, and search functionality.
class ServiceProviderRepository {
  final AppDatabase _database;

  ServiceProviderRepository(this._database);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all service providers
  Future<List<ServiceProvider>> getAllProviders() async {
    try {
      return await _database.serviceProviderDao.getAllProviders();
    } catch (e) {
      throw RepositoryException('Failed to get service providers: $e');
    }
  }

  /// Watch all service providers (reactive stream)
  Stream<List<ServiceProvider>> watchAllProviders() {
    return _database.serviceProviderDao.watchAllProviders();
  }

  /// Get a service provider by ID
  Future<ServiceProvider?> getProviderById(String id) async {
    try {
      return await _database.serviceProviderDao.getProviderById(id);
    } catch (e) {
      throw RepositoryException('Failed to get service provider: $e');
    }
  }

  /// Watch a service provider by ID (reactive stream)
  Stream<ServiceProvider?> watchProviderById(String id) {
    return _database.serviceProviderDao.watchProviderById(id);
  }

  /// Search service providers by name
  Future<List<ServiceProvider>> searchProviders(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllProviders();
      }
      return await _database.serviceProviderDao.searchProviders(query);
    } catch (e) {
      throw RepositoryException('Failed to search service providers: $e');
    }
  }

  /// Get service providers with minimum rating
  Future<List<ServiceProvider>> getProvidersByMinRating(double minRating) async {
    try {
      if (minRating < 1.0 || minRating > 5.0) {
        throw RepositoryException('Rating must be between 1.0 and 5.0');
      }
      return await _database.serviceProviderDao.getProvidersByMinRating(minRating);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to get providers by rating: $e');
    }
  }

  /// Get top rated service providers
  Future<List<ServiceProvider>> getTopRatedProviders({int limit = 10}) async {
    try {
      return await _database.serviceProviderDao.getTopRatedProviders(limit);
    } catch (e) {
      throw RepositoryException('Failed to get top rated providers: $e');
    }
  }

  /// Get service providers with no rating
  Future<List<ServiceProvider>> getUnratedProviders() async {
    try {
      return await _database.serviceProviderDao.getUnratedProviders();
    } catch (e) {
      throw RepositoryException('Failed to get unrated providers: $e');
    }
  }

  /// Get count of service providers
  Future<int> getProviderCount() async {
    try {
      return await _database.serviceProviderDao.getProviderCount() ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get provider count: $e');
    }
  }

  /// Get average rating across all providers
  Future<double> getAverageRating() async {
    try {
      return await _database.serviceProviderDao.getAverageRating() ?? 0.0;
    } catch (e) {
      throw RepositoryException('Failed to get average rating: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Add a new service provider
  Future<void> addProvider(ServiceProvider provider) async {
    try {
      // Validate before inserting
      final error = provider.validate();
      if (error != null) {
        throw RepositoryException('Invalid service provider: $error');
      }
      
      await _database.serviceProviderDao.insertProvider(provider);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add service provider: $e');
    }
  }

  /// Add multiple service providers
  Future<void> addProviders(List<ServiceProvider> providers) async {
    try {
      // Validate all providers
      for (final provider in providers) {
        final error = provider.validate();
        if (error != null) {
          throw RepositoryException('Invalid service provider ${provider.name}: $error');
        }
      }
      
      await _database.serviceProviderDao.insertProviders(providers);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add service providers: $e');
    }
  }

  /// Update an existing service provider
  Future<void> updateProvider(ServiceProvider provider) async {
    try {
      // Validate before updating
      final error = provider.validate();
      if (error != null) {
        throw RepositoryException('Invalid service provider: $error');
      }

      // Check if provider exists
      final existing = await getProviderById(provider.id);
      if (existing == null) {
        throw RepositoryException('Service provider not found: ${provider.id}');
      }
      
      await _database.serviceProviderDao.updateProvider(provider);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update service provider: $e');
    }
  }

  /// Update provider rating
  Future<void> updateProviderRating(String providerId, double rating) async {
    try {
      if (rating < 1.0 || rating > 5.0) {
        throw RepositoryException('Rating must be between 1.0 and 5.0');
      }

      // Check if provider exists
      final existing = await getProviderById(providerId);
      if (existing == null) {
        throw RepositoryException('Service provider not found: $providerId');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _database.serviceProviderDao.updateProviderRating(
        providerId,
        rating,
        timestamp,
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update provider rating: $e');
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a service provider
  Future<void> deleteProvider(ServiceProvider provider) async {
    try {
      await _database.serviceProviderDao.deleteProvider(provider);
    } catch (e) {
      throw RepositoryException('Failed to delete service provider: $e');
    }
  }

  /// Delete a service provider by ID
  Future<void> deleteProviderById(String id) async {
    try {
      // Check if provider exists
      final existing = await getProviderById(id);
      if (existing == null) {
        throw RepositoryException('Service provider not found: $id');
      }

      await _database.serviceProviderDao.deleteProviderById(id);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to delete service provider: $e');
    }
  }

  /// Delete all service providers
  Future<void> deleteAllProviders() async {
    try {
      await _database.serviceProviderDao.deleteAllProviders();
    } catch (e) {
      throw RepositoryException('Failed to delete all service providers: $e');
    }
  }

  // ============================================================================
  // BUSINESS LOGIC METHODS
  // ============================================================================

  /// Get providers by specialty
  Future<List<ServiceProvider>> getProvidersBySpecialty(String specialty) async {
    try {
      final allProviders = await getAllProviders();
      
      return allProviders.where((provider) {
        return provider.specialties.any(
          (s) => s.toLowerCase().contains(specialty.toLowerCase()),
        );
      }).toList();
    } catch (e) {
      throw RepositoryException('Failed to get providers by specialty: $e');
    }
  }

  /// Get highly rated providers (4 stars or above)
  Future<List<ServiceProvider>> getHighlyRatedProviders() async {
    return await getProvidersByMinRating(4.0);
  }

  /// Get provider statistics
  Future<ProviderStatistics> getStatistics() async {
    try {
      final totalProviders = await getProviderCount();
      final averageRating = await getAverageRating();
      final topRated = await getTopRatedProviders(limit: 1);
      final unrated = await getUnratedProviders();

      return ProviderStatistics(
        totalProviders: totalProviders,
        averageRating: averageRating,
        highestRating: topRated.isNotEmpty ? topRated.first.rating : null,
        unratedCount: unrated.length,
      );
    } catch (e) {
      throw RepositoryException('Failed to get provider statistics: $e');
    }
  }

  /// Check if provider name already exists
  Future<bool> providerNameExists(String name) async {
    try {
      final providers = await searchProviders(name);
      return providers.any(
        (p) => p.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      throw RepositoryException('Failed to check provider name: $e');
    }
  }

  /// Get recommended providers (highly rated with good specialties)
  Future<List<ServiceProvider>> getRecommendedProviders() async {
    try {
      final providers = await getProvidersByMinRating(4.0);
      
      // Sort by rating descending
      providers.sort((a, b) {
        final aRating = a.rating ?? 0;
        final bRating = b.rating ?? 0;
        return bRating.compareTo(aRating);
      });

      return providers.take(5).toList();
    } catch (e) {
      throw RepositoryException('Failed to get recommended providers: $e');
    }
  }

  /// Check if any providers exist
  Future<bool> hasProviders() async {
    final count = await getProviderCount();
    return count > 0;
  }
}

/// Provider statistics data class
class ProviderStatistics {
  final int totalProviders;
  final double averageRating;
  final double? highestRating;
  final int unratedCount;

  ProviderStatistics({
    required this.totalProviders,
    required this.averageRating,
    this.highestRating,
    required this.unratedCount,
  });

  @override
  String toString() {
    return 'ProviderStatistics(total: $totalProviders, avgRating: $averageRating, highest: $highestRating, unrated: $unratedCount)';
  }
}
