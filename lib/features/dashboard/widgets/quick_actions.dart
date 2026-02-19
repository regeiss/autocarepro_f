import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/providers/vehicle_providers.dart';
import '../../vehicles/screens/vehicle_form_screen.dart';
import '../../maintenance/screens/maintenance_form_screen.dart';
import '../../reminders/screens/reminder_form_screen.dart';
import '../../documents/screens/document_form_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../../app/theme.dart';

/// Quick action buttons for common dashboard tasks
class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);

    return vehiclesAsync.when(
      data: (vehicles) => _QuickActionsContent(vehicles: vehicles),
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _QuickActionsContent extends StatelessWidget {
  final List<Vehicle> vehicles;

  const _QuickActionsContent({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'Add Vehicle',
              onTap: () => _navigateToAddVehicle(context),
            ),
            _QuickActionButton(
              icon: Icons.build_circle_outlined,
              label: 'Log Service',
              onTap: () => _navigateToMaintenance(context),
            ),
            _QuickActionButton(
              icon: Icons.notifications_active_outlined,
              label: 'Reminder',
              onTap: () => _navigateToReminder(context),
            ),
            _QuickActionButton(
              icon: Icons.description_outlined,
              label: 'Document',
              onTap: () => _navigateToDocument(context),
            ),
            _QuickActionButton(
              icon: Icons.assessment_outlined,
              label: 'Reports',
              onTap: () => _navigateToReports(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddVehicle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VehicleFormScreen(),
      ),
    );
  }

  void _navigateToMaintenance(BuildContext context) {
    if (vehicles.isEmpty) {
      _navigateToAddVehicle(context);
      return;
    }
    if (vehicles.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MaintenanceFormScreen(vehicleId: vehicles.first.id),
        ),
      );
    } else {
      _showVehiclePicker(
        context,
        title: 'Select vehicle for service',
        onSelected: (vehicle) {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MaintenanceFormScreen(vehicleId: vehicle.id),
            ),
          );
        },
      );
    }
  }

  void _navigateToReminder(BuildContext context) {
    if (vehicles.isEmpty) {
      _navigateToAddVehicle(context);
      return;
    }
    if (vehicles.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReminderFormScreen(vehicleId: vehicles.first.id),
        ),
      );
    } else {
      _showVehiclePicker(
        context,
        title: 'Select vehicle for reminder',
        onSelected: (vehicle) {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReminderFormScreen(vehicleId: vehicle.id),
            ),
          );
        },
      );
    }
  }

  void _navigateToDocument(BuildContext context) {
    if (vehicles.isEmpty) {
      _navigateToAddVehicle(context);
      return;
    }
    if (vehicles.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DocumentFormScreen(vehicleId: vehicles.first.id),
        ),
      );
    } else {
      _showVehiclePicker(
        context,
        title: 'Select vehicle for document',
        onSelected: (vehicle) {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DocumentFormScreen(vehicleId: vehicle.id),
            ),
          );
        },
      );
    }
  }

  void _navigateToReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportsScreen(),
      ),
    );
  }

  void _showVehiclePicker(
    BuildContext context, {
    required String title,
    required void Function(Vehicle) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...vehicles.map(
              (vehicle) => ListTile(
                leading: Icon(Icons.directions_car, color: AppTheme.primaryColor),
                title: Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
                onTap: () => onSelected(vehicle),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: AppTheme.primaryColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
