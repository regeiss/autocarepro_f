import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';
import 'vehicle_model.dart';

/// Store vehicle-related documents and photos
@Entity(
  tableName: 'documents',
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
    Index(value: ['documentType']),
  ],
)
class Document {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'vehicleId')
  final String vehicleId;

  final String documentType;
  final String filePath;
  final String? title;
  final String? description;
  final int? fileSize; // Size in bytes
  final String? mimeType;
  final int createdAt; // Stored as milliseconds since epoch

  Document({
    required this.id,
    required this.vehicleId,
    required this.documentType,
    required this.filePath,
    this.title,
    this.description,
    this.fileSize,
    this.mimeType,
    required this.createdAt,
  });

  /// Factory constructor for creating new documents
  factory Document.create({
    required String vehicleId,
    required DocumentType documentType,
    required String filePath,
    String? title,
    String? description,
    int? fileSize,
    String? mimeType,
  }) {
    final now = DateTime.now();
    return Document(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      documentType: documentType.value,
      filePath: filePath,
      title: title ?? documentType.displayName,
      description: description,
      fileSize: fileSize,
      mimeType: mimeType,
      createdAt: now.millisecondsSinceEpoch,
    );
  }

  /// Copy with method for updates
  Document copyWith({
    String? documentType,
    String? filePath,
    String? title,
    String? description,
    int? fileSize,
    String? mimeType,
  }) {
    return Document(
      id: id,
      vehicleId: vehicleId,
      documentType: documentType ?? this.documentType,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      description: description ?? this.description,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt,
    );
  }

  /// Get created date as DateTime
  DateTime get createdAtAsDateTime {
    return DateTime.fromMillisecondsSinceEpoch(createdAt);
  }

  /// Get file size in human-readable format
  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown size';

    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if file is an image
  bool get isImage {
    if (mimeType == null) return false;
    return mimeType!.startsWith('image/');
  }

  /// Check if file is a PDF
  bool get isPdf {
    if (mimeType == null) return false;
    return mimeType == 'application/pdf';
  }

  /// Get file extension
  String? get fileExtension {
    final parts = filePath.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }

  /// Validation
  String? validate() {
    if (vehicleId.trim().isEmpty) return 'Vehicle ID is required';
    if (documentType.trim().isEmpty) return 'Document type is required';
    if (filePath.trim().isEmpty) return 'File path is required';
    if (fileSize != null && fileSize! < 0) {
      return 'File size cannot be negative';
    }
    return null;
  }

  @override
  String toString() {
    return 'Document(id: $id, type: $documentType, title: ${title ?? "Untitled"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Document && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Document type enum
enum DocumentType {
  receipt('receipt', 'Receipt', 'Receipt for service or parts'),
  insurance('insurance', 'Insurance', 'Insurance documentation'),
  registration('registration', 'Registration', 'Vehicle registration'),
  manual('manual', 'Owner\'s Manual', 'Vehicle owner\'s manual'),
  warranty('warranty', 'Warranty', 'Warranty information'),
  inspection('inspection', 'Inspection Report', 'Safety or emissions inspection'),
  photo('photo', 'Photo', 'Vehicle photo'),
  title('title', 'Title', 'Vehicle title document'),
  other('other', 'Other', 'Other document');

  const DocumentType(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  static DocumentType fromValue(String value) {
    return DocumentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DocumentType.other,
    );
  }

  static List<String> get allDisplayNames {
    return DocumentType.values.map((type) => type.displayName).toList();
  }
}
