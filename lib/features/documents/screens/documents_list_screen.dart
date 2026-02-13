// Screen to display list of documents for a vehicle
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/document_providers.dart';
import '../../dashboard/widgets/empty_state.dart';
import '../widgets/document_list_tile.dart';
import 'document_detail_screen.dart';
import 'document_form_screen.dart';

class DocumentsListScreen extends ConsumerWidget {
  final String vehicleId;

  const DocumentsListScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsStreamProvider(vehicleId));
    final selectedTypeFilter = ref.watch(documentTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          // Filter menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by type',
            onSelected: (value) {
              ref.read(documentTypeFilterProvider.notifier).state = 
                  value == 'all' ? null : value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: selectedTypeFilter == null ? Theme.of(context).primaryColor : null,
                    ),
                    const SizedBox(width: 12),
                    const Text('All Types'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...DocumentType.values.map((type) => PopupMenuItem(
                value: type.value,
                child: Row(
                  children: [
                    Icon(
                      _getIconForType(type),
                      color: selectedTypeFilter == type.value ? Theme.of(context).primaryColor : null,
                    ),
                    const SizedBox(width: 12),
                    Text(type.displayName),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
      body: documentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (documents) {
          // Apply filter
          var filteredDocuments = documents;
          if (selectedTypeFilter != null) {
            filteredDocuments = documents
                .where((doc) => doc.documentType == selectedTypeFilter)
                .toList();
          }

          // Sort by date (newest first)
          filteredDocuments.sort((a, b) => 
            b.createdAt.compareTo(a.createdAt));

          if (filteredDocuments.isEmpty) {
            return EmptyState(
              icon: selectedTypeFilter != null ? Icons.filter_list_off : Icons.description,
              title: selectedTypeFilter != null 
                  ? 'No ${DocumentType.fromValue(selectedTypeFilter).displayName}s'
                  : 'No Documents Yet',
              message: selectedTypeFilter != null
                  ? 'No documents of this type found.\nTry a different filter or add a new document.'
                  : 'Start adding documents like insurance,\nregistration, receipts, and photos.',
              actionLabel: selectedTypeFilter != null ? 'Clear Filter' : 'Add Document',
              onAction: selectedTypeFilter != null
                  ? () => ref.read(documentTypeFilterProvider.notifier).state = null
                  : () => _navigateToAddDocument(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(documentsStreamProvider(vehicleId));
            },
            child: Column(
              children: [
                // Active filter chip
                if (selectedTypeFilter != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Chip(
                      avatar: Icon(
                        _getIconForType(DocumentType.fromValue(selectedTypeFilter)),
                        size: 16,
                      ),
                      label: Text(
                        DocumentType.fromValue(selectedTypeFilter).displayName,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        ref.read(documentTypeFilterProvider.notifier).state = null;
                      },
                    ),
                  ),

                // Document count
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '${filteredDocuments.length} document${filteredDocuments.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Documents list
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final document = filteredDocuments[index];
                      return DocumentListTile(
                        document: document,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DocumentDetailScreen(
                                documentId: document.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddDocument(context),
        tooltip: 'Add Document',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddDocument(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentFormScreen(
          vehicleId: vehicleId,
        ),
      ),
    );
  }

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.receipt:
        return Icons.receipt_long;
      case DocumentType.insurance:
        return Icons.shield;
      case DocumentType.registration:
        return Icons.description;
      case DocumentType.manual:
        return Icons.menu_book;
      case DocumentType.warranty:
        return Icons.verified_user;
      case DocumentType.inspection:
        return Icons.fact_check;
      case DocumentType.photo:
        return Icons.photo;
      case DocumentType.title:
        return Icons.article;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }
}
