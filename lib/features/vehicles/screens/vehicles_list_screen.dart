import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/vehicle_providers.dart';
import '../widgets/vehicle_list_tile.dart';
import '../../dashboard/widgets/empty_state.dart';
import 'vehicle_form_screen.dart';
import 'vehicle_detail_screen.dart';
import '../../../services/app_logger.dart';

/// Vehicles list screen
///
/// Displays a list of all vehicles with options to add, edit, and delete.
class VehiclesListScreen extends ConsumerWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO(robertogeissler): Implement search
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          AppLogger.error(
            'Error loading vehicles',
            tag: 'VehiclesList',
            error: error,
            stackTrace: stack,
          );

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading vehicles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(vehiclesStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (vehicles) {
          AppLogger.debug(
            'Vehicles loaded',
            tag: 'VehiclesList',
            data: {'count': vehicles.length},
          );

          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car,
              title: 'No Vehicles',
              message: 'Add your first vehicle to get started',
              actionLabel: 'Add Vehicle',
              onAction: () => _navigateToAddVehicle(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(vehiclesStreamProvider);
            },
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return VehicleListTile(
                  vehicle: vehicle,
                  onTap: () => _navigateToDetail(context, vehicle.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddVehicle(context),
        tooltip: 'Add Vehicle',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddVehicle(BuildContext context) {
    AppLogger.info('Navigating to add vehicle form', tag: 'VehiclesList');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const VehicleFormScreen()));
  }

  void _navigateToDetail(BuildContext context, String vehicleId) {
    AppLogger.info(
      'Navigating to vehicle detail',
      tag: 'VehiclesList',
      data: {'vehicleId': vehicleId},
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(vehicleId: vehicleId),
      ),
    );
  }
}
