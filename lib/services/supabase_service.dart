import 'package:opart_v2/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured => SupabaseConfig.isConfigured;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (_initialized || !isConfigured) {
      return;
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _initialized = true;
  }

  /// Optional: signs in anonymously when enabled on the Supabase project.
  /// The print shop works without this — uploads go through edge functions.
  static Future<User?> ensureAnonymousUser() async {
    if (!isConfigured) {
      return null;
    }

    final session = client.auth.currentSession;
    if (session != null) {
      return session.user;
    }

    try {
      final response = await client.auth.signInAnonymously();
      return response.user;
    } on AuthException catch (error) {
      if (error.message.toLowerCase().contains('anonymous')) {
        return null;
      }
      rethrow;
    }
  }
}
