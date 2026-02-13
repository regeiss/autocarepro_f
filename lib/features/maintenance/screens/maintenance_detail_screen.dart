// Maintenance Detail Screen - view full maintenance record details
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/maintenance_providers.dart';
import '../../../data/providers/repository_providers.dart';
import 'maintenance_form_screen.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final String maintenanceId;

  const MaintenanceDetailScreen({
    super.key,
    required this.maintenanceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(maintenanceDetailProvider(maintenanceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Details'),
        actions: [
          recordAsync.when(
            data: (record) {
              if (record == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEdit(context, record);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref, record);
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
      body: recordAsync.when(
        data: (record) {
          if (record == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Maintenance record not found'),
                ],
              ),
            );
          }
          return _buildContent(context, record);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(maintenanceDetailProvider(maintenanceId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MaintenanceRecord record) {
    final theme = Theme.of(context);
    final serviceDate = DateTime.fromMillisecondsSinceEpoch(record.serviceDate);
    final serviceType = ServiceType.fromDisplayName(record.serviceType);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Service Type Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getServiceTypeColor(serviceType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getServiceTypeIcon(serviceType),
                    color: _getServiceTypeColor(serviceType),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  serviceType.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (record.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    record.description!,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cost Card
        if (record.cost != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Total Cost',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${record.cost!.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Details Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailTile(
                  icon: Icons.calendar_today,
                  label: 'Service Date',
                  value: DateFormat.yMMMd().format(serviceDate),
                ),
                if (record.mileage != null)
                  _DetailTile(
                    icon: Icons.speed,
                    label: 'Mileage',
                    value: '${_formatNumber(record.mileage!.toInt())} mi',
                  ),
                if (record.serviceProvider != null)
                  _DetailTile(
                    icon: Icons.store,
                    label: 'Service Provider',
                    value: record.serviceProvider!,
                  ),
              ],
            ),
          ),
        ),

        // Parts Replaced Card
        if (record.partsReplacedJson != null && record.partsReplacedJson!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.construction, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Parts Replaced',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    record.partsReplacedJson!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Receipt Photo Card
        if (record.receiptPhotoPath != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 8),
                      Text(
                        'Receipt Photo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () => _showFullScreenImage(context, record.receiptPhotoPath!),
                      child: Hero(
                        tag: 'receipt_${record.id}',
                        child: Image.file(
                          File(record.receiptPhotoPath!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tap to view full size',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Notes Card
        if (record.notes != null && record.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    record.notes!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Metadata Card
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Info',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(record.createdAt))}',
                  style: theme.textTheme.bodySmall,
                ),
                if (record.updatedAt != record.createdAt)
                  Text(
                    'Updated: ${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(record.updatedAt))}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  void _navigateToEdit(BuildContext context, MaintenanceRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceFormScreen(
          vehicleId: record.vehicleId,
          record: record,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, MaintenanceRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance Record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(maintenanceRepositoryProvider);
        await repository.deleteRecordById(record.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance record deleted')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Hero(
              tag: 'receipt_$maintenanceId',
              child: InteractiveViewer(
                child: Image.file(File(imagePath)),
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
