import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

/// Store information about mechanics and service shops
@Entity(
  tableName: 'service_providers',
  indices: [
    Index(value: ['name']),
    Index(value: ['profileId']),
  ],
)
class ServiceProvider {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'profileId')
  final String profileId;

  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? website;
  final String? notes;
  final double? rating; // 1.0 to 5.0
  final String? specialtiesJson; // JSON string array
  final int createdAt; // Stored as milliseconds since epoch
  final int updatedAt; // Stored as milliseconds since epoch

  ServiceProvider({
    required this.id,
    required this.profileId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.notes,
    this.rating,
    this.specialtiesJson,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for creating new service providers
  factory ServiceProvider.create({
    required String profileId,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? website,
    String? notes,
    double? rating,
    List<String>? specialties,
  }) {
    final now = DateTime.now();
    return ServiceProvider(
      id: const Uuid().v4(),
      profileId: profileId,
      name: name,
      phone: phone,
      email: email,
      address: address,
      website: website,
      notes: notes,
      rating: rating,
      specialtiesJson: specialties != null && specialties.isNotEmpty
          ? _encodeSpecialties(specialties)
          : null,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );
  }

  /// Copy with method for updates
  ServiceProvider copyWith({
    String? profileId,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? website,
    String? notes,
    double? rating,
    List<String>? specialties,
  }) {
    return ServiceProvider(
      id: id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      specialtiesJson: specialties != null
          ? (specialties.isNotEmpty ? _encodeSpecialties(specialties) : null)
          : specialtiesJson,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Helper to encode specialties as JSON
  static String _encodeSpecialties(List<String> specialties) {
    return specialties.join(',');
  }

  /// Helper to decode specialties from JSON
  List<String> get specialties {
    if (specialtiesJson == null || specialtiesJson!.isEmpty) return [];
    return specialtiesJson!.split(',').map((s) => s.trim()).toList();
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
    if (name.trim().isEmpty) return 'Name is required';
    if (rating != null && (rating! < 1.0 || rating! > 5.0)) {
      return 'Rating must be between 1.0 and 5.0';
    }
    if (email != null && email!.isNotEmpty) {
      // Basic email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email!)) {
        return 'Invalid email format';
      }
    }
    return null;
  }

  /// Get display contact info
  String get displayContact {
    final List<String> contacts = [];
    if (phone != null && phone!.isNotEmpty) contacts.add(phone!);
    if (email != null && email!.isNotEmpty) contacts.add(email!);
    return contacts.isNotEmpty ? contacts.join(' • ') : 'No contact info';
  }

  @override
  String toString() {
    return 'ServiceProvider(id: $id, name: $name, rating: ${rating ?? "N/A"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceProvider && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Common service provider specialties
class ProviderSpecialty {
  static const String oilChange = 'Oil Change';
  static const String brakes = 'Brakes';
  static const String tires = 'Tires';
  static const String transmission = 'Transmission';
  static const String engine = 'Engine';
  static const String electrical = 'Electrical';
  static const String bodyWork = 'Body Work';
  static const String detailing = 'Detailing';
  static const String diagnostic = 'Diagnostic';
  static const String airConditioning = 'Air Conditioning';

  static List<String> get all => [
        oilChange,
        brakes,
        tires,
        transmission,
        engine,
        electrical,
        bodyWork,
        detailing,
        diagnostic,
        airConditioning,
      ];
}
