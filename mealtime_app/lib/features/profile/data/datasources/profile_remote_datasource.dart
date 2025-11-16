import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/profile/data/models/profile_model.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/services/api/profile_api_service.dart';

abstract class ProfileRemoteDataSource {
  Future<Profile> getProfile(String idOrUsername);
  Future<Profile> updateProfile(String idOrUsername, Profile profile);
  Future<String> uploadAvatar(String idOrUsername, String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ProfileApiService apiService;
  final Dio dio;

  ProfileRemoteDataSourceImpl({
    required this.apiService,
    required this.dio,
  });

  @override
  Future<Profile> getProfile(String idOrUsername) async {
    try {
      final apiResponse = await apiService.getProfile(idOrUsername);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar perfil',
        );
      }

      if (apiResponse.data == null) {
        throw ServerException('Perfil retornou vazio');
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Erro ao buscar perfil: ${e.toString()}');
    }
  }

  @override
  Future<Profile> updateProfile(String idOrUsername, Profile profile) async {
    try {
      final request = ProfileInputModel(
        username: profile.username,
        fullName: profile.fullName,
        avatarUrl: profile.avatarUrl,
        timezone: profile.timezone,
      );
      final apiResponse = await apiService.updateProfile(idOrUsername, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar perfil',
        );
      }

      if (apiResponse.data == null) {
        throw ServerException('Perfil retornou vazio após atualização');
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Erro ao atualizar perfil: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadAvatar(String idOrUsername, String filePath) async {
    try {
      final file = File(filePath);
      
      // Verificar se o arquivo existe antes de tentar ler
      if (!await file.exists()) {
        throw NotFoundException(
          'Arquivo não encontrado: $filePath',
        );
      }
      
      final filename = path.basename(file.path);
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filename,
        ),
      });

      final uploadUrl = Uri.parse(ApiConstants.baseUrlV2)
          .resolve(ApiConstants.v2Upload)
          .toString();
      
      final response = await dio.post(
        uploadUrl,
        data: formData,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao fazer upload',
        );
      }

      final uploadResponse = UploadResponse.fromJson(apiResponse.data!);
      return uploadResponse.url;
    } on NotFoundException {
      rethrow;
    } on FileSystemException catch (e) {
      throw ServerException(
        'Erro de sistema de arquivos ao fazer upload: ${e.message}',
      );
    } catch (e, st) {
      if (e is ServerException) rethrow;
      throw ServerException(
        'Erro ao fazer upload: ${e.toString()}\nStack trace: $st',
      );
    }
  }
}

/// Response model para upload (duplicado aqui para uso no datasource)
class UploadResponse {
  final String url;
  final String? filename;

  const UploadResponse({
    required this.url,
    this.filename,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    // Validar que o campo 'url' existe e é uma String
    if (!json.containsKey('url')) {
      throw ServerException(
        'Resposta de upload inválida: campo "url" não encontrado',
      );
    }
    
    if (json['url'] == null) {
      throw ServerException(
        'Resposta de upload inválida: campo "url" é null',
      );
    }
    
    if (json['url'] is! String) {
      throw ServerException(
        'Resposta de upload inválida: campo "url" não é uma String',
      );
    }
    
    return UploadResponse(
      url: json['url'] as String,
      filename: json['filename'] as String?,
    );
  }
}

