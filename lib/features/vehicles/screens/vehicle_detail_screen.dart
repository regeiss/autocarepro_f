import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/vehicle_providers.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/providers/maintenance_providers.dart';
import '../../../data/providers/reminder_providers.dart';
import '../../../data/providers/document_providers.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../../app/theme.dart';
import 'vehicle_form_screen.dart';
import '../../maintenance/screens/maintenance_list_screen.dart';
import '../../maintenance/screens/maintenance_form_screen.dart';
import '../../reminders/screens/reminders_list_screen.dart';
import '../../reminders/screens/reminder_form_screen.dart';
import '../../documents/screens/documents_list_screen.dart';
import '../../documents/screens/document_form_screen.dart';

/// Vehicle detail screen
/// 
/// Displays detailed information about a specific vehicle.
class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleStreamProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        actions: [
          vehicleAsync.when(
            data: (vehicle) {
              if (vehicle == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEdit(context, vehicle);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref, vehicle.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: vehicleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading vehicle',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (vehicle) {
          if (vehicle == null) {
            return const Center(
              child: Text('Vehicle not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card with main info
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          vehicle.displayName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (vehicle.licensePlate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            vehicle.licensePlate!,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Vehicle Information
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Vehicle Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                const SizedBox(height: 8),

                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _DetailTile(
                        icon: Icons.business,
                        label: 'Make',
                        value: vehicle.make,
                      ),
                      const Divider(height: 1),
                      _DetailTile(
                        icon: Icons.directions_car,
                        label: 'Model',
                        value: vehicle.model,
                      ),
                      const Divider(height: 1),
                      _DetailTile(
                        icon: Icons.calendar_today,
                        label: 'Year',
                        value: vehicle.year.toString(),
                      ),
                      if (vehicle.vin != null) ...[
                        const Divider(height: 1),
                        _DetailTile(
                          icon: Icons.qr_code,
                          label: 'VIN',
                          value: vehicle.vin!,
                        ),
                      ],
                      if (vehicle.currentMileage != null) ...[
                        const Divider(height: 1),
                        _DetailTile(
                          icon: Icons.speed,
                          label: 'Current Mileage',
                          value: '${vehicle.currentMileage!.toStringAsFixed(0)} ${vehicle.mileageUnit}',
                        ),
                      ],
                      if (vehicle.purchaseDateAsDateTime != null) ...[
                        const Divider(height: 1),
                        _DetailTile(
                          icon: Icons.shopping_cart,
                          label: 'Purchase Date',
                          value: _formatDate(vehicle.purchaseDateAsDateTime!),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Notes section (if available)
                if (vehicle.notes != null && vehicle.notes!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        vehicle.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MaintenanceFormScreen(
                                      vehicleId: vehicle.id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.build),
                              label: const Text('Add Service'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ReminderFormScreen(
                                      vehicleId: vehicle.id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.notifications),
                              label: const Text('Add Reminder'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DocumentFormScreen(
                                  vehicleId: vehicle.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.description),
                          label: const Text('Add Document'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Maintenance Summary Card
                Consumer(
                  builder: (context, ref, child) {
                    final maintenanceCountAsync = ref.watch(maintenanceCountProvider(vehicle.id));
                    final totalCostAsync = ref.watch(totalMaintenanceCostProvider(vehicle.id));

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MaintenanceListScreen(
                                vehicleId: vehicle.id,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.build_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Maintenance History',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        maintenanceCountAsync.when(
                                          data: (count) => Text(
                                            '$count services',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          loading: () => const Text('Loading...'),
                                          error: (_, __) => const Text('--'),
                                        ),
                                        const Text(' • '),
                                        totalCostAsync.when(
                                          data: (cost) => Text(
                                            '\$${cost.toStringAsFixed(2)} total',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          loading: () => const Text('Loading...'),
                                          error: (_, __) => const Text('--'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Reminders Summary Card
                Consumer(
                  builder: (context, ref, child) {
                    final reminderCountAsync = ref.watch(reminderCountProvider(vehicle.id));

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RemindersListScreen(
                                vehicleId: vehicle.id,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.notifications_active,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Reminders',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    reminderCountAsync.when(
                                      data: (count) => Text(
                                        '$count reminder${count != 1 ? 's' : ''} set',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      loading: () => const Text('Loading...'),
                                      error: (_, __) => const Text('--'),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Documents Summary Card
                Consumer(
                  builder: (context, ref, child) {
                    final documentCountAsync = ref.watch(documentCountProvider(vehicle.id));

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DocumentsListScreen(
                                vehicleId: vehicle.id,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.description,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Documents',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    documentCountAsync.when(
                                      data: (count) => Text(
                                        '$count document${count != 1 ? 's' : ''} stored',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      loading: () => const Text('Loading...'),
                                      error: (_, __) => const Text('--'),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToEdit(BuildContext context, vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VehicleFormScreen(vehicle: vehicle),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String vehicleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Are you sure you want to delete this vehicle? This will also delete all associated maintenance records, reminders, and documents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteVehicle(context, ref, vehicleId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(BuildContext context, WidgetRef ref, String vehicleId) async {
    try {
      final repository = ref.read(vehicleRepositoryProvider);
      await repository.deleteVehicleById(vehicleId);

      // Refresh providers
      ref.invalidate(vehiclesStreamProvider);
      ref.invalidate(vehicleCountProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle deleted successfully')),
        );
        Navigator.of(context).pop();
      }
    } on RepositoryException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
