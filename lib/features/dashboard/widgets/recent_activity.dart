import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/recent_activity_provider.dart';
import '../../../app/theme.dart';
import '../../maintenance/screens/maintenance_detail_screen.dart';
import '../../reminders/screens/reminder_detail_screen.dart';
import '../../documents/screens/document_detail_screen.dart';

/// Recent activity feed showing maintenance, reminders, and documents
class RecentActivity extends ConsumerWidget {
  final int limit;

  const RecentActivity({super.key, this.limit = 8});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider(limit));

    return activityAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No recent activity yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: items.map((item) => _ActivityTile(item: item)).toList(),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Error loading activity',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getIconAndColor(item.type);
    final timeAgo = _formatTimeAgo(item.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppTheme.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getIconAndColor(ActivityType type) {
    switch (type) {
      case ActivityType.maintenance:
        return (Icons.build, AppTheme.primaryColor);
      case ActivityType.reminder:
        return (Icons.notifications_active, AppTheme.warningColor);
      case ActivityType.document:
        return (Icons.description, AppTheme.secondaryColor);
    }
  }

  String _formatTimeAgo(int timestampMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  void _navigateToDetail(BuildContext context) {
    switch (item.type) {
      case ActivityType.maintenance:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MaintenanceDetailScreen(maintenanceId: item.id),
          ),
        );
        break;
      case ActivityType.reminder:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReminderDetailScreen(reminderId: item.id),
          ),
        );
        break;
      case ActivityType.document:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DocumentDetailScreen(documentId: item.id),
          ),
        );
        break;
    }
  }
}
