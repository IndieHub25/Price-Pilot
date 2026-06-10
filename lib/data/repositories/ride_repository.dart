import '../models/ride_model.dart';
import '../models/location_model.dart';
import '../services/database_service.dart';

import '../../core/utils/location_utils.dart';
import '../../core/utils/price_utils.dart';

/// Fetches and compares ride options across supported ride-hailing services.
///
/// Pricing configuration (base fares, per-km/per-min rates) is loaded from the
/// Supabase `ride_options` table instead of being hardcoded. Client-side fare
/// estimation uses [PriceUtils.estimatePrice] with the DB-sourced rates.
///
/// Supported services:
/// - Uber (Bike, Auto, Mini, Sedan)
/// - Ola (Bike, Auto, Mini, Sedan)
/// - Rapido (Bike, Auto)
/// - Meru Cabs (Sedan, SUV)
/// - BluSmart (Sedan, Premium)
/// - InDrive (Mini, Sedan)
/// - Namma Yatri (Auto, Mini)
class RideRepository {
  final DatabaseService _db;

  RideRepository({required DatabaseService databaseService})
    : _db = databaseService;

  /// Fetches ride options for the given pickup and dropoff locations.
  ///
  /// Loads pricing configs from the `ride_options` Supabase table and
  /// generates fare estimates. Returns a list of [RideModel] sorted by
  /// price (lowest first).
  Future<List<RideModel>> getRideOptions({
    required LocationModel pickup,
    required LocationModel dropoff,
  }) async {
    final double distanceKm = LocationUtils.haversineDistance(
      pickup.latitude,
      pickup.longitude,
      dropoff.latitude,
      dropoff.longitude,
    );

    // Estimate duration: average city speed ~25 km/h
    final int durationMinutes = (distanceKm / 25 * 60).round().clamp(3, 180);

    // Fetch pricing configs from Supabase
    final configs = await _db.query('ride_options');

    if (configs.isEmpty) {
      throw Exception(
        'No ride pricing configuration found. '
        'Please seed the ride_options table in Supabase.',
      );
    }

    final ts = DateTime.now().millisecondsSinceEpoch;
    final List<RideModel> rides = [];

    for (final config in configs) {
      final String service = config['service'] as String;
      final String vehicleType = config['vehicle_type'] as String;
      final double baseFare = (config['base_fare'] as num).toDouble();
      final double perKmRate = (config['per_km_rate'] as num).toDouble();
      final double perMinRate = (config['per_min_rate'] as num).toDouble();
      final double surgeMultiplier =
          (config['surge_multiplier'] as num?)?.toDouble() ?? 1.0;
      final int seatingCapacity =
          (config['seating_capacity'] as num?)?.toInt() ?? 4;
      final int etaBufferMinutes =
          (config['eta_buffer_minutes'] as num?)?.toInt() ?? 5;

      final String id =
          '${service.toLowerCase().replaceAll(' ', '')}_${vehicleType.toLowerCase()}_$ts';

      final double price = PriceUtils.estimatePrice(
        baseFare: baseFare,
        perKmRate: perKmRate,
        perMinRate: perMinRate,
        distanceKm: distanceKm,
        durationMin: durationMinutes,
        surgeMultiplier: surgeMultiplier,
      );

      rides.add(
        RideModel(
          id: id,
          service: service,
          vehicleType: vehicleType,
          price: price,
          estimatedTimeMinutes: durationMinutes + etaBufferMinutes,
          surgeMultiplier: surgeMultiplier,
          seatingCapacity: seatingCapacity,
        ),
      );
    }

    // Sort by price ascending
    rides.sort((a, b) => a.price.compareTo(b.price));
    return rides;
  }
}
