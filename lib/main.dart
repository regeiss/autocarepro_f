import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/providers/database_provider.dart';
import 'services/local_database/app_database.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final database = await DatabaseBuilder.build();

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
}
