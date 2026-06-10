import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/ride/ride_comparison_screen.dart';
import '../presentation/screens/ride/ride_tracking_screen.dart';
import '../presentation/screens/ride/ride_details_screen.dart';
import '../presentation/screens/booking/booking_confirmation_screen.dart';
import '../presentation/screens/booking/booking_history_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

/// Centralized route definitions and navigation helpers.
class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String rideComparison = '/ride-comparison';
  static const String rideTracking = '/ride-tracking';
  static const String rideDetails = '/ride-details';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String bookingHistory = '/booking-history';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), routeSettings);
      case onboarding:
        return _buildRoute(const OnboardingScreen(), routeSettings);
      case login:
        return _buildRoute(const LoginScreen(), routeSettings);
      case signup:
        return _buildRoute(const SignupScreen(), routeSettings);
      case home:
        return _buildRoute(const HomeScreen(), routeSettings);
      case rideComparison:
        return _buildRoute(const RideComparisonScreen(), routeSettings);
      case rideTracking:
        return _buildRoute(const RideTrackingScreen(), routeSettings);
      case rideDetails:
        return _buildRoute(const RideDetailsScreen(), routeSettings);
      case bookingConfirmation:
        return _buildRoute(const BookingConfirmationScreen(), routeSettings);
      case bookingHistory:
        return _buildRoute(const BookingHistoryScreen(), routeSettings);
      case profile:
        return _buildRoute(const ProfileScreen(), routeSettings);
      case settings:
        return _buildRoute(const SettingsScreen(), routeSettings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('Route not found: ${routeSettings.name}')),
          ),
          routeSettings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
