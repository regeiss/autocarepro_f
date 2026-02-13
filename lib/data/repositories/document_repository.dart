import '../models/document_model.dart';
import '../../services/local_database/app_database.dart';
import 'vehicle_repository.dart';

/// Repository for document data operations
/// 
/// This repository provides a clean API for document-related operations,
/// including file management, document organization, and storage tracking.
class DocumentRepository {
  final AppDatabase _database;

  DocumentRepository(this._database);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all documents
  Future<List<Document>> getAllDocuments() async {
    try {
      return await _database.documentDao.getAllDocuments();
    } catch (e) {
      throw RepositoryException('Failed to get documents: $e');
    }
  }

  /// Watch all documents (reactive stream)
  Stream<List<Document>> watchAllDocuments() {
    return _database.documentDao.watchAllDocuments();
  }

  /// Get a document by ID
  Future<Document?> getDocumentById(String id) async {
    try {
      return await _database.documentDao.getDocumentById(id);
    } catch (e) {
      throw RepositoryException('Failed to get document: $e');
    }
  }

  /// Get documents for a specific vehicle
  Future<List<Document>> getDocumentsByVehicle(String vehicleId) async {
    try {
      return await _database.documentDao.getDocumentsByVehicleId(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to get documents for vehicle: $e');
    }
  }

  /// Watch documents for a specific vehicle (reactive stream)
  Stream<List<Document>> watchDocumentsByVehicle(String vehicleId) {
    return _database.documentDao.watchDocumentsByVehicleId(vehicleId);
  }

  /// Get documents by type
  Future<List<Document>> getDocumentsByType(String documentType) async {
    try {
      return await _database.documentDao.getDocumentsByType(documentType);
    } catch (e) {
      throw RepositoryException('Failed to get documents by type: $e');
    }
  }

  /// Get documents by vehicle and type
  Future<List<Document>> getDocumentsByVehicleAndType(
    String vehicleId,
    String documentType,
  ) async {
    try {
      return await _database.documentDao.getDocumentsByVehicleAndType(
        vehicleId,
        documentType,
      );
    } catch (e) {
      throw RepositoryException('Failed to get documents: $e');
    }
  }

  /// Get recent documents
  Future<List<Document>> getRecentDocuments({int limit = 10}) async {
    try {
      return await _database.documentDao.getRecentDocuments(limit);
    } catch (e) {
      throw RepositoryException('Failed to get recent documents: $e');
    }
  }

  /// Search documents by title or description
  Future<List<Document>> searchDocuments(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllDocuments();
      }
      return await _database.documentDao.searchDocuments(query);
    } catch (e) {
      throw RepositoryException('Failed to search documents: $e');
    }
  }

  /// Get document count for a vehicle
  Future<int> getDocumentCountByVehicle(String vehicleId) async {
    try {
      return await _database.documentDao.getDocumentCountByVehicle(vehicleId) ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get document count: $e');
    }
  }

  /// Get document count by type
  Future<int> getDocumentCountByType(String documentType) async {
    try {
      return await _database.documentDao.getDocumentCountByType(documentType) ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get document count by type: $e');
    }
  }

  /// Get total file size for a vehicle (in bytes)
  Future<int> getTotalFileSizeByVehicle(String vehicleId) async {
    try {
      return await _database.documentDao.getTotalFileSizeByVehicle(vehicleId) ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get total file size: $e');
    }
  }

  /// Get total file size for all documents (in bytes)
  Future<int> getTotalFileSize() async {
    try {
      return await _database.documentDao.getTotalFileSize() ?? 0;
    } catch (e) {
      throw RepositoryException('Failed to get total file size: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Add a new document
  Future<void> addDocument(Document document) async {
    try {
      // Validate before inserting
      final error = document.validate();
      if (error != null) {
        throw RepositoryException('Invalid document: $error');
      }
      
      await _database.documentDao.insertDocument(document);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add document: $e');
    }
  }

  /// Add multiple documents
  Future<void> addDocuments(List<Document> documents) async {
    try {
      // Validate all documents
      for (final document in documents) {
        final error = document.validate();
        if (error != null) {
          throw RepositoryException('Invalid document ${document.title}: $error');
        }
      }
      
      await _database.documentDao.insertDocuments(documents);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add documents: $e');
    }
  }

  /// Update an existing document
  Future<void> updateDocument(Document document) async {
    try {
      // Validate before updating
      final error = document.validate();
      if (error != null) {
        throw RepositoryException('Invalid document: $error');
      }

      // Check if document exists
      final existing = await getDocumentById(document.id);
      if (existing == null) {
        throw RepositoryException('Document not found: ${document.id}');
      }
      
      await _database.documentDao.updateDocument(document);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update document: $e');
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a document
  /// Note: This does NOT delete the actual file, only the database record
  Future<void> deleteDocument(Document document) async {
    try {
      await _database.documentDao.deleteDocument(document);
    } catch (e) {
      throw RepositoryException('Failed to delete document: $e');
    }
  }

  /// Delete a document by ID
  /// Note: This does NOT delete the actual file, only the database record
  Future<void> deleteDocumentById(String id) async {
    try {
      // Check if document exists
      final existing = await getDocumentById(id);
      if (existing == null) {
        throw RepositoryException('Document not found: $id');
      }

      await _database.documentDao.deleteDocumentById(id);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to delete document: $e');
    }
  }

  /// Delete all documents for a vehicle
  /// Note: This does NOT delete the actual files, only the database records
  Future<void> deleteDocumentsByVehicle(String vehicleId) async {
    try {
      await _database.documentDao.deleteDocumentsByVehicleId(vehicleId);
    } catch (e) {
      throw RepositoryException('Failed to delete documents for vehicle: $e');
    }
  }

  /// Delete all documents
  /// Note: This does NOT delete the actual files, only the database records
  Future<void> deleteAllDocuments() async {
    try {
      await _database.documentDao.deleteAllDocuments();
    } catch (e) {
      throw RepositoryException('Failed to delete all documents: $e');
    }
  }

  // ============================================================================
  // BUSINESS LOGIC METHODS
  // ============================================================================

  /// Get document summary for a vehicle
  Future<DocumentSummary> getVehicleSummary(String vehicleId) async {
    try {
      final documents = await getDocumentsByVehicle(vehicleId);
      final totalSize = await getTotalFileSizeByVehicle(vehicleId);
      
      // Count by type
      final typeCounts = <String, int>{};
      for (final doc in documents) {
        typeCounts[doc.documentType] = (typeCounts[doc.documentType] ?? 0) + 1;
      }

      // Count images
      final imageCount = documents.where((d) => d.isImage).length;
      final pdfCount = documents.where((d) => d.isPdf).length;

      return DocumentSummary(
        totalDocuments: documents.length,
        totalSize: totalSize,
        imageCount: imageCount,
        pdfCount: pdfCount,
        documentsByType: typeCounts,
      );
    } catch (e) {
      throw RepositoryException('Failed to get document summary: $e');
    }
  }

  /// Get total storage used in human-readable format
  Future<String> getTotalStorageFormatted() async {
    try {
      final totalBytes = await getTotalFileSize();
      return _formatFileSize(totalBytes);
    } catch (e) {
      throw RepositoryException('Failed to get formatted storage: $e');
    }
  }

  /// Get storage used by vehicle in human-readable format
  Future<String> getVehicleStorageFormatted(String vehicleId) async {
    try {
      final totalBytes = await getTotalFileSizeByVehicle(vehicleId);
      return _formatFileSize(totalBytes);
    } catch (e) {
      throw RepositoryException('Failed to get formatted storage: $e');
    }
  }

  /// Get image documents only
  Future<List<Document>> getImageDocuments(String vehicleId) async {
    try {
      final documents = await getDocumentsByVehicle(vehicleId);
      return documents.where((d) => d.isImage).toList();
    } catch (e) {
      throw RepositoryException('Failed to get image documents: $e');
    }
  }

  /// Get PDF documents only
  Future<List<Document>> getPdfDocuments(String vehicleId) async {
    try {
      final documents = await getDocumentsByVehicle(vehicleId);
      return documents.where((d) => d.isPdf).toList();
    } catch (e) {
      throw RepositoryException('Failed to get PDF documents: $e');
    }
  }

  /// Check if vehicle has any documents
  Future<bool> vehicleHasDocuments(String vehicleId) async {
    final count = await getDocumentCountByVehicle(vehicleId);
    return count > 0;
  }

  /// Get documents grouped by type
  Future<Map<String, List<Document>>> getDocumentsGroupedByType(
    String vehicleId,
  ) async {
    try {
      final documents = await getDocumentsByVehicle(vehicleId);
      final grouped = <String, List<Document>>{};

      for (final doc in documents) {
        if (!grouped.containsKey(doc.documentType)) {
          grouped[doc.documentType] = [];
        }
        grouped[doc.documentType]!.add(doc);
      }

      return grouped;
    } catch (e) {
      throw RepositoryException('Failed to group documents: $e');
    }
  }

  // Helper method to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

/// Document summary data class
class DocumentSummary {
  final int totalDocuments;
  final int totalSize; // in bytes
  final int imageCount;
  final int pdfCount;
  final Map<String, int> documentsByType;

  DocumentSummary({
    required this.totalDocuments,
    required this.totalSize,
    required this.imageCount,
    required this.pdfCount,
    required this.documentsByType,
  });

  String get formattedSize {
    if (totalSize < 1024) {
      return '$totalSize B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    } else if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  @override
  String toString() {
    return 'DocumentSummary(total: $totalDocuments, size: $formattedSize, images: $imageCount, pdfs: $pdfCount)';
  }
}
