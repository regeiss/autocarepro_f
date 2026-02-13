import 'package:floor/floor.dart';
import '../../../data/models/document_model.dart';

/// Data Access Object for Document operations
@dao
abstract class DocumentDao {
  /// Get all documents ordered by creation date (newest first)
  @Query('SELECT * FROM documents ORDER BY createdAt DESC')
  Future<List<Document>> getAllDocuments();

  /// Get all documents as a stream
  @Query('SELECT * FROM documents ORDER BY createdAt DESC')
  Stream<List<Document>> watchAllDocuments();

  /// Get a document by ID
  @Query('SELECT * FROM documents WHERE id = :id')
  Future<Document?> getDocumentById(String id);

  /// Get documents by vehicle ID
  @Query('SELECT * FROM documents WHERE vehicleId = :vehicleId ORDER BY createdAt DESC')
  Future<List<Document>> getDocumentsByVehicleId(String vehicleId);

  /// Get documents by vehicle ID as a stream
  @Query('SELECT * FROM documents WHERE vehicleId = :vehicleId ORDER BY createdAt DESC')
  Stream<List<Document>> watchDocumentsByVehicleId(String vehicleId);

  /// Get documents by type
  @Query('SELECT * FROM documents WHERE documentType = :documentType ORDER BY createdAt DESC')
  Future<List<Document>> getDocumentsByType(String documentType);

  /// Get documents by vehicle and type
  @Query('''
    SELECT * FROM documents 
    WHERE vehicleId = :vehicleId 
    AND documentType = :documentType
    ORDER BY createdAt DESC
  ''')
  Future<List<Document>> getDocumentsByVehicleAndType(String vehicleId, String documentType);

  /// Get recent documents (last N documents)
  @Query('SELECT * FROM documents ORDER BY createdAt DESC LIMIT :limit')
  Future<List<Document>> getRecentDocuments(int limit);

  /// Search documents by title or description
  @Query('''
    SELECT * FROM documents 
    WHERE title LIKE '%' || :query || '%' 
    OR description LIKE '%' || :query || '%'
    ORDER BY createdAt DESC
  ''')
  Future<List<Document>> searchDocuments(String query);

  /// Get count of documents by vehicle
  @Query('SELECT COUNT(*) FROM documents WHERE vehicleId = :vehicleId')
  Future<int?> getDocumentCountByVehicle(String vehicleId);

  /// Get count of documents by type
  @Query('SELECT COUNT(*) FROM documents WHERE documentType = :documentType')
  Future<int?> getDocumentCountByType(String documentType);

  /// Get total file size for a vehicle
  @Query('SELECT SUM(fileSize) FROM documents WHERE vehicleId = :vehicleId')
  Future<int?> getTotalFileSizeByVehicle(String vehicleId);

  /// Get total file size for all documents
  @Query('SELECT SUM(fileSize) FROM documents')
  Future<int?> getTotalFileSize();

  /// Insert a new document
  @insert
  Future<void> insertDocument(Document document);

  /// Insert multiple documents
  @insert
  Future<void> insertDocuments(List<Document> documents);

  /// Update an existing document
  @update
  Future<void> updateDocument(Document document);

  /// Delete a document
  @delete
  Future<void> deleteDocument(Document document);

  /// Delete document by ID
  @Query('DELETE FROM documents WHERE id = :id')
  Future<void> deleteDocumentById(String id);

  /// Delete all documents for a vehicle
  @Query('DELETE FROM documents WHERE vehicleId = :vehicleId')
  Future<void> deleteDocumentsByVehicleId(String vehicleId);

  /// Delete all documents
  @Query('DELETE FROM documents')
  Future<void> deleteAllDocuments();
}
