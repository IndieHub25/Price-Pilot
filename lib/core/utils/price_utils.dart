import 'package:intl/intl.dart';

/// Utility functions for price formatting and comparison.
class PriceUtils {
  PriceUtils._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyFormatDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 2,
  );

  /// Formats a price in INR with no decimals (e.g., "Rs.250").
  static String format(double price) {
    return _currencyFormat.format(price);
  }

  /// Formats a price with two decimal places (e.g., "Rs.250.50").
  static String formatPrecise(double price) {
    return _currencyFormatDecimal.format(price);
  }

  /// Returns the percentage difference between two prices.
  static double percentageDifference(double basePrice, double comparePrice) {
    if (basePrice == 0) return 0;
    return ((comparePrice - basePrice) / basePrice) * 100;
  }

  /// Returns a savings string (e.g., "Save Rs.50" or "Best Price").
  static String savingsLabel(double lowestPrice, double currentPrice) {
    if (currentPrice <= lowestPrice) {
      return 'Best Price';
    }
    final double savings = currentPrice - lowestPrice;
    return 'Save ${format(savings)} with cheapest option';
  }

  /// Calculates estimated price based on distance and base rate.
  static double estimatePrice({
    required double baseFare,
    required double perKmRate,
    required double perMinRate,
    required double distanceKm,
    required int durationMin,
    double surgeMultiplier = 1.0,
  }) {
    final double price =
        (baseFare + (perKmRate * distanceKm) + (perMinRate * durationMin)) *
        surgeMultiplier;
    return double.parse(price.toStringAsFixed(2));
  }
}
