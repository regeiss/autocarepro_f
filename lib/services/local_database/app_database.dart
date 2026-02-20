import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../data/models/profile_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/maintenance_record_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/service_provider_model.dart';
import '../../data/models/document_model.dart';

import 'daos/profile_dao.dart';
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
@Database(version: 2, entities: [
  Profile,
  Vehicle,
  MaintenanceRecord,
  Reminder,
  ServiceProvider,
  Document,
])
abstract class AppDatabase extends FloorDatabase {
  /// Profile data access object
  ProfileDao get profileDao;

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
        .addMigrations([_migration1to2])
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

/// Migration from version 1 to 2: Add profiles and profile scoping
final _migration1to2 = Migration(1, 2, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS profiles (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      avatarPath TEXT,
      createdAt INTEGER NOT NULL,
      updatedAt INTEGER NOT NULL
    )
  ''');
  await database.execute('ALTER TABLE vehicles ADD COLUMN profileId TEXT');
  await database.execute('ALTER TABLE service_providers ADD COLUMN profileId TEXT');
  const defaultProfileId = '00000000-0000-0000-0000-000000000001';
  final now = DateTime.now().millisecondsSinceEpoch;
  await database.execute(
    "INSERT INTO profiles (id, name, avatarPath, createdAt, updatedAt) VALUES ('$defaultProfileId', 'Default', NULL, $now, $now)",
  );
  await database.execute("UPDATE vehicles SET profileId = '$defaultProfileId' WHERE profileId IS NULL");
  await database.execute("UPDATE service_providers SET profileId = '$defaultProfileId' WHERE profileId IS NULL");
});

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
