import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/vehicle_providers.dart';
import '../../../data/providers/maintenance_providers.dart';
import '../../../data/providers/reminder_providers.dart';
import '../../../data/providers/document_providers.dart';
import '../../../data/providers/service_provider_providers.dart';
import '../../../data/providers/analytics_providers.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/empty_state.dart';
import '../../vehicles/screens/vehicle_form_screen.dart';
import '../../vehicles/screens/vehicles_list_screen.dart';
import '../../maintenance/widgets/maintenance_list_tile.dart';
import '../../maintenance/screens/maintenance_detail_screen.dart';
import '../../reminders/widgets/reminder_list_tile.dart';
import '../../reminders/screens/reminder_detail_screen.dart';
import '../../documents/widgets/document_list_tile.dart';
import '../../documents/screens/document_detail_screen.dart';
import '../../service_providers/widgets/service_provider_list_tile.dart';
import '../../service_providers/screens/service_provider_detail_screen.dart';
import '../../service_providers/screens/service_providers_list_screen.dart';
import '../../reports/screens/reports_screen.dart';

/// Dashboard screen - Main entry point of the app
/// 
/// Displays:
/// - Summary statistics
/// - Vehicle cards (horizontal scroll)
/// - Upcoming reminders
/// - Recent maintenance
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCarePro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: vehiclesAsync.when(
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
                'Error loading data',
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
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car,
              title: 'No Vehicles Yet',
              message: 'Add your first vehicle to start tracking maintenance',
              actionLabel: 'Add Vehicle',
              onAction: () => _navigateToAddVehicle(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(vehiclesStreamProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary statistics
                  const DashboardStats(),

                  const SizedBox(height: 16),

                  // Vehicles section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Vehicles',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () => _navigateToVehiclesList(context),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Horizontal vehicle cards
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        return VehicleCard(vehicle: vehicles[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Upcoming reminders section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Upcoming Reminders',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Upcoming reminders list
                  Consumer(
                    builder: (context, ref, child) {
                      final upcomingRemindersAsync = ref.watch(upcomingRemindersProvider(5));

                      return upcomingRemindersAsync.when(
                        data: (reminders) {
                          if (reminders.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text('No upcoming reminders'),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: reminders.map((reminder) {
                                return ReminderListTile(
                                  reminder: reminder,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ReminderDetailScreen(
                                          reminderId: reminder.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('Error loading reminders'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent maintenance section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Recent Maintenance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Recent maintenance list
                  Consumer(
                    builder: (context, ref, child) {
                      final recentMaintenanceAsync = ref.watch(recentMaintenanceProvider(5));

                      return recentMaintenanceAsync.when(
                        data: (records) {
                          if (records.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text('No maintenance records yet'),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: records.map((record) {
                                return MaintenanceListTile(
                                  record: record,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => MaintenanceDetailScreen(
                                          maintenanceId: record.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('Error loading maintenance'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Documents header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Recent Documents',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Recent documents list
                  Consumer(
                    builder: (context, ref, child) {
                      final recentDocumentsAsync = ref.watch(recentDocumentsProvider(5));

                      return recentDocumentsAsync.when(
                        data: (documents) {
                          if (documents.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text('No documents yet'),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: documents.map((document) {
                                return DocumentListTile(
                                  document: document,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => DocumentDetailScreen(
                                          documentId: document.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('Error loading documents'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Top Service Providers header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Service Providers',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ServiceProvidersListScreen(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Top providers list
                  Consumer(
                    builder: (context, ref, child) {
                      final topProvidersAsync = ref.watch(topRatedProvidersProvider(3));

                      return topProvidersAsync.when(
                        data: (providers) {
                          if (providers.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text('No service providers yet'),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: providers.map((provider) {
                                return ServiceProviderListTile(
                                  provider: provider,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ServiceProviderDetailScreen(
                                          providerId: provider.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('Error loading providers'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Reports & Analytics Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ReportsScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.assessment,
                                    color: Theme.of(context).primaryColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reports & Export',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Generate PDF reports and export your data',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 12),
                              Consumer(
                                builder: (context, ref, child) {
                                  final analyticsAsync = ref.watch(allVehiclesAnalyticsProvider);
                                  
                                  return analyticsAsync.when(
                                    data: (analytics) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildQuickStat(
                                            context,
                                            Icons.directions_car,
                                            '${analytics.totalVehicles}',
                                            'Vehicles',
                                          ),
                                          _buildQuickStat(
                                            context,
                                            Icons.build,
                                            '${analytics.totalMaintenanceRecords}',
                                            'Services',
                                          ),
                                          _buildQuickStat(
                                            context,
                                            Icons.description,
                                            '${analytics.totalDocuments}',
                                            'Documents',
                                          ),
                                        ],
                                      );
                                    },
                                    loading: () => const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    error: (_, __) => const SizedBox.shrink(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddVehicle(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _navigateToAddVehicle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VehicleFormScreen(),
      ),
    );
  }

  void _navigateToVehiclesList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VehiclesListScreen(),
      ),
    );
  }
}
