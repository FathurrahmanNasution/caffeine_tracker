import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class SupabaseStorageService {
  final _supabase = Supabase.instance.client;
  static const String bucketName = 'profile-pictures';

  /// Upload profile picture to Supabase Storage
  Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return null;
      }

      final fileExt = path.extension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = '$userId/$fileName';

      // Upload file
      await _supabase.storage.from(bucketName).upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  /// Delete profile picture from Supabase Storage
  Future<bool> deleteProfilePicture(String photoUrl) async {
    try {
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex == -1) {
        return false;
      }
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from(bucketName).remove([filePath]);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update profile picture (delete old, upload new)
  Future<String?> updateProfilePicture(
    String userId,
    File newImageFile,
    String? oldPhotoUrl,
  ) async {
    try {
      // Delete old photo if exists
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        await deleteProfilePicture(oldPhotoUrl);
      }

      // Upload new photo
      return await uploadProfilePicture(userId, newImageFile);
    } catch (e) {
      return null;
    }
  }
}