import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/core/utils/price_utils.dart';

void main() {
  group('PriceUtils', () {
    group('estimatePrice', () {
      test('calculates price without surge', () {
        final price = PriceUtils.estimatePrice(
          baseFare: 50,
          perKmRate: 10,
          perMinRate: 2,
          distanceKm: 5,
          durationMin: 15,
        );
        // 50 + (10 * 5) + (2 * 15) = 50 + 50 + 30 = 130
        expect(price, 130.0);
      });

      test('calculates price with surge multiplier', () {
        final price = PriceUtils.estimatePrice(
          baseFare: 50,
          perKmRate: 10,
          perMinRate: 2,
          distanceKm: 5,
          durationMin: 15,
          surgeMultiplier: 1.5,
        );
        // (50 + 50 + 30) * 1.5 = 195
        expect(price, 195.0);
      });

      test('returns base fare only for zero distance and duration', () {
        final price = PriceUtils.estimatePrice(
          baseFare: 30,
          perKmRate: 10,
          perMinRate: 2,
          distanceKm: 0,
          durationMin: 0,
        );
        expect(price, 30.0);
      });

      test('rounds to 2 decimal places', () {
        final price = PriceUtils.estimatePrice(
          baseFare: 33.33,
          perKmRate: 7.77,
          perMinRate: 1.11,
          distanceKm: 3,
          durationMin: 7,
        );
        // 33.33 + 23.31 + 7.77 = 64.41
        expect(price.toString().split('.').last.length, lessThanOrEqualTo(2));
      });

      test('default surge multiplier is 1.0', () {
        final price = PriceUtils.estimatePrice(
          baseFare: 100,
          perKmRate: 10,
          perMinRate: 1,
          distanceKm: 10,
          durationMin: 20,
        );
        // 100 + 100 + 20 = 220
        expect(price, 220.0);
      });
    });

    group('format', () {
      test('formats price as INR with no decimals', () {
        final formatted = PriceUtils.format(250);
        expect(formatted, contains('250'));
        expect(formatted, contains('\u20B9'));
      });

      test('formats price rounding to whole number', () {
        final formatted = PriceUtils.format(250.75);
        expect(formatted, contains('251'));
      });
    });

    group('formatPrecise', () {
      test('formats price with 2 decimal places', () {
        final formatted = PriceUtils.formatPrecise(250.50);
        expect(formatted, contains('250.50'));
      });
    });

    group('percentageDifference', () {
      test('returns 0 for same prices', () {
        expect(PriceUtils.percentageDifference(100, 100), 0.0);
      });

      test('returns positive for higher compare price', () {
        expect(PriceUtils.percentageDifference(100, 150), 50.0);
      });

      test('returns negative for lower compare price', () {
        expect(PriceUtils.percentageDifference(200, 100), -50.0);
      });

      test('returns 0 when base price is 0', () {
        expect(PriceUtils.percentageDifference(0, 100), 0.0);
      });
    });

    group('savingsLabel', () {
      test('returns Best Price when current equals lowest', () {
        expect(PriceUtils.savingsLabel(100, 100), 'Best Price');
      });

      test('returns Best Price when current is lower than lowest', () {
        expect(PriceUtils.savingsLabel(100, 50), 'Best Price');
      });

      test('returns Save label when current is higher', () {
        final label = PriceUtils.savingsLabel(100, 200);
        expect(label, contains('Save'));
        expect(label, contains('cheapest'));
      });
    });
  });
}
