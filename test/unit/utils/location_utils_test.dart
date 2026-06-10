import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/core/utils/location_utils.dart';

void main() {
  group('LocationUtils', () {
    group('haversineDistance', () {
      test('returns 0 for same coordinates', () {
        final distance = LocationUtils.haversineDistance(
          28.6139,
          77.2090,
          28.6139,
          77.2090,
        );
        expect(distance, 0.0);
      });

      test('calculates correct distance between Delhi and Mumbai', () {
        // Delhi (28.6139, 77.2090) to Mumbai (19.0760, 72.8777)
        final distance = LocationUtils.haversineDistance(
          28.6139,
          77.2090,
          19.0760,
          72.8777,
        );
        // Known distance is ~1,148 km
        expect(distance, closeTo(1148, 20));
      });

      test('calculates short distance correctly', () {
        // ~1 km difference
        final distance = LocationUtils.haversineDistance(
          28.6139,
          77.2090,
          28.6230,
          77.2090,
        );
        expect(distance, closeTo(1.01, 0.2));
      });

      test('is symmetric (A→B == B→A)', () {
        final d1 = LocationUtils.haversineDistance(
          28.6139,
          77.2090,
          19.0760,
          72.8777,
        );
        final d2 = LocationUtils.haversineDistance(
          19.0760,
          72.8777,
          28.6139,
          77.2090,
        );
        expect(d1, closeTo(d2, 0.001));
      });
    });

    group('formatDistance', () {
      test('formats distance < 1 km in meters', () {
        expect(LocationUtils.formatDistance(0.5), '500 m');
      });

      test('formats distance >= 1 km in kilometers', () {
        expect(LocationUtils.formatDistance(5.3), '5.3 km');
      });

      test('formats very small distance', () {
        expect(LocationUtils.formatDistance(0.05), '50 m');
      });

      test('formats large distance', () {
        expect(LocationUtils.formatDistance(1148.0), '1148.0 km');
      });
    });

    group('formatDuration', () {
      test('formats minutes < 60', () {
        expect(LocationUtils.formatDuration(45), '45 min');
      });

      test('formats exactly 1 hour', () {
        expect(LocationUtils.formatDuration(60), '1 hr');
      });

      test('formats hours and minutes', () {
        expect(LocationUtils.formatDuration(90), '1 hr 30 min');
      });

      test('formats multiple hours', () {
        expect(LocationUtils.formatDuration(150), '2 hr 30 min');
      });

      test('formats exactly N hours', () {
        expect(LocationUtils.formatDuration(120), '2 hr');
      });
    });
  });
}
