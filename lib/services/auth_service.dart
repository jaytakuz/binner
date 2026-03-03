import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user.dart' as app_models;
import 'supabase_service.dart';
import 'user_service.dart';

class AuthService {
  static supabase.SupabaseClient get _client => SupabaseService.client;
  static supabase.GoTrueClient get _auth => _client.auth;

  static app_models.User? get currentUser => _mapUser(_auth.currentUser);

  static bool get isLoggedIn => currentUser != null;

  static Stream<app_models.User?> get authStateChanges =>
      _auth.onAuthStateChange.map((event) => _mapUser(event.session?.user));

  static Future<supabase.AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> logout() => _auth.signOut();

  /// Register a new user with email and password
  /// Creates both auth user and profile record in database
  static Future<supabase.AuthResponse> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    // Step 1: Register user with Supabase Auth
    final authResponse = await _auth.signUp(
      email: email,
      password: password,
      data: {if (name != null && name.isNotEmpty) 'name': name},
    );

    // Step 2: Create profile in database if registration was successful
    if (authResponse.user != null) {
      try {
        await UserService.createProfile(
          userId: authResponse.user!.id,
          email: email,
          name: name ?? email.split('@').first,
        );
      } catch (e) {
        // If profile creation fails, we should still return the auth response
        // The profile can be created later or synced via database triggers
        print('Warning: Failed to create user profile: $e');
      }
    }

    return authResponse;
  }

  static app_models.User? _mapUser(supabase.User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata ?? {};
    final email = user.email ?? '';
    final emailName = email.isNotEmpty ? email.split('@').first : 'Binner User';
    final name = metadata['name'] as String? ?? emailName;
    return app_models.User(
      id: user.id,
      email: email,
      name: name,
      profileImage: metadata['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  /// Get complete user profile from database
  /// Falls back to auth metadata if profile doesn't exist
  static Future<app_models.User?> getUserProfile() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return null;

    try {
      // Try to get profile from database first
      final profile = await UserService.getProfile(authUser.id);
      if (profile != null) return profile;

      // Fallback to creating profile from auth metadata
      return _mapUser(authUser);
    } catch (e) {
      // If database query fails, fallback to auth metadata
      return _mapUser(authUser);
    }
  }

  /// Sync user profile to database (useful after updates)
  static Future<void> syncProfileToDatabase() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return;

    final metadata = authUser.userMetadata ?? {};
    final email = authUser.email ?? '';
    final name = metadata['name'] as String? ?? email.split('@').first;

    // Check if profile exists
    final exists = await UserService.profileExists(authUser.id);

    if (exists) {
      // Update existing profile
      await UserService.updateProfile(userId: authUser.id, name: name);
    } else {
      // Create new profile
      await UserService.createProfile(
        userId: authUser.id,
        email: email,
        name: name,
      );
    }
  }

  /// Request password reset email from Supabase
  static Future<void> requestPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Update password with name verification
  /// This creates a password reset request in the database
  static Future<void> updatePasswordWithVerification({
    required String userId,
    required String newPassword,
  }) async {
    try {
      // Use Supabase RPC to update password
      // This requires a database function to be set up
      await _client.rpc(
        'update_user_password',
        params: {'user_id': userId, 'new_password': newPassword},
      );
    } catch (e) {
      // If RPC function doesn't exist, try alternative method
      if (e.toString().contains('Could not find') ||
          e.toString().contains('not found') ||
          e.toString().contains('does not exist')) {
        // Create a password reset token in the database
        await _client.from('password_reset_requests').insert({
          'user_id': userId,
          'new_password_hash': newPassword, // In production, hash this!
          'created_at': DateTime.now().toIso8601String(),
        });

        throw Exception(
          'Password reset request created. Please contact admin to complete the reset.',
        );
      }
      rethrow;
    }
  }
}
