import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:price_pilot/core/theme/app_theme.dart';
import 'package:price_pilot/data/providers/auth_provider.dart';
import 'package:price_pilot/data/providers/location_provider.dart';

import 'package:price_pilot/data/repositories/location_repository.dart';
import 'package:price_pilot/data/services/database_service.dart';
import 'package:price_pilot/data/services/location_service.dart';
import 'package:price_pilot/navigation/app_router.dart';
import 'package:price_pilot/presentation/screens/home/home_screen.dart';
import '../../helpers/mocks.dart';

void main() {
  Widget buildTestWidget() {
    final dbService = DatabaseService();
    final authRepo = MockAuthRepository();
    final locationService = LocationService();
    final locationRepo = LocationRepository(
      locationService: locationService,
      databaseService: dbService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(locationRepository: locationRepo),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('renders Price Pilot title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Price Pilot'), findsOneWidget);
    });

    testWidgets('renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('has 4 bottom nav items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.items.length, 4);
    });

    testWidgets('renders pickup and dropoff fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('renders Compare Prices button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Compare Prices'), findsOneWidget);
    });

    testWidgets('renders quick action buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('History'), findsOneWidget);
      expect(find.text('Home'), findsWidgets); // text + nav item
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('shows snackbar when comparing with empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Compare Prices'));
      await tester.pump();

      expect(
        find.text('Please enter both pickup and drop-off locations'),
        findsOneWidget,
      );
    });
  });
}
