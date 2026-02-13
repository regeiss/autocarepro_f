// Maintenance List Tile Widget - reusable list item for maintenance records
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';

class MaintenanceListTile extends StatelessWidget {
  final MaintenanceRecord record;
  final VoidCallback? onTap;

  const MaintenanceListTile({
    super.key,
    required this.record,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serviceDate = DateTime.fromMillisecondsSinceEpoch(record.serviceDate);
    final formattedDate = DateFormat.yMMMd().format(serviceDate);
    final serviceType = ServiceType.fromDisplayName(record.serviceType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Service Type and Cost
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Type Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getServiceTypeColor(serviceType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getServiceTypeIcon(serviceType),
                      color: _getServiceTypeColor(serviceType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Service Type Name and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceType.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (record.description != null && record.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            record.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Cost
                  if (record.cost != null)
                    Text(
                      '\$${record.cost!.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Footer: Date, Mileage, Service Provider
              Row(
                children: [
                  // Date
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (record.mileage != null) ...[
                    const SizedBox(width: 16),
                    // Mileage
                    Icon(
                      Icons.speed,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatNumber(record.mileage!.toInt())} mi',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const Spacer(),
                  // Service Provider
                  if (record.serviceProvider != null) ...[
                    Icon(
                      Icons.store,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        record.serviceProvider!,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              // Parts Replaced Indicator
              if (record.partsReplacedJson != null && record.partsReplacedJson!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Parts replaced',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              // Receipt Photo Indicator
              if (record.receiptPhotoPath != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 16,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Receipt attached',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceTypeIcon(ServiceType type) {
    switch (type) {
      case ServiceType.oilChange:
        return Icons.oil_barrel;
      case ServiceType.tireRotation:
        return Icons.tire_repair;
      case ServiceType.brakeService:
        return Icons.motion_photos_pause;
      case ServiceType.batteryReplacement:
        return Icons.battery_charging_full;
      case ServiceType.airFilter:
        return Icons.air;
      case ServiceType.transmission:
        return Icons.sync;
      case ServiceType.coolant:
        return Icons.water_drop;
      case ServiceType.sparkPlugs:
        return Icons.electric_bolt;
      case ServiceType.alignment:
        return Icons.straighten;
      case ServiceType.inspection:
        return Icons.fact_check;
      case ServiceType.registration:
        return Icons.description;
      case ServiceType.insurance:
        return Icons.shield;
      case ServiceType.cleaning:
        return Icons.local_car_wash;
      case ServiceType.other:
        return Icons.build;
    }
  }

  Color _getServiceTypeColor(ServiceType type) {
    switch (type) {
      case ServiceType.oilChange:
        return Colors.amber;
      case ServiceType.tireRotation:
        return Colors.grey;
      case ServiceType.brakeService:
        return Colors.red;
      case ServiceType.batteryReplacement:
        return Colors.green;
      case ServiceType.airFilter:
        return Colors.lightBlue;
      case ServiceType.transmission:
        return Colors.purple;
      case ServiceType.coolant:
        return Colors.cyan;
      case ServiceType.sparkPlugs:
        return Colors.orange;
      case ServiceType.alignment:
        return Colors.indigo;
      case ServiceType.inspection:
        return Colors.blue;
      case ServiceType.registration:
        return Colors.teal;
      case ServiceType.insurance:
        return Colors.deepPurple;
      case ServiceType.cleaning:
        return Colors.lightGreen;
      case ServiceType.other:
        return Colors.brown;
    }
  }

  String _formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }
}
