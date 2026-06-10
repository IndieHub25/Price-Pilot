import 'package:flutter/foundation.dart';
import '../models/ride_model.dart';
import '../models/location_model.dart';
import '../repositories/ride_repository.dart';

/// Manages ride comparison state for the UI.
///
/// Fetches ride options when pickup and dropoff are set, sorts results,
/// and exposes loading / error states for the presentation layer.
class RideProvider extends ChangeNotifier {
  final RideRepository _rideRepository;

  RideProvider({required RideRepository rideRepository})
    : _rideRepository = rideRepository;

  List<RideModel> _rides = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedVehicleFilter;

  List<RideModel> get rides {
    if (_selectedVehicleFilter == null) return _rides;
    return _rides
        .where((r) => r.vehicleType == _selectedVehicleFilter)
        .toList();
  }

  List<RideModel> get allRides => _rides;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedVehicleFilter => _selectedVehicleFilter;

  /// The cheapest ride across all services.
  RideModel? get bestPrice => _rides.isNotEmpty ? _rides.first : null;

  /// Available vehicle types from current results.
  List<String> get availableVehicleTypes =>
      _rides.map((r) => r.vehicleType).toSet().toList();

  /// Fetches ride options for the given route.
  Future<void> fetchRides({
    required LocationModel pickup,
    required LocationModel dropoff,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rides = await _rideRepository.getRideOptions(
        pickup: pickup,
        dropoff: dropoff,
      );
    } catch (e) {
      _error = e.toString();
      _rides = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters displayed rides by vehicle type.
  void setVehicleFilter(String? vehicleType) {
    _selectedVehicleFilter = vehicleType;
    notifyListeners();
  }

  /// Clears current ride results and resets state.
  void clearRides() {
    _rides = [];
    _error = null;
    _selectedVehicleFilter = null;
    notifyListeners();
  }
}
