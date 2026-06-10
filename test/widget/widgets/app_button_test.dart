import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/core/theme/app_theme.dart';
import 'package:price_pilot/presentation/widgets/common/app_button.dart';

void main() {
  Widget buildTestWidget(AppButton button) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Center(child: button)),
    );
  }

  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(AppButton(label: 'Test Button', onPressed: () {})),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'Tap Me', onPressed: () => pressed = true),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(pressed, true);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            label: 'Loading',
            onPressed: () => pressed = true,
            isLoading: true,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, false);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'Loading', onPressed: () {}, isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'With Icon', onPressed: () {}, icon: Icons.login),
        ),
      );

      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('renders as outlined button when isOutlined is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'Outlined', onPressed: () {}, isOutlined: true),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppButton(label: 'Disabled')),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
