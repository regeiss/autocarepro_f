import 'package:flutter/material.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../app/theme.dart';

/// Vehicle list tile widget
/// 
/// Displays vehicle information in a list tile format.
class VehicleListTile extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;

  const VehicleListTile({
    super.key,
    required this.vehicle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.directions_car,
            color: AppTheme.primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          vehicle.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (vehicle.licensePlate != null)
              Text('License: ${vehicle.licensePlate}'),
            if (vehicle.currentMileage != null)
              Text(
                'Mileage: ${vehicle.currentMileage!.toStringAsFixed(0)} ${vehicle.mileageUnit}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
