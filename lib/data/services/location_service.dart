import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/location_model.dart';

/// Provides device location access and geocoding services.
///
/// Wraps the geolocator and geocoding packages to present a unified
/// location API with proper error handling and permission management.
class LocationService {
  /// Checks and requests location permissions.
  /// Returns `true` if the app has location access.
  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please enable GPS.',
        code: 'SERVICE_DISABLED',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permission was denied.',
          code: 'PERMISSION_DENIED',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. '
        'Please enable it from app settings.',
        code: 'PERMISSION_DENIED_FOREVER',
      );
    }

    return true;
  }

  /// Returns the current device position as a [LocationModel].
  Future<LocationModel> getCurrentLocation() async {
    try {
      await requestPermission();

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: AppConstants.locationTimeout,
        ),
      );

      // Reverse geocode to get an address
      String? address;
      try {
        final placemarks = await geo.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = [
            place.street,
            place.subLocality,
            place.locality,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        }
      } catch (_) {
        // Geocoding failure is non-fatal; proceed without address.
      }

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException(
        'Failed to get current location',
        originalError: e,
      );
    }
  }

  /// Geocodes an address string to a [LocationModel].
  Future<LocationModel> geocodeAddress(String address) async {
    try {
      final locations = await geo.locationFromAddress(address);
      if (locations.isEmpty) {
        throw const LocationException('No results found for the given address');
      }
      final loc = locations.first;
      return LocationModel(
        latitude: loc.latitude,
        longitude: loc.longitude,
        address: address,
      );
    } catch (e) {
      throw LocationException(
        'Geocoding failed for "$address"',
        originalError: e,
      );
    }
  }

  /// Reverse geocodes coordinates to a human-readable address.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      return [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
      ].where((s) => s != null && s.isNotEmpty).join(', ');
    } catch (_) {
      return null;
    }
  }

  /// Returns a stream of position updates for live tracking.
  Stream<LocationModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    ).map(
      (position) => LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }
}
