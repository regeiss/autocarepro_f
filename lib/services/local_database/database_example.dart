/// Example usage of the AutoCarePro database
/// 
/// This file demonstrates how to use the database in your app.
/// DO NOT import this file in production - it's just for reference.

import 'app_database.dart';
import '../../data/models/models.dart';

/// Example class demonstrating database operations
class DatabaseExample {
  late final AppDatabase database;

  /// Initialize the database
  Future<void> init() async {
    database = await DatabaseBuilder.build();
  }

  /// Example: Add a new vehicle
  Future<void> exampleAddVehicle() async {
    final vehicle = Vehicle.create(
      make: 'Toyota',
      model: 'Camry',
      year: 2020,
      currentMileage: 45000.0,
      licensePlate: 'ABC-1234',
      mileageUnit: 'miles',
    );

    await database.vehicleDao.insertVehicle(vehicle);
    print('Vehicle added: ${vehicle.displayName}');
  }

  /// Example: Get all vehicles
  Future<void> exampleGetAllVehicles() async {
    final vehicles = await database.vehicleDao.getAllVehicles();
    print('Found ${vehicles.length} vehicles');

    for (final vehicle in vehicles) {
      print('- ${vehicle.displayName} (${vehicle.currentMileage} ${vehicle.mileageUnit})');
    }
  }

  /// Example: Search vehicles
  Future<void> exampleSearchVehicles(String query) async {
    final results = await database.vehicleDao.searchVehicles(query);
    print('Search "$query" found ${results.length} results');
  }

  /// Example: Add maintenance record
  Future<void> exampleAddMaintenance(String vehicleId) async {
    final record = MaintenanceRecord.create(
      vehicleId: vehicleId,
      serviceType: ServiceType.oilChange.displayName,
      serviceDate: DateTime.now(),
      mileage: 45000.0,
      cost: 49.99,
      currency: 'USD',
      notes: 'Full synthetic oil',
    );

    await database.maintenanceRecordDao.insertRecord(record);
    print('Maintenance record added');
  }

  /// Example: Get maintenance history for a vehicle
  Future<void> exampleGetMaintenanceHistory(String vehicleId) async {
    final records = await database.maintenanceRecordDao
        .getRecordsByVehicleId(vehicleId);

    print('Found ${records.length} maintenance records');

    for (final record in records) {
      print('- ${record.serviceType} on ${record.serviceDateAsDateTime}');
    }
  }

  /// Example: Calculate total maintenance cost
  Future<void> exampleCalculateTotalCost(String vehicleId) async {
    final totalCost = await database.maintenanceRecordDao
        .getTotalCostByVehicle(vehicleId);

    print('Total maintenance cost: \$${totalCost?.toStringAsFixed(2) ?? "0.00"}');
  }

  /// Example: Add a reminder
  Future<void> exampleAddReminder(String vehicleId) async {
    final reminder = Reminder.create(
      vehicleId: vehicleId,
      serviceType: 'Oil Change',
      reminderType: ReminderType.mileage,
      intervalValue: 5000,
      intervalUnit: IntervalUnit.miles,
      lastServiceMileage: 45000.0,
    );

    await database.reminderDao.insertReminder(reminder);
    print('Reminder created for next oil change at 50,000 miles');
  }

  /// Example: Get active reminders
  Future<void> exampleGetActiveReminders() async {
    final reminders = await database.reminderDao.getActiveReminders();
    print('Active reminders: ${reminders.length}');

    for (final reminder in reminders) {
      print('- ${reminder.serviceType} (${reminder.reminderType})');
    }
  }

  /// Example: Get due reminders
  Future<void> exampleGetDueReminders() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final dueReminders = await database.reminderDao
        .getDueTimeReminders(currentTime);

    print('Due reminders: ${dueReminders.length}');
  }

  /// Example: Add service provider
  Future<void> exampleAddServiceProvider() async {
    final provider = ServiceProvider.create(
      name: 'Quick Lube Auto',
      phone: '555-1234',
      email: 'info@quicklube.com',
      address: '123 Main St',
      rating: 4.5,
      specialties: [
        ProviderSpecialty.oilChange,
        ProviderSpecialty.brakes,
        ProviderSpecialty.tires,
      ],
    );

    await database.serviceProviderDao.insertProvider(provider);
    print('Service provider added: ${provider.name}');
  }

  /// Example: Get top-rated providers
  Future<void> exampleGetTopProviders() async {
    final topProviders = await database.serviceProviderDao
        .getTopRatedProviders(5);

    print('Top 5 service providers:');
    for (final provider in topProviders) {
      print('- ${provider.name} (${provider.rating}★)');
    }
  }

  /// Example: Add document
  Future<void> exampleAddDocument(String vehicleId) async {
    final document = Document.create(
      vehicleId: vehicleId,
      documentType: DocumentType.receipt,
      filePath: '/path/to/receipt.jpg',
      title: 'Oil Change Receipt',
      description: 'Receipt from Quick Lube Auto',
      fileSize: 1024 * 500, // 500 KB
      mimeType: 'image/jpeg',
    );

    await database.documentDao.insertDocument(document);
    print('Document added: ${document.title}');
  }

  /// Example: Get documents for a vehicle
  Future<void> exampleGetDocuments(String vehicleId) async {
    final documents = await database.documentDao
        .getDocumentsByVehicleId(vehicleId);

    print('Found ${documents.length} documents');

    for (final doc in documents) {
      print('- ${doc.title} (${doc.fileSizeFormatted})');
    }
  }

  /// Example: Update vehicle mileage
  Future<void> exampleUpdateMileage(String vehicleId, double newMileage) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await database.vehicleDao.updateVehicleMileage(
      vehicleId,
      newMileage,
      timestamp,
    );

    print('Mileage updated to $newMileage');
  }

  /// Example: Delete vehicle (cascade deletes related records)
  Future<void> exampleDeleteVehicle(String vehicleId) async {
    await database.vehicleDao.deleteVehicleById(vehicleId);
    print('Vehicle deleted (including all related records)');
  }

  /// Example: Using streams for reactive UI
  Stream<List<Vehicle>> exampleWatchVehicles() {
    // This stream will automatically emit new data when vehicles change
    return database.vehicleDao.watchAllVehicles();
  }

  /// Example: Complete workflow - Add vehicle with maintenance and reminders
  Future<void> exampleCompleteWorkflow() async {
    // 1. Add a vehicle
    final vehicle = Vehicle.create(
      make: 'Honda',
      model: 'Accord',
      year: 2021,
      currentMileage: 12000.0,
    );
    await database.vehicleDao.insertVehicle(vehicle);

    // 2. Add maintenance record
    final maintenance = MaintenanceRecord.create(
      vehicleId: vehicle.id,
      serviceType: ServiceType.oilChange.displayName,
      serviceDate: DateTime.now(),
      mileage: 12000.0,
      cost: 59.99,
    );
    await database.maintenanceRecordDao.insertRecord(maintenance);

    // 3. Add reminder for next oil change
    final reminder = Reminder.create(
      vehicleId: vehicle.id,
      serviceType: 'Oil Change',
      reminderType: ReminderType.mileage,
      intervalValue: 5000,
      intervalUnit: IntervalUnit.miles,
      lastServiceMileage: 12000.0,
    );
    await database.reminderDao.insertReminder(reminder);

    // 4. Get vehicle statistics
    final recordCount = await database.maintenanceRecordDao
        .getRecordCountByVehicle(vehicle.id);
    final totalCost = await database.maintenanceRecordDao
        .getTotalCostByVehicle(vehicle.id);

    print('Vehicle setup complete!');
    print('- Vehicle: ${vehicle.displayName}');
    print('- Maintenance records: $recordCount');
    print('- Total cost: \$${totalCost?.toStringAsFixed(2)}');
    print('- Active reminders: 1');
  }

  /// Close database connection
  Future<void> close() async {
    await database.close();
  }
}

/// Run all examples (for testing purposes only)
Future<void> runAllExamples() async {
  final example = DatabaseExample();
  
  try {
    // Initialize database
    await example.init();
    print('✅ Database initialized\n');

    // Run complete workflow example
    await example.exampleCompleteWorkflow();
    print('\n✅ Complete workflow executed');

    // Get all vehicles
    await example.exampleGetAllVehicles();
    print('\n✅ Retrieved all vehicles');

  } catch (e) {
    print('❌ Error: $e');
  } finally {
    await example.close();
    print('\n✅ Database closed');
  }
}

// Uncomment to run examples (for testing only):
// void main() async {
//   await runAllExamples();
// }
