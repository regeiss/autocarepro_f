// Maintenance List Screen - displays all maintenance records for a vehicle
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/maintenance_providers.dart';
import '../widgets/maintenance_list_tile.dart';
import '../../dashboard/widgets/empty_state.dart';
import 'maintenance_form_screen.dart';
import 'maintenance_detail_screen.dart';

class MaintenanceListScreen extends ConsumerWidget {
  final String vehicleId;

  const MaintenanceListScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(maintenanceStreamProvider(vehicleId));
    final costStatsAsync = ref.watch(costStatisticsProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Records'),
      ),
      body: Column(
        children: [
          // Cost Statistics Card
          costStatsAsync.when(
            data: (stats) => _buildStatsCard(context, stats),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Maintenance List
          Expanded(
            child: maintenanceAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return EmptyState(
                    icon: Icons.build_circle_outlined,
                    title: 'No Maintenance Records',
                    message: 'Add your first maintenance record to track service history',
                    actionLabel: 'Add Maintenance',
                    onAction: () => _navigateToAddMaintenance(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(maintenanceStreamProvider(vehicleId));
                    ref.invalidate(costStatisticsProvider(vehicleId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return MaintenanceListTile(
                        record: record,
                        onTap: () => _navigateToDetail(context, record.id),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${error.toString()}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(maintenanceStreamProvider(vehicleId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMaintenance(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
    );
  }

  void _navigateToAddMaintenance(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceFormScreen(
          vehicleId: vehicleId,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String maintenanceId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceDetailScreen(
          maintenanceId: maintenanceId,
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, Map<String, dynamic> stats) {
    final count = stats['count'] as int;
    
    if (count == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              'Total Spent',
              '\$${stats['total'].toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildStatItem(
              context,
              'Services',
              '${stats['count']}',
              Icons.build,
              Colors.blue,
            ),
            _buildStatItem(
              context,
              'Average',
              '\$${stats['average'].toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
