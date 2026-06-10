import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../models/location_model.dart';
import '../repositories/booking_repository.dart';
import '../../core/constants/app_constants.dart';

/// Manages booking state: creation, history retrieval, and status updates.
class BookingProvider extends ChangeNotifier {
  final BookingRepository _bookingRepository;

  BookingProvider({required BookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  List<BookingModel> _bookings = [];
  BookingModel? _activeBooking;
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get activeBooking => _activeBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Creates a new booking and saves it to the database.
  Future<BookingModel> createBooking({
    required String userId,
    required LocationModel pickup,
    required LocationModel dropoff,
    required String service,
    required String vehicleType,
    required double price,
    double? distanceKm,
    int? durationMinutes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        pickup: pickup,
        dropoff: dropoff,
        service: service,
        vehicleType: vehicleType,
        price: price,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        status: AppConstants.statusConfirmed,
        bookedAt: DateTime.now(),
      );

      await _bookingRepository.saveBooking(booking);
      _activeBooking = booking;
      _bookings.insert(0, booking);
      return booking;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads booking history for the given user.
  Future<void> loadBookings(String userId, {int page = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _bookingRepository.getBookings(userId, page: page);
      if (page == 0) {
        _bookings = results;
      } else {
        _bookings.addAll(results);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the status of the active booking.
  Future<void> updateStatus(String bookingId, String status) async {
    try {
      await _bookingRepository.updateBookingStatus(bookingId, status);

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: status);
      }
      if (_activeBooking?.id == bookingId) {
        _activeBooking = _activeBooking!.copyWith(status: status);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clears the active booking (after ride completion or cancellation).
  void clearActiveBooking() {
    _activeBooking = null;
    notifyListeners();
  }
}
