import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/data/providers/ride_provider.dart';
import 'package:price_pilot/data/repositories/ride_repository.dart';
import 'package:price_pilot/data/services/database_service.dart';

void main() {
  late RideProvider rideProvider;
  late RideRepository rideRepository;

  setUp(() {
    rideRepository = RideRepository(databaseService: DatabaseService());
    rideProvider = RideProvider(rideRepository: rideRepository);
  });

  group('RideProvider', () {
    test('initial state is empty', () {
      expect(rideProvider.rides, isEmpty);
      expect(rideProvider.allRides, isEmpty);
      expect(rideProvider.isLoading, false);
      expect(rideProvider.error, isNull);
      expect(rideProvider.selectedVehicleFilter, isNull);
      expect(rideProvider.bestPrice, isNull);
      expect(rideProvider.availableVehicleTypes, isEmpty);
    });

    test('clearRides resets all state', () {
      rideProvider.clearRides();

      expect(rideProvider.rides, isEmpty);
      expect(rideProvider.allRides, isEmpty);
      expect(rideProvider.error, isNull);
      expect(rideProvider.selectedVehicleFilter, isNull);
    });

    test('setVehicleFilter updates filter', () {
      rideProvider.setVehicleFilter('Mini');
      expect(rideProvider.selectedVehicleFilter, 'Mini');
    });

    test('setVehicleFilter to null clears filter', () {
      rideProvider.setVehicleFilter('Mini');
      rideProvider.setVehicleFilter(null);
      expect(rideProvider.selectedVehicleFilter, isNull);
    });

    test('notifies listeners on filter change', () {
      int notifications = 0;
      rideProvider.addListener(() => notifications++);

      rideProvider.setVehicleFilter('Auto');
      expect(notifications, 1);
    });

    test('notifies listeners on clearRides', () {
      int notifications = 0;
      rideProvider.addListener(() => notifications++);

      rideProvider.clearRides();
      expect(notifications, 1);
    });
  });
}
