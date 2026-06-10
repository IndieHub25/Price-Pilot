import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/data/providers/booking_provider.dart';
import 'package:price_pilot/data/repositories/booking_repository.dart';
import 'package:price_pilot/data/services/database_service.dart';

void main() {
  late BookingProvider bookingProvider;

  setUp(() {
    final databaseService = DatabaseService();
    final bookingRepository = BookingRepository(
      databaseService: databaseService,
    );
    bookingProvider = BookingProvider(bookingRepository: bookingRepository);
  });

  group('BookingProvider', () {
    test('initial state is empty', () {
      expect(bookingProvider.bookings, isEmpty);
      expect(bookingProvider.activeBooking, isNull);
      expect(bookingProvider.isLoading, false);
      expect(bookingProvider.error, isNull);
    });

    test('clearActiveBooking resets active booking', () {
      bookingProvider.clearActiveBooking();
      expect(bookingProvider.activeBooking, isNull);
    });

    test('notifies listeners on clearActiveBooking', () {
      int notifications = 0;
      bookingProvider.addListener(() => notifications++);

      bookingProvider.clearActiveBooking();
      expect(notifications, 1);
    });
  });
}
