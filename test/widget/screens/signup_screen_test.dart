import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:price_pilot/core/theme/app_theme.dart';
import 'package:price_pilot/data/providers/auth_provider.dart';

import 'package:price_pilot/navigation/app_router.dart';
import '../../helpers/mocks.dart';
import 'package:price_pilot/presentation/screens/auth/signup_screen.dart';

void main() {
  Widget buildTestWidget() {
    final authRepo = MockAuthRepository();

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(authRepository: authRepo),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const SignupScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }

  group('SignupScreen', () {
    testWidgets('renders name, email, and phone fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should have 4 text fields: name, email, password, phone
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('renders Create Account title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('shows name validation error on empty submit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the Create Account button
      final buttons = find.byType(ElevatedButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('shows email validation error on empty submit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Fill only name field
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');

      final buttons = find.byType(ElevatedButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows phone validation error on empty submit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Fill name and email fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'test@example.com');

      final buttons = find.byType(ElevatedButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      expect(find.text('Phone number is required'), findsOneWidget);
    });

    testWidgets('shows phone validation error on short number', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'test@example.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), '12345');

      final buttons = find.byType(ElevatedButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid 10-digit phone number'), findsOneWidget);
    });

    testWidgets('renders back button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });
}
