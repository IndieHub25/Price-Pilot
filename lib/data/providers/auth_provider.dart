import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Manages authentication state and current user session via Supabase.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // Listen to Supabase auth state changes
    _authRepository.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// Attempts to restore a previous session from Supabase.
  Future<void> tryAutoLogin() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  /// Creates a new user account via Supabase Auth.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authRepository.createUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      _currentUser = user;
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs in with email and password via Supabase Auth.
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      _currentUser = user;
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out the current user via Supabase Auth.
  Future<void> logout() async {
    await _authRepository.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  /// Updates the current user's profile.
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _authRepository.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clears any current error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
