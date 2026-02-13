import 'dart:convert';
import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';
import 'vehicle_model.dart';

/// Records a maintenance/service event for a vehicle
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
  indices: [
    Index(value: ['vehicleId']),
    Index(value: ['serviceDate']),
  ],
)
class MaintenanceRecord {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'vehicleId')
  final String vehicleId;

  final String serviceType;
  final int serviceDate; // Stored as milliseconds since epoch
  final double? mileage;
  final double? cost;
  final String currency;
  final String? serviceProvider;
  final String? serviceProviderId;
  final String? description;
  final String? notes;
  final String? receiptPhotoPath;
  final String? partsReplacedJson; // JSON string array
  final int? nextServiceDue; // Stored as milliseconds since epoch
  final double? nextServiceMileage;
  final int createdAt; // Stored as milliseconds since epoch
  final int updatedAt; // Stored as milliseconds since epoch

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

  /// Factory constructor for creating new maintenance records
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
      serviceDate: serviceDate.millisecondsSinceEpoch,
      mileage: mileage,
      cost: cost,
      currency: currency,
      serviceProvider: serviceProvider,
      serviceProviderId: serviceProviderId,
      description: description,
      notes: notes,
      receiptPhotoPath: receiptPhotoPath,
      partsReplacedJson:
          partsReplaced != null && partsReplaced.isNotEmpty
              ? jsonEncode(partsReplaced)
              : null,
      nextServiceDue: nextServiceDue?.millisecondsSinceEpoch,
      nextServiceMileage: nextServiceMileage,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );
  }

  /// Copy with method for updates
  MaintenanceRecord copyWith({
    String? serviceType,
    DateTime? serviceDate,
    double? mileage,
    double? cost,
    String? currency,
    String? serviceProvider,
    String? serviceProviderId,
    String? description,
    String? notes,
    String? receiptPhotoPath,
    List<String>? partsReplaced,
    DateTime? nextServiceDue,
    double? nextServiceMileage,
  }) {
    return MaintenanceRecord(
      id: id,
      vehicleId: vehicleId,
      serviceType: serviceType ?? this.serviceType,
      serviceDate: serviceDate?.millisecondsSinceEpoch ?? this.serviceDate,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      receiptPhotoPath: receiptPhotoPath ?? this.receiptPhotoPath,
      partsReplacedJson: partsReplaced != null
          ? (partsReplaced.isNotEmpty ? jsonEncode(partsReplaced) : null)
          : partsReplacedJson,
      nextServiceDue:
          nextServiceDue?.millisecondsSinceEpoch ?? this.nextServiceDue,
      nextServiceMileage: nextServiceMileage ?? this.nextServiceMileage,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Helper to get parts as list
  List<String> get partsReplaced {
    if (partsReplacedJson == null || partsReplacedJson!.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(partsReplacedJson!));
    } catch (e) {
      return [];
    }
  }

  /// Get service date as DateTime
  DateTime get serviceDateAsDateTime {
    return DateTime.fromMillisecondsSinceEpoch(serviceDate);
  }

  /// Get next service due as DateTime
  DateTime? get nextServiceDueAsDateTime {
    return nextServiceDue != null
        ? DateTime.fromMillisecondsSinceEpoch(nextServiceDue!)
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

  /// Check if service is overdue based on mileage
  bool isOverdueMileage(double currentMileage) {
    if (nextServiceMileage == null) return false;
    return currentMileage >= nextServiceMileage!;
  }

  /// Check if service is overdue based on date
  bool get isOverdueDate {
    if (nextServiceDue == null) return false;
    return DateTime.now().isAfter(nextServiceDueAsDateTime!);
  }

  /// Validation
  String? validate() {
    if (vehicleId.trim().isEmpty) return 'Vehicle ID is required';
    if (serviceType.trim().isEmpty) return 'Service type is required';
    if (serviceDateAsDateTime.isAfter(DateTime.now())) {
      return 'Service date cannot be in the future';
    }
    if (mileage != null && mileage! < 0) {
      return 'Mileage cannot be negative';
    }
    if (cost != null && cost! < 0) {
      return 'Cost cannot be negative';
    }
    if (nextServiceMileage != null &&
        mileage != null &&
        nextServiceMileage! <= mileage!) {
      return 'Next service mileage must be greater than current mileage';
    }
    return null;
  }

  @override
  String toString() {
    return 'MaintenanceRecord(id: $id, type: $serviceType, date: ${serviceDateAsDateTime.toString().split(' ')[0]}, cost: ${cost ?? 0} $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaintenanceRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Common service types enum
enum ServiceType {
  oilChange('Oil Change'),
  tireRotation('Tire Rotation'),
  brakeService('Brake Service'),
  batteryReplacement('Battery Replacement'),
  airFilter('Air Filter Replacement'),
  transmission('Transmission Service'),
  coolant('Coolant Flush'),
  sparkPlugs('Spark Plugs Replacement'),
  alignment('Wheel Alignment'),
  inspection('Safety Inspection'),
  registration('Registration Renewal'),
  insurance('Insurance Renewal'),
  cleaning('Car Wash/Detailing'),
  other('Other');

  const ServiceType(this.displayName);
  final String displayName;

  static ServiceType fromDisplayName(String name) {
    return ServiceType.values.firstWhere(
      (type) => type.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => ServiceType.other,
    );
  }

  static List<String> get allDisplayNames {
    return ServiceType.values.map((type) => type.displayName).toList();
  }
}
