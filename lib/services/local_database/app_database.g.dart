// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ProfileDao? _profileDaoInstance;

  VehicleDao? _vehicleDaoInstance;

  MaintenanceRecordDao? _maintenanceRecordDaoInstance;

  ReminderDao? _reminderDaoInstance;

  ServiceProviderDao? _serviceProviderDaoInstance;

  DocumentDao? _documentDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `profiles` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `avatarPath` TEXT, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `vehicles` (`id` TEXT NOT NULL, `profileId` TEXT NOT NULL, `make` TEXT NOT NULL, `model` TEXT NOT NULL, `year` INTEGER NOT NULL, `vin` TEXT, `licensePlate` TEXT, `currentMileage` REAL, `mileageUnit` TEXT NOT NULL, `purchaseDate` INTEGER, `photoPath` TEXT, `notes` TEXT, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, FOREIGN KEY (`profileId`) REFERENCES `profiles` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `maintenance_records` (`id` TEXT NOT NULL, `vehicleId` TEXT NOT NULL, `serviceType` TEXT NOT NULL, `serviceDate` INTEGER NOT NULL, `mileage` REAL, `cost` REAL, `currency` TEXT NOT NULL, `serviceProvider` TEXT, `serviceProviderId` TEXT, `description` TEXT, `notes` TEXT, `receiptPhotoPath` TEXT, `partsReplacedJson` TEXT, `nextServiceDue` INTEGER, `nextServiceMileage` REAL, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `reminders` (`id` TEXT NOT NULL, `vehicleId` TEXT NOT NULL, `serviceType` TEXT NOT NULL, `reminderType` TEXT NOT NULL, `intervalValue` INTEGER NOT NULL, `intervalUnit` TEXT NOT NULL, `lastServiceDate` INTEGER, `lastServiceMileage` REAL, `nextReminderDate` INTEGER, `nextReminderMileage` REAL, `isActive` INTEGER NOT NULL, `notifyBefore` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `service_providers` (`id` TEXT NOT NULL, `profileId` TEXT NOT NULL, `name` TEXT NOT NULL, `phone` TEXT, `email` TEXT, `address` TEXT, `website` TEXT, `notes` TEXT, `rating` REAL, `specialtiesJson` TEXT, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `documents` (`id` TEXT NOT NULL, `vehicleId` TEXT NOT NULL, `documentType` TEXT NOT NULL, `filePath` TEXT NOT NULL, `title` TEXT, `description` TEXT, `fileSize` INTEGER, `mimeType` TEXT, `createdAt` INTEGER NOT NULL, FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE INDEX `index_vehicles_profileId` ON `vehicles` (`profileId`)');
        await database.execute(
            'CREATE INDEX `index_maintenance_records_vehicleId` ON `maintenance_records` (`vehicleId`)');
        await database.execute(
            'CREATE INDEX `index_maintenance_records_serviceDate` ON `maintenance_records` (`serviceDate`)');
        await database.execute(
            'CREATE INDEX `index_reminders_vehicleId` ON `reminders` (`vehicleId`)');
        await database.execute(
            'CREATE INDEX `index_reminders_isActive` ON `reminders` (`isActive`)');
        await database.execute(
            'CREATE INDEX `index_service_providers_name` ON `service_providers` (`name`)');
        await database.execute(
            'CREATE INDEX `index_service_providers_profileId` ON `service_providers` (`profileId`)');
        await database.execute(
            'CREATE INDEX `index_documents_vehicleId` ON `documents` (`vehicleId`)');
        await database.execute(
            'CREATE INDEX `index_documents_documentType` ON `documents` (`documentType`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ProfileDao get profileDao {
    return _profileDaoInstance ??= _$ProfileDao(database, changeListener);
  }

  @override
  VehicleDao get vehicleDao {
    return _vehicleDaoInstance ??= _$VehicleDao(database, changeListener);
  }

  @override
  MaintenanceRecordDao get maintenanceRecordDao {
    return _maintenanceRecordDaoInstance ??=
        _$MaintenanceRecordDao(database, changeListener);
  }

  @override
  ReminderDao get reminderDao {
    return _reminderDaoInstance ??= _$ReminderDao(database, changeListener);
  }

  @override
  ServiceProviderDao get serviceProviderDao {
    return _serviceProviderDaoInstance ??=
        _$ServiceProviderDao(database, changeListener);
  }

  @override
  DocumentDao get documentDao {
    return _documentDaoInstance ??= _$DocumentDao(database, changeListener);
  }
}

class _$ProfileDao extends ProfileDao {
  _$ProfileDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _profileInsertionAdapter = InsertionAdapter(
            database,
            'profiles',
            (Profile item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'avatarPath': item.avatarPath,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _profileUpdateAdapter = UpdateAdapter(
            database,
            'profiles',
            ['id'],
            (Profile item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'avatarPath': item.avatarPath,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _profileDeletionAdapter = DeletionAdapter(
            database,
            'profiles',
            ['id'],
            (Profile item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'avatarPath': item.avatarPath,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Profile> _profileInsertionAdapter;

  final UpdateAdapter<Profile> _profileUpdateAdapter;

  final DeletionAdapter<Profile> _profileDeletionAdapter;

  @override
  Future<List<Profile>> getAllProfiles() async {
    return _queryAdapter.queryList('SELECT * FROM profiles ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => Profile(
            id: row['id'] as String,
            name: row['name'] as String,
            avatarPath: row['avatarPath'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Stream<List<Profile>> watchAllProfiles() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM profiles ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => Profile(
            id: row['id'] as String,
            name: row['name'] as String,
            avatarPath: row['avatarPath'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        queryableName: 'profiles',
        isView: false);
  }

  @override
  Future<Profile?> getProfileById(String id) async {
    return _queryAdapter.query('SELECT * FROM profiles WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Profile(
            id: row['id'] as String,
            name: row['name'] as String,
            avatarPath: row['avatarPath'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id]);
  }

  @override
  Stream<Profile?> watchProfileById(String id) {
    return _queryAdapter.queryStream('SELECT * FROM profiles WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Profile(
            id: row['id'] as String,
            name: row['name'] as String,
            avatarPath: row['avatarPath'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id],
        queryableName: 'profiles',
        isView: false);
  }

  @override
  Future<int?> getProfileCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM profiles',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> deleteProfileById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM profiles WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertProfile(Profile profile) async {
    await _profileInsertionAdapter.insert(profile, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await _profileUpdateAdapter.update(profile, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProfile(Profile profile) async {
    await _profileDeletionAdapter.delete(profile);
  }
}

class _$VehicleDao extends VehicleDao {
  _$VehicleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _vehicleInsertionAdapter = InsertionAdapter(
            database,
            'vehicles',
            (Vehicle item) => <String, Object?>{
                  'id': item.id,
                  'profileId': item.profileId,
                  'make': item.make,
                  'model': item.model,
                  'year': item.year,
                  'vin': item.vin,
                  'licensePlate': item.licensePlate,
                  'currentMileage': item.currentMileage,
                  'mileageUnit': item.mileageUnit,
                  'purchaseDate': item.purchaseDate,
                  'photoPath': item.photoPath,
                  'notes': item.notes,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _vehicleUpdateAdapter = UpdateAdapter(
            database,
            'vehicles',
            ['id'],
            (Vehicle item) => <String, Object?>{
                  'id': item.id,
                  'profileId': item.profileId,
                  'make': item.make,
                  'model': item.model,
                  'year': item.year,
                  'vin': item.vin,
                  'licensePlate': item.licensePlate,
                  'currentMileage': item.currentMileage,
                  'mileageUnit': item.mileageUnit,
                  'purchaseDate': item.purchaseDate,
                  'photoPath': item.photoPath,
                  'notes': item.notes,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _vehicleDeletionAdapter = DeletionAdapter(
            database,
            'vehicles',
            ['id'],
            (Vehicle item) => <String, Object?>{
                  'id': item.id,
                  'profileId': item.profileId,
                  'make': item.make,
                  'model': item.model,
                  'year': item.year,
                  'vin': item.vin,
                  'licensePlate': item.licensePlate,
                  'currentMileage': item.currentMileage,
                  'mileageUnit': item.mileageUnit,
                  'purchaseDate': item.purchaseDate,
                  'photoPath': item.photoPath,
                  'notes': item.notes,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Vehicle> _vehicleInsertionAdapter;

  final UpdateAdapter<Vehicle> _vehicleUpdateAdapter;

  final DeletionAdapter<Vehicle> _vehicleDeletionAdapter;

  @override
  Future<List<Vehicle>> getAllVehicles() async {
    return _queryAdapter.queryList(
        'SELECT * FROM vehicles ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Vehicle(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            make: row['make'] as String,
            model: row['model'] as String,
            year: row['year'] as int,
            vin: row['vin'] as String?,
            licensePlate: row['licensePlate'] as String?,
            currentMileage: row['currentMileage'] as double?,
            mileageUnit: row['mileageUnit'] as String,
            purchaseDate: row['purchaseDate'] as int?,
            photoPath: row['photoPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<List<Vehicle>> getVehiclesByProfileId(String profileId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vehicles WHERE profileId = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Vehicle(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            make: row['make'] as String,
            model: row['model'] as String,
            year: row['year'] as int,
            vin: row['vin'] as String?,
            licensePlate: row['licensePlate'] as String?,
            currentMileage: row['currentMileage'] as double?,
            mileageUnit: row['mileageUnit'] as String,
            purchaseDate: row['purchaseDate'] as int?,
            photoPath: row['photoPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [profileId]);
  }

  @override
  Stream<List<Vehicle>> watchVehiclesByProfileId(String profileId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM vehicles WHERE profileId = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Vehicle(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            make: row['make'] as String,
            model: row['model'] as String,
            year: row['year'] as int,
            vin: row['vin'] as String?,
            licensePlate: row['licensePlate'] as String?,
            currentMileage: row['currentMileage'] as double?,
            mileageUnit: row['mileageUnit'] as String,
            purchaseDate: row['purchaseDate'] as int?,
            photoPath: row['photoPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [profileId],
        queryableName: 'vehicles',
        isView: false);
  }

  @override
  Stream<List<Vehicle>> watchAllVehicles() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM vehicles ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Vehicle(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            make: row['make'] as String,
            model: row['model'] as String,
            year: row['year'] as int,
            vin: row['vin'] as String?,
            licensePlate: row['licensePlate'] as String?,
            currentMileage: row['currentMileage'] as double?,
            mileageUnit: row['mileageUnit'] as String,
            purchaseDate: row['purchaseDate'] as int?,
            photoPath: row['photoPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        queryableName: 'vehicles',
        isView: false);
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    return _queryAdapter.query('SELECT * FROM vehicles WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Vehicle(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            make: row['make'] as String,
            model: row['model'] as String,
            year: row['year'] as int,
            vin: row['vin'] as String?,
            licensePlate: row['licensePlate'] as String?,
            currentMileage: row['currentMileage'] as double?,
            mileageUnit: row['mileageUnit'] as String,
            purchaseDate: row['purchaseDate'] as int?,
            photoPath: row['photoPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id]);
  }

  @override
  Stream<Vehicle?> watchVehicleById(String id) {
    return _queryAdapter.queryStream('SELECT * FROM vehicles WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Vehicle(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            make: row['make'] as String,
            model: row['model'] as String,
            year: row['year'] as int,
            vin: row['vin'] as String?,
            licensePlate: row['licensePlate'] as String?,
            currentMileage: row['currentMileage'] as double?,
            mileageUnit: row['mileageUnit'] as String,
            purchaseDate: row['purchaseDate'] as int?,
            photoPath: row['photoPath'] as String?,
            notes: row['notes'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id],
        queryableName: 'vehicles',
        isView: false);
  }

  @override
  Future<List<Vehicle>> searchVehicles(
    String profileId,
    String query,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vehicles      WHERE profileId = ?1     AND (make LIKE \'%\' || ?2 || \'%\'      OR model LIKE \'%\' || ?2 || \'%\'      OR CAST(year AS TEXT) LIKE \'%\' || ?2 || \'%\')     ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Vehicle(id: row['id'] as String, profileId: row['profileId'] as String, make: row['make'] as String, model: row['model'] as String, year: row['year'] as int, vin: row['vin'] as String?, licensePlate: row['licensePlate'] as String?, currentMileage: row['currentMileage'] as double?, mileageUnit: row['mileageUnit'] as String, purchaseDate: row['purchaseDate'] as int?, photoPath: row['photoPath'] as String?, notes: row['notes'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [profileId, query]);
  }

  @override
  Future<List<Vehicle>> searchAllVehicles(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vehicles      WHERE make LIKE \'%\' || ?1 || \'%\'      OR model LIKE \'%\' || ?1 || \'%\'      OR CAST(year AS TEXT) LIKE \'%\' || ?1 || \'%\'     ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Vehicle(id: row['id'] as String, profileId: row['profileId'] as String, make: row['make'] as String, model: row['model'] as String, year: row['year'] as int, vin: row['vin'] as String?, licensePlate: row['licensePlate'] as String?, currentMileage: row['currentMileage'] as double?, mileageUnit: row['mileageUnit'] as String, purchaseDate: row['purchaseDate'] as int?, photoPath: row['photoPath'] as String?, notes: row['notes'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [query]);
  }

  @override
  Future<List<Vehicle>> getVehiclesByYearRange(
    int startYear,
    int endYear,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vehicles      WHERE year BETWEEN ?1 AND ?2     ORDER BY year DESC',
        mapper: (Map<String, Object?> row) => Vehicle(id: row['id'] as String, profileId: row['profileId'] as String, make: row['make'] as String, model: row['model'] as String, year: row['year'] as int, vin: row['vin'] as String?, licensePlate: row['licensePlate'] as String?, currentMileage: row['currentMileage'] as double?, mileageUnit: row['mileageUnit'] as String, purchaseDate: row['purchaseDate'] as int?, photoPath: row['photoPath'] as String?, notes: row['notes'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [startYear, endYear]);
  }

  @override
  Future<int?> getVehicleCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM vehicles',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getVehicleCountByProfile(String profileId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM vehicles WHERE profileId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [profileId]);
  }

  @override
  Future<void> updateVehicleMileage(
    String id,
    double mileage,
    int timestamp,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE vehicles SET currentMileage = ?2, updatedAt = ?3 WHERE id = ?1',
        arguments: [id, mileage, timestamp]);
  }

  @override
  Future<void> deleteVehicleById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM vehicles WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteAllVehicles() async {
    await _queryAdapter.queryNoReturn('DELETE FROM vehicles');
  }

  @override
  Future<void> insertVehicle(Vehicle vehicle) async {
    await _vehicleInsertionAdapter.insert(vehicle, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertVehicles(List<Vehicle> vehicles) async {
    await _vehicleInsertionAdapter.insertList(
        vehicles, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _vehicleUpdateAdapter.update(vehicle, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVehicle(Vehicle vehicle) async {
    await _vehicleDeletionAdapter.delete(vehicle);
  }
}

class _$MaintenanceRecordDao extends MaintenanceRecordDao {
  _$MaintenanceRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _maintenanceRecordInsertionAdapter = InsertionAdapter(
            database,
            'maintenance_records',
            (MaintenanceRecord item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost,
                  'currency': item.currency,
                  'serviceProvider': item.serviceProvider,
                  'serviceProviderId': item.serviceProviderId,
                  'description': item.description,
                  'notes': item.notes,
                  'receiptPhotoPath': item.receiptPhotoPath,
                  'partsReplacedJson': item.partsReplacedJson,
                  'nextServiceDue': item.nextServiceDue,
                  'nextServiceMileage': item.nextServiceMileage,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _maintenanceRecordUpdateAdapter = UpdateAdapter(
            database,
            'maintenance_records',
            ['id'],
            (MaintenanceRecord item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost,
                  'currency': item.currency,
                  'serviceProvider': item.serviceProvider,
                  'serviceProviderId': item.serviceProviderId,
                  'description': item.description,
                  'notes': item.notes,
                  'receiptPhotoPath': item.receiptPhotoPath,
                  'partsReplacedJson': item.partsReplacedJson,
                  'nextServiceDue': item.nextServiceDue,
                  'nextServiceMileage': item.nextServiceMileage,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _maintenanceRecordDeletionAdapter = DeletionAdapter(
            database,
            'maintenance_records',
            ['id'],
            (MaintenanceRecord item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost,
                  'currency': item.currency,
                  'serviceProvider': item.serviceProvider,
                  'serviceProviderId': item.serviceProviderId,
                  'description': item.description,
                  'notes': item.notes,
                  'receiptPhotoPath': item.receiptPhotoPath,
                  'partsReplacedJson': item.partsReplacedJson,
                  'nextServiceDue': item.nextServiceDue,
                  'nextServiceMileage': item.nextServiceMileage,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MaintenanceRecord> _maintenanceRecordInsertionAdapter;

  final UpdateAdapter<MaintenanceRecord> _maintenanceRecordUpdateAdapter;

  final DeletionAdapter<MaintenanceRecord> _maintenanceRecordDeletionAdapter;

  @override
  Future<List<MaintenanceRecord>> getAllRecords() async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records ORDER BY serviceDate DESC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            serviceDate: row['serviceDate'] as int,
            mileage: row['mileage'] as double?,
            cost: row['cost'] as double?,
            currency: row['currency'] as String,
            serviceProvider: row['serviceProvider'] as String?,
            serviceProviderId: row['serviceProviderId'] as String?,
            description: row['description'] as String?,
            notes: row['notes'] as String?,
            receiptPhotoPath: row['receiptPhotoPath'] as String?,
            partsReplacedJson: row['partsReplacedJson'] as String?,
            nextServiceDue: row['nextServiceDue'] as int?,
            nextServiceMileage: row['nextServiceMileage'] as double?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Stream<List<MaintenanceRecord>> watchAllRecords() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM maintenance_records ORDER BY serviceDate DESC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            serviceDate: row['serviceDate'] as int,
            mileage: row['mileage'] as double?,
            cost: row['cost'] as double?,
            currency: row['currency'] as String,
            serviceProvider: row['serviceProvider'] as String?,
            serviceProviderId: row['serviceProviderId'] as String?,
            description: row['description'] as String?,
            notes: row['notes'] as String?,
            receiptPhotoPath: row['receiptPhotoPath'] as String?,
            partsReplacedJson: row['partsReplacedJson'] as String?,
            nextServiceDue: row['nextServiceDue'] as int?,
            nextServiceMileage: row['nextServiceMileage'] as double?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        queryableName: 'maintenance_records',
        isView: false);
  }

  @override
  Future<MaintenanceRecord?> getRecordById(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM maintenance_records WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            serviceDate: row['serviceDate'] as int,
            mileage: row['mileage'] as double?,
            cost: row['cost'] as double?,
            currency: row['currency'] as String,
            serviceProvider: row['serviceProvider'] as String?,
            serviceProviderId: row['serviceProviderId'] as String?,
            description: row['description'] as String?,
            notes: row['notes'] as String?,
            receiptPhotoPath: row['receiptPhotoPath'] as String?,
            partsReplacedJson: row['partsReplacedJson'] as String?,
            nextServiceDue: row['nextServiceDue'] as int?,
            nextServiceMileage: row['nextServiceMileage'] as double?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id]);
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsByVehicleId(
      String vehicleId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records WHERE vehicleId = ?1 ORDER BY serviceDate DESC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, serviceDate: row['serviceDate'] as int, mileage: row['mileage'] as double?, cost: row['cost'] as double?, currency: row['currency'] as String, serviceProvider: row['serviceProvider'] as String?, serviceProviderId: row['serviceProviderId'] as String?, description: row['description'] as String?, notes: row['notes'] as String?, receiptPhotoPath: row['receiptPhotoPath'] as String?, partsReplacedJson: row['partsReplacedJson'] as String?, nextServiceDue: row['nextServiceDue'] as int?, nextServiceMileage: row['nextServiceMileage'] as double?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId]);
  }

  @override
  Stream<List<MaintenanceRecord>> watchRecordsByVehicleId(String vehicleId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM maintenance_records WHERE vehicleId = ?1 ORDER BY serviceDate DESC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            serviceDate: row['serviceDate'] as int,
            mileage: row['mileage'] as double?,
            cost: row['cost'] as double?,
            currency: row['currency'] as String,
            serviceProvider: row['serviceProvider'] as String?,
            serviceProviderId: row['serviceProviderId'] as String?,
            description: row['description'] as String?,
            notes: row['notes'] as String?,
            receiptPhotoPath: row['receiptPhotoPath'] as String?,
            partsReplacedJson: row['partsReplacedJson'] as String?,
            nextServiceDue: row['nextServiceDue'] as int?,
            nextServiceMileage: row['nextServiceMileage'] as double?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId],
        queryableName: 'maintenance_records',
        isView: false);
  }

  @override
  Future<List<MaintenanceRecord>> getRecentRecords(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records ORDER BY serviceDate DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            serviceDate: row['serviceDate'] as int,
            mileage: row['mileage'] as double?,
            cost: row['cost'] as double?,
            currency: row['currency'] as String,
            serviceProvider: row['serviceProvider'] as String?,
            serviceProviderId: row['serviceProviderId'] as String?,
            description: row['description'] as String?,
            notes: row['notes'] as String?,
            receiptPhotoPath: row['receiptPhotoPath'] as String?,
            partsReplacedJson: row['partsReplacedJson'] as String?,
            nextServiceDue: row['nextServiceDue'] as int?,
            nextServiceMileage: row['nextServiceMileage'] as double?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [limit]);
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsByServiceType(
      String serviceType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records WHERE serviceType = ?1 ORDER BY serviceDate DESC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, serviceDate: row['serviceDate'] as int, mileage: row['mileage'] as double?, cost: row['cost'] as double?, currency: row['currency'] as String, serviceProvider: row['serviceProvider'] as String?, serviceProviderId: row['serviceProviderId'] as String?, description: row['description'] as String?, notes: row['notes'] as String?, receiptPhotoPath: row['receiptPhotoPath'] as String?, partsReplacedJson: row['partsReplacedJson'] as String?, nextServiceDue: row['nextServiceDue'] as int?, nextServiceMileage: row['nextServiceMileage'] as double?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [serviceType]);
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsByDateRange(
    int startDate,
    int endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records      WHERE serviceDate BETWEEN ?1 AND ?2     ORDER BY serviceDate DESC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, serviceDate: row['serviceDate'] as int, mileage: row['mileage'] as double?, cost: row['cost'] as double?, currency: row['currency'] as String, serviceProvider: row['serviceProvider'] as String?, serviceProviderId: row['serviceProviderId'] as String?, description: row['description'] as String?, notes: row['notes'] as String?, receiptPhotoPath: row['receiptPhotoPath'] as String?, partsReplacedJson: row['partsReplacedJson'] as String?, nextServiceDue: row['nextServiceDue'] as int?, nextServiceMileage: row['nextServiceMileage'] as double?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [startDate, endDate]);
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsByVehicleAndDateRange(
    String vehicleId,
    int startDate,
    int endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records      WHERE vehicleId = ?1      AND serviceDate BETWEEN ?2 AND ?3     ORDER BY serviceDate DESC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, serviceDate: row['serviceDate'] as int, mileage: row['mileage'] as double?, cost: row['cost'] as double?, currency: row['currency'] as String, serviceProvider: row['serviceProvider'] as String?, serviceProviderId: row['serviceProviderId'] as String?, description: row['description'] as String?, notes: row['notes'] as String?, receiptPhotoPath: row['receiptPhotoPath'] as String?, partsReplacedJson: row['partsReplacedJson'] as String?, nextServiceDue: row['nextServiceDue'] as int?, nextServiceMileage: row['nextServiceMileage'] as double?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId, startDate, endDate]);
  }

  @override
  Future<double?> getTotalCostByVehicle(String vehicleId) async {
    return _queryAdapter.query(
        'SELECT SUM(cost) FROM maintenance_records WHERE vehicleId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [vehicleId]);
  }

  @override
  Future<double?> getTotalCost() async {
    return _queryAdapter.query('SELECT SUM(cost) FROM maintenance_records',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Future<double?> getTotalCostByDateRange(
    int startDate,
    int endDate,
  ) async {
    return _queryAdapter.query(
        'SELECT SUM(cost) FROM maintenance_records      WHERE serviceDate BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [startDate, endDate]);
  }

  @override
  Future<int?> getRecordCountByVehicle(String vehicleId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM maintenance_records WHERE vehicleId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [vehicleId]);
  }

  @override
  Future<MaintenanceRecord?> getLatestRecordByVehicle(String vehicleId) async {
    return _queryAdapter.query(
        'SELECT * FROM maintenance_records      WHERE vehicleId = ?1      ORDER BY serviceDate DESC      LIMIT 1',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, serviceDate: row['serviceDate'] as int, mileage: row['mileage'] as double?, cost: row['cost'] as double?, currency: row['currency'] as String, serviceProvider: row['serviceProvider'] as String?, serviceProviderId: row['serviceProviderId'] as String?, description: row['description'] as String?, notes: row['notes'] as String?, receiptPhotoPath: row['receiptPhotoPath'] as String?, partsReplacedJson: row['partsReplacedJson'] as String?, nextServiceDue: row['nextServiceDue'] as int?, nextServiceMileage: row['nextServiceMileage'] as double?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId]);
  }

  @override
  Future<List<MaintenanceRecord>> getUpcomingServices() async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records      WHERE nextServiceDue IS NOT NULL      AND nextServiceDue > 0     ORDER BY nextServiceDue ASC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            serviceDate: row['serviceDate'] as int,
            mileage: row['mileage'] as double?,
            cost: row['cost'] as double?,
            currency: row['currency'] as String,
            serviceProvider: row['serviceProvider'] as String?,
            serviceProviderId: row['serviceProviderId'] as String?,
            description: row['description'] as String?,
            notes: row['notes'] as String?,
            receiptPhotoPath: row['receiptPhotoPath'] as String?,
            partsReplacedJson: row['partsReplacedJson'] as String?,
            nextServiceDue: row['nextServiceDue'] as int?,
            nextServiceMileage: row['nextServiceMileage'] as double?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<List<MaintenanceRecord>> getOverdueServices(int currentTime) async {
    return _queryAdapter.queryList(
        'SELECT * FROM maintenance_records      WHERE nextServiceDue IS NOT NULL      AND nextServiceDue < ?1     ORDER BY nextServiceDue ASC',
        mapper: (Map<String, Object?> row) => MaintenanceRecord(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, serviceDate: row['serviceDate'] as int, mileage: row['mileage'] as double?, cost: row['cost'] as double?, currency: row['currency'] as String, serviceProvider: row['serviceProvider'] as String?, serviceProviderId: row['serviceProviderId'] as String?, description: row['description'] as String?, notes: row['notes'] as String?, receiptPhotoPath: row['receiptPhotoPath'] as String?, partsReplacedJson: row['partsReplacedJson'] as String?, nextServiceDue: row['nextServiceDue'] as int?, nextServiceMileage: row['nextServiceMileage'] as double?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [currentTime]);
  }

  @override
  Future<void> deleteRecordById(String id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM maintenance_records WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteRecordsByVehicleId(String vehicleId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM maintenance_records WHERE vehicleId = ?1',
        arguments: [vehicleId]);
  }

  @override
  Future<void> deleteAllRecords() async {
    await _queryAdapter.queryNoReturn('DELETE FROM maintenance_records');
  }

  @override
  Future<void> insertRecord(MaintenanceRecord record) async {
    await _maintenanceRecordInsertionAdapter.insert(
        record, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertRecords(List<MaintenanceRecord> records) async {
    await _maintenanceRecordInsertionAdapter.insertList(
        records, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecord(MaintenanceRecord record) async {
    await _maintenanceRecordUpdateAdapter.update(
        record, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecord(MaintenanceRecord record) async {
    await _maintenanceRecordDeletionAdapter.delete(record);
  }
}

class _$ReminderDao extends ReminderDao {
  _$ReminderDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _reminderInsertionAdapter = InsertionAdapter(
            database,
            'reminders',
            (Reminder item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'serviceType': item.serviceType,
                  'reminderType': item.reminderType,
                  'intervalValue': item.intervalValue,
                  'intervalUnit': item.intervalUnit,
                  'lastServiceDate': item.lastServiceDate,
                  'lastServiceMileage': item.lastServiceMileage,
                  'nextReminderDate': item.nextReminderDate,
                  'nextReminderMileage': item.nextReminderMileage,
                  'isActive': item.isActive ? 1 : 0,
                  'notifyBefore': item.notifyBefore,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _reminderUpdateAdapter = UpdateAdapter(
            database,
            'reminders',
            ['id'],
            (Reminder item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'serviceType': item.serviceType,
                  'reminderType': item.reminderType,
                  'intervalValue': item.intervalValue,
                  'intervalUnit': item.intervalUnit,
                  'lastServiceDate': item.lastServiceDate,
                  'lastServiceMileage': item.lastServiceMileage,
                  'nextReminderDate': item.nextReminderDate,
                  'nextReminderMileage': item.nextReminderMileage,
                  'isActive': item.isActive ? 1 : 0,
                  'notifyBefore': item.notifyBefore,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _reminderDeletionAdapter = DeletionAdapter(
            database,
            'reminders',
            ['id'],
            (Reminder item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'serviceType': item.serviceType,
                  'reminderType': item.reminderType,
                  'intervalValue': item.intervalValue,
                  'intervalUnit': item.intervalUnit,
                  'lastServiceDate': item.lastServiceDate,
                  'lastServiceMileage': item.lastServiceMileage,
                  'nextReminderDate': item.nextReminderDate,
                  'nextReminderMileage': item.nextReminderMileage,
                  'isActive': item.isActive ? 1 : 0,
                  'notifyBefore': item.notifyBefore,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reminder> _reminderInsertionAdapter;

  final UpdateAdapter<Reminder> _reminderUpdateAdapter;

  final DeletionAdapter<Reminder> _reminderDeletionAdapter;

  @override
  Future<List<Reminder>> getAllReminders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Stream<List<Reminder>> watchAllReminders() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM reminders ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        queryableName: 'reminders',
        isView: false);
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    return _queryAdapter.query('SELECT * FROM reminders WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id]);
  }

  @override
  Future<List<Reminder>> getRemindersByVehicleId(String vehicleId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders WHERE vehicleId = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId]);
  }

  @override
  Stream<List<Reminder>> watchRemindersByVehicleId(String vehicleId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM reminders WHERE vehicleId = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId],
        queryableName: 'reminders',
        isView: false);
  }

  @override
  Future<List<Reminder>> getActiveReminders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders WHERE isActive = 1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Stream<List<Reminder>> watchActiveReminders() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM reminders WHERE isActive = 1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        queryableName: 'reminders',
        isView: false);
  }

  @override
  Future<List<Reminder>> getActiveRemindersByVehicleId(String vehicleId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders WHERE vehicleId = ?1 AND isActive = 1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, reminderType: row['reminderType'] as String, intervalValue: row['intervalValue'] as int, intervalUnit: row['intervalUnit'] as String, lastServiceDate: row['lastServiceDate'] as int?, lastServiceMileage: row['lastServiceMileage'] as double?, nextReminderDate: row['nextReminderDate'] as int?, nextReminderMileage: row['nextReminderMileage'] as double?, isActive: (row['isActive'] as int) != 0, notifyBefore: row['notifyBefore'] as int, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId]);
  }

  @override
  Future<List<Reminder>> getTimeBasedReminders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders WHERE reminderType = \"time\" AND isActive = 1 ORDER BY nextReminderDate ASC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<List<Reminder>> getMileageBasedReminders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders WHERE reminderType = \"mileage\" AND isActive = 1 ORDER BY nextReminderMileage ASC',
        mapper: (Map<String, Object?> row) => Reminder(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            serviceType: row['serviceType'] as String,
            reminderType: row['reminderType'] as String,
            intervalValue: row['intervalValue'] as int,
            intervalUnit: row['intervalUnit'] as String,
            lastServiceDate: row['lastServiceDate'] as int?,
            lastServiceMileage: row['lastServiceMileage'] as double?,
            nextReminderDate: row['nextReminderDate'] as int?,
            nextReminderMileage: row['nextReminderMileage'] as double?,
            isActive: (row['isActive'] as int) != 0,
            notifyBefore: row['notifyBefore'] as int,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<List<Reminder>> getMileageBasedRemindersByVehicle(
      String vehicleId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders      WHERE vehicleId = ?1      AND reminderType = \"mileage\"      AND isActive = 1      ORDER BY nextReminderMileage ASC',
        mapper: (Map<String, Object?> row) => Reminder(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, reminderType: row['reminderType'] as String, intervalValue: row['intervalValue'] as int, intervalUnit: row['intervalUnit'] as String, lastServiceDate: row['lastServiceDate'] as int?, lastServiceMileage: row['lastServiceMileage'] as double?, nextReminderDate: row['nextReminderDate'] as int?, nextReminderMileage: row['nextReminderMileage'] as double?, isActive: (row['isActive'] as int) != 0, notifyBefore: row['notifyBefore'] as int, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [vehicleId]);
  }

  @override
  Future<List<Reminder>> getDueTimeReminders(int currentTime) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders      WHERE reminderType = \"time\"      AND isActive = 1      AND nextReminderDate IS NOT NULL      AND nextReminderDate <= ?1     ORDER BY nextReminderDate ASC',
        mapper: (Map<String, Object?> row) => Reminder(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, reminderType: row['reminderType'] as String, intervalValue: row['intervalValue'] as int, intervalUnit: row['intervalUnit'] as String, lastServiceDate: row['lastServiceDate'] as int?, lastServiceMileage: row['lastServiceMileage'] as double?, nextReminderDate: row['nextReminderDate'] as int?, nextReminderMileage: row['nextReminderMileage'] as double?, isActive: (row['isActive'] as int) != 0, notifyBefore: row['notifyBefore'] as int, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [currentTime]);
  }

  @override
  Future<List<Reminder>> getUpcomingTimeReminders(
    int currentTime,
    int futureTime,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders      WHERE reminderType = \"time\"      AND isActive = 1      AND nextReminderDate IS NOT NULL      AND nextReminderDate BETWEEN ?1 AND ?2     ORDER BY nextReminderDate ASC',
        mapper: (Map<String, Object?> row) => Reminder(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, reminderType: row['reminderType'] as String, intervalValue: row['intervalValue'] as int, intervalUnit: row['intervalUnit'] as String, lastServiceDate: row['lastServiceDate'] as int?, lastServiceMileage: row['lastServiceMileage'] as double?, nextReminderDate: row['nextReminderDate'] as int?, nextReminderMileage: row['nextReminderMileage'] as double?, isActive: (row['isActive'] as int) != 0, notifyBefore: row['notifyBefore'] as int, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [currentTime, futureTime]);
  }

  @override
  Future<List<Reminder>> getRemindersByServiceType(String serviceType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reminders WHERE serviceType = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Reminder(id: row['id'] as String, vehicleId: row['vehicleId'] as String, serviceType: row['serviceType'] as String, reminderType: row['reminderType'] as String, intervalValue: row['intervalValue'] as int, intervalUnit: row['intervalUnit'] as String, lastServiceDate: row['lastServiceDate'] as int?, lastServiceMileage: row['lastServiceMileage'] as double?, nextReminderDate: row['nextReminderDate'] as int?, nextReminderMileage: row['nextReminderMileage'] as double?, isActive: (row['isActive'] as int) != 0, notifyBefore: row['notifyBefore'] as int, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [serviceType]);
  }

  @override
  Future<int?> getActiveReminderCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM reminders WHERE isActive = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getActiveReminderCountByVehicle(String vehicleId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM reminders WHERE vehicleId = ?1 AND isActive = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [vehicleId]);
  }

  @override
  Future<void> activateReminder(
    String id,
    int timestamp,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE reminders SET isActive = 1, updatedAt = ?2 WHERE id = ?1',
        arguments: [id, timestamp]);
  }

  @override
  Future<void> deactivateReminder(
    String id,
    int timestamp,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE reminders SET isActive = 0, updatedAt = ?2 WHERE id = ?1',
        arguments: [id, timestamp]);
  }

  @override
  Future<void> updateNextReminderDate(
    String id,
    int nextDate,
    int timestamp,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE reminders SET nextReminderDate = ?2, updatedAt = ?3 WHERE id = ?1',
        arguments: [id, nextDate, timestamp]);
  }

  @override
  Future<void> updateNextReminderMileage(
    String id,
    double nextMileage,
    int timestamp,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE reminders SET nextReminderMileage = ?2, updatedAt = ?3 WHERE id = ?1',
        arguments: [id, nextMileage, timestamp]);
  }

  @override
  Future<void> deleteReminderById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM reminders WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteRemindersByVehicleId(String vehicleId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM reminders WHERE vehicleId = ?1',
        arguments: [vehicleId]);
  }

  @override
  Future<void> deleteAllReminders() async {
    await _queryAdapter.queryNoReturn('DELETE FROM reminders');
  }

  @override
  Future<void> insertReminder(Reminder reminder) async {
    await _reminderInsertionAdapter.insert(reminder, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertReminders(List<Reminder> reminders) async {
    await _reminderInsertionAdapter.insertList(
        reminders, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    await _reminderUpdateAdapter.update(reminder, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteReminder(Reminder reminder) async {
    await _reminderDeletionAdapter.delete(reminder);
  }
}

class _$ServiceProviderDao extends ServiceProviderDao {
  _$ServiceProviderDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _serviceProviderInsertionAdapter = InsertionAdapter(
            database,
            'service_providers',
            (ServiceProvider item) => <String, Object?>{
                  'id': item.id,
                  'profileId': item.profileId,
                  'name': item.name,
                  'phone': item.phone,
                  'email': item.email,
                  'address': item.address,
                  'website': item.website,
                  'notes': item.notes,
                  'rating': item.rating,
                  'specialtiesJson': item.specialtiesJson,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _serviceProviderUpdateAdapter = UpdateAdapter(
            database,
            'service_providers',
            ['id'],
            (ServiceProvider item) => <String, Object?>{
                  'id': item.id,
                  'profileId': item.profileId,
                  'name': item.name,
                  'phone': item.phone,
                  'email': item.email,
                  'address': item.address,
                  'website': item.website,
                  'notes': item.notes,
                  'rating': item.rating,
                  'specialtiesJson': item.specialtiesJson,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener),
        _serviceProviderDeletionAdapter = DeletionAdapter(
            database,
            'service_providers',
            ['id'],
            (ServiceProvider item) => <String, Object?>{
                  'id': item.id,
                  'profileId': item.profileId,
                  'name': item.name,
                  'phone': item.phone,
                  'email': item.email,
                  'address': item.address,
                  'website': item.website,
                  'notes': item.notes,
                  'rating': item.rating,
                  'specialtiesJson': item.specialtiesJson,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ServiceProvider> _serviceProviderInsertionAdapter;

  final UpdateAdapter<ServiceProvider> _serviceProviderUpdateAdapter;

  final DeletionAdapter<ServiceProvider> _serviceProviderDeletionAdapter;

  @override
  Future<List<ServiceProvider>> getAllProviders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM service_providers ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ServiceProvider(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            name: row['name'] as String,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            address: row['address'] as String?,
            website: row['website'] as String?,
            notes: row['notes'] as String?,
            rating: row['rating'] as double?,
            specialtiesJson: row['specialtiesJson'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<List<ServiceProvider>> getProvidersByProfileId(
      String profileId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM service_providers WHERE profileId = ?1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ServiceProvider(id: row['id'] as String, profileId: row['profileId'] as String, name: row['name'] as String, phone: row['phone'] as String?, email: row['email'] as String?, address: row['address'] as String?, website: row['website'] as String?, notes: row['notes'] as String?, rating: row['rating'] as double?, specialtiesJson: row['specialtiesJson'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [profileId]);
  }

  @override
  Stream<List<ServiceProvider>> watchProvidersByProfileId(String profileId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM service_providers WHERE profileId = ?1 ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ServiceProvider(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            name: row['name'] as String,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            address: row['address'] as String?,
            website: row['website'] as String?,
            notes: row['notes'] as String?,
            rating: row['rating'] as double?,
            specialtiesJson: row['specialtiesJson'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [profileId],
        queryableName: 'service_providers',
        isView: false);
  }

  @override
  Stream<List<ServiceProvider>> watchAllProviders() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM service_providers ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ServiceProvider(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            name: row['name'] as String,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            address: row['address'] as String?,
            website: row['website'] as String?,
            notes: row['notes'] as String?,
            rating: row['rating'] as double?,
            specialtiesJson: row['specialtiesJson'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        queryableName: 'service_providers',
        isView: false);
  }

  @override
  Future<ServiceProvider?> getProviderById(String id) async {
    return _queryAdapter.query('SELECT * FROM service_providers WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ServiceProvider(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            name: row['name'] as String,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            address: row['address'] as String?,
            website: row['website'] as String?,
            notes: row['notes'] as String?,
            rating: row['rating'] as double?,
            specialtiesJson: row['specialtiesJson'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id]);
  }

  @override
  Stream<ServiceProvider?> watchProviderById(String id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM service_providers WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ServiceProvider(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            name: row['name'] as String,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            address: row['address'] as String?,
            website: row['website'] as String?,
            notes: row['notes'] as String?,
            rating: row['rating'] as double?,
            specialtiesJson: row['specialtiesJson'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [id],
        queryableName: 'service_providers',
        isView: false);
  }

  @override
  Future<List<ServiceProvider>> searchProviders(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM service_providers      WHERE name LIKE \'%\' || ?1 || \'%\'     ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ServiceProvider(id: row['id'] as String, profileId: row['profileId'] as String, name: row['name'] as String, phone: row['phone'] as String?, email: row['email'] as String?, address: row['address'] as String?, website: row['website'] as String?, notes: row['notes'] as String?, rating: row['rating'] as double?, specialtiesJson: row['specialtiesJson'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [query]);
  }

  @override
  Future<List<ServiceProvider>> getProvidersByMinRating(
      double minRating) async {
    return _queryAdapter.queryList(
        'SELECT * FROM service_providers      WHERE rating IS NOT NULL      AND rating >= ?1     ORDER BY rating DESC, name ASC',
        mapper: (Map<String, Object?> row) => ServiceProvider(id: row['id'] as String, profileId: row['profileId'] as String, name: row['name'] as String, phone: row['phone'] as String?, email: row['email'] as String?, address: row['address'] as String?, website: row['website'] as String?, notes: row['notes'] as String?, rating: row['rating'] as double?, specialtiesJson: row['specialtiesJson'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [minRating]);
  }

  @override
  Future<List<ServiceProvider>> getTopRatedProviders(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM service_providers      WHERE rating IS NOT NULL      ORDER BY rating DESC, name ASC     LIMIT ?1',
        mapper: (Map<String, Object?> row) => ServiceProvider(id: row['id'] as String, profileId: row['profileId'] as String, name: row['name'] as String, phone: row['phone'] as String?, email: row['email'] as String?, address: row['address'] as String?, website: row['website'] as String?, notes: row['notes'] as String?, rating: row['rating'] as double?, specialtiesJson: row['specialtiesJson'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [limit]);
  }

  @override
  Future<List<ServiceProvider>> getTopRatedProvidersByProfile(
    String profileId,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM service_providers      WHERE profileId = ?1 AND rating IS NOT NULL      ORDER BY rating DESC, name ASC     LIMIT ?2',
        mapper: (Map<String, Object?> row) => ServiceProvider(id: row['id'] as String, profileId: row['profileId'] as String, name: row['name'] as String, phone: row['phone'] as String?, email: row['email'] as String?, address: row['address'] as String?, website: row['website'] as String?, notes: row['notes'] as String?, rating: row['rating'] as double?, specialtiesJson: row['specialtiesJson'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [profileId, limit]);
  }

  @override
  Future<List<ServiceProvider>> getUnratedProviders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM service_providers      WHERE rating IS NULL     ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => ServiceProvider(
            id: row['id'] as String,
            profileId: row['profileId'] as String,
            name: row['name'] as String,
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            address: row['address'] as String?,
            website: row['website'] as String?,
            notes: row['notes'] as String?,
            rating: row['rating'] as double?,
            specialtiesJson: row['specialtiesJson'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<int?> getProviderCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM service_providers',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<double?> getAverageRating() async {
    return _queryAdapter.query(
        'SELECT AVG(rating) FROM service_providers WHERE rating IS NOT NULL',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Future<void> updateProviderRating(
    String id,
    double rating,
    int timestamp,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE service_providers SET rating = ?2, updatedAt = ?3 WHERE id = ?1',
        arguments: [id, rating, timestamp]);
  }

  @override
  Future<void> deleteProviderById(String id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM service_providers WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteAllProviders() async {
    await _queryAdapter.queryNoReturn('DELETE FROM service_providers');
  }

  @override
  Future<void> deleteByProfileId(String profileId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM service_providers WHERE profileId = ?1',
        arguments: [profileId]);
  }

  @override
  Future<void> insertProvider(ServiceProvider provider) async {
    await _serviceProviderInsertionAdapter.insert(
        provider, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertProviders(List<ServiceProvider> providers) async {
    await _serviceProviderInsertionAdapter.insertList(
        providers, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProvider(ServiceProvider provider) async {
    await _serviceProviderUpdateAdapter.update(
        provider, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProvider(ServiceProvider provider) async {
    await _serviceProviderDeletionAdapter.delete(provider);
  }
}

class _$DocumentDao extends DocumentDao {
  _$DocumentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _documentInsertionAdapter = InsertionAdapter(
            database,
            'documents',
            (Document item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'documentType': item.documentType,
                  'filePath': item.filePath,
                  'title': item.title,
                  'description': item.description,
                  'fileSize': item.fileSize,
                  'mimeType': item.mimeType,
                  'createdAt': item.createdAt
                },
            changeListener),
        _documentUpdateAdapter = UpdateAdapter(
            database,
            'documents',
            ['id'],
            (Document item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'documentType': item.documentType,
                  'filePath': item.filePath,
                  'title': item.title,
                  'description': item.description,
                  'fileSize': item.fileSize,
                  'mimeType': item.mimeType,
                  'createdAt': item.createdAt
                },
            changeListener),
        _documentDeletionAdapter = DeletionAdapter(
            database,
            'documents',
            ['id'],
            (Document item) => <String, Object?>{
                  'id': item.id,
                  'vehicleId': item.vehicleId,
                  'documentType': item.documentType,
                  'filePath': item.filePath,
                  'title': item.title,
                  'description': item.description,
                  'fileSize': item.fileSize,
                  'mimeType': item.mimeType,
                  'createdAt': item.createdAt
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Document> _documentInsertionAdapter;

  final UpdateAdapter<Document> _documentUpdateAdapter;

  final DeletionAdapter<Document> _documentDeletionAdapter;

  @override
  Future<List<Document>> getAllDocuments() async {
    return _queryAdapter.queryList(
        'SELECT * FROM documents ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Document(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            documentType: row['documentType'] as String,
            filePath: row['filePath'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            fileSize: row['fileSize'] as int?,
            mimeType: row['mimeType'] as String?,
            createdAt: row['createdAt'] as int));
  }

  @override
  Stream<List<Document>> watchAllDocuments() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM documents ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Document(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            documentType: row['documentType'] as String,
            filePath: row['filePath'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            fileSize: row['fileSize'] as int?,
            mimeType: row['mimeType'] as String?,
            createdAt: row['createdAt'] as int),
        queryableName: 'documents',
        isView: false);
  }

  @override
  Future<Document?> getDocumentById(String id) async {
    return _queryAdapter.query('SELECT * FROM documents WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Document(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            documentType: row['documentType'] as String,
            filePath: row['filePath'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            fileSize: row['fileSize'] as int?,
            mimeType: row['mimeType'] as String?,
            createdAt: row['createdAt'] as int),
        arguments: [id]);
  }

  @override
  Future<List<Document>> getDocumentsByVehicleId(String vehicleId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM documents WHERE vehicleId = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Document(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            documentType: row['documentType'] as String,
            filePath: row['filePath'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            fileSize: row['fileSize'] as int?,
            mimeType: row['mimeType'] as String?,
            createdAt: row['createdAt'] as int),
        arguments: [vehicleId]);
  }

  @override
  Stream<List<Document>> watchDocumentsByVehicleId(String vehicleId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM documents WHERE vehicleId = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Document(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            documentType: row['documentType'] as String,
            filePath: row['filePath'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            fileSize: row['fileSize'] as int?,
            mimeType: row['mimeType'] as String?,
            createdAt: row['createdAt'] as int),
        arguments: [vehicleId],
        queryableName: 'documents',
        isView: false);
  }

  @override
  Future<List<Document>> getDocumentsByType(String documentType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM documents WHERE documentType = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Document(id: row['id'] as String, vehicleId: row['vehicleId'] as String, documentType: row['documentType'] as String, filePath: row['filePath'] as String, title: row['title'] as String?, description: row['description'] as String?, fileSize: row['fileSize'] as int?, mimeType: row['mimeType'] as String?, createdAt: row['createdAt'] as int),
        arguments: [documentType]);
  }

  @override
  Future<List<Document>> getDocumentsByVehicleAndType(
    String vehicleId,
    String documentType,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM documents      WHERE vehicleId = ?1      AND documentType = ?2     ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Document(id: row['id'] as String, vehicleId: row['vehicleId'] as String, documentType: row['documentType'] as String, filePath: row['filePath'] as String, title: row['title'] as String?, description: row['description'] as String?, fileSize: row['fileSize'] as int?, mimeType: row['mimeType'] as String?, createdAt: row['createdAt'] as int),
        arguments: [vehicleId, documentType]);
  }

  @override
  Future<List<Document>> getRecentDocuments(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM documents ORDER BY createdAt DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => Document(
            id: row['id'] as String,
            vehicleId: row['vehicleId'] as String,
            documentType: row['documentType'] as String,
            filePath: row['filePath'] as String,
            title: row['title'] as String?,
            description: row['description'] as String?,
            fileSize: row['fileSize'] as int?,
            mimeType: row['mimeType'] as String?,
            createdAt: row['createdAt'] as int),
        arguments: [limit]);
  }

  @override
  Future<List<Document>> searchDocuments(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM documents      WHERE title LIKE \'%\' || ?1 || \'%\'      OR description LIKE \'%\' || ?1 || \'%\'     ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Document(id: row['id'] as String, vehicleId: row['vehicleId'] as String, documentType: row['documentType'] as String, filePath: row['filePath'] as String, title: row['title'] as String?, description: row['description'] as String?, fileSize: row['fileSize'] as int?, mimeType: row['mimeType'] as String?, createdAt: row['createdAt'] as int),
        arguments: [query]);
  }

  @override
  Future<int?> getDocumentCountByVehicle(String vehicleId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM documents WHERE vehicleId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [vehicleId]);
  }

  @override
  Future<int?> getDocumentCountByType(String documentType) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM documents WHERE documentType = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [documentType]);
  }

  @override
  Future<int?> getTotalFileSizeByVehicle(String vehicleId) async {
    return _queryAdapter.query(
        'SELECT SUM(fileSize) FROM documents WHERE vehicleId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [vehicleId]);
  }

  @override
  Future<int?> getTotalFileSize() async {
    return _queryAdapter.query('SELECT SUM(fileSize) FROM documents',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> deleteDocumentById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM documents WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteDocumentsByVehicleId(String vehicleId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM documents WHERE vehicleId = ?1',
        arguments: [vehicleId]);
  }

  @override
  Future<void> deleteAllDocuments() async {
    await _queryAdapter.queryNoReturn('DELETE FROM documents');
  }

  @override
  Future<void> insertDocument(Document document) async {
    await _documentInsertionAdapter.insert(document, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertDocuments(List<Document> documents) async {
    await _documentInsertionAdapter.insertList(
        documents, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateDocument(Document document) async {
    await _documentUpdateAdapter.update(document, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDocument(Document document) async {
    await _documentDeletionAdapter.delete(document);
  }
}
