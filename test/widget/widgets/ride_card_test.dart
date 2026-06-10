import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/core/theme/app_theme.dart';
import 'package:price_pilot/data/models/ride_model.dart';
import 'package:price_pilot/presentation/widgets/ride/ride_card.dart';

void main() {
  Widget buildTestWidget({
    required RideModel ride,
    bool isBestPrice = false,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: RideCard(
          ride: ride,
          isBestPrice: isBestPrice,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  const sampleRide = RideModel(
    id: 'test_1',
    service: 'Uber',
    vehicleType: 'Mini',
    price: 250,
    estimatedTimeMinutes: 15,
    seatingCapacity: 4,
  );

  const surgeRide = RideModel(
    id: 'test_2',
    service: 'Ola',
    vehicleType: 'Sedan',
    price: 450,
    estimatedTimeMinutes: 20,
    surgeMultiplier: 1.5,
    seatingCapacity: 4,
  );

  group('RideCard', () {
    testWidgets('displays service name', (tester) async {
      await tester.pumpWidget(buildTestWidget(ride: sampleRide));
      expect(find.text('Uber'), findsOneWidget);
    });

    testWidgets('displays vehicle type', (tester) async {
      await tester.pumpWidget(buildTestWidget(ride: sampleRide));
      expect(find.text('Mini'), findsOneWidget);
    });

    testWidgets('displays price', (tester) async {
      await tester.pumpWidget(buildTestWidget(ride: sampleRide));
      expect(find.textContaining('250'), findsWidgets);
    });

    testWidgets('displays estimated time', (tester) async {
      await tester.pumpWidget(buildTestWidget(ride: sampleRide));
      expect(find.textContaining('15'), findsWidgets);
    });

    testWidgets('shows best price badge when isBestPrice is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(ride: sampleRide, isBestPrice: true),
      );
      expect(find.textContaining('Best'), findsWidgets);
    });

    testWidgets('shows surge indicator for surge rides', (tester) async {
      await tester.pumpWidget(buildTestWidget(ride: surgeRide));
      expect(find.textContaining('1.5'), findsWidgets);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(ride: sampleRide, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(RideCard));
      expect(tapped, true);
    });

    testWidgets('displays seating capacity', (tester) async {
      await tester.pumpWidget(buildTestWidget(ride: sampleRide));
      expect(find.textContaining('4'), findsWidgets);
    });
  });
}
