import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/providers/database_provider.dart';
import 'services/local_database/app_database.dart';
import 'services/app_logger.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Starting AutoCarePro application');

  try {
    // Initialize the database
    AppLogger.debug('Initializing database');
    final database = await DatabaseBuilder.build();
    AppLogger.info('Database initialized successfully');

    // Run the app with Riverpod
    runApp(
      ProviderScope(
        overrides: [
          // Override the database provider with the actual database instance
          databaseProvider.overrideWithValue(database),
        ],
        child: const AutoCareProApp(),
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.critical(
      'Failed to initialize application',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}
