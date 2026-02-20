// Riverpod providers for analytics and reports
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_providers.dart';
import 'repository_providers.dart';

// ============================================================================
// Maintenance Analytics
// ============================================================================

/// Provider for maintenance cost analysis
final maintenanceCostAnalyticsProvider = FutureProvider.family<MaintenanceCostAnalytics, String>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  
  final records = await repository.getRecordsByVehicle(vehicleId);
  final totalCost = records.fold(0.0, (sum, record) => sum + (record.cost ?? 0));
  final avgCost = records.isNotEmpty ? totalCost / records.length : 0.0;
  
  // Get costs by service type
  final costsByType = <String, double>{};
  for (var record in records) {
    final cost = record.cost ?? 0;
    costsByType[record.serviceType] = (costsByType[record.serviceType] ?? 0) + cost;
  }
  
  // Get monthly costs (last 12 months)
  final now = DateTime.now();
  final monthlyCosts = <String, double>{};
  for (var i = 11; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    monthlyCosts[monthKey] = 0.0;
  }
  
  for (var record in records) {
    final date = DateTime.fromMillisecondsSinceEpoch(record.serviceDate);
    final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    if (monthlyCosts.containsKey(monthKey)) {
      monthlyCosts[monthKey] = (monthlyCosts[monthKey] ?? 0) + (record.cost ?? 0);
    }
  }
  
  return MaintenanceCostAnalytics(
    totalCost: totalCost,
    averageCost: avgCost,
    serviceCount: records.length,
    costsByType: costsByType,
    monthlyCosts: monthlyCosts,
    highestCost: records.isEmpty ? 0 : records.map((r) => r.cost ?? 0).reduce((a, b) => a > b ? a : b),
    lowestCost: records.isEmpty ? 0 : records.map((r) => r.cost ?? 0).where((c) => c > 0).fold(double.infinity, (a, b) => a < b ? a : b),
  );
});

/// Provider for all vehicles analytics (profile-scoped)
final allVehiclesAnalyticsProvider = FutureProvider<AllVehiclesAnalytics>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) {
    return AllVehiclesAnalytics(
      totalVehicles: 0,
      totalMaintenanceRecords: 0,
      totalMaintenanceCost: 0,
      totalReminders: 0,
      totalDocuments: 0,
      totalServiceProviders: 0,
      averageCostPerVehicle: 0,
    );
  }
  final vehicleRepo = ref.watch(vehicleRepositoryProvider);
  final maintenanceRepo = ref.watch(maintenanceRepositoryProvider);
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final documentRepo = ref.watch(documentRepositoryProvider);
  final providerRepo = ref.watch(serviceProviderRepositoryProvider);
  
  final vehicles = await vehicleRepo.getVehiclesByProfile(profileId);
  final totalVehicles = vehicles.length;
  
  final vehicleIds = vehicles.map((v) => v.id).toSet();
  final allMaintenance = (await maintenanceRepo.getAllRecords())
      .where((r) => vehicleIds.contains(r.vehicleId))
      .toList();
  final totalMaintenanceRecords = allMaintenance.length;
  final totalMaintenanceCost = allMaintenance.fold(0.0, (sum, r) => sum + (r.cost ?? 0));
  
  final allReminders = (await reminderRepo.getActiveReminders())
      .where((r) => vehicleIds.contains(r.vehicleId))
      .toList();
  final totalReminders = allReminders.length;
  
  final allDocuments = (await documentRepo.getAllDocuments())
      .where((d) => vehicleIds.contains(d.vehicleId))
      .toList();
  final totalDocuments = allDocuments.length;
  
  final allProviders = await providerRepo.getProvidersByProfile(profileId);
  final totalProviders = allProviders.length;
  
  return AllVehiclesAnalytics(
    totalVehicles: totalVehicles,
    totalMaintenanceRecords: totalMaintenanceRecords,
    totalMaintenanceCost: totalMaintenanceCost,
    totalReminders: totalReminders,
    totalDocuments: totalDocuments,
    totalServiceProviders: totalProviders,
    averageCostPerVehicle: totalVehicles > 0 ? totalMaintenanceCost / totalVehicles : 0,
  );
});

/// Provider for service type distribution
final serviceTypeDistributionProvider = FutureProvider.family<Map<String, int>, String>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final records = await repository.getRecordsByVehicle(vehicleId);
  
  final distribution = <String, int>{};
  for (var record in records) {
    distribution[record.serviceType] = (distribution[record.serviceType] ?? 0) + 1;
  }
  
  return distribution;
});

/// Provider for maintenance frequency (services per month)
final maintenanceFrequencyProvider = FutureProvider.family<double, String>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final records = await repository.getRecordsByVehicle(vehicleId);
  
  if (records.isEmpty) return 0.0;
  
  final firstDate = DateTime.fromMillisecondsSinceEpoch(
    records.map((r) => r.serviceDate).reduce((a, b) => a < b ? a : b)
  );
  final lastDate = DateTime.fromMillisecondsSinceEpoch(
    records.map((r) => r.serviceDate).reduce((a, b) => a > b ? a : b)
  );
  
  final months = ((lastDate.difference(firstDate).inDays) / 30).ceil();
  return months > 0 ? records.length / months : records.length.toDouble();
});

// ============================================================================
// Data Models for Analytics
// ============================================================================

class MaintenanceCostAnalytics {
  final double totalCost;
  final double averageCost;
  final int serviceCount;
  final Map<String, double> costsByType;
  final Map<String, double> monthlyCosts;
  final double highestCost;
  final double lowestCost;

  MaintenanceCostAnalytics({
    required this.totalCost,
    required this.averageCost,
    required this.serviceCount,
    required this.costsByType,
    required this.monthlyCosts,
    required this.highestCost,
    required this.lowestCost,
  });
}

class AllVehiclesAnalytics {
  final int totalVehicles;
  final int totalMaintenanceRecords;
  final double totalMaintenanceCost;
  final int totalReminders;
  final int totalDocuments;
  final int totalServiceProviders;
  final double averageCostPerVehicle;

  AllVehiclesAnalytics({
    required this.totalVehicles,
    required this.totalMaintenanceRecords,
    required this.totalMaintenanceCost,
    required this.totalReminders,
    required this.totalDocuments,
    required this.totalServiceProviders,
    required this.averageCostPerVehicle,
  });
}

/// Statistics data model from document repository
class DocumentStatistics {
  final int totalDocuments;
  final int totalSize;
  final int imageCount;
  final int pdfCount;
  final Map<String, int> documentsByType;

  DocumentStatistics({
    required this.totalDocuments,
    required this.totalSize,
    required this.imageCount,
    required this.pdfCount,
    required this.documentsByType,
  });
}

/// Statistics data model from service provider repository
class ProviderStatistics {
  final int totalCount;
  final int ratedCount;
  final int unratedCount;
  final double averageRating;
  final int highlyRatedCount;
  final Map<String, int> providersBySpecialty;

  ProviderStatistics({
    required this.totalCount,
    required this.ratedCount,
    required this.unratedCount,
    required this.averageRating,
    required this.highlyRatedCount,
    required this.providersBySpecialty,
  });
}
