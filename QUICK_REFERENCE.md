# AutoCarePro - Quick Reference Card

## 📚 Documentation Quick Links

| Document | Use When... |
|----------|-------------|
| **PROJECT_SUMMARY.md** | You need a high-level overview |
| **DEVELOPMENT_PLAN.md** | You need technical details and roadmap |
| **NEXT_STEPS.md** | You're ready to start coding |
| **DATA_MODELS.md** | You're creating models or database |
| **ARCHITECTURE.md** | You need to understand app structure |
| **This File** | You need quick commands or reminders |

---

## ⚡ Essential Commands

### Setup Commands
```bash
# Install dependencies
flutter pub get

# Create folder structure (Windows PowerShell)
mkdir lib\features\dashboard, lib\features\vehicles, lib\core\utils

# Generate code (after adding Floor/Freezed)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Development Commands
```bash
# Run app
flutter run

# Run on specific device
flutter run -d windows
flutter run -d android
flutter run -d ios

# Hot reload (in running app): press 'r'
# Hot restart (in running app): press 'R'

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test
flutter test --coverage
```

### Debugging Commands
```bash
# Clean build
flutter clean
flutter pub get

# Check devices
flutter devices

# Doctor
flutter doctor

# View logs
flutter logs
```

---

## 📁 Project Structure at a Glance

```
lib/
├── main.dart                    # App entry point
├── app/
│   ├── app.dart                # Main app widget
│   ├── routes.dart             # Navigation
│   └── theme.dart              # App theme
├── core/
│   ├── constants/              # App constants
│   ├── utils/                  # Helper functions
│   └── widgets/                # Reusable widgets
├── data/
│   ├── models/                 # Data models
│   ├── repositories/           # Data access
│   └── services/               # Platform services
└── features/
    ├── dashboard/              # Dashboard feature
    ├── vehicles/               # Vehicle management
    ├── maintenance/            # Maintenance records
    ├── reminders/              # Service reminders
    └── reports/                # Reports & analytics
```

---

## 🎯 Current Sprint: Sprint 1

### Tasks
- [ ] Update pubspec.yaml with dependencies
- [ ] Create folder structure
- [ ] Create Vehicle model
- [ ] Create MaintenanceRecord model
- [ ] Set up Floor database
- [ ] Create VehicleDao
- [ ] Create MaintenanceRecordDao
- [ ] Create VehicleRepository
- [ ] Write unit tests

### Files to Create (in order)
1. `lib/data/models/vehicle_model.dart`
2. `lib/data/models/maintenance_record_model.dart`
3. `lib/services/local_database/app_database.dart`
4. `lib/data/repositories/vehicle_repository.dart`
5. `test/unit/models/vehicle_test.dart`

---

## 📦 Key Dependencies

```yaml
# Add to pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  sqflite: ^2.3.2                # SQLite
  floor: ^1.4.2                  # ORM for SQLite
  go_router: ^14.0.2             # Navigation
  google_fonts: ^6.2.1           # Typography
  image_picker: ^1.0.7           # Camera/Gallery
  shared_preferences: ^2.2.2     # Key-value storage
  path_provider: ^2.1.2          # File paths
  flutter_local_notifications: ^17.0.0  # Notifications
  intl: ^0.19.0                  # Date formatting
  fl_chart: ^0.66.2              # Charts
  uuid: ^4.3.3                   # ID generation

dev_dependencies:
  build_runner: ^2.4.8           # Code generation
  floor_generator: ^1.4.2        # Floor codegen
```

---

## 🗄️ Database Quick Reference

### Create a Model
```dart
@Entity(tableName: 'vehicles')
class Vehicle {
  @PrimaryKey()
  final String id;
  final String make;
  final String model;
  // ... other fields
}
```

### Create a DAO
```dart
@dao
abstract class VehicleDao {
  @Query('SELECT * FROM vehicles')
  Future<List<Vehicle>> getAllVehicles();
  
  @insert
  Future<void> insertVehicle(Vehicle vehicle);
  
  @update
  Future<void> updateVehicle(Vehicle vehicle);
  
  @delete
  Future<void> deleteVehicle(Vehicle vehicle);
}
```

### Create Database
```dart
@Database(version: 1, entities: [Vehicle])
abstract class AppDatabase extends FloorDatabase {
  VehicleDao get vehicleDao;
}
```

---

## 🎨 Theme Quick Reference

### Color Scheme
```dart
const primaryColor = Color(0xFF2196F3);    // Blue
const secondaryColor = Color(0xFFFF9800);  // Orange
const successColor = Color(0xFF4CAF50);    // Green
const warningColor = Color(0xFFFFC107);    // Amber
const errorColor = Color(0xFFF44336);      // Red
```

### Common Widgets
```dart
// Button
ElevatedButton(
  onPressed: () {},
  child: Text('Save'),
)

// Text Field
TextField(
  decoration: InputDecoration(
    labelText: 'Vehicle Make',
    border: OutlineInputBorder(),
  ),
)

// Card
Card(
  child: ListTile(
    title: Text('Toyota Camry'),
    subtitle: Text('2020'),
  ),
)
```

---

## 🔧 Riverpod Quick Reference

### Provider Types
```dart
// Simple provider
final myProvider = Provider((ref) => 'Hello');

// Async provider
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  return await repository.getAll();
});

// State provider
final counterProvider = StateProvider((ref) => 0);

// StateNotifier provider
final controllerProvider = StateNotifierProvider<MyController, State>((ref) {
  return MyController();
});
```

### Using Providers
```dart
// In a ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    
    return vehicles.when(
      data: (data) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

## 🐛 Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| Hot reload not working | Press 'R' for hot restart |
| Dependency conflict | `flutter clean && flutter pub get` |
| Build errors after adding packages | Run build_runner again |
| Floor not generating | Check @Entity, @dao annotations |
| Provider not updating | Use ref.invalidate() or ref.refresh() |
| Navigation not working | Check route paths, use context.go() |

---

## 📊 Data Models Summary

### Vehicle
- **Fields**: id, make, model, year, vin, licensePlate, currentMileage, photoPath
- **Relations**: Has many MaintenanceRecords, Reminders, Documents

### MaintenanceRecord
- **Fields**: id, vehicleId, serviceType, serviceDate, mileage, cost, notes
- **Relations**: Belongs to Vehicle

### Reminder
- **Fields**: id, vehicleId, serviceType, reminderType, intervalValue, nextReminderDate
- **Relations**: Belongs to Vehicle

---

## ✅ Definition of Done (Per Feature)

- [ ] Code written and follows style guide
- [ ] Unit tests written and passing
- [ ] Widget tests for UI components
- [ ] No linter errors
- [ ] Documentation updated
- [ ] Tested on device/emulator
- [ ] Edge cases handled
- [ ] Loading states implemented
- [ ] Error handling implemented
- [ ] Code reviewed (if team)

---

## 🎯 Today's Goals

Based on Sprint 1, your immediate goals:

1. ✅ Review all documentation (you're doing it!)
2. ⬜ Add dependencies to `pubspec.yaml`
3. ⬜ Run `flutter pub get`
4. ⬜ Create folder structure
5. ⬜ Create Vehicle model
6. ⬜ Create Floor database setup
7. ⬜ Test database operations

---

## 💡 Pro Tips

1. **Use const constructors** - Better performance
2. **Name providers clearly** - vehicleListProvider, not dataProvider
3. **Write tests first** - TDD saves debugging time
4. **Commit often** - Small commits are easier to review
5. **Use TODO comments** - Mark areas needing attention
6. **Profile before optimizing** - Don't guess performance issues
7. **Read error messages carefully** - Flutter errors are descriptive

---

## 📞 When You're Stuck

1. **Check Documentation** - Review relevant .md files
2. **Flutter Docs** - https://docs.flutter.dev
3. **Package Docs** - Check pub.dev for package-specific help
4. **Stack Overflow** - Search for specific errors
5. **GitHub Issues** - Check package repositories
6. **Flutter Discord** - Community help

---

## 🚀 Quick Start (Right Now!)

```bash
# 1. Open terminal in project directory
cd d:\dev\autocarepro

# 2. Open in VS Code (optional)
code .

# 3. Add dependencies (copy from DATA_MODELS.md)
# Edit pubspec.yaml

# 4. Get packages
flutter pub get

# 5. Create your first model
# Create lib/data/models/vehicle_model.dart
# Copy template from DATA_MODELS.md

# 6. Run the app to verify setup
flutter run
```

---

## 📈 Progress Tracking

### Week 1-2 (Current)
- Sprint 1: Foundation & Core Models
- Goal: Working database with CRUD operations

### Week 3-4
- Sprint 2: Vehicle Management
- Goal: Add, edit, view vehicles with UI

### Week 5-6
- Sprint 3: Maintenance Records
- Goal: Track service history

### Week 7+
- Continue with remaining sprints

---

## 🎉 Motivation

Remember:
- Start small, iterate quickly
- Don't aim for perfection in first version
- Test on real devices early
- User feedback is gold
- Celebrate small wins!

---

**Need more details?** → Check the full documentation files  
**Ready to code?** → Open NEXT_STEPS.md and start!  
**Confused about structure?** → Review ARCHITECTURE.md  

**Happy Coding! 🚗💨**

---

*Last Updated: February 13, 2026*
