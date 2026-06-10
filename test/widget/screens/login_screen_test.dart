import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:price_pilot/core/theme/app_theme.dart';
import 'package:price_pilot/data/providers/auth_provider.dart';

import 'package:price_pilot/navigation/app_router.dart';
import '../../helpers/mocks.dart';
import 'package:price_pilot/presentation/screens/auth/login_screen.dart';

void main() {
  Widget buildTestWidget() {
    final authRepo = MockAuthRepository();

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(authRepository: authRepo),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email input field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('renders Sign In button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders Create Account link', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('renders Welcome Back text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('shows validation error on empty email submit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap sign in without entering email
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows validation error on invalid email', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('renders app logo', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
