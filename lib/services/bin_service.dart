import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/bin.dart';
import 'supabase_service.dart';

class BinService {
  static const String _tableName = 'bins';
  static const String _bucketName = 'bins';
  static final SupabaseClient _client = SupabaseService.client;

  static Stream<List<Bin>> watchBins() {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map((row) => Bin.fromJson(row as Map<String, dynamic>))
              .toList(),
        );
  }

  static Future<List<Bin>> fetchBins() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);
    return (response as List<dynamic>)
        .map((row) => Bin.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  static Future<Bin> createBin({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
    required String binType,
    required String addedByName,
    String? addedById,
    String? description,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadBinImage(imageFile);
    }

    final payload = {
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'bin_type': binType,
      'description': description,
      'image_url': imageUrl,
      'added_by_name': addedByName,
      'added_by_id': (addedById == null || addedById.isEmpty)
          ? null
          : addedById,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _client
        .from(_tableName)
        .insert(payload)
        .select()
        .single() as Map<String, dynamic>;
    return Bin.fromJson(response);
  }

  static Future<String> _uploadBinImage(File file) async {
    final fileExt = file.path.split('.').last;
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_client.auth.currentUser?.id ?? 'bin'}.$fileExt';
    final storagePath = 'bin-images/$fileName';

    await _client.storage.from(_bucketName).uploadBinary(
          storagePath,
          await file.readAsBytes(),
          fileOptions: FileOptions(
            upsert: false,
            contentType: 'image/$fileExt',
          ),
        );
    return _client.storage.from(_bucketName).getPublicUrl(storagePath);
  }
}
