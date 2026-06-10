# Changelog

All notable changes to the Price Pilot project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2026-02-10

### Added

#### Scripts
- `scripts/sync_version.sh` — Reads version from CHANGELOG.md and syncs it to `pubspec.yaml` and `app_constants.dart`. Supports `--check` mode for CI pipelines
- `scripts/build_apk.sh` — Builds a release APK and copies it to `apk/PricePilot-v{version}.apk` with versioned filename
- `docs/supabase_migration.sql` — Complete Supabase SQL schema with tables, indices, RLS policies, and seed data

#### Supabase Integration
- `supabase_flutter` and `flutter_dotenv` dependencies for cloud database
- `SupabaseConfig` singleton for client initialization from `.env` credentials
- `.env.example` template for required environment variables

### Changed

#### Data Layer — Supabase Migration
- **`database_service.dart`**: Rewrote from SQLite (`sqflite`) to Supabase REST API. Maintains same CRUD interface (`insert`, `query`, `update`, `delete`)
- **`auth_repository.dart`**: Replaced local SQLite auth with Supabase Auth (email + password sign-up/sign-in/sign-out). Added `onAuthStateChange` stream
- **`ride_repository.dart`**: Replaced `Random()`-based simulated pricing with Supabase `ride_options` table. Pricing config (base fares, per-km/per-min rates, surge multipliers) now fetched from database
- **`auth_provider.dart`**: Uses Supabase session for auto-login instead of `SharedPreferences`. Listens to `onAuthStateChange` for reactive auth state
- **`main.dart`**: Initializes Supabase before `runApp`. `RideRepository` now receives `DatabaseService` instead of `ApiService`

#### Presentation Layer
- **`login_screen.dart`**: Added password field for Supabase Auth
- **`signup_screen.dart`**: Added password field for Supabase Auth

#### Constants
- **`app_constants.dart`**: Replaced SQLite `databaseName`/`databaseVersion` with Supabase table name constants

#### Tests
- Removed `sqflite_common_ffi` dependency from all provider tests
- Updated test setup to match new Supabase-backed constructors
- `ride_provider_test.dart`: Removed live fetch tests (require Supabase), kept sync state tests

### Removed
- `sqflite`, `path_provider`, `path` dependencies (SQLite stack)
- All `Random()`-based ride price simulation (`dart:math` in ride_repository)
- `SharedPreferences`-based session persistence in auth_provider
- Local-only SQLite authentication flow

## [0.5.0] - 2026-02-10

### Added

#### Core Layer
- Premium dark theme with custom color palette (`AppColors`), Material 3 typography (`AppTypography`), and unified `AppTheme`
- App-wide constants (`AppConstants`) and API endpoint configuration (`ApiConstants`)
- Structured error handling with custom exception hierarchy (`AppException`, `NetworkException`, `LocationException`, `DatabaseException`, `AuthException`, `BookingException`, `ValidationException`)
- Location utilities (Haversine distance, formatting) and price utilities (formatting, estimation)

#### Data Layer
- **Models**: `LocationModel`, `RideModel` (with surge pricing), `BookingModel`, `DriverModel`, `UserModel` — all with JSON serialization and `copyWith`
- **Services**: `DatabaseService` (SQLite with 5-table schema, indices, CRUD), `ApiService` (HTTP with error handling), `LocationService` (GPS + geocoding)
- **Repositories**: `RideRepository` (simulated multi-service price comparison), `BookingRepository` (booking persistence), `AuthRepository` (local auth with SharedPreferences), `LocationRepository` (saved locations + search history)
- **Providers**: `RideProvider`, `BookingProvider`, `AuthProvider`, `LocationProvider` — all with loading/error states via `ChangeNotifier`

#### Presentation Layer
- **Common Widgets**: `AppButton` (gradient + loading states), `AppTextField` (themed input), `LoadingIndicator`, `AppErrorWidget` (with retry), `RideCard` (rich comparison card), `PriceComparisonList`, `RideOptionTile`, `BookingCard`, `BookingStatusBadge`
- **Screens**: Splash (animated), Onboarding (3-page), Login, Signup, Home (map placeholder + quick actions + bottom nav), Ride Comparison (filters + booking sheet), Ride Tracking (pulsing animation + driver info), Ride Details, Booking Confirmation (success animation), Booking History (pull-to-refresh), Profile (view/edit modes), Settings (toggles + app info)
- **Navigation**: `AppRouter` with 12 named routes and centralized route generation

#### Infrastructure
- Flutter project scaffold targeting Android with `com.pricepilot` organization
- `pubspec.yaml` configured with 20+ dependencies (provider, google_maps_flutter, geolocator, etc.)
- Strict `analysis_options.yaml` with comprehensive linting rules
- Launcher icon configuration using project logo

### Removed
- All React/Vite/TypeScript web application files (complete rebuild to Flutter)
