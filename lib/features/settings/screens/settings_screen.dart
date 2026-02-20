import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../profiles/screens/profiles_list_screen.dart';
import '../providers/settings_provider.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profiles section
          _SectionHeader(title: 'Profiles'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.person, color: AppTheme.primaryColor),
              title: const Text('Manage Profiles'),
              subtitle: const Text('Switch profiles, add or edit'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfilesListScreen(),
                  ),
                );
              },
            ),
          ),

          // Appearance section
          _SectionHeader(title: 'Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.brightness_6, color: AppTheme.primaryColor),
                  title: const Text('Theme'),
                  subtitle: Text(_themeModeLabel(themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeModePicker(context, ref),
                ),
              ],
            ),
          ),

          // About section
          _SectionHeader(title: 'About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  title: const Text('About AutoCarePro'),
                  subtitle: const Text('Version 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeModePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose theme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...ThemeMode.values.map((mode) {
              return ListTile(
                leading: Icon(
                  _themeModeIcon(mode),
                  color: AppTheme.primaryColor,
                ),
                title: Text(_themeModeLabel(mode)),
                trailing: ref.watch(themeModeProvider) == mode
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AutoCarePro',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 AutoCarePro',
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
