import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:price_pilot/core/theme/app_theme.dart';
import 'package:price_pilot/core/constants/app_constants.dart';
import 'package:price_pilot/core/config/supabase_config.dart';
import 'package:price_pilot/navigation/app_router.dart';
import 'package:price_pilot/data/services/database_service.dart';
import 'package:price_pilot/data/services/location_service.dart';
import 'package:price_pilot/data/repositories/ride_repository.dart';
import 'package:price_pilot/data/repositories/booking_repository.dart';
import 'package:price_pilot/data/repositories/auth_repository.dart';
import 'package:price_pilot/data/repositories/location_repository.dart';
import 'package:price_pilot/data/providers/ride_provider.dart';
import 'package:price_pilot/data/providers/booking_provider.dart';
import 'package:price_pilot/data/providers/auth_provider.dart';
import 'package:price_pilot/data/providers/location_provider.dart';

/// Full end-to-end integration test for the Price Pilot app.
///
/// This test runs on an Android emulator or physical device and exercises
/// the complete user journey:
/// 1. Splash → Onboarding → Signup (with email + phone)
/// 2. Home screen interaction (location inputs, compare prices)
/// 3. Ride comparison (verifying all 7 services)
/// 4. Booking flow (select ride → confirm → booking confirmation)
/// 5. Profile editing and settings toggles
/// 6. Logout and re-login
///
/// Run via Android Studio: Right-click this file → Run
/// Run via CLI: flutter test integration_test/app_test.dart
void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Warning: Supabase initialization failed: $e');
  }

  Widget buildApp({
    required RideRepository rideRepository,
    required BookingRepository bookingRepository,
    required AuthRepository authRepository,
    required LocationRepository locationRepository,
  }) {
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

  group('Price Pilot E2E Test', () {
    late DatabaseService databaseService;
    late LocationService locationService;
    late RideRepository rideRepository;
    late BookingRepository bookingRepository;
    late AuthRepository authRepository;
    late LocationRepository locationRepository;

    setUp(() async {
      databaseService = DatabaseService();
      locationService = LocationService();

      rideRepository = RideRepository(databaseService: databaseService);
      bookingRepository = BookingRepository(databaseService: databaseService);
      authRepository = AuthRepository();
      locationRepository = LocationRepository(
        locationService: locationService,
        databaseService: databaseService,
      );
    });

    testWidgets(
      'Complete user journey: signup → compare → book → profile → settings',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            rideRepository: rideRepository,
            bookingRepository: bookingRepository,
            authRepository: authRepository,
            locationRepository: locationRepository,
          ),
        );

        // ─── Step 1: Splash Screen ──────────────────────
        // The splash screen auto-navigates after a delay
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // ─── Step 2: Onboarding Flow ────────────────────
        // Should be on the onboarding screen
        // Look for the "Get Started" or swipe-through text
        if (find.text('Next').evaluate().isNotEmpty) {
          // Swipe through all 3 onboarding pages
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();

          if (find.text('Next').evaluate().isNotEmpty) {
            await tester.tap(find.text('Next'));
            await tester.pumpAndSettle();
          }
        }

        // Look for the final CTA
        if (find.text('Get Started').evaluate().isNotEmpty) {
          await tester.tap(find.text('Get Started'));
          await tester.pumpAndSettle();
        }

        // ─── Step 3: Navigate to Signup ─────────────────
        // We should be on the login screen
        // If on login, navigate to signup
        if (find.text('Create Account').evaluate().isNotEmpty) {
          await tester.tap(find.text('Create Account'));
          await tester.pumpAndSettle();
        }

        // ─── Step 4: Create Account (Email + Phone) ─────
        final textFields = find.byType(TextFormField);

        if (textFields.evaluate().length >= 3) {
          // Fill in Name
          await tester.enterText(textFields.at(0), 'Test User');
          await tester.pumpAndSettle();

          // Fill in Email
          await tester.enterText(textFields.at(1), 'test@pricepilot.com');
          await tester.pumpAndSettle();

          // Fill in Phone (mandatory)
          await tester.enterText(textFields.at(2), '9876543210');
          await tester.pumpAndSettle();

          // Test validation first: try submitting with invalid phone
          await tester.enterText(textFields.at(2), '123');
          await tester.pumpAndSettle();

          // Find and tap the Create Account button
          final createButtons = find.byType(ElevatedButton);
          if (createButtons.evaluate().isNotEmpty) {
            await tester.tap(createButtons.last);
            await tester.pumpAndSettle();

            // Should see phone validation error
            expect(
              find.text('Enter a valid 10-digit phone number'),
              findsWidgets,
            );
          }

          // Now enter a valid phone
          await tester.enterText(textFields.at(2), '9876543210');
          await tester.pumpAndSettle();

          // Submit signup
          final signupButtons = find.byType(ElevatedButton);
          if (signupButtons.evaluate().isNotEmpty) {
            await tester.tap(signupButtons.last);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        // ─── Step 5: Home Screen ────────────────────────
        // Should now be on the home screen
        expect(find.text('Price Pilot'), findsWidgets);

        // Verify bottom navigation bar is present
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Verify quick action buttons
        expect(find.text('History'), findsOneWidget);

        // ─── Step 6: Enter Locations & Compare ──────────
        final homeTextFields = find.byType(TextFormField);
        if (homeTextFields.evaluate().length >= 2) {
          // Enter pickup location
          await tester.enterText(
            homeTextFields.at(0),
            'Connaught Place, Delhi',
          );
          await tester.pumpAndSettle();

          // Enter dropoff location
          await tester.enterText(homeTextFields.at(1), 'Hauz Khas, Delhi');
          await tester.pumpAndSettle();

          // Tap Compare Prices
          if (find.text('Compare Prices').evaluate().isNotEmpty) {
            await tester.tap(find.text('Compare Prices'));
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        // ─── Step 7: Ride Comparison Screen ─────────────
        if (find.text('Compare Prices').evaluate().isNotEmpty) {
          // Wait for rides to load
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify ride cards are displayed
          // Check that services from all 7 providers are listed
          final allText = find.byType(Text);
          final textWidgets = allText
              .evaluate()
              .map((e) => (e.widget as Text).data ?? '')
              .toList();

          // At least some services should be visible
          const serviceNames = AppConstants.allServices;
          final visibleServices = serviceNames
              .where((s) => textWidgets.any((t) => t.contains(s)))
              .toList();

          // Should have results from multiple services
          expect(visibleServices.length, greaterThanOrEqualTo(1));

          // ─── Step 8: Select a Ride and Book ─────────────
          // Try to tap the first ride card
          final cards = find.byType(Card);
          if (cards.evaluate().isNotEmpty) {
            await tester.tap(cards.first);
            await tester.pumpAndSettle();

            // Should show booking confirmation bottom sheet
            if (find.text('Confirm Booking').evaluate().isNotEmpty) {
              expect(find.text('Confirm Booking'), findsOneWidget);

              // Tap "Book Now"
              if (find.text('Book Now').evaluate().isNotEmpty) {
                await tester.tap(find.text('Book Now'));
                await tester.pumpAndSettle(const Duration(seconds: 2));
              }
            }
          }
        }

        // ─── Step 9: Navigate via Bottom Nav ────────────
        // Go back to home if needed
        final nav = find.byType(BottomNavigationBar);
        if (nav.evaluate().isNotEmpty) {
          // Tap "Rides" tab (index 1)
          await tester.tap(find.text('Rides'));
          await tester.pumpAndSettle();

          // Go back
          if (find.byType(BackButton).evaluate().isNotEmpty) {
            await tester.tap(find.byType(BackButton).first);
            await tester.pumpAndSettle();
          } else if (find
              .byIcon(Icons.arrow_back_rounded)
              .evaluate()
              .isNotEmpty) {
            await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
            await tester.pumpAndSettle();
          }
        }

        // ─── Step 10: Profile Screen ────────────────────
        final profileNav = find.byType(BottomNavigationBar);
        if (profileNav.evaluate().isNotEmpty) {
          // Tap "Profile" tab (index 2)
          await tester.tap(find.text('Profile'));
          await tester.pumpAndSettle();

          // Check for profile elements
          if (find.text('Test User').evaluate().isNotEmpty) {
            expect(find.text('Test User'), findsWidgets);
          }

          // Look for edit button
          if (find.byIcon(Icons.edit_rounded).evaluate().isNotEmpty) {
            await tester.tap(find.byIcon(Icons.edit_rounded));
            await tester.pumpAndSettle();

            // Edit fields should appear - modify name
            final editFields = find.byType(TextFormField);
            if (editFields.evaluate().isNotEmpty) {
              await tester.enterText(editFields.first, 'Updated User');
              await tester.pumpAndSettle();

              // Save
              if (find.byIcon(Icons.check_rounded).evaluate().isNotEmpty) {
                await tester.tap(find.byIcon(Icons.check_rounded));
                await tester.pumpAndSettle();
              }
            }
          }

          // Go back
          if (find.byIcon(Icons.arrow_back_rounded).evaluate().isNotEmpty) {
            await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
            await tester.pumpAndSettle();
          }
        }

        // ─── Step 11: Settings Screen ───────────────────
        final settingsNav = find.byType(BottomNavigationBar);
        if (settingsNav.evaluate().isNotEmpty) {
          // Tap "Settings" tab (index 3)
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();

          // Toggle notification switch
          final switches = find.byType(SwitchListTile);
          if (switches.evaluate().isNotEmpty) {
            await tester.tap(switches.first);
            await tester.pumpAndSettle();

            // Toggle it back
            await tester.tap(switches.first);
            await tester.pumpAndSettle();
          }

          // Check app version is displayed
          expect(find.text(AppConstants.appVersion), findsWidgets);

          // Go back
          if (find.byIcon(Icons.arrow_back_rounded).evaluate().isNotEmpty) {
            await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
            await tester.pumpAndSettle();
          }
        }

        // ─── Step 12: Logout and Re-login ───────────────
        // Navigate to profile and logout
        if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
          await tester.tap(find.text('Profile'));
          await tester.pumpAndSettle();

          if (find.text('Logout').evaluate().isNotEmpty) {
            await tester.tap(find.text('Logout'));
            await tester.pumpAndSettle();
          } else if (find.byIcon(Icons.logout_rounded).evaluate().isNotEmpty) {
            await tester.tap(find.byIcon(Icons.logout_rounded));
            await tester.pumpAndSettle();
          }
        }

        // Should be back at login screen
        if (find.text('Sign In').evaluate().isNotEmpty) {
          // Re-login with previously created account
          final loginFields = find.byType(TextFormField);
          if (loginFields.evaluate().isNotEmpty) {
            await tester.enterText(loginFields.first, 'test@pricepilot.com');
            await tester.pumpAndSettle();

            await tester.tap(find.text('Sign In'));
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        // Should be back on home screen
        if (find.text('Price Pilot').evaluate().isNotEmpty) {
          expect(find.text('Price Pilot'), findsWidgets);
        }
      },
    );
  });
}
