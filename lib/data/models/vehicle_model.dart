import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

import 'profile_model.dart';

/// Represents a vehicle in the user's garage
@Entity(
  tableName: 'vehicles',
  foreignKeys: [
    ForeignKey(
      childColumns: ['profileId'],
      parentColumns: ['id'],
      entity: Profile,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
  indices: [Index(value: ['profileId'])],
)
class Vehicle {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'profileId')
  final String profileId;

  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final double? currentMileage;
  final String mileageUnit; // 'miles' or 'km'
  final int? purchaseDate; // Stored as milliseconds since epoch
  final String? photoPath;
  final String? notes;
  final int createdAt; // Stored as milliseconds since epoch
  final int updatedAt; // Stored as milliseconds since epoch

  Vehicle({
    required this.id,
    required this.profileId,
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

  /// Factory constructor for creating new vehicles
  factory Vehicle.create({
    required String profileId,
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
      profileId: profileId,
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      currentMileage: currentMileage,
      mileageUnit: mileageUnit,
      purchaseDate: purchaseDate?.millisecondsSinceEpoch,
      photoPath: photoPath,
      notes: notes,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );
  }

  /// Copy with method for updates
  Vehicle copyWith({
    String? profileId,
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
      profileId: profileId ?? this.profileId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      currentMileage: currentMileage ?? this.currentMileage,
      mileageUnit: mileageUnit ?? this.mileageUnit,
      purchaseDate: purchaseDate?.millisecondsSinceEpoch ?? this.purchaseDate,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Display name for UI
  String get displayName => '$year $make $model';

  /// Get purchase date as DateTime
  DateTime? get purchaseDateAsDateTime {
    return purchaseDate != null
        ? DateTime.fromMillisecondsSinceEpoch(purchaseDate!)
        : null;
  }

  /// Get created date as DateTime
  DateTime get createdAtAsDateTime {
    return DateTime.fromMillisecondsSinceEpoch(createdAt);
  }

  /// Get updated date as DateTime
  DateTime get updatedAtAsDateTime {
    return DateTime.fromMillisecondsSinceEpoch(updatedAt);
  }

  /// Validation
  String? validate() {
    if (profileId.trim().isEmpty) return 'Profile is required';
    if (make.trim().isEmpty) return 'Make is required';
    if (model.trim().isEmpty) return 'Model is required';
    if (year < 1900 || year > DateTime.now().year + 1) {
      return 'Invalid year';
    }
    if (currentMileage != null && currentMileage! < 0) {
      return 'Mileage cannot be negative';
    }
    if (vin != null && vin!.isNotEmpty && vin!.length != 17) {
      return 'VIN must be 17 characters';
    }
    if (mileageUnit != 'miles' && mileageUnit != 'km') {
      return 'Mileage unit must be either "miles" or "km"';
    }
    return null;
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, displayName: $displayName, mileage: $currentMileage $mileageUnit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Vehicle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum for mileage units
enum MileageUnit {
  miles('miles', 'Miles'),
  kilometers('km', 'Kilometers');

  const MileageUnit(this.value, this.displayName);
  final String value;
  final String displayName;

  static MileageUnit fromValue(String value) {
    return MileageUnit.values.firstWhere(
      (unit) => unit.value == value,
      orElse: () => MileageUnit.miles,
    );
  }
}
