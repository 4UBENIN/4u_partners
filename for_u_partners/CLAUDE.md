# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

For U Partners is a Flutter multi-service partner application supporting three service types:
- **Drivers** (ride-hailing service)
- **Delivery** (delivery service)
- **Pressing** (laundry/dry-cleaning service)

The app is built with the **Stacked** architecture framework, using dependency injection and code generation for routing, services, and view models.

## Build and Development Commands

### Essential Commands

```bash
# Get dependencies
flutter pub get

# Run code generation (required after modifying routes, services, or dependencies in app.dart)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Run and update golden tests
flutter test --update-goldens

# Build for production
flutter build apk              # Android
flutter build ios              # iOS
flutter build appbundle        # Android App Bundle
```

### Code Generation

After modifying `lib/app/app.dart` (adding routes, services, bottom sheets, or dialogs), you **must** run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `app.locator.dart` - Dependency injection
- `app.router.dart` - Route definitions
- `app.dialogs.dart` - Dialog setup
- `app.bottomsheets.dart` - Bottom sheet setup

## Architecture

### Stacked Framework

The app follows the Stacked MVVM pattern:

- **Views**: UI components in `lib/ui/views/` (organized by service type: `drivers/`, `delivery/`, `pressing/`)
- **ViewModels**: Business logic paired with views (e.g., `home_view.dart` + `home_viewmodel.dart`)
- **Services**: Singleton/LazySingleton services in `lib/services/`
- **Models**: Data models in `lib/models/`

### Configuration File

`stacked.json` defines the project structure for Stacked CLI commands:
- Views path: `ui/views`
- Services path: `services`
- Bottom sheets: `ui/bottom_sheets`
- Dialogs: `ui/dialogs`

### Dependency Injection

All services and some view models are registered in `lib/app/app.dart` using `@StackedApp`:

```dart
@StackedApp(
  routes: [...],
  dependencies: [
    LazySingleton(classType: AuthService),
    LazySingleton(classType: DriverService),
    Singleton(classType: HomemainViewModel),
    // etc.
  ],
)
```

Access services using the generated locator:
```dart
final authService = locator<AuthService>();
```

### Service Types Structure

The app has three parallel service implementations:

1. **Drivers** (`lib/ui/views/drivers/`):
   - `homemain/` - Main navigation wrapper
   - `home/` - Dashboard with wallet, current ride, activity
   - `courses/` - Ride management and active ride tracking
   - `activity/` - Ride history
   - `profil/` - Driver profile
   - `vehicles/` - Vehicle management
   - `documents/` - Document management
   - `wallet/` - Earnings and wallet

2. **Delivery** (`lib/ui/views/delivery/`):
   - Similar structure adapted for delivery orders

3. **Pressing** (`lib/ui/views/pressing/`):
   - Similar structure adapted for laundry services

### Key Services

**Authentication & User Management:**
- `AuthService` - Login, registration, logout, token management
- `SharedpreferencesService` - Local storage for tokens and user data

**Driver-Specific Services:**
- `DriverService` - Driver operations, go online/offline, course management, stats
- `ActiveCourseCheckerService` - Checks for active courses on app start/resume
- `CourseRestorationService` - Restores active course state after app backgrounding
- `LocationTrackingService` - Real-time location tracking during rides
- `VehicleService` - Vehicle CRUD operations
- `WalletService` - Wallet and earnings management

**Course Management:**
- `ArrivalStateService` - Manages arrival state during rides
- `PauseStateService` - Manages pause state during rides

**UI Services:**
- `ChatService` - In-app messaging
- `PickersService` - Image/file picker utilities
- `ProfilePhotoService` - Profile photo upload/management

**Notifications:**
- `NotificationService` - Push notification handling
- `LocalNotifService` - Local notifications

### Active Course Restoration Flow

The app automatically restores active courses when launched or resumed:

1. **App lifecycle** (`main.dart`): Checks for active courses on app start/resume
2. **ActiveCourseCheckerService**: Queries API for courses with active statuses:
   - `chauffeur_en_route`, `en_route_vers_client`, `arrive_au_point_depart`
   - `chauffeur_arrive`, `en_cours`, `en_pause`, `en_attente_paiement`
3. **CourseRestorationService**: Temporarily stores course data
4. **Navigation**: Routes to `CoursesView` which consumes and restores the course state

### Environment Configuration

Environment variables are stored in `.env` (not committed) and loaded via `flutter_dotenv`:

```
API_ENDPOINT=https://foryou.cilassocies.com/api
MAPBOX_PUBLIC_TOKEN=...
MAPBOX_PRIVATE_TOKEN=...
MAPBOX_URL=...
```

Access in code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

String baseUrl = dotenv.env['API_ENDPOINT']!;
```

Create your own `.env` from `.env.example` before running the app.

### API Integration

Base API configuration is in `lib/ui/common/api_constant.dart`:
```dart
class ApiConstant {
  static String baseUrl = dotenv.env['API_ENDPOINT']!;
  static String get saveFcmTokenDriver => '$baseUrl/conducteur/save-fcm-token';
  // etc.
}
```

Services use `http` or `dio` packages for API calls, with Bearer token authentication:
```dart
final token = await sharedPreferencesService.getToken();
final response = await http.get(
  Uri.parse(url),
  headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  },
);
```

### Firebase Integration

Firebase is configured for:
- Push notifications (FCM)
- Crashlytics
- Cloud Firestore
- Storage

Initialization happens in `main.dart` before running the app.

### Navigation

Stacked uses generated routing via `app.router.dart`:

```dart
// Navigate to a view
navigationService.navigateTo(Routes.homeView);

// Navigate with arguments
navigationService.navigateTo(
  Routes.activitydetailsView,
  arguments: ActivitydetailsViewArguments(courseId: 123),
);

// Navigate back
navigationService.back();
```

### Bottom Sheets & Dialogs

Registered in `app.dart` and accessed via services:

```dart
// Show dialog
final dialogService = locator<DialogService>();
await dialogService.showCustomDialog(variant: DialogType.infoAlert);

// Show bottom sheet
final bottomSheetService = locator<BottomSheetService>();
await bottomSheetService.showCustomSheet(variant: BottomSheetType.notice);
```

## Common Patterns

### Creating a New View

1. Create view and viewmodel files in appropriate directory
2. Add route in `lib/app/app.dart`:
   ```dart
   MaterialRoute(page: MyNewView),
   ```
3. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Adding a New Service

1. Create service file in `lib/services/`
2. Register in `lib/app/app.dart`:
   ```dart
   LazySingleton(classType: MyNewService),
   ```
3. Run code generation
4. Use via locator: `locator<MyNewService>()`

### Authentication Flow

- User logs in via `AuthService.login()`
- Token is stored in `SharedPreferences`
- All API calls include `Authorization: Bearer {token}` header
- On `Unauthenticated.` error, services call `AuthService.logOut()`

## Important Notes

- Always run `dart run build_runner build --delete-conflicting-outputs` after modifying `app.dart`
- Golden tests are in `test/golden/` and use `golden_toolkit` package
- The app supports multiple platforms: Android, iOS, Web, Linux, macOS, Windows
- There's a dependency override for `vibration: ^3.1.4` due to `slider_button` constraints
- App version is managed in `pubspec.yaml` (currently `1.0.0+23`)
