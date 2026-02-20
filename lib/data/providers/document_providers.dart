// Riverpod providers for documents
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'profile_providers.dart';
import 'repository_providers.dart';
import '../repositories/document_repository.dart';

// ============================================================================
// List Providers
// ============================================================================

/// Provider for all documents of a specific vehicle
final documentsListProvider = FutureProvider.family<List<Document>, String>((ref, vehicleId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getDocumentsByVehicle(vehicleId);
});

/// Stream provider for real-time document updates
final documentsStreamProvider = StreamProvider.family<List<Document>, String>((ref, vehicleId) {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.watchDocumentsByVehicle(vehicleId);
});

/// Provider for documents by type
final documentsByTypeProvider = FutureProvider.family<List<Document>, ({String vehicleId, String type})>((ref, params) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getDocumentsByVehicleAndType(params.vehicleId, params.type);
});

/// Provider for recent documents (profile-scoped)
final recentDocumentsProvider = FutureProvider.family<List<Document>, int>((ref, limit) async {
  final profileId = ref.watch(currentProfileIdProvider).value;
  if (profileId == null) return [];
  final vehicleRepo = ref.watch(vehicleRepositoryProvider);
  final documentRepo = ref.watch(documentRepositoryProvider);
  final vehicles = await vehicleRepo.getVehiclesByProfile(profileId);
  final vehicleIds = vehicles.map((v) => v.id).toSet();
  final documents = await documentRepo.getRecentDocuments(limit: limit * 2);
  return documents.where((d) => vehicleIds.contains(d.vehicleId)).take(limit).toList();
});

/// Provider for image documents only
final imageDocumentsProvider = FutureProvider.family<List<Document>, String>((ref, vehicleId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getImageDocuments(vehicleId);
});

/// Provider for PDF documents only
final pdfDocumentsProvider = FutureProvider.family<List<Document>, String>((ref, vehicleId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getPdfDocuments(vehicleId);
});

// ============================================================================
// Single Document Providers
// ============================================================================

/// Provider for a single document by ID
final documentDetailProvider = FutureProvider.family<Document?, String>((ref, id) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getDocumentById(id);
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for document count per vehicle
final documentCountProvider = FutureProvider.family<int, String>((ref, vehicleId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getDocumentCountByVehicle(vehicleId);
});

/// Provider for total storage used by vehicle
final vehicleStorageProvider = FutureProvider.family<String, String>((ref, vehicleId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getVehicleStorageFormatted(vehicleId);
});

/// Provider for total storage used
final totalStorageProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getTotalStorageFormatted();
});

/// Provider for vehicle document summary
final documentSummaryProvider = FutureProvider.family<DocumentSummary, String>((ref, vehicleId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getVehicleSummary(vehicleId);
});

/// Provider for documents grouped by type
final documentsGroupedProvider = FutureProvider.family<Map<String, List<Document>>, String>((ref, vehicleId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return await repository.getDocumentsGroupedByType(vehicleId);
});

// ============================================================================
// UI State Providers
// ============================================================================

/// State provider for selected document (for editing)
final selectedDocumentProvider = StateProvider<Document?>((ref) => null);

/// State provider for document type filter
final documentTypeFilterProvider = StateProvider<String?>((ref) => null);

/// State provider for file upload progress
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);
