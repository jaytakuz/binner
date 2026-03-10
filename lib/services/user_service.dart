import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;
import 'supabase_service.dart';

class UserService {
  static SupabaseClient get _client => SupabaseService.client;
  static const String _tableName = 'profiles';

  /// Create a new user profile in the database
  static Future<app_models.User> createProfile({
    required String userId,
    required String email,
    required String name,
    String? profileImage,
  }) async {
    final now = DateTime.now();
    final data = {
      'id': userId,
      'email': email,
      'name': name,
      'images_url': profileImage,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _client
        .from(_tableName)
        .insert(data)
        .select()
        .single();

    return app_models.User.fromJson(response);
  }

  /// Get user profile by ID
  static Future<app_models.User?> getProfile(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single();

      return app_models.User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  static Future<app_models.User> updateProfile({
    required String userId,
    String? name,
    String? profileImage,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) data['name'] = name;
    if (profileImage != null) data['images_url'] = profileImage;

    final response = await _client
        .from(_tableName)
        .update(data)
        .eq('id', userId)
        .select()
        .single();

    return app_models.User.fromJson(response);
  }

  /// Delete user profile
  static Future<void> deleteProfile(String userId) async {
    await _client.from(_tableName).delete().eq('id', userId);
  }

  /// Check if profile exists
  static Future<bool> profileExists(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get user profile by email
  static Future<app_models.User?> getProfileByEmail(String email) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return app_models.User.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
