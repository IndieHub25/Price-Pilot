import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/data/models/booking_model.dart';
import 'package:price_pilot/data/models/location_model.dart';

void main() {
  group('BookingModel', () {
    final now = DateTime(2026, 2, 10, 12, 0, 0);
    final completed = DateTime(2026, 2, 10, 12, 30, 0);

    final sampleJson = {
      'id': 'booking_001',
      'user_id': 'user_001',
      'pickup_lat': 28.6139,
      'pickup_lng': 77.2090,
      'pickup_address': 'CP, Delhi',
      'dropoff_lat': 28.5355,
      'dropoff_lng': 77.2100,
      'dropoff_address': 'Hauz Khas, Delhi',
      'service': 'Uber',
      'vehicle_type': 'Mini',
      'price': 250.0,
      'distance_km': 8.5,
      'duration_minutes': 25,
      'status': 'confirmed',
      'booked_at': now.toIso8601String(),
      'completed_at': completed.toIso8601String(),
      'driver_id': 'driver_001',
    };

    test('fromJson creates a valid model', () {
      final booking = BookingModel.fromJson(sampleJson);

      expect(booking.id, 'booking_001');
      expect(booking.userId, 'user_001');
      expect(booking.pickup.latitude, 28.6139);
      expect(booking.pickup.longitude, 77.2090);
      expect(booking.pickup.address, 'CP, Delhi');
      expect(booking.dropoff.latitude, 28.5355);
      expect(booking.dropoff.address, 'Hauz Khas, Delhi');
      expect(booking.service, 'Uber');
      expect(booking.vehicleType, 'Mini');
      expect(booking.price, 250.0);
      expect(booking.distanceKm, 8.5);
      expect(booking.durationMinutes, 25);
      expect(booking.status, 'confirmed');
      expect(booking.bookedAt, now);
      expect(booking.completedAt, completed);
      expect(booking.driverId, 'driver_001');
    });

    test('toJson produces correct map', () {
      final booking = BookingModel.fromJson(sampleJson);
      final json = booking.toJson();

      expect(json['id'], 'booking_001');
      expect(json['user_id'], 'user_001');
      expect(json['pickup_lat'], 28.6139);
      expect(json['pickup_lng'], 77.2090);
      expect(json['dropoff_lat'], 28.5355);
      expect(json['service'], 'Uber');
      expect(json['vehicle_type'], 'Mini');
      expect(json['price'], 250.0);
      expect(json['status'], 'confirmed');
    });

    test('fromJson handles null optional fields', () {
      final minimalJson = {
        'id': 'booking_002',
        'user_id': 'user_001',
        'pickup_lat': 28.6139,
        'pickup_lng': 77.2090,
        'dropoff_lat': 28.5355,
        'dropoff_lng': 77.2100,
        'service': 'Ola',
        'vehicle_type': 'Auto',
        'price': 150.0,
        'status': 'pending',
        'booked_at': now.toIso8601String(),
      };

      final booking = BookingModel.fromJson(minimalJson);

      expect(booking.distanceKm, isNull);
      expect(booking.durationMinutes, isNull);
      expect(booking.completedAt, isNull);
      expect(booking.driverId, isNull);
      expect(booking.pickup.address, isNull);
    });

    test('copyWith creates copy with overridden values', () {
      final booking = BookingModel.fromJson(sampleJson);
      final updated = booking.copyWith(
        status: 'completed',
        completedAt: completed,
      );

      expect(updated.status, 'completed');
      expect(updated.completedAt, completed);
      expect(updated.id, booking.id);
      expect(updated.price, booking.price);
    });

    test('copyWith preserves all values when no args', () {
      final booking = BookingModel.fromJson(sampleJson);
      final copy = booking.copyWith();

      expect(copy.id, booking.id);
      expect(copy.status, booking.status);
      expect(copy.price, booking.price);
    });

    test('status transitions via copyWith', () {
      const pickup = LocationModel(latitude: 28.6, longitude: 77.2);
      const dropoff = LocationModel(latitude: 28.5, longitude: 77.2);

      final booking = BookingModel(
        id: 'b1',
        userId: 'u1',
        pickup: pickup,
        dropoff: dropoff,
        service: 'Uber',
        vehicleType: 'Mini',
        price: 200,
        status: 'pending',
        bookedAt: now,
      );

      final confirmed = booking.copyWith(status: 'confirmed');
      expect(confirmed.status, 'confirmed');

      final inProgress = confirmed.copyWith(status: 'in_progress');
      expect(inProgress.status, 'in_progress');

      final done = inProgress.copyWith(
        status: 'completed',
        completedAt: completed,
      );
      expect(done.status, 'completed');
      expect(done.completedAt, completed);
    });

    test('equality is based on id', () {
      const pickup = LocationModel(latitude: 28.6, longitude: 77.2);
      const dropoff = LocationModel(latitude: 28.5, longitude: 77.2);

      final b1 = BookingModel(
        id: 'same',
        userId: 'u1',
        pickup: pickup,
        dropoff: dropoff,
        service: 'Uber',
        vehicleType: 'Mini',
        price: 100,
        status: 'pending',
        bookedAt: now,
      );
      final b2 = BookingModel(
        id: 'same',
        userId: 'u2',
        pickup: dropoff,
        dropoff: pickup,
        service: 'Ola',
        vehicleType: 'Sedan',
        price: 500,
        status: 'completed',
        bookedAt: now,
      );

      expect(b1, equals(b2));
    });

    test('toString contains service and status', () {
      final booking = BookingModel.fromJson(sampleJson);

      expect(booking.toString(), contains('Uber'));
      expect(booking.toString(), contains('confirmed'));
    });
  });
}
