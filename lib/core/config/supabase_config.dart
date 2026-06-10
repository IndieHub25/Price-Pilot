import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initializes and provides access to the Supabase client.
///
/// Call [initialize] once during app startup (before `runApp`).
/// Then use [client] anywhere to access the Supabase instance.
class SupabaseConfig {
  SupabaseConfig._();

  /// Initialize Supabase with credentials from the .env file.
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw Exception(
        'Missing Supabase credentials. '
        'Set SUPABASE_URL and SUPABASE_ANON_KEY in .env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  /// The global Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Shorthand for the Supabase auth module.
  static GoTrueClient get auth => client.auth;
}
