import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as path;
import 'package:mealtime_app/core/errors/failures.dart';

abstract class SupabaseStorageDataSource {
  Future<Either<Failure, String>> uploadAvatar(File imageFile, String userId);
  Future<Either<Failure, void>> deleteAvatar(String filePath);
}

class SupabaseStorageDataSourceImpl implements SupabaseStorageDataSource {
  final SupabaseClient _supabase;

  SupabaseStorageDataSourceImpl({required SupabaseClient supabase})
    : _supabase = supabase;

  @override
  Future<Either<Failure, String>> uploadAvatar(
    File imageFile,
    String userId,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final ext = path.extension(imageFile.path);
      final fileExt = ext.length > 1 ? ext.substring(1) : 'jpg';
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = 'avatars/$userId/$fileName';

      // Upload do arquivo
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: _getContentType(fileExt)),
          );

      // Criar URL assinada
      final imageUrlResponse = await _supabase.storage
          .from('avatars')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10); // 10 anos

      return Right(imageUrlResponse);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAvatar(String filePath) async {
    try {
      await _supabase.storage.from('avatars').remove([filePath]);

      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
