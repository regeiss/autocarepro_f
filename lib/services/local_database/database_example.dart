/// Example usage of the AutoCarePro database
/// 
/// This file demonstrates how to use the database in your app.
/// DO NOT import this file in production - it's just for reference.
library;

import 'app_database.dart';
import '../../data/models/models.dart';
import '../app_logger.dart';

/// Example class demonstrating database operations
class DatabaseExample {
  late final AppDatabase database;

  /// Initialize the database
  Future<void> init() async {
    database = await DatabaseBuilder.build();
  }

  /// Example: Add a new vehicle
  Future<void> exampleAddVehicle(String profileId) async {
    final vehicle = Vehicle.create(
      profileId: profileId,
      make: 'Toyota',
      model: 'Camry',
      year: 2020,
      currentMileage: 45000.0,
      licensePlate: 'ABC-1234',
      mileageUnit: 'miles',
    );

    await database.vehicleDao.insertVehicle(vehicle);
    AppLogger.info('Vehicle added: ${vehicle.displayName}', tag: 'DatabaseExample');
  }

  /// Example: Get all vehicles
  Future<void> exampleGetAllVehicles() async {
    final vehicles = await database.vehicleDao.getAllVehicles();
    AppLogger.info('Found ${vehicles.length} vehicles', tag: 'DatabaseExample');

    for (final vehicle in vehicles) {
      AppLogger.debug('- ${vehicle.displayName} (${vehicle.currentMileage} ${vehicle.mileageUnit})', tag: 'DatabaseExample');
    }
  }

  /// Example: Search vehicles
  Future<void> exampleSearchVehicles(String profileId, String query) async {
    final results = await database.vehicleDao.searchVehicles(profileId, query);
    AppLogger.info('Search "$query" found ${results.length} results', tag: 'DatabaseExample');
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
    AppLogger.info('Maintenance record added', tag: 'DatabaseExample');
  }

  /// Example: Get maintenance history for a vehicle
  Future<void> exampleGetMaintenanceHistory(String vehicleId) async {
    final records = await database.maintenanceRecordDao
        .getRecordsByVehicleId(vehicleId);

    AppLogger.info('Found ${records.length} maintenance records', tag: 'DatabaseExample');

    for (final record in records) {
      AppLogger.debug('- ${record.serviceType} on ${record.serviceDateAsDateTime}', tag: 'DatabaseExample');
    }
  }

  /// Example: Calculate total maintenance cost
  Future<void> exampleCalculateTotalCost(String vehicleId) async {
    final totalCost = await database.maintenanceRecordDao
        .getTotalCostByVehicle(vehicleId);

    AppLogger.info('Total maintenance cost: \$${totalCost?.toStringAsFixed(2) ?? "0.00"}', tag: 'DatabaseExample');
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
    AppLogger.info('Reminder created for next oil change at 50,000 miles', tag: 'DatabaseExample');
  }

  /// Example: Get active reminders
  Future<void> exampleGetActiveReminders() async {
    final reminders = await database.reminderDao.getActiveReminders();
    AppLogger.info('Active reminders: ${reminders.length}', tag: 'DatabaseExample');

    for (final reminder in reminders) {
      AppLogger.debug('- ${reminder.serviceType} (${reminder.reminderType})', tag: 'DatabaseExample');
    }
  }

  /// Example: Get due reminders
  Future<void> exampleGetDueReminders() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final dueReminders = await database.reminderDao
        .getDueTimeReminders(currentTime);

    AppLogger.info('Due reminders: ${dueReminders.length}', tag: 'DatabaseExample');
  }

  /// Example: Add service provider
  Future<void> exampleAddServiceProvider(String profileId) async {
    final provider = ServiceProvider.create(
      profileId: profileId,
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
    AppLogger.info('Service provider added: ${provider.name}', tag: 'DatabaseExample');
  }

  /// Example: Get top-rated providers
  Future<void> exampleGetTopProviders() async {
    final topProviders = await database.serviceProviderDao
        .getTopRatedProviders(5);

    AppLogger.info('Top 5 service providers:', tag: 'DatabaseExample');
    for (final provider in topProviders) {
      AppLogger.debug('- ${provider.name} (${provider.rating}★)', tag: 'DatabaseExample');
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
    AppLogger.info('Document added: ${document.title}', tag: 'DatabaseExample');
  }

  /// Example: Get documents for a vehicle
  Future<void> exampleGetDocuments(String vehicleId) async {
    final documents = await database.documentDao
        .getDocumentsByVehicleId(vehicleId);

    AppLogger.info('Found ${documents.length} documents', tag: 'DatabaseExample');

    for (final doc in documents) {
      AppLogger.debug('- ${doc.title} (${doc.fileSizeFormatted})', tag: 'DatabaseExample');
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

    AppLogger.info('Mileage updated to $newMileage', tag: 'DatabaseExample');
  }

  /// Example: Delete vehicle (cascade deletes related records)
  Future<void> exampleDeleteVehicle(String vehicleId) async {
    await database.vehicleDao.deleteVehicleById(vehicleId);
    AppLogger.info('Vehicle deleted (including all related records)', tag: 'DatabaseExample');
  }

  /// Example: Using streams for reactive UI
  Stream<List<Vehicle>> exampleWatchVehicles() {
    // This stream will automatically emit new data when vehicles change
    return database.vehicleDao.watchAllVehicles();
  }

  /// Example: Complete workflow - Add vehicle with maintenance and reminders
  Future<void> exampleCompleteWorkflow(String profileId) async {
    // 1. Add a vehicle
    final vehicle = Vehicle.create(
      profileId: profileId,
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

    AppLogger.info('Vehicle setup complete!', tag: 'DatabaseExample');
    AppLogger.info('- Vehicle: ${vehicle.displayName}', tag: 'DatabaseExample');
    AppLogger.info('- Maintenance records: $recordCount', tag: 'DatabaseExample');
    AppLogger.info('- Total cost: \$${totalCost?.toStringAsFixed(2)}', tag: 'DatabaseExample');
    AppLogger.info('- Active reminders: 1', tag: 'DatabaseExample');
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
    AppLogger.info('Database initialized', tag: 'DatabaseExample');

    // Ensure we have a profile and run complete workflow example
    var profiles = await example.database.profileDao.getAllProfiles();
    if (profiles.isEmpty) {
      final defaultProfile = Profile.create(name: 'Default');
      await example.database.profileDao.insertProfile(defaultProfile);
      profiles = [defaultProfile];
    }
    await example.exampleCompleteWorkflow(profiles.first.id);
    AppLogger.info('Complete workflow executed', tag: 'DatabaseExample');

    // Get all vehicles
    await example.exampleGetAllVehicles();
    AppLogger.info('Retrieved all vehicles', tag: 'DatabaseExample');

  } catch (e, stackTrace) {
    AppLogger.error('Error running examples', tag: 'DatabaseExample', error: e, stackTrace: stackTrace);
  } finally {
    await example.close();
    AppLogger.info('Database closed', tag: 'DatabaseExample');
  }
}

// Uncomment to run examples (for testing only):
// void main() async {
//   await runAllExamples();
// }
