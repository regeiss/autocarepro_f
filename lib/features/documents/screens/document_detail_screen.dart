// Screen to display document details with file viewer
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/document_providers.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../app/theme.dart';
import 'document_form_screen.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String documentId;

  const DocumentDetailScreen({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(documentDetailProvider(documentId));

    return documentAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Document Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      data: (document) {
        if (document == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Document Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Document not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return _DocumentDetailContent(document: document);
      },
    );
  }
}

class _DocumentDetailContent extends ConsumerWidget {
  final Document document;

  const _DocumentDetailContent({required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docType = DocumentType.fromValue(document.documentType);
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(document.title ?? docType.displayName),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _shareDocument(context),
          ),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DocumentFormScreen(
                    vehicleId: document.vehicleId,
                    document: document,
                  ),
                ),
              );
            },
          ),
          // Delete button
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context, ref);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Preview
            _buildFilePreview(context, document),

            // Document Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getIconColor(docType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getIconColor(docType).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForType(docType),
                          size: 16,
                          color: _getIconColor(docType),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          docType.displayName,
                          style: TextStyle(
                            color: _getIconColor(docType),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    document.title ?? docType.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(document.createdAtAsDateTime)} at ${timeFormat.format(document.createdAtAsDateTime)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Description
                  if (document.description != null &&
                      document.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      document.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // File Information
                  Text(
                    'File Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                    context,
                    Icons.insert_drive_file,
                    'File Name',
                    document.filePath.split('/').last,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoRow(
                    context,
                    Icons.storage,
                    'File Size',
                    document.fileSizeFormatted,
                  ),
                  const SizedBox(height: 12),

                  if (document.mimeType != null)
                    _buildInfoRow(
                      context,
                      Icons.description,
                      'File Type',
                      document.mimeType!,
                    ),

                  if (document.fileExtension != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.extension,
                      'Extension',
                      document.fileExtension!.toUpperCase(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context, Document document) {
    if (document.isImage) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.black,
        child: File(document.filePath).existsSync()
            ? Image.file(
                File(document.filePath),
                fit: BoxFit.contain,
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.white54),
                    SizedBox(height: 8),
                    Text(
                      'Image file not found',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
      );
    } else if (document.isPdf) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.red[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.red[700],
            ),
            const SizedBox(height: 16),
            Text(
              'PDF Document',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              document.fileSizeFormatted,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              document.fileExtension?.toUpperCase() ?? 'File',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              document.fileSizeFormatted,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareDocument(BuildContext context) async {
    try {
      final file = File(document.filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File not found')),
          );
        }
        return;
      }

      await Share.shareXFiles(
        [XFile(document.filePath)],
        text: document.title ?? document.documentType,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing document: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document?'),
        content: const Text(
          'This will permanently delete this document. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(documentRepositoryProvider);

        // Delete the file
        final file = File(document.filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Delete from database
        await repository.deleteDocumentById(document.id);

        // Invalidate providers
        ref.invalidate(documentsStreamProvider(document.vehicleId));
        ref.invalidate(documentCountProvider(document.vehicleId));

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting document: $e')),
          );
        }
      }
    }
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

  Color _getIconColor(DocumentType type) {
    switch (type) {
      case DocumentType.receipt:
        return AppTheme.successColor;
      case DocumentType.insurance:
        return AppTheme.primaryColor;
      case DocumentType.registration:
        return AppTheme.warningColor;
      case DocumentType.manual:
        return Colors.blue;
      case DocumentType.warranty:
        return Colors.purple;
      case DocumentType.inspection:
        return Colors.teal;
      case DocumentType.photo:
        return Colors.pink;
      case DocumentType.title:
        return Colors.deepOrange;
      case DocumentType.other:
        return Colors.grey;
    }
  }
}
