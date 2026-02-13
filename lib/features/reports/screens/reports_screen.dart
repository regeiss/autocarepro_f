// Reports and export screen
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/vehicle_providers.dart';
import '../../../data/providers/analytics_providers.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../services/report_generator_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? _selectedVehicleId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;

  final _reportService = ReportGeneratorService();
  final _dateFormat = DateFormat('MMM d, yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Export'),
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No vehicles available for reports'),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Vehicle Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Vehicle',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        value: _selectedVehicleId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Vehicles'),
                          ),
                          ...vehicles.map((vehicle) {
                            return DropdownMenuItem(
                              value: vehicle.id,
                              child: Text(
                                '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedVehicleId = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date Range Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Range (Optional)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectStartDate(context),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _startDate != null
                                    ? _dateFormat.format(_startDate!)
                                    : 'Start Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectEndDate(context),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _endDate != null
                                    ? _dateFormat.format(_endDate!)
                                    : 'End Date',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_startDate != null || _endDate != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear Dates'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Statistics Preview
              if (_selectedVehicleId != null)
                _buildVehicleStats(_selectedVehicleId!)
              else
                _buildAllVehiclesStats(),

              const SizedBox(height: 16),

              // Generate PDF Report
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(
                            'PDF Reports',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : () => _generatePDFReport(vehicles),
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: Text(_isGenerating ? 'Generating...' : 'Generate PDF Report'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Export Data
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.download, color: Colors.green),
                          const SizedBox(width: 12),
                          Text(
                            'Export Data',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isGenerating ? null : () => _exportMaintenanceCSV(vehicles),
                              icon: const Icon(Icons.description),
                              label: const Text('Maintenance CSV'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isGenerating ? null : () => _exportVehiclesCSV(vehicles),
                              icon: const Icon(Icons.directions_car),
                              label: const Text('Vehicles CSV'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVehicleStats(String vehicleId) {
    final analyticsAsync = ref.watch(maintenanceCostAnalyticsProvider(vehicleId));

    return analyticsAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (analytics) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Total Services',
                      '${analytics.serviceCount}',
                      Icons.build,
                    ),
                    _buildStatColumn(
                      'Total Cost',
                      _currencyFormat.format(analytics.totalCost),
                      Icons.attach_money,
                    ),
                    _buildStatColumn(
                      'Avg Cost',
                      _currencyFormat.format(analytics.averageCost),
                      Icons.analytics,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllVehiclesStats() {
    final analyticsAsync = ref.watch(allVehiclesAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (analytics) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fleet Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatColumn(
                      'Vehicles',
                      '${analytics.totalVehicles}',
                      Icons.directions_car,
                    ),
                    _buildStatColumn(
                      'Services',
                      '${analytics.totalMaintenanceRecords}',
                      Icons.build,
                    ),
                    _buildStatColumn(
                      'Total Cost',
                      _currencyFormat.format(analytics.totalMaintenanceCost),
                      Icons.attach_money,
                    ),
                    _buildStatColumn(
                      'Avg/Vehicle',
                      _currencyFormat.format(analytics.averageCostPerVehicle),
                      Icons.analytics,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _generatePDFReport(List<Vehicle> vehicles) async {
    setState(() => _isGenerating = true);

    try {
      File? pdfFile;

      if (_selectedVehicleId != null) {
        // Single vehicle report
        final vehicle = vehicles.firstWhere((v) => v.id == _selectedVehicleId);
        final maintenanceRepo = ref.read(maintenanceRepositoryProvider);
        final records = await maintenanceRepo.getRecordsByVehicle(_selectedVehicleId!);

        pdfFile = await _reportService.generateVehicleMaintenanceReport(
          vehicle: vehicle,
          records: records,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        // All vehicles report
        final maintenanceRepo = ref.read(maintenanceRepositoryProvider);
        final maintenanceByVehicle = <String, List<MaintenanceRecord>>{};
        
        for (var vehicle in vehicles) {
          maintenanceByVehicle[vehicle.id] =
              await maintenanceRepo.getRecordsByVehicle(vehicle.id);
        }

        pdfFile = await _reportService.generateAllVehiclesReport(
          vehicles: vehicles,
          maintenanceByVehicle: maintenanceByVehicle,
        );
      }

      setState(() => _isGenerating = false);

      if (mounted) {
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Report Generated'),
            content: const Text('What would you like to do with the report?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('open'),
                child: const Text('Open'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('share'),
                child: const Text('Share'),
              ),
            ],
          ),
        );

        if (action == 'open') {
          await OpenFile.open(pdfFile.path);
        } else if (action == 'share') {
          await _reportService.shareReport(pdfFile);
        }
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    }
  }

  Future<void> _exportMaintenanceCSV(List<Vehicle> vehicles) async {
    setState(() => _isGenerating = true);

    try {
      final maintenanceRepo = ref.read(maintenanceRepositoryProvider);
      List<MaintenanceRecord> records;

      if (_selectedVehicleId != null) {
        records = await maintenanceRepo.getRecordsByVehicle(_selectedVehicleId!);
      } else {
        records = await maintenanceRepo.getAllRecords();
      }

      // Apply date filter if set
      if (_startDate != null || _endDate != null) {
        records = records.where((record) {
          final date = DateTime.fromMillisecondsSinceEpoch(record.serviceDate);
          if (_startDate != null && date.isBefore(_startDate!)) return false;
          if (_endDate != null && date.isAfter(_endDate!)) return false;
          return true;
        }).toList();
      }

      final file = await _reportService.exportMaintenanceToCSV(records);

      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${records.length} records to CSV'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }

  Future<void> _exportVehiclesCSV(List<Vehicle> vehicles) async {
    setState(() => _isGenerating = true);

    try {
      final vehiclesToExport = _selectedVehicleId != null
          ? vehicles.where((v) => v.id == _selectedVehicleId).toList()
          : vehicles;

      final file = await _reportService.exportVehiclesToCSV(vehiclesToExport);

      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${vehiclesToExport.length} vehicles to CSV'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }
}
