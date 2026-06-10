import '../models/location_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../../core/constants/app_constants.dart';

/// Manages location data: current position, saved locations, and search history.
class LocationRepository {
  final LocationService _locationService;
  final DatabaseService _db;

  LocationRepository({
    required LocationService locationService,
    required DatabaseService databaseService,
  }) : _locationService = locationService,
       _db = databaseService;

  /// Returns the current device location.
  Future<LocationModel> getCurrentLocation() {
    return _locationService.getCurrentLocation();
  }

  /// Geocodes an address string to coordinates.
  Future<LocationModel> geocodeAddress(String address) {
    return _locationService.geocodeAddress(address);
  }

  /// Returns a live stream of location updates.
  Stream<LocationModel> getLocationStream() {
    return _locationService.getLocationStream();
  }

  // ---------------------------------------------------------------------------
  // Saved locations
  // ---------------------------------------------------------------------------

  /// Saves a location under a label (home, work, or custom name).
  Future<void> saveLocation({
    required String userId,
    required String name,
    required LocationModel location,
    String type = AppConstants.locationTypeOther,
  }) async {
    await _db.insert('saved_locations', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': location.address,
      'type': type,
    });
  }

  /// Returns all saved locations for a user.
  Future<List<Map<String, dynamic>>> getSavedLocations(String userId) async {
    return _db.query(
      'saved_locations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
  }

  /// Deletes a saved location.
  Future<void> deleteSavedLocation(String locationId) async {
    await _db.delete(
      'saved_locations',
      where: 'id = ?',
      whereArgs: [locationId],
    );
  }

  // ---------------------------------------------------------------------------
  // Search history
  // ---------------------------------------------------------------------------

  /// Records a search query.
  Future<void> addSearchHistory({
    required String userId,
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    await _db.insert('search_history', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
      'query': query,
      'latitude': latitude,
      'longitude': longitude,
      'searched_at': DateTime.now().toIso8601String(),
    });

    // Trim to limit
    final history = await _db.query(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'searched_at DESC',
    );

    if (history.length > AppConstants.searchHistoryLimit) {
      final oldestToKeep =
          history[AppConstants.searchHistoryLimit - 1]['searched_at'];
      await _db.delete(
        'search_history',
        where: 'user_id = ? AND searched_at < ?',
        whereArgs: [userId, oldestToKeep],
      );
    }
  }

  /// Returns recent searches for a user.
  Future<List<Map<String, dynamic>>> getSearchHistory(
    String userId, {
    int limit = 10,
  }) async {
    return _db.query(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'searched_at DESC',
      limit: limit,
    );
  }

  /// Clears all search history for a user.
  Future<void> clearSearchHistory(String userId) async {
    await _db.delete(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
