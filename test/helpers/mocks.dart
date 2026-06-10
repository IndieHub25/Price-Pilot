import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:price_pilot/data/repositories/auth_repository.dart';
import 'package:price_pilot/data/models/user_model.dart';

class MockAuthRepository extends AuthRepository {
  final _authStateController = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Return a dummy user for testing
    return UserModel(
      id: 'test-user-id',
      email: email,
      name: 'Test User',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return UserModel(
      id: 'new-user-id',
      email: email,
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );
  }

  void emitAuthState(AuthState state) {
    _authStateController.add(state);
  }

  void close() {
    _authStateController.close();
  }
}
