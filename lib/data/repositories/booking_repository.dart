import '../models/booking_model.dart';
import '../services/database_service.dart';
import '../../core/constants/app_constants.dart';

/// Manages booking persistence using the local SQLite database.
class BookingRepository {
  final DatabaseService _db;

  BookingRepository({required DatabaseService databaseService})
    : _db = databaseService;

  /// Saves a new booking to the database.
  Future<void> saveBooking(BookingModel booking) async {
    await _db.insert('bookings', booking.toJson());
  }

  /// Returns all bookings for the given user, newest first.
  Future<List<BookingModel>> getBookings(String userId, {int page = 0}) async {
    final results = await _db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'booked_at DESC',
      limit: AppConstants.bookingHistoryPageSize,
      offset: page * AppConstants.bookingHistoryPageSize,
    );
    return results.map((row) => BookingModel.fromJson(row)).toList();
  }

  /// Returns a single booking by its ID.
  Future<BookingModel?> getBookingById(String bookingId) async {
    final results = await _db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [bookingId],
    );
    if (results.isEmpty) return null;
    return BookingModel.fromJson(results.first);
  }

  /// Updates the status of an existing booking.
  Future<void> updateBookingStatus(String bookingId, String status) async {
    final Map<String, dynamic> data = {'status': status};
    if (status == AppConstants.statusCompleted) {
      data['completed_at'] = DateTime.now().toIso8601String();
    }
    await _db.update('bookings', data, where: 'id = ?', whereArgs: [bookingId]);
  }

  /// Deletes a booking record.
  Future<void> deleteBooking(String bookingId) async {
    await _db.delete('bookings', where: 'id = ?', whereArgs: [bookingId]);
  }

  /// Returns the count of bookings for a user by status.
  Future<int> getBookingCount(String userId, {String? status}) async {
    final String where;
    final List<dynamic> whereArgs;

    if (status != null) {
      where = 'user_id = ? AND status = ?';
      whereArgs = [userId, status];
    } else {
      where = 'user_id = ?';
      whereArgs = [userId];
    }

    final results = await _db.query(
      'bookings',
      where: where,
      whereArgs: whereArgs,
    );
    return results.length;
  }
}
