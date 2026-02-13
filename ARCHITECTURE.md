# AutoCarePro - Architecture Overview

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer (Flutter Widgets)             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Dashboard │  │ Vehicles │  │Mainten.  │  │ Reports  │   │
│  │ Screen   │  │ Screens  │  │ Screens  │  │ Screens  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │ User Interactions
┌────────────────────────▼────────────────────────────────────┐
│              State Management (Riverpod Providers)           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Vehicle    │  │ Maintenance  │  │   Reminder   │     │
│  │  Providers   │  │  Providers   │  │  Providers   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │ Business Logic
┌────────────────────────▼────────────────────────────────────┐
│               Repository Layer (Data Abstraction)            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Vehicle    │  │ Maintenance  │  │   Reminder   │     │
│  │ Repository   │  │ Repository   │  │ Repository   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │ Data Operations
┌────────────────────────▼────────────────────────────────────┐
│                  Data Sources & Services                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Database   │  │    Local     │  │ Notification │     │
│  │   (Floor)    │  │   Storage    │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📱 Feature Module Structure

Each feature follows the same pattern for consistency:

```
features/
└── [feature_name]/
    ├── screens/          # UI Screens
    │   ├── list_screen.dart
    │   ├── detail_screen.dart
    │   └── form_screen.dart
    ├── widgets/          # Reusable UI Components
    │   ├── item_card.dart
    │   ├── item_tile.dart
    │   └── form_fields.dart
    └── controllers/      # Business Logic (Providers)
        └── [feature]_controller.dart
```

### Example: Vehicles Feature

```
features/vehicles/
├── screens/
│   ├── vehicles_list_screen.dart      # Shows all vehicles
│   ├── vehicle_detail_screen.dart     # Shows single vehicle details
│   └── vehicle_form_screen.dart       # Add/Edit vehicle form
├── widgets/
│   ├── vehicle_card.dart              # Card display for list
│   ├── vehicle_stats.dart             # Statistics widget
│   └── vehicle_photo_picker.dart      # Photo selection widget
└── controllers/
    └── vehicle_controller.dart         # Vehicle business logic
```

---

## 🗄️ Data Flow

### Reading Data (Example: Loading Vehicles)

```
1. User Opens App
        ↓
2. Dashboard Screen Loads
        ↓
3. Riverpod Provider Requested
   (vehicleListProvider)
        ↓
4. Provider Calls Repository
   (vehicleRepository.getAllVehicles())
        ↓
5. Repository Queries Database
   (Floor DAO query)
        ↓
6. Database Returns Data
        ↓
7. Repository Returns List<Vehicle>
        ↓
8. Provider Updates State
        ↓
9. UI Rebuilds with Data
        ↓
10. User Sees Vehicle List
```

### Writing Data (Example: Adding Vehicle)

```
1. User Taps "Add Vehicle"
        ↓
2. Form Screen Opens
        ↓
3. User Fills Form & Taps Save
        ↓
4. Form Validates Input
        ↓
5. Controller Method Called
   (vehicleController.addVehicle())
        ↓
6. Controller Calls Repository
   (vehicleRepository.insertVehicle())
        ↓
7. Repository Saves to Database
   (Floor DAO insert)
        ↓
8. Database Returns Success
        ↓
9. Provider Invalidates Cache
        ↓
10. UI Automatically Refreshes
        ↓
11. User Sees New Vehicle in List
```

---

## 🔄 State Management with Riverpod

### Provider Types Used

```dart
// 1. FutureProvider - For async data loading
final vehicleListProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repository = ref.read(vehicleRepositoryProvider);
  return await repository.getAllVehicles();
});

// 2. StateNotifierProvider - For mutable state
final vehicleControllerProvider = 
    StateNotifierProvider<VehicleController, AsyncValue<List<Vehicle>>>((ref) {
  return VehicleController(ref.read(vehicleRepositoryProvider));
});

// 3. Provider - For static dependencies
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final database = ref.read(databaseProvider);
  return VehicleRepository(database.vehicleDao);
});
```

### Provider Hierarchy

```
main.dart (ProviderScope)
    ↓
App-Level Providers
├── databaseProvider
├── storageProvider
└── notificationProvider
    ↓
Repository Providers
├── vehicleRepositoryProvider
├── maintenanceRepositoryProvider
└── reminderRepositoryProvider
    ↓
Controller Providers
├── vehicleControllerProvider
├── maintenanceControllerProvider
└── reminderControllerProvider
    ↓
UI-Specific Providers
├── dashboardStatsProvider
├── upcomingRemindersProvider
└── expenseReportProvider
```

---

## 💾 Database Architecture (Floor + SQLite)

### Database Structure

```
AppDatabase
├── @Database(version: 1, entities: [Vehicle, MaintenanceRecord, ...])
├── VehicleDao
│   ├── getAllVehicles() → Future<List<Vehicle>>
│   ├── getVehicleById(id) → Future<Vehicle?>
│   ├── insertVehicle(vehicle) → Future<void>
│   ├── updateVehicle(vehicle) → Future<void>
│   └── deleteVehicle(vehicle) → Future<void>
├── MaintenanceRecordDao
│   ├── getAllRecords() → Future<List<MaintenanceRecord>>
│   ├── getRecordsByVehicle(vehicleId) → Future<List<MaintenanceRecord>>
│   ├── insertRecord(record) → Future<void>
│   ├── updateRecord(record) → Future<void>
│   └── deleteRecord(record) → Future<void>
└── ReminderDao
    ├── getAllReminders() → Future<List<Reminder>>
    ├── getRemindersByVehicle(vehicleId) → Future<List<Reminder>>
    ├── getActiveReminders() → Future<List<Reminder>>
    ├── insertReminder(reminder) → Future<void>
    ├── updateReminder(reminder) → Future<void>
    └── deleteReminder(reminder) → Future<void>
```

### Database Initialization Flow

```dart
// 1. Define Database
@Database(version: 1, entities: [Vehicle, MaintenanceRecord, Reminder])
abstract class AppDatabase extends FloorDatabase {
  VehicleDao get vehicleDao;
  MaintenanceRecordDao get maintenanceRecordDao;
  ReminderDao get reminderDao;
}

// 2. Build Database
final database = await $FloorAppDatabase
    .databaseBuilder('autocarepro.db')
    .addMigrations([migration1to2, migration2to3])
    .build();

// 3. Access DAOs
final vehicleDao = database.vehicleDao;
final vehicles = await vehicleDao.getAllVehicles();
```

---

## 📊 Navigation Structure

### Route Hierarchy (go_router)

```
/ (Root)
├── /dashboard                    # Main dashboard
├── /vehicles                     # Vehicle list
│   ├── /vehicles/add            # Add new vehicle
│   ├── /vehicles/:id            # Vehicle detail
│   │   ├── /vehicles/:id/edit   # Edit vehicle
│   │   └── /vehicles/:id/maintenance/:mid  # Maintenance detail
│   └── /vehicles/:id/maintenance/add      # Add maintenance
├── /maintenance                  # All maintenance records
├── /reminders                    # Reminder list
│   ├── /reminders/add           # Add reminder
│   └── /reminders/:id/edit      # Edit reminder
├── /reports                      # Reports dashboard
│   ├── /reports/expenses        # Expense report
│   └── /reports/mileage         # Mileage report
└── /settings                     # App settings
```

### Navigation Example

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/vehicles',
      builder: (context, state) => const VehiclesListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const VehicleFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return VehicleDetailScreen(vehicleId: id);
          },
        ),
      ],
    ),
  ],
);
```

---

## 🔔 Notification System

### Notification Flow

```
1. User Sets Reminder
        ↓
2. Reminder Saved to Database
        ↓
3. NotificationService Calculates Due Date
        ↓
4. Schedule Local Notification
   (flutter_local_notifications)
        ↓
5. System Triggers Notification at Due Time
        ↓
6. User Taps Notification
        ↓
7. App Opens to Reminder Detail
```

### Notification Service Structure

```dart
class NotificationService {
  // Initialize notifications
  Future<void> initialize();
  
  // Schedule a reminder notification
  Future<void> scheduleReminder(Reminder reminder);
  
  // Cancel a notification
  Future<void> cancelNotification(String reminderId);
  
  // Handle notification tap
  void handleNotificationTap(String? payload);
  
  // Check and reschedule due reminders
  Future<void> rescheduleReminders();
}
```

---

## 📸 Image Handling

### Image Flow

```
1. User Selects Photo Source (Camera/Gallery)
        ↓
2. ImagePicker Opens
        ↓
3. User Selects/Captures Image
        ↓
4. Image Compression
        ↓
5. Save to App Documents Directory
        ↓
6. Store File Path in Database
        ↓
7. Display Image Using File Path
        ↓
8. (On Delete) Clean Up Image File
```

### File Storage Structure

```
App Documents Directory
├── vehicles/
│   └── [vehicle_id]/
│       └── photo.jpg
├── receipts/
│   └── [maintenance_id]/
│       └── receipt.jpg
└── documents/
    └── [document_id]/
        └── file.[ext]
```

---

## 📈 Reports & Analytics

### Report Generation Flow

```
1. User Navigates to Reports
        ↓
2. Select Report Type & Date Range
        ↓
3. Controller Aggregates Data
   ├── Query Maintenance Records
   ├── Calculate Totals
   └── Group by Categories
        ↓
4. Transform Data for Charts
        ↓
5. fl_chart Renders Visualization
        ↓
6. User Views Interactive Chart
        ↓
7. (Optional) Export to PDF
```

### Analytics Data Structure

```dart
class ExpenseReport {
  final DateRange dateRange;
  final double totalCost;
  final Map<String, double> costByType;
  final Map<String, double> costByVehicle;
  final List<ExpenseDataPoint> timeline;
  
  // Generate chart data
  List<BarChartGroupData> toBarChartData();
  List<PieChartSectionData> toPieChartData();
  List<LineChartBarData> toLineChartData();
}
```

---

## 🧪 Testing Architecture

### Test Pyramid

```
                    ┌─────────┐
                    │   E2E   │ (Few)
                    │  Tests  │
                  ┌─┴─────────┴─┐
                  │   Widget    │ (Some)
                  │    Tests    │
              ┌───┴─────────────┴───┐
              │      Unit Tests      │ (Many)
              │   (Models, Logic,   │
              │    Repositories)    │
              └─────────────────────┘
```

### Test Organization

```
test/
├── unit/
│   ├── models/
│   │   ├── vehicle_test.dart
│   │   └── maintenance_record_test.dart
│   ├── repositories/
│   │   └── vehicle_repository_test.dart
│   └── utils/
│       └── date_utils_test.dart
├── widget/
│   ├── dashboard/
│   │   └── dashboard_screen_test.dart
│   └── vehicles/
│       └── vehicle_card_test.dart
└── integration/
    └── vehicle_crud_test.dart
```

---

## 🔐 Security Considerations

### Data Security

```
Local Database (SQLite)
├── Encrypted at OS level (Android/iOS)
├── No network transmission (offline)
├── Sandboxed app directory
└── Wiped on app uninstall

User Data
├── No PII collected
├── All data local to device
├── No analytics by default
└── User controls all data
```

### File Security

```
Stored Images
├── Saved in app private directory
├── Not accessible by other apps
├── Not backed up to cloud (by default)
└── Deleted with app data
```

---

## 🚀 Performance Optimization

### Key Strategies

```
1. Database Optimization
   ├── Indexed foreign keys
   ├── Query only needed columns
   ├── Batch operations
   └── Connection pooling

2. Image Optimization
   ├── Compress before storage
   ├── Generate thumbnails
   ├── Lazy load images
   └── Cache loaded images

3. UI Performance
   ├── Use const constructors
   ├── Minimize rebuilds (Riverpod)
   ├── ListView.builder for lists
   └── Pagination for large datasets

4. State Management
   ├── Provider auto-dispose
   ├── Granular providers
   ├── Avoid unnecessary refreshes
   └── Cache computed values
```

---

## 🔄 App Lifecycle

### Initialization Flow

```
main()
  ↓
ProviderScope
  ↓
Initialize Services
├── Database
├── Notifications
└── Storage
  ↓
Check First Launch
  ↓
Load App
├── Dashboard (if has data)
└── Onboarding (if first launch)
```

### Background Tasks

```
App in Background
  ↓
System Triggers Notification
  ↓
(on iOS) Background Fetch
├── Update Reminders
└── Reschedule Notifications
```

---

## 📦 Build & Deployment

### Build Pipeline

```
Development
  ↓
flutter analyze
  ↓
flutter test
  ↓
Manual Testing
  ↓
flutter build apk/ios
  ↓
App Store Submission
  ↓
Review Process
  ↓
Production Release
```

---

## 🎯 Summary

### Architecture Benefits

✅ **Separation of Concerns**: Clear layer boundaries  
✅ **Testability**: Each layer can be tested independently  
✅ **Maintainability**: Feature-first structure is easy to navigate  
✅ **Scalability**: Easy to add new features  
✅ **Performance**: Optimized data flow and caching  
✅ **Type Safety**: Compile-time error checking  

### Key Technologies

- **UI**: Flutter Widgets
- **State**: Riverpod
- **Data**: Floor + SQLite
- **Navigation**: go_router
- **Notifications**: flutter_local_notifications
- **Charts**: fl_chart

---

*Last Updated: February 13, 2026*  
*See DEVELOPMENT_PLAN.md for complete technical specifications*
