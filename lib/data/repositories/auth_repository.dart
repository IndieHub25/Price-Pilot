import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/user_model.dart';

/// Manages user authentication and profile persistence via Supabase.
///
/// Uses Supabase Auth for sign-up / sign-in / sign-out and the
/// `users` table for profile data.
class AuthRepository {
  /// Creates a new user account via Supabase Auth and stores profile data.
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    // 1. Create auth account
    final authResponse = await SupabaseConfig.auth.signUp(
      email: email,
      password: password,
    );

    final authUser = authResponse.user;
    if (authUser == null) {
      throw Exception('Sign-up failed: no user returned.');
    }

    // 2. Insert profile into users table
    final now = DateTime.now();
    final user = UserModel(
      id: authUser.id,
      name: name,
      email: email,
      phone: phone,
      createdAt: now,
    );

    await SupabaseConfig.client.from('users').insert({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'avatar_url': user.avatarUrl,
      'created_at': user.createdAt.toIso8601String(),
    });

    return user;
  }

  /// Signs in with email + password via Supabase Auth.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final authResponse = await SupabaseConfig.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final authUser = authResponse.user;
    if (authUser == null) {
      throw Exception('Sign-in failed: no user returned.');
    }

    // Fetch profile from users table
    final profile = await SupabaseConfig.client
        .from('users')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (profile == null) {
      throw Exception('User profile not found.');
    }

    return UserModel.fromJson(profile);
  }

  /// Retrieves a user profile by ID from the users table.
  Future<UserModel?> getUserById(String userId) async {
    final result = await SupabaseConfig.client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (result == null) return null;
    return UserModel.fromJson(result);
  }

  /// Returns the currently authenticated user's profile, or null.
  Future<UserModel?> getCurrentUser() async {
    final session = SupabaseConfig.auth.currentSession;
    if (session == null) return null;
    return getUserById(session.user.id);
  }

  /// Updates user profile data in the users table.
  Future<void> updateUser(UserModel user) async {
    await SupabaseConfig.client
        .from('users')
        .update({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'avatar_url': user.avatarUrl,
        })
        .eq('id', user.id);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await SupabaseConfig.auth.signOut();
  }

  /// Deletes a user's profile data. Auth account deletion requires
  /// admin privileges and should be handled server-side.
  Future<void> deleteUser(String userId) async {
    await SupabaseConfig.client.from('users').delete().eq('id', userId);
  }

  /// Stream of auth state changes for reactive session management.
  Stream<AuthState> get onAuthStateChange =>
      SupabaseConfig.auth.onAuthStateChange;
}
