import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class SupabaseStorageService {
  final _supabase = Supabase.instance.client;
  static const String bucketName = 'profile-pictures';
  static const String drinkBucketName = 'drink-images';

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

  Future<String?> updateProfilePicture(
      String userId,
      File newImageFile,
      String? oldPhotoUrl,
      ) async {
    try {
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        await deleteProfilePicture(oldPhotoUrl);
      }

      return await uploadProfilePicture(userId, newImageFile);
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadDrinkImage(File imageFile, String drinkName) async {
    try {
      if (!await imageFile.exists()) {
        return null;
      }

      final fileExt = path.extension(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = drinkName.replaceAll(' ', '_').toLowerCase();
      final fileName = '${timestamp}_$sanitizedName$fileExt';
      final filePath = 'drinks/$fileName';

      await _supabase.storage.from(drinkBucketName).upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      final publicUrl = _supabase.storage.from(drinkBucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteDrinkImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      final bucketIndex = pathSegments.indexOf(drinkBucketName);
      if (bucketIndex == -1) {
        return false;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from(drinkBucketName).remove([filePath]);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> updateDrinkImage(
      File newImageFile,
      String drinkName,
      String? oldImageUrl,
      ) async {
    try {
      if (oldImageUrl != null && oldImageUrl.startsWith('http')) {
        await deleteDrinkImage(oldImageUrl);
      }

      return await uploadDrinkImage(newImageFile, drinkName);
    } catch (e) {
      return null;
    }
  }
}