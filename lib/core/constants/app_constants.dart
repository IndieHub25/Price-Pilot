/// Application-wide constant values.
class AppConstants {
  AppConstants._();

  // App metadata
  static const String appName = 'Price Pilot';
  static const String appTagline =
      'Navigate your journey through the best prices';
  static const String appVersion = '0.6.0';
  static const String packageName = 'com.pricepilot.app';

  // Map defaults
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;
  static const double defaultZoom = 14.0;
  static const double searchZoom = 16.0;

  // Ride services
  static const String serviceUber = 'Uber';
  static const String serviceOla = 'Ola';
  static const String serviceRapido = 'Rapido';
  static const String serviceMeru = 'Meru';
  static const String serviceBluSmart = 'BluSmart';
  static const String serviceInDrive = 'InDrive';
  static const String serviceNammaYatri = 'Namma Yatri';

  /// All supported ride-hailing services.
  static const List<String> allServices = [
    serviceUber,
    serviceOla,
    serviceRapido,
    serviceMeru,
    serviceBluSmart,
    serviceInDrive,
    serviceNammaYatri,
  ];

  // Vehicle types
  static const String vehicleAuto = 'Auto';
  static const String vehicleMini = 'Mini';
  static const String vehicleSedan = 'Sedan';
  static const String vehicleSuv = 'SUV';
  static const String vehicleBike = 'Bike';
  static const String vehiclePremium = 'Premium';

  // Booking statuses
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusEnRoute = 'en_route';
  static const String statusArrived = 'arrived';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Supabase table names
  static const String tableUsers = 'users';
  static const String tableBookings = 'bookings';
  static const String tableSavedLocations = 'saved_locations';
  static const String tableSearchHistory = 'search_history';
  static const String tablePreferences = 'preferences';
  static const String tableRideOptions = 'ride_options';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 15);

  // Pagination
  static const int searchHistoryLimit = 50;
  static const int bookingHistoryPageSize = 20;

  // Saved location types
  static const String locationTypeHome = 'home';
  static const String locationTypeWork = 'work';
  static const String locationTypeOther = 'other';

  // Deep link schemes
  static const String uberDeepLink = 'uber://';
  static const String olaDeepLink = 'olacabs://';
  static const String rapidoDeepLink = 'rapido://';
  static const String meruDeepLink = 'merucabs://';
  static const String bluSmartDeepLink = 'blusmart://';
  static const String inDriveDeepLink = 'indrive://';
  static const String nammaYatriDeepLink = 'nammayatri://';

  // Play Store links (fallback)
  static const String uberPlayStore =
      'https://play.google.com/store/apps/details?id=com.ubercab';
  static const String olaPlayStore =
      'https://play.google.com/store/apps/details?id=com.olacabs.customer';
  static const String rapidoPlayStore =
      'https://play.google.com/store/apps/details?id=com.rapido.passenger';
  static const String meruPlayStore =
      'https://play.google.com/store/apps/details?id=com.merucabs';
  static const String bluSmartPlayStore =
      'https://play.google.com/store/apps/details?id=com.blu.smart';
  static const String inDrivePlayStore =
      'https://play.google.com/store/apps/details?id=sinet.startup.inDriver';
  static const String nammaYatriPlayStore =
      'https://play.google.com/store/apps/details?id=in.juspay.nammayatri';
}
