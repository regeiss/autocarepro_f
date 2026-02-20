import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_model.dart';
import 'profile_providers.dart';
import 'repository_providers.dart';

/// Provider for all vehicles list (profile-scoped)
final vehiclesListProvider = FutureProvider<List<Vehicle>>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return [];
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getVehiclesByProfile(profileId);
});

/// Provider for vehicle count (profile-scoped)
final vehicleCountProvider = FutureProvider<int>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return 0;
  final repository = ref.watch(vehicleRepositoryProvider);
  return (await repository.getVehiclesByProfile(profileId)).length;
});

/// Provider for a single vehicle by ID
/// 
/// Returns a specific vehicle by its ID.
final vehicleByIdProvider = FutureProvider.family<Vehicle?, String>((ref, id) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getVehicleById(id);
});

/// Stream provider for all vehicles (reactive, profile-scoped)
final vehiclesStreamProvider = StreamProvider<List<Vehicle>>((ref) {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return Stream.value([]);
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.watchVehiclesByProfile(profileId);
});

/// Stream provider for a single vehicle by ID (reactive)
/// 
/// Automatically updates when the vehicle changes in the database.
final vehicleStreamProvider = StreamProvider.family<Vehicle?, String>((ref, id) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.watchVehicleById(id);
});

/// Provider for vehicles sorted by mileage
final vehiclesByMileageProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getVehiclesSortedByMileage();
});

/// Provider for vehicles sorted by year
final vehiclesByYearProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getVehiclesSortedByYear();
});

/// Provider for recent vehicles
final recentVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getRecentVehicles();
});

/// State provider for selected vehicle ID
/// 
/// Manages the currently selected vehicle in the UI.
final selectedVehicleIdProvider = StateProvider<String?>((ref) => null);

/// Provider for the currently selected vehicle
/// 
/// Returns the vehicle that is currently selected based on selectedVehicleIdProvider.
final selectedVehicleProvider = Provider<AsyncValue<Vehicle?>>((ref) {
  final selectedId = ref.watch(selectedVehicleIdProvider);
  
  if (selectedId == null) {
    return const AsyncValue.data(null);
  }
  
  return ref.watch(vehicleByIdProvider(selectedId));
});
