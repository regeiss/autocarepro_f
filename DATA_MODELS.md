# Data Models Reference

This document provides detailed specifications for all data models in AutoCarePro.

## Core Principles

1. **Immutability**: Use `@immutable` or `@freezed` for models
2. **Type Safety**: Leverage Dart's strong typing
3. **Validation**: Validate data at model level
4. **Serialization**: Support JSON and database serialization
5. **Relationships**: Use foreign keys for related data

## Model Hierarchy

```
Vehicle (Parent)
├── MaintenanceRecord (Child)
├── Reminder (Child)
└── Document (Child)

ServiceProvider (Independent)
```

---

## 1. Vehicle Model

### Purpose
Represents a vehicle in the user's garage.

### Fields

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | String | Yes | Unique identifier | UUID format |
| make | String | Yes | Vehicle manufacturer | Max 50 chars |
| model | String | Yes | Vehicle model name | Max 50 chars |
| year | int | Yes | Manufacturing year | 1900-current year |
| vin | String | No | Vehicle Identification Number | 17 chars or null |
| licensePlate | String | No | License/registration plate | Max 15 chars |
| currentMileage | double | No | Current odometer reading | >= 0 |
| mileageUnit | String | Yes | 'miles' or 'km' | Enum: MileageUnit |
| purchaseDate | DateTime | No | Date of purchase | <= today |
| photoPath | String | No | Path to vehicle photo | Local file path |
| notes | String | No | Additional notes | Max 500 chars |
| createdAt | DateTime | Yes | Record creation time | Auto-generated |
| updatedAt | DateTime | Yes | Last update time | Auto-updated |

### Example Implementation

```dart
import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

@Entity(tableName: 'vehicles')
class Vehicle {
  @PrimaryKey()
  final String id;
  
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final double? currentMileage;
  final String mileageUnit; // 'miles' or 'km'
  final DateTime? purchaseDate;
  final String? photoPath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    this.currentMileage,
    this.mileageUnit = 'miles',
    this.purchaseDate,
    this.photoPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating new vehicles
  factory Vehicle.create({
    required String make,
    required String model,
    required int year,
    String? vin,
    String? licensePlate,
    double? currentMileage,
    String mileageUnit = 'miles',
    DateTime? purchaseDate,
    String? photoPath,
    String? notes,
  }) {
    final now = DateTime.now();
    return Vehicle(
      id: const Uuid().v4(),
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      currentMileage: currentMileage,
      mileageUnit: mileageUnit,
      purchaseDate: purchaseDate,
      photoPath: photoPath,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with method for updates
  Vehicle copyWith({
    String? make,
    String? model,
    int? year,
    String? vin,
    String? licensePlate,
    double? currentMileage,
    String? mileageUnit,
    DateTime? purchaseDate,
    String? photoPath,
    String? notes,
  }) {
    return Vehicle(
      id: id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      currentMileage: currentMileage ?? this.currentMileage,
      mileageUnit: mileageUnit ?? this.mileageUnit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Display name for UI
  String get displayName => '$year $make $model';
  
  // Validation
  String? validate() {
    if (make.isEmpty) return 'Make is required';
    if (model.isEmpty) return 'Model is required';
    if (year < 1900 || year > DateTime.now().year + 1) {
      return 'Invalid year';
    }
    if (currentMileage != null && currentMileage! < 0) {
      return 'Mileage cannot be negative';
    }
    if (vin != null && vin!.length != 17) {
      return 'VIN must be 17 characters';
    }
    return null;
  }
}
```

---

## 2. MaintenanceRecord Model

### Purpose
Records a maintenance/service event for a vehicle.

### Fields

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | String | Yes | Unique identifier | UUID format |
| vehicleId | String | Yes | Related vehicle ID | Foreign key |
| serviceType | String | Yes | Type of service | Max 100 chars |
| serviceDate | DateTime | Yes | Date of service | <= today |
| mileage | double | No | Odometer at service | >= 0 |
| cost | double | No | Service cost | >= 0 |
| currency | String | Yes | Currency code | ISO 4217 (USD, EUR) |
| serviceProvider | String | No | Shop/mechanic name | Max 100 chars |
| serviceProviderId | String | No | Link to provider | Foreign key |
| description | String | No | Service description | Max 1000 chars |
| notes | String | No | Additional notes | Max 500 chars |
| receiptPhotoPath | String | No | Receipt image path | Local file path |
| partsReplaced | List<String> | No | Parts replaced | JSON array |
| nextServiceDue | DateTime | No | Next service date | > serviceDate |
| nextServiceMileage | double | No | Next service mileage | > mileage |
| createdAt | DateTime | Yes | Record creation | Auto-generated |
| updatedAt | DateTime | Yes | Last update | Auto-updated |

### Common Service Types

```dart
enum ServiceType {
  oilChange('Oil Change'),
  tireRotation('Tire Rotation'),
  brakeService('Brake Service'),
  batteryReplacement('Battery Replacement'),
  airFilter('Air Filter'),
  transmission('Transmission Service'),
  coolant('Coolant Flush'),
  sparkPlugs('Spark Plugs'),
  alignment('Wheel Alignment'),
  inspection('Safety Inspection'),
  registration('Registration Renewal'),
  other('Other');

  const ServiceType(this.displayName);
  final String displayName;
}
```

### Example Implementation

```dart
import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

@Entity(
  tableName: 'maintenance_records',
  foreignKeys: [
    ForeignKey(
      childColumns: ['vehicleId'],
      parentColumns: ['id'],
      entity: Vehicle,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class MaintenanceRecord {
  @PrimaryKey()
  final String id;
  
  @ColumnInfo(name: 'vehicleId')
  final String vehicleId;
  
  final String serviceType;
  final DateTime serviceDate;
  final double? mileage;
  final double? cost;
  final String currency;
  final String? serviceProvider;
  final String? serviceProviderId;
  final String? description;
  final String? notes;
  final String? receiptPhotoPath;
  final String? partsReplacedJson; // JSON string
  final DateTime? nextServiceDue;
  final double? nextServiceMileage;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.serviceDate,
    this.mileage,
    this.cost,
    this.currency = 'USD',
    this.serviceProvider,
    this.serviceProviderId,
    this.description,
    this.notes,
    this.receiptPhotoPath,
    this.partsReplacedJson,
    this.nextServiceDue,
    this.nextServiceMileage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceRecord.create({
    required String vehicleId,
    required String serviceType,
    required DateTime serviceDate,
    double? mileage,
    double? cost,
    String currency = 'USD',
    String? serviceProvider,
    String? serviceProviderId,
    String? description,
    String? notes,
    String? receiptPhotoPath,
    List<String>? partsReplaced,
    DateTime? nextServiceDue,
    double? nextServiceMileage,
  }) {
    final now = DateTime.now();
    return MaintenanceRecord(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      serviceType: serviceType,
      serviceDate: serviceDate,
      mileage: mileage,
      cost: cost,
      currency: currency,
      serviceProvider: serviceProvider,
      serviceProviderId: serviceProviderId,
      description: description,
      notes: notes,
      receiptPhotoPath: receiptPhotoPath,
      partsReplacedJson: partsReplaced != null ? jsonEncode(partsReplaced) : null,
      nextServiceDue: nextServiceDue,
      nextServiceMileage: nextServiceMileage,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Helper to get parts as list
  List<String> get partsReplaced {
    if (partsReplacedJson == null) return [];
    return List<String>.from(jsonDecode(partsReplacedJson!));
  }
}
```

---

## 3. Reminder Model

### Purpose
Schedules maintenance reminders based on time or mileage.

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique identifier |
| vehicleId | String | Yes | Related vehicle |
| serviceType | String | Yes | Service to remind |
| reminderType | String | Yes | 'time' or 'mileage' |
| intervalValue | int | Yes | Interval number |
| intervalUnit | String | Yes | 'days', 'months', 'miles', 'km' |
| lastServiceDate | DateTime | No | Last service date |
| lastServiceMileage | double | No | Last service mileage |
| nextReminderDate | DateTime | No | Calculated next date |
| nextReminderMileage | double | No | Calculated next mileage |
| isActive | bool | Yes | Reminder enabled |
| notifyBefore | int | Yes | Days/miles before |
| createdAt | DateTime | Yes | Creation time |
| updatedAt | DateTime | Yes | Update time |

### Example

```dart
@Entity(
  tableName: 'reminders',
  foreignKeys: [
    ForeignKey(
      childColumns: ['vehicleId'],
      parentColumns: ['id'],
      entity: Vehicle,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class Reminder {
  @PrimaryKey()
  final String id;
  
  final String vehicleId;
  final String serviceType;
  final String reminderType; // 'time' or 'mileage'
  final int intervalValue;
  final String intervalUnit; // 'days', 'months', 'miles', 'km'
  final DateTime? lastServiceDate;
  final double? lastServiceMileage;
  final DateTime? nextReminderDate;
  final double? nextReminderMileage;
  final bool isActive;
  final int notifyBefore; // Notify X days/miles before
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.reminderType,
    required this.intervalValue,
    required this.intervalUnit,
    this.lastServiceDate,
    this.lastServiceMileage,
    this.nextReminderDate,
    this.nextReminderMileage,
    this.isActive = true,
    this.notifyBefore = 7, // Default 7 days or miles
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate if reminder is due
  bool get isDue {
    if (!isActive) return false;
    
    if (reminderType == 'time' && nextReminderDate != null) {
      return DateTime.now().isAfter(nextReminderDate!);
    }
    
    // Mileage check requires current vehicle mileage
    return false;
  }
  
  // Calculate days until due
  int? get daysUntilDue {
    if (nextReminderDate == null) return null;
    return nextReminderDate!.difference(DateTime.now()).inDays;
  }
}
```

---

## 4. ServiceProvider Model

### Purpose
Store information about mechanics and service shops.

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique identifier |
| name | String | Yes | Provider name |
| phone | String | No | Contact phone |
| email | String | No | Contact email |
| address | String | No | Physical address |
| website | String | No | Website URL |
| notes | String | No | User notes |
| rating | double | No | User rating (1-5) |
| specialties | List<String> | No | Service specialties |
| createdAt | DateTime | Yes | Creation time |
| updatedAt | DateTime | Yes | Update time |

---

## 5. Document Model

### Purpose
Store vehicle-related documents and photos.

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique identifier |
| vehicleId | String | Yes | Related vehicle |
| documentType | String | Yes | Type of document |
| filePath | String | Yes | Local file path |
| title | String | No | Document title |
| description | String | No | Description |
| fileSize | int | No | Size in bytes |
| mimeType | String | No | File MIME type |
| createdAt | DateTime | Yes | Creation time |

### Document Types

```dart
enum DocumentType {
  receipt('Receipt'),
  insurance('Insurance'),
  registration('Registration'),
  manual('Owner\'s Manual'),
  warranty('Warranty'),
  photo('Photo'),
  other('Other');

  const DocumentType(this.displayName);
  final String displayName;
}
```

---

## Database Relationships

### One-to-Many Relationships

```
Vehicle (1) ──── (Many) MaintenanceRecord
Vehicle (1) ──── (Many) Reminder
Vehicle (1) ──── (Many) Document
```

### Cascade Delete
When a Vehicle is deleted, all related records should be deleted automatically using `onDelete: ForeignKeyAction.cascade`.

---

## Validation Rules

### Vehicle
- Make and Model: Required, 1-50 characters
- Year: Between 1900 and current year + 1
- VIN: Exactly 17 alphanumeric characters (if provided)
- Mileage: Non-negative number

### MaintenanceRecord
- Service Date: Cannot be in the future
- Mileage: Non-negative, typically >= previous records
- Cost: Non-negative
- Service Type: Required, from predefined list or custom

### Reminder
- Interval: Positive integer
- Last Service Date: Must be before next service date
- Notify Before: Positive integer, less than interval

---

## JSON Serialization

Each model should support:
- `toJson()`: Convert to JSON map
- `fromJson()`: Create from JSON map
- For Floor, use type converters for DateTime, Lists, etc.

### Example Type Converter

```dart
class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}
```

---

## Testing Models

### Unit Test Checklist
- [ ] Model creation with valid data
- [ ] Model creation with invalid data (validation)
- [ ] copyWith method updates fields correctly
- [ ] JSON serialization/deserialization
- [ ] Computed properties return correct values
- [ ] Foreign key relationships maintained
- [ ] Default values applied correctly

### Example Test

```dart
void main() {
  group('Vehicle Model Tests', () {
    test('Create valid vehicle', () {
      final vehicle = Vehicle.create(
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
      );
      
      expect(vehicle.make, 'Toyota');
      expect(vehicle.model, 'Camry');
      expect(vehicle.year, 2020);
      expect(vehicle.id.length, 36); // UUID length
    });
    
    test('Validation catches invalid year', () {
      final vehicle = Vehicle.create(
        make: 'Toyota',
        model: 'Camry',
        year: 1800, // Invalid year
      );
      
      expect(vehicle.validate(), isNotNull);
    });
  });
}
```

---

## Migration Strategy

When updating models:
1. Increment database version
2. Create migration script
3. Handle data transformation
4. Test migration thoroughly

### Example Migration

```dart
final migration1to2 = Migration(1, 2, (database) async {
  // Add new column
  await database.execute(
    'ALTER TABLE vehicles ADD COLUMN notes TEXT'
  );
});
```

---

**Last Updated**: February 13, 2026
**Version**: 1.0
