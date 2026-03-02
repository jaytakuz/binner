import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user.dart' as app_models;
import 'supabase_service.dart';

class AuthService {
  static supabase.SupabaseClient get _client => SupabaseService.client;
  static supabase.GoTrueClient get _auth => _client.auth;

  static app_models.User? get currentUser => _mapUser(_auth.currentUser);

  static bool get isLoggedIn => currentUser != null;

  static Stream<app_models.User?> get authStateChanges => _auth
      .onAuthStateChange
      .map((event) => _mapUser(event.session?.user));

  static Future<supabase.AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> logout() => _auth.signOut();

  static Future<supabase.AuthResponse> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
  }

  static app_models.User? _mapUser(supabase.User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata ?? {};
    final email = user.email ?? '';
    final emailName =
        email.isNotEmpty ? email.split('@').first : 'Binner User';
    final name = metadata['name'] as String? ?? emailName;
    return app_models.User(
      id: user.id,
      email: email,
      name: name,
      phone: metadata['phone'] as String?,
      profileImage: metadata['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }
}
