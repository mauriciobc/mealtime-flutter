import 'package:flutter/foundation.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/auth/data/models/user_model.dart';
import 'package:mealtime_app/services/api/auth_api_service.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String fullName);
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final apiResponse = await apiService.login(
        LoginRequest(email: email, password: password),
      );

      debugPrint('[AuthRemoteDataSource] apiResponse: $apiResponse');
      debugPrint('[AuthRemoteDataSource] apiResponse.data: ${apiResponse.data}');
      debugPrint('[AuthRemoteDataSource] apiResponse.data type: ${apiResponse.data?.runtimeType}');

      // Verificar se a resposta contém dados
      if (apiResponse.data == null) {
        throw ServerException('Resposta da API está vazia');
      }

      final authResponse = apiResponse.data!;
      
      // Verificar se foi bem-sucedido (tem access_token)
      if (!authResponse.isSuccess) {
        throw ServerException(
          authResponse.error ?? 'Erro desconhecido no login',
        );
      }

      // Validação adicional
      if (authResponse.accessToken == null) {
        throw ServerException('Token de acesso não foi retornado');
      }

      return authResponse;
    } on FormatException catch (e) {
      debugPrint('[AuthRemoteDataSource] FormatException: ${e.message}');
      debugPrint('[AuthRemoteDataSource] FormatException source: ${e.source}');
      debugPrint('[AuthRemoteDataSource] FormatException offset: ${e.offset}');
      throw ServerException(
        'Erro ao processar resposta do servidor: ${e.message}',
      );
    } catch (e, stackTrace) {
      debugPrint('[AuthRemoteDataSource] Login error: $e');
      debugPrint('[AuthRemoteDataSource] Stack trace: $stackTrace');
      throw ServerException('Erro ao fazer login: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final apiResponse = await apiService.register(
        RegisterRequest(email: email, password: password, fullName: fullName),
      );

      // Verificar se a resposta contém dados
      if (apiResponse.data == null) {
        throw ServerException('Resposta da API está vazia');
      }

      final authResponse = apiResponse.data!;
      
      // Verificar se foi bem-sucedido (tem access_token) ou requer confirmação
      if (!authResponse.isSuccess && !authResponse.hasError) {
        // Registro pode retornar sem token se requer confirmação de email
        if (authResponse.requiresEmailConfirmation == true) {
          return authResponse; // Retornar mesmo sem token
        }
        throw ServerException('Erro desconhecido no registro');
      }
      
      // Se tem erro, lançar exceção
      if (authResponse.hasError) {
        throw ServerException(
          authResponse.error ?? 'Erro desconhecido no registro',
        );
      }

      return authResponse;
    } on FormatException catch (e) {
      throw ServerException(
        'Erro ao processar resposta do servidor: ${e.message}',
      );
    } catch (e) {
      throw ServerException('Erro ao fazer registro: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final apiResponse = await apiService.logout();

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido no logout',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao fazer logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final apiResponse = await apiService.getProfile();

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar perfil',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao buscar perfil: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final apiResponse = await apiService.refreshToken(
        RefreshTokenRequest(refreshToken: refreshToken),
      );

      // Verificar se a resposta contém dados
      if (apiResponse.data == null) {
        throw ServerException('Resposta da API está vazia');
      }

      final authResponse = apiResponse.data!;
      
      // Verificar se foi bem-sucedido (tem access_token)
      if (!authResponse.isSuccess) {
        throw ServerException(
          authResponse.error ?? 'Erro desconhecido ao renovar token',
        );
      }

      // Validação adicional
      if (authResponse.accessToken == null) {
        throw ServerException('Novo token de acesso não foi retornado');
      }

      return authResponse;
    } on FormatException catch (e) {
      throw ServerException(
        'Erro ao processar resposta do servidor: ${e.message}',
      );
    } catch (e) {
      throw ServerException('Erro ao renovar token: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final apiResponse = await apiService.forgotPassword(
        ForgotPasswordRequest(email: email),
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao solicitar recuperação',
        );
      }
    } catch (e) {
      throw ServerException(
        'Erro ao solicitar recuperação de senha: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    try {
      final apiResponse = await apiService.resetPassword(
        ResetPasswordRequest(token: token, password: password),
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao redefinir senha',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao redefinir senha: ${e.toString()}');
    }
  }
}
