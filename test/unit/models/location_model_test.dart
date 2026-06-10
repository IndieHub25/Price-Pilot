import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/data/models/location_model.dart';

void main() {
  group('LocationModel', () {
    final sampleJson = {
      'latitude': 28.6139,
      'longitude': 77.2090,
      'address': 'Connaught Place, New Delhi',
      'place_id': 'ChIJ123',
      'name': 'CP',
    };

    test('fromJson creates a valid model', () {
      final location = LocationModel.fromJson(sampleJson);

      expect(location.latitude, 28.6139);
      expect(location.longitude, 77.2090);
      expect(location.address, 'Connaught Place, New Delhi');
      expect(location.placeId, 'ChIJ123');
      expect(location.name, 'CP');
    });

    test('toJson produces correct map', () {
      final location = LocationModel.fromJson(sampleJson);
      final json = location.toJson();

      expect(json['latitude'], 28.6139);
      expect(json['longitude'], 77.2090);
      expect(json['address'], 'Connaught Place, New Delhi');
      expect(json['place_id'], 'ChIJ123');
      expect(json['name'], 'CP');
    });

    test('JSON round-trip preserves data', () {
      final original = LocationModel.fromJson(sampleJson);
      final restored = LocationModel.fromJson(original.toJson());

      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.address, original.address);
    });

    test('fromJson handles null optional fields', () {
      final minimalJson = {'latitude': 12.9716, 'longitude': 77.5946};

      final location = LocationModel.fromJson(minimalJson);

      expect(location.latitude, 12.9716);
      expect(location.longitude, 77.5946);
      expect(location.address, isNull);
      expect(location.placeId, isNull);
      expect(location.name, isNull);
    });

    test('copyWith creates copy with overridden values', () {
      final location = LocationModel.fromJson(sampleJson);
      final updated = location.copyWith(address: 'New Address');

      expect(updated.address, 'New Address');
      expect(updated.latitude, location.latitude);
      expect(updated.longitude, location.longitude);
    });

    test('equality is based on latitude and longitude', () {
      const loc1 = LocationModel(
        latitude: 28.6139,
        longitude: 77.2090,
        address: 'A',
      );
      const loc2 = LocationModel(
        latitude: 28.6139,
        longitude: 77.2090,
        address: 'B',
      );

      expect(loc1, equals(loc2));
    });

    test('inequality when different coordinates', () {
      const loc1 = LocationModel(latitude: 28.6139, longitude: 77.2090);
      const loc2 = LocationModel(latitude: 12.9716, longitude: 77.5946);

      expect(loc1, isNot(equals(loc2)));
    });

    test('toString contains lat and lng', () {
      final location = LocationModel.fromJson(sampleJson);

      expect(location.toString(), contains('28.6139'));
      expect(location.toString(), contains('77.209'));
    });
  });
}
