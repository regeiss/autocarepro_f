# AppLogger - Logging Framework

A comprehensive logging service for the AutoCarePro application.

## Features

- **Multiple Log Levels**: Debug, Info, Warning, Error, Critical
- **Structured Logging**: Support for tags, metadata, errors, and stack traces
- **Environment-Aware**: Different log levels for debug vs release builds
- **Developer-Friendly**: Uses `dart:developer` log for IDE integration
- **Visual Console Output**: Emoji-coded log levels for easy scanning

## Usage

### Basic Logging

```dart
import 'package:autocarepro/services/app_logger.dart';

// Debug messages (only shown in debug mode by default)
AppLogger.debug('User clicked button');

// Info messages
AppLogger.info('Vehicle saved successfully');

// Warning messages
AppLogger.warning('Low fuel reminder not set');

// Error messages
AppLogger.error('Failed to save data');

// Critical errors
AppLogger.critical('Database connection lost');
```

### Logging with Tags

Tags help categorize and filter logs:

```dart
AppLogger.info('Database query executed', tag: 'Database');
AppLogger.debug('API response received', tag: 'Network');
AppLogger.error('Navigation failed', tag: 'Router');
```

### Logging with Additional Data

Include structured data with your logs:

```dart
AppLogger.info(
  'Vehicle created',
  tag: 'VehicleService',
  data: {
    'vehicleId': '123',
    'make': 'Toyota',
    'model': 'Camry',
  },
);
```

### Logging Errors with Stack Traces

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  AppLogger.error(
    'Operation failed',
    tag: 'Service',
    error: e,
    stackTrace: stackTrace,
    data: {'operation': 'riskyOperation'},
  );
  rethrow;
}
```

### Using Helper Extensions

The logger includes convenience extensions:

```dart
// Database operations
logDatabaseOperation('Inserted vehicle', data: {'id': vehicleId});

// Navigation events
logNavigation('/vehicles/detail', params: {'id': '123'});

// Service operations
logServiceOperation('VehicleService', 'create', data: {'vehicleId': '123'});
```

## Log Levels

| Level    | Use Case                                        | Emoji |
|----------|------------------------------------------------|-------|
| Debug    | Development details, debugging info            | 🔍    |
| Info     | General informational messages                 | 💡    |
| Warning  | Potential issues, deprecations                 | ⚠️    |
| Error    | Recoverable errors, exceptions                 | ❌    |
| Critical | Critical failures, unrecoverable errors        | 🔥    |

## Configuration

### Setting Minimum Log Level

By default:
- **Debug builds**: All logs (Debug and above) are shown
- **Release builds**: Only Info and above are shown

To change the minimum log level:

```dart
// In main.dart or app initialization
AppLogger.setMinimumLogLevel(LogLevel.warning); // Only show warnings and above
```

## Best Practices

1. **Use Appropriate Levels**:
   - `debug`: Temporary logs for development
   - `info`: Important state changes, user actions
   - `warning`: Potential issues that don't break functionality
   - `error`: Caught exceptions, failed operations
   - `critical`: Fatal errors, data corruption

2. **Use Tags Consistently**:
   - Use tags to group related logs (e.g., 'Database', 'Network', 'UI')
   - Keep tags short and descriptive

3. **Include Context**:
   - Use the `data` parameter to add relevant context
   - Include IDs, timestamps, or other identifying information

4. **Log Exceptions Properly**:
   - Always include both `error` and `stackTrace` parameters
   - Add context data to help diagnose the issue

5. **Don't Over-Log**:
   - Avoid logging in tight loops
   - Don't log sensitive user data (passwords, tokens, etc.)
   - Use debug level for verbose information

## Examples

### Service Layer

```dart
class VehicleService {
  Future<void> saveVehicle(Vehicle vehicle) async {
    AppLogger.info(
      'Saving vehicle',
      tag: 'VehicleService',
      data: {'vehicleId': vehicle.id, 'make': vehicle.make},
    );

    try {
      await repository.save(vehicle);
      AppLogger.info('Vehicle saved successfully', tag: 'VehicleService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save vehicle',
        tag: 'VehicleService',
        error: e,
        stackTrace: stackTrace,
        data: {'vehicleId': vehicle.id},
      );
      rethrow;
    }
  }
}
```

### UI Layer

```dart
class VehicleDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider(vehicleId));

    return vehicleAsync.when(
      loading: () {
        AppLogger.debug('Loading vehicle details', tag: 'VehicleDetail');
        return const CircularProgressIndicator();
      },
      error: (error, stack) {
        AppLogger.error(
          'Failed to load vehicle',
          tag: 'VehicleDetail',
          error: error,
          stackTrace: stack,
          data: {'vehicleId': vehicleId},
        );
        return ErrorWidget(error);
      },
      data: (vehicle) {
        AppLogger.debug(
          'Vehicle loaded',
          tag: 'VehicleDetail',
          data: {'vehicleId': vehicle.id},
        );
        return VehicleDetailsWidget(vehicle: vehicle);
      },
    );
  }
}
```

## Console Output Format

Logs in debug mode appear in the console with this format:

```
💡 [INFO    ] 2026-02-18T10:30:45.123 - [VehicleService] Saving vehicle
Data: {vehicleId: 123, make: Toyota}
```

## IDE Integration

The logger uses `dart:developer.log()` which integrates with:
- **VS Code/Cursor**: Logs appear in the Debug Console
- **Android Studio**: Logs appear in the Logcat with proper filtering
- **DevTools**: Full timeline and logging visualization

## Future Enhancements

Potential additions for production use:
- File-based logging for release builds
- Remote logging to analytics/crash reporting services
- Log rotation and size management
- Performance metrics tracking
- User session tracking
