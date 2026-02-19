import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/settings/providers/settings_provider.dart';

/// Main application widget
/// 
/// This is the root widget of the AutoCarePro application.
class AutoCareProApp extends ConsumerWidget {
  const AutoCareProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'AutoCarePro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}
