# AutoCarePro 🚗

A comprehensive car maintenance tracking application built with Flutter. Manage vehicle maintenance, track expenses, schedule services, and maintain complete service history all in one place.

## Features

### Current (MVP Development)
- ✅ Project setup and architecture
- 🚧 Vehicle management (add, edit, delete)
- 🚧 Maintenance record tracking
- 🚧 Dashboard with overview stats
- 🚧 Service reminders
- 🚧 Expense tracking

### Planned
- Service provider management
- Reports and analytics
- Document storage
- Push notifications
- Cloud sync
- Multi-user support

## Tech Stack

- **Framework**: Flutter 3.8.1
- **Language**: Dart 3.8.1
- **State Management**: Riverpod
- **Database**: sqflite + Floor
- **Navigation**: go_router
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications

## Project Structure

```
lib/
├── app/                  # App configuration
├── core/                 # Shared utilities and widgets
├── data/                 # Models, repositories, services
├── features/             # Feature modules
│   ├── dashboard/
│   ├── vehicles/
│   ├── maintenance/
│   ├── reminders/
│   └── reports/
└── services/             # Platform services
```

## Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd autocarepro
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Development

- See [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) for detailed architecture and roadmap
- Run tests: `flutter test`
- Generate code: `flutter pub run build_runner build`
- Check for issues: `flutter analyze`

## Documentation

- [Development Plan](./DEVELOPMENT_PLAN.md) - Complete project architecture and roadmap
- [API Documentation](./docs/api.md) - Coming soon
- [User Guide](./docs/user_guide.md) - Coming soon

## Contributing

This is a personal/commercial project. Contribution guidelines will be added later.

## License

All rights reserved. License to be determined.

## Contact

Project maintained by [Your Name]

---

**Status**: 🚧 In Development
**Version**: 1.0.0
**Last Updated**: February 13, 2026
