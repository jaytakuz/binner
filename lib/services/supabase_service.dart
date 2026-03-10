import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final _url = dotenv.env['SUPABASE_URL'] ?? '';
  static final _anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw StateError(
        'Supabase environment variables are missing. '
        'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
      );
    }

    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
