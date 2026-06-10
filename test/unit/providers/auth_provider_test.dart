import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/data/providers/auth_provider.dart';
import '../../helpers/mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authProvider = AuthProvider(authRepository: mockAuthRepository);
  });

  tearDown(() {
    mockAuthRepository.close();
  });

  group('AuthProvider', () {
    test('initial state is unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoading, false);
      expect(authProvider.error, isNull);
    });

    test('clearError resets error to null', () {
      authProvider.clearError();
      expect(authProvider.error, isNull);
    });

    test('notifies listeners on clearError', () {
      int notifications = 0;
      authProvider.addListener(() => notifications++);

      authProvider.clearError();
      expect(notifications, 1);
    });
  });
}
