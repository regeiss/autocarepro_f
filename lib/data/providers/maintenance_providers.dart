// Riverpod providers for maintenance records
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'profile_providers.dart';
import 'repository_providers.dart';

// ============================================================================
// List Providers
// ============================================================================

/// Provider for all maintenance records of a specific vehicle
final maintenanceListProvider = FutureProvider.family<List<MaintenanceRecord>, String>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return await repository.getRecordsByVehicle(vehicleId);
});

/// Stream provider for real-time maintenance records updates
final maintenanceStreamProvider = StreamProvider.family<List<MaintenanceRecord>, String>((ref, vehicleId) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.watchRecordsByVehicle(vehicleId);
});

/// Provider for recent maintenance records (profile-scoped)
final recentMaintenanceProvider = FutureProvider.family<List<MaintenanceRecord>, int>((ref, limit) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return [];
  final vehicleRepo = ref.watch(vehicleRepositoryProvider);
  final maintenanceRepo = ref.watch(maintenanceRepositoryProvider);
  final vehicles = await vehicleRepo.getVehiclesByProfile(profileId);
  final vehicleIds = vehicles.map((v) => v.id).toSet();
  final records = await maintenanceRepo.getRecentRecords(limit: limit * 2);
  return records.where((r) => vehicleIds.contains(r.vehicleId)).take(limit).toList();
});

// ============================================================================
// Single Record Providers
// ============================================================================

/// Provider for a single maintenance record by ID
final maintenanceDetailProvider = FutureProvider.family<MaintenanceRecord?, String>((ref, id) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return await repository.getRecordById(id);
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for total maintenance count for a vehicle
final maintenanceCountProvider = FutureProvider.family<int, String>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return await repository.getRecordCountByVehicle(vehicleId);
});

/// Provider for total cost spent on a vehicle
final totalMaintenanceCostProvider = FutureProvider.family<double, String>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return await repository.getTotalCostByVehicle(vehicleId);
});

/// Provider for monthly maintenance expenses
final monthlyExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return await repository.getCostThisMonth();
});

/// Provider for cost statistics for a vehicle
final costStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  
  final total = await repository.getTotalCostByVehicle(vehicleId);
  final records = await repository.getRecordsByVehicle(vehicleId);
  
  if (records.isEmpty) {
    return {
      'total': 0.0,
      'average': 0.0,
      'count': 0,
      'highest': 0.0,
      'lowest': 0.0,
    };
  }
  
  final costs = records.map((r) => r.cost ?? 0.0).toList()..sort();
  
  return {
    'total': total,
    'average': total / records.length,
    'count': records.length,
    'highest': costs.last,
    'lowest': costs.first,
  };
});

// ============================================================================
// UI State Providers
// ============================================================================

/// State provider for selected maintenance record (for editing)
final selectedMaintenanceProvider = StateProvider<MaintenanceRecord?>((ref) => null);
