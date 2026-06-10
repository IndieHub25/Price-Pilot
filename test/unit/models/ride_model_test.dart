import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/data/models/ride_model.dart';

void main() {
  group('RideModel', () {
    final sampleJson = {
      'id': 'uber_mini_123',
      'service': 'Uber',
      'vehicle_type': 'Mini',
      'price': 250.50,
      'estimated_time_minutes': 15,
      'surge_multiplier': 1.5,
      'icon_url': 'https://example.com/uber.png',
      'is_available': true,
      'seating_capacity': 4,
    };

    test('fromJson creates a valid model', () {
      final ride = RideModel.fromJson(sampleJson);

      expect(ride.id, 'uber_mini_123');
      expect(ride.service, 'Uber');
      expect(ride.vehicleType, 'Mini');
      expect(ride.price, 250.50);
      expect(ride.estimatedTimeMinutes, 15);
      expect(ride.surgeMultiplier, 1.5);
      expect(ride.iconUrl, 'https://example.com/uber.png');
      expect(ride.isAvailable, true);
      expect(ride.seatingCapacity, 4);
    });

    test('toJson produces correct map', () {
      final ride = RideModel.fromJson(sampleJson);
      final json = ride.toJson();

      expect(json['id'], 'uber_mini_123');
      expect(json['service'], 'Uber');
      expect(json['vehicle_type'], 'Mini');
      expect(json['price'], 250.50);
      expect(json['estimated_time_minutes'], 15);
      expect(json['surge_multiplier'], 1.5);
    });

    test('JSON round-trip preserves data', () {
      final original = RideModel.fromJson(sampleJson);
      final restored = RideModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.service, original.service);
      expect(restored.price, original.price);
      expect(restored.surgeMultiplier, original.surgeMultiplier);
    });

    test('fromJson uses defaults for optional fields', () {
      final minimalJson = {
        'id': 'test_1',
        'service': 'Ola',
        'vehicle_type': 'Auto',
        'price': 100.0,
        'estimated_time_minutes': 10,
      };

      final ride = RideModel.fromJson(minimalJson);

      expect(ride.surgeMultiplier, 1.0);
      expect(ride.iconUrl, isNull);
      expect(ride.isAvailable, true);
      expect(ride.seatingCapacity, isNull);
    });

    test('hasSurge returns true when multiplier > 1.0', () {
      final ride = RideModel.fromJson(sampleJson);
      expect(ride.hasSurge, true);
    });

    test('hasSurge returns false when multiplier is 1.0', () {
      const ride = RideModel(
        id: 'test',
        service: 'Uber',
        vehicleType: 'Mini',
        price: 200,
        estimatedTimeMinutes: 10,
        surgeMultiplier: 1.0,
      );
      expect(ride.hasSurge, false);
    });

    test('priceBeforeSurge calculates correctly', () {
      const ride = RideModel(
        id: 'test',
        service: 'Uber',
        vehicleType: 'Mini',
        price: 300,
        estimatedTimeMinutes: 10,
        surgeMultiplier: 1.5,
      );
      expect(ride.priceBeforeSurge, 200.0);
    });

    test('priceBeforeSurge returns price when no surge', () {
      const ride = RideModel(
        id: 'test',
        service: 'Uber',
        vehicleType: 'Mini',
        price: 200,
        estimatedTimeMinutes: 10,
      );
      expect(ride.priceBeforeSurge, 200.0);
    });

    test('copyWith creates a new instance with overridden values', () {
      final ride = RideModel.fromJson(sampleJson);
      final copied = ride.copyWith(price: 500.0, service: 'Ola');

      expect(copied.id, ride.id);
      expect(copied.price, 500.0);
      expect(copied.service, 'Ola');
      expect(copied.vehicleType, ride.vehicleType);
    });

    test('copyWith preserves original when no args', () {
      final ride = RideModel.fromJson(sampleJson);
      final copied = ride.copyWith();

      expect(copied.id, ride.id);
      expect(copied.price, ride.price);
      expect(copied.service, ride.service);
    });

    test('equality is based on id', () {
      const ride1 = RideModel(
        id: 'abc',
        service: 'Uber',
        vehicleType: 'Mini',
        price: 100,
        estimatedTimeMinutes: 10,
      );
      const ride2 = RideModel(
        id: 'abc',
        service: 'Ola',
        vehicleType: 'Sedan',
        price: 500,
        estimatedTimeMinutes: 20,
      );

      expect(ride1, equals(ride2));
    });

    test('inequality when different ids', () {
      const ride1 = RideModel(
        id: 'abc',
        service: 'Uber',
        vehicleType: 'Mini',
        price: 100,
        estimatedTimeMinutes: 10,
      );
      const ride2 = RideModel(
        id: 'def',
        service: 'Uber',
        vehicleType: 'Mini',
        price: 100,
        estimatedTimeMinutes: 10,
      );

      expect(ride1, isNot(equals(ride2)));
    });

    test('toString contains service and vehicle type', () {
      const ride = RideModel(
        id: 'test',
        service: 'Uber',
        vehicleType: 'Sedan',
        price: 350,
        estimatedTimeMinutes: 15,
      );

      expect(ride.toString(), contains('Uber'));
      expect(ride.toString(), contains('Sedan'));
      expect(ride.toString(), contains('350'));
    });
  });
}
