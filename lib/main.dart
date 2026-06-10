import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'navigation/app_router.dart';
import 'data/services/database_service.dart';

import 'data/services/location_service.dart';
import 'data/repositories/ride_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/location_repository.dart';
import 'data/providers/ride_provider.dart';
import 'data/providers/booking_provider.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize core services
  final databaseService = DatabaseService();
  final locationService = LocationService();

  // Initialize repositories
  final rideRepository = RideRepository(databaseService: databaseService);
  final bookingRepository = BookingRepository(databaseService: databaseService);
  final authRepository = AuthRepository();
  final locationRepository = LocationRepository(
    locationService: locationService,
    databaseService: databaseService,
  );

  runApp(
    PricePilotApp(
      rideRepository: rideRepository,
      bookingRepository: bookingRepository,
      authRepository: authRepository,
      locationRepository: locationRepository,
    ),
  );
}

/// Root widget for the Price Pilot application.
class PricePilotApp extends StatelessWidget {
  final RideRepository rideRepository;
  final BookingRepository bookingRepository;
  final AuthRepository authRepository;
  final LocationRepository locationRepository;

  const PricePilotApp({
    super.key,
    required this.rideRepository,
    required this.bookingRepository,
    required this.authRepository,
    required this.locationRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              LocationProvider(locationRepository: locationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RideProvider(rideRepository: rideRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(bookingRepository: bookingRepository),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
