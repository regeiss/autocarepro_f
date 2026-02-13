import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/local_database/app_database.dart';

/// Provider for the app database
/// 
/// This is a singleton provider that initializes the database once
/// and makes it available throughout the app.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden with an actual database instance',
  );
});

/// Provider for initializing the database
/// 
/// This is a future provider that handles the asynchronous database initialization.
final databaseInitProvider = FutureProvider<AppDatabase>((ref) async {
  return await DatabaseBuilder.build();
});
