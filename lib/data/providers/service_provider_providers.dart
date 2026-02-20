// Riverpod providers for service providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'profile_providers.dart';
import 'repository_providers.dart';
import '../repositories/service_provider_repository.dart';

// ============================================================================
// List Providers
// ============================================================================

/// Provider for all service providers (profile-scoped)
final serviceProvidersListProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return [];
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getProvidersByProfile(profileId);
});

/// Stream provider for real-time service provider updates (profile-scoped)
final serviceProvidersStreamProvider = StreamProvider<List<ServiceProvider>>((ref) {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return Stream.value([]);
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return repository.watchProvidersByProfile(profileId);
});

/// Provider for top-rated providers (profile-scoped)
final topRatedProvidersProvider = FutureProvider.family<List<ServiceProvider>, int>((ref, limit) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return [];
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getTopRatedProvidersByProfile(profileId, limit: limit);
});

/// Provider for highly rated providers (4.0+)
final highlyRatedProvidersProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getHighlyRatedProviders();
});

/// Provider for recommended providers (highly rated, sorted by usage)
final recommendedProvidersProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getRecommendedProviders();
});

/// Provider for searching providers
final searchProvidersProvider = FutureProvider.family<List<ServiceProvider>, String>((ref, query) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  if (query.isEmpty) {
    return await repository.getAllProviders();
  }
  return await repository.searchProviders(query);
});

/// Provider for providers by minimum rating
final providersByRatingProvider = FutureProvider.family<List<ServiceProvider>, double>((ref, minRating) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getProvidersByMinRating(minRating);
});

/// Provider for unrated providers
final unratedProvidersProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getUnratedProviders();
});

/// Provider for providers by specialty
final providersBySpecialtyProvider = FutureProvider.family<List<ServiceProvider>, String>((ref, specialty) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getProvidersBySpecialty(specialty);
});

// ============================================================================
// Single Provider Providers
// ============================================================================

/// Provider for a single service provider by ID
final serviceProviderDetailProvider = FutureProvider.family<ServiceProvider?, String>((ref, id) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getProviderById(id);
});

/// Stream provider for a single service provider by ID
final serviceProviderStreamProvider = StreamProvider.family<ServiceProvider?, String>((ref, id) {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return repository.watchProviderById(id);
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for total provider count
final providerCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getProviderCount();
});

/// Provider for average provider rating
final averageProviderRatingProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getAverageRating();
});

/// Provider for provider statistics
final providerStatisticsProvider = FutureProvider<ProviderStatistics>((ref) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.getStatistics();
});

/// Provider to check if any providers exist
final hasProvidersProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(serviceProviderRepositoryProvider);
  return await repository.hasProviders();
});

// ============================================================================
// UI State Providers
// ============================================================================

/// State provider for selected service provider (for editing)
final selectedServiceProviderProvider = StateProvider<ServiceProvider?>((ref) => null);

/// State provider for search query
final providerSearchQueryProvider = StateProvider<String>((ref) => '');

/// State provider for rating filter
final providerRatingFilterProvider = StateProvider<double?>((ref) => null);

/// State provider for sort option
enum ProviderSortOption {
  nameAsc,
  nameDesc,
  ratingHigh,
  ratingLow,
  newest,
  oldest,
}

final providerSortOptionProvider = StateProvider<ProviderSortOption>((ref) => ProviderSortOption.nameAsc);
