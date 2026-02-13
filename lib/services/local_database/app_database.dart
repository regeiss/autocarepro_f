import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../data/models/vehicle_model.dart';
import '../../data/models/maintenance_record_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/service_provider_model.dart';
import '../../data/models/document_model.dart';

import 'daos/vehicle_dao.dart';
import 'daos/maintenance_record_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/service_provider_dao.dart';
import 'daos/document_dao.dart';

part 'app_database.g.dart'; // Generated file

/// AutoCarePro local database
/// 
/// This is the main database class that manages all local data storage
/// using Floor (SQLite wrapper) for type-safe database operations.
@Database(version: 1, entities: [
  Vehicle,
  MaintenanceRecord,
  Reminder,
  ServiceProvider,
  Document,
])
abstract class AppDatabase extends FloorDatabase {
  /// Vehicle data access object
  VehicleDao get vehicleDao;

  /// Maintenance record data access object
  MaintenanceRecordDao get maintenanceRecordDao;

  /// Reminder data access object
  ReminderDao get reminderDao;

  /// Service provider data access object
  ServiceProviderDao get serviceProviderDao;

  /// Document data access object
  DocumentDao get documentDao;
}

/// Database builder and initialization
class DatabaseBuilder {
  static const String _databaseName = 'autocarepro.db';

  /// Build and initialize the database
  static Future<AppDatabase> build() async {
    return await $FloorAppDatabase
        .databaseBuilder(_databaseName)
        .addMigrations([
          // Add migrations here when schema changes
          // Example: migration1to2,
        ])
        .addCallback(_callback)
        .build();
  }

  /// Database callback for initialization and other events
  static final _callback = Callback(
    onCreate: (database, version) async {
      // Optional: Seed initial data here
      // debugPrint('Database created - version $version');
    },
    onOpen: (database) async {
      // Called every time database is opened
      // debugPrint('Database opened');
    },
    onUpgrade: (database, startVersion, endVersion) async {
      // Called when database is upgraded
      // debugPrint('Database upgraded from $startVersion to $endVersion');
    },
  );
}

/// Example migration (for future use)
/// 
/// When you need to change the database schema, create migrations like this:
/// 
/// ```dart
/// final migration1to2 = Migration(1, 2, (database) async {
///   // Add new column
///   await database.execute(
///     'ALTER TABLE vehicles ADD COLUMN color TEXT'
///   );
/// });
/// ```
/// 
/// Then add it to the migrations list in the builder:
/// ```dart
/// .addMigrations([migration1to2])
/// ```
