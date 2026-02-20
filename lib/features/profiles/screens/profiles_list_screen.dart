import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/providers/profile_providers.dart';
import '../../../data/providers/repository_providers.dart';
import 'profile_form_screen.dart';

/// Screen listing all profiles with ability to add, edit, switch, and delete
class ProfilesListScreen extends ConsumerWidget {
  const ProfilesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesStreamProvider);
    final currentProfileId = ref.watch(currentProfileIdProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToProfileForm(context),
            tooltip: 'Add profile',
          ),
        ],
      ),
      body: profilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (profiles) {
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No profiles yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a profile to organize your vehicles',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _navigateToProfileForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Profile'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final isCurrent = profile.id == currentProfileId;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(profile.name),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Current',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'switch':
                          ref
                              .read(currentProfileIdProvider.notifier)
                              .setCurrentProfileId(profile.id);
                          break;
                        case 'edit':
                          _navigateToProfileForm(context, profile: profile);
                          break;
                        case 'delete':
                          _confirmDelete(context, ref, profile);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'switch',
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz),
                            SizedBox(width: 12),
                            Text('Switch to'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        enabled: profiles.length > 1,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref
                        .read(currentProfileIdProvider.notifier)
                        .setCurrentProfileId(profile.id);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToProfileForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Profile'),
      ),
    );
  }

  void _navigateToProfileForm(BuildContext context, {Profile? profile}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileFormScreen(profile: profile),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Profile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
          'Delete "${profile.name}"? This will also delete all vehicles, '
          'maintenance records, reminders, and documents in this profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(profileRepositoryProvider).deleteProfile(profile);
              if (context.mounted) {
                ref.invalidate(currentProfileIdProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile deleted')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
