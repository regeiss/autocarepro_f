// Widget to display a document in a list
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';
import '../../../app/theme.dart';

class DocumentListTile extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DocumentListTile({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final docType = DocumentType.fromValue(document.documentType);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Document type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconColor(docType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(docType),
                  color: _getIconColor(docType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      document.title ?? docType.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Type and date
                    Row(
                      children: [
                        Text(
                          docType.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          dateFormat.format(document.createdAtAsDateTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),

                    // File size
                    if (document.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        document.fileSizeFormatted,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              // File type indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getFileTypeBadgeColor(document),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getFileTypeLabel(document),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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

  Color _getFileTypeBadgeColor(Document document) {
    if (document.isImage) {
      return Colors.blue;
    } else if (document.isPdf) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String _getFileTypeLabel(Document document) {
    if (document.isImage) {
      return 'IMG';
    } else if (document.isPdf) {
      return 'PDF';
    } else {
      final ext = document.fileExtension;
      return ext?.toUpperCase() ?? 'FILE';
    }
  }
}
