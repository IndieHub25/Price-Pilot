import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../repositories/location_repository.dart';

/// Manages location state: current position, pickup/dropoff, and saved locations.
class LocationProvider extends ChangeNotifier {
  final LocationRepository _locationRepository;

  LocationProvider({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  LocationModel? _currentLocation;
  LocationModel? _pickupLocation;
  LocationModel? _dropoffLocation;
  List<Map<String, dynamic>> _savedLocations = [];
  List<Map<String, dynamic>> _searchHistory = [];
  bool _isLoading = false;
  String? _error;

  LocationModel? get currentLocation => _currentLocation;
  LocationModel? get pickupLocation => _pickupLocation;
  LocationModel? get dropoffLocation => _dropoffLocation;
  List<Map<String, dynamic>> get savedLocations => _savedLocations;
  List<Map<String, dynamic>> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Whether both pickup and dropoff are set.
  bool get isRouteReady => _pickupLocation != null && _dropoffLocation != null;

  /// Fetches the device's current GPS position.
  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLocation = await _locationRepository.getCurrentLocation();
      // Auto-set pickup to current location if not already set
      _pickupLocation ??= _currentLocation;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the pickup location.
  void setPickupLocation(LocationModel location) {
    _pickupLocation = location;
    notifyListeners();
  }

  /// Sets the dropoff location.
  void setDropoffLocation(LocationModel location) {
    _dropoffLocation = location;
    notifyListeners();
  }

  /// Geocodes an address and sets it as pickup.
  Future<void> setPickupFromAddress(String address) async {
    try {
      final location = await _locationRepository.geocodeAddress(address);
      _pickupLocation = location;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Geocodes an address and sets it as dropoff.
  Future<void> setDropoffFromAddress(String address) async {
    try {
      final location = await _locationRepository.geocodeAddress(address);
      _dropoffLocation = location;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Swaps pickup and dropoff locations.
  void swapLocations() {
    final temp = _pickupLocation;
    _pickupLocation = _dropoffLocation;
    _dropoffLocation = temp;
    notifyListeners();
  }

  /// Loads saved locations from the database.
  Future<void> loadSavedLocations(String userId) async {
    try {
      _savedLocations = await _locationRepository.getSavedLocations(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Loads recent search history.
  Future<void> loadSearchHistory(String userId) async {
    try {
      _searchHistory = await _locationRepository.getSearchHistory(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clears the current route.
  void clearRoute() {
    _pickupLocation = null;
    _dropoffLocation = null;
    _error = null;
    notifyListeners();
  }
}
