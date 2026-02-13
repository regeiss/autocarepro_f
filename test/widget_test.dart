// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:autocarepro/app/app.dart';
import 'package:autocarepro/services/local_database/app_database.dart';
import 'package:autocarepro/data/providers/database_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize test database
    final database = await DatabaseBuilder.build();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const AutoCareProApp(),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('AutoCarePro'), findsOneWidget);
  });
}
