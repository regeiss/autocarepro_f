// Service for generating PDF reports and exporting data
library;

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/models.dart';

class ReportGeneratorService {
  static final ReportGeneratorService _instance = ReportGeneratorService._internal();
  factory ReportGeneratorService() => _instance;
  ReportGeneratorService._internal();

  final _dateFormat = DateFormat('MMM d, yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  // ============================================================================
  // PDF Report Generation
  // ============================================================================

  /// Generate comprehensive vehicle maintenance report
  Future<File> generateVehicleMaintenanceReport({
    required Vehicle vehicle,
    required List<MaintenanceRecord> records,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Filter records by date if specified
    var filteredRecords = records;
    if (startDate != null || endDate != null) {
      filteredRecords = records.where((record) {
        final date = DateTime.fromMillisecondsSinceEpoch(record.serviceDate);
        if (startDate != null && date.isBefore(startDate)) return false;
        if (endDate != null && date.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    // Sort by date (newest first)
    filteredRecords.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

    // Calculate statistics
    final totalCost = filteredRecords.fold(0.0, (sum, r) => sum + (r.cost ?? 0));
    final avgCost = filteredRecords.isNotEmpty ? totalCost / filteredRecords.length : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Vehicle Maintenance Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated: ${_dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                if (startDate != null || endDate != null)
                  pw.Text(
                    'Period: ${startDate != null ? _dateFormat.format(startDate) : 'Start'} - ${endDate != null ? _dateFormat.format(endDate) : 'Present'}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Summary Statistics
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Total Services', '${filteredRecords.length}'),
                    _buildStatItem('Total Cost', _currencyFormat.format(totalCost)),
                    _buildStatItem('Average Cost', _currencyFormat.format(avgCost)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Maintenance Records Table
          pw.Text(
            'Service History',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),

          if (filteredRecords.isEmpty)
            pw.Text('No maintenance records found for this period.')
          else
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
              headers: ['Date', 'Service Type', 'Cost', 'Mileage', 'Provider'],
              data: filteredRecords.map((record) {
                return [
                  _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(record.serviceDate)),
                  record.serviceType,
                  record.cost != null ? _currencyFormat.format(record.cost) : '-',
                  record.mileage != null ? '${record.mileage!.toStringAsFixed(0)} mi' : '-',
                  record.serviceProvider ?? '-',
                ];
              }).toList(),
            ),
        ],
      ),
    );

    // Save to file
    final output = await _getSaveDirectory();
    final file = File('${output.path}/vehicle_report_${vehicle.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Generate summary report for all vehicles
  Future<File> generateAllVehiclesReport({
    required List<Vehicle> vehicles,
    required Map<String, List<MaintenanceRecord>> maintenanceByVehicle,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Fleet Maintenance Summary',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated: ${_dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Overall Statistics
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Overall Statistics',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Total Vehicles', '${vehicles.length}'),
                    _buildStatItem(
                      'Total Services',
                      '${maintenanceByVehicle.values.fold(0, (sum, records) => sum + records.length)}',
                    ),
                    _buildStatItem(
                      'Total Cost',
                      _currencyFormat.format(
                        maintenanceByVehicle.values
                            .expand((records) => records)
                            .fold(0.0, (sum, r) => sum + (r.cost ?? 0)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Per-Vehicle Summary
          pw.Text(
            'Vehicle Summaries',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),

          ...vehicles.map((vehicle) {
            final records = maintenanceByVehicle[vehicle.id] ?? [];
            final totalCost = records.fold(0.0, (sum, r) => sum + (r.cost ?? 0));
            
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Services: ${records.length}'),
                      pw.Text('Total Cost: ${_currencyFormat.format(totalCost)}'),
                      pw.Text('Avg Cost: ${_currencyFormat.format(records.isNotEmpty ? totalCost / records.length : 0)}'),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    // Save to file
    final output = await _getSaveDirectory();
    final file = File('${output.path}/fleet_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // Data Export (CSV/JSON)
  // ============================================================================

  /// Export maintenance records to CSV
  Future<File> exportMaintenanceToCSV(List<MaintenanceRecord> records) async {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Date,Service Type,Description,Cost,Mileage,Service Provider,Notes');
    
    // Data rows
    for (var record in records) {
      final date = _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(record.serviceDate));
      final cost = record.cost?.toStringAsFixed(2) ?? '';
      final mileage = record.mileage?.toStringAsFixed(0) ?? '';
      final description = _escapeCsv(record.description ?? '');
      final provider = _escapeCsv(record.serviceProvider ?? '');
      final notes = _escapeCsv(record.notes ?? '');
      
      buffer.writeln('$date,${record.serviceType},$description,$cost,$mileage,$provider,$notes');
    }
    
    // Save to file
    final output = await _getSaveDirectory();
    final file = File('${output.path}/maintenance_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }

  /// Export vehicles to CSV
  Future<File> exportVehiclesToCSV(List<Vehicle> vehicles) async {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Year,Make,Model,VIN,License Plate,Mileage,Purchase Date');
    
    // Data rows
    for (var vehicle in vehicles) {
      final purchaseDate = vehicle.purchaseDate != null
          ? _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(vehicle.purchaseDate!))
          : '';
      final vin = _escapeCsv(vehicle.vin ?? '');
      final plate = _escapeCsv(vehicle.licensePlate ?? '');
      final mileage = vehicle.currentMileage?.toStringAsFixed(0) ?? '';
      
      buffer.writeln('${vehicle.year},${vehicle.make},${vehicle.model},$vin,$plate,$mileage,$purchaseDate');
    }
    
    // Save to file
    final output = await _getSaveDirectory();
    final file = File('${output.path}/vehicles_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<Directory> _getSaveDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${directory.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    return reportsDir;
  }

  // ============================================================================
  // Printing/Sharing
  // ============================================================================

  /// Print or share a PDF report
  Future<void> printReport(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
    );
  }

  /// Share PDF via system share sheet
  Future<void> shareReport(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }
}
