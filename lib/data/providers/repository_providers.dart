import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/repositories.dart';
import 'database_provider.dart';

/// Provider for VehicleRepository
/// 
/// Provides access to vehicle data operations.
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return VehicleRepository(database);
});

/// Provider for MaintenanceRepository
/// 
/// Provides access to maintenance record operations.
final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return MaintenanceRepository(database);
});

/// Provider for ReminderRepository
/// 
/// Provides access to reminder operations.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ReminderRepository(database);
});

/// Provider for ServiceProviderRepository
/// 
/// Provides access to service provider operations.
final serviceProviderRepositoryProvider = Provider<ServiceProviderRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ServiceProviderRepository(database);
});

/// Provider for DocumentRepository
/// 
/// Provides access to document operations.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DocumentRepository(database);
});
