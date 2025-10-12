import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/auth/data/models/user_model.dart';
import 'package:mealtime_app/services/api/auth_api_service.dart' as api;
import 'package:mealtime_app/features/auth/data/datasources/auth_remote_datasource.dart';

/// Implementação do AuthRemoteDataSource usando Supabase diretamente
/// ao invés da API backend
class SupabaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  SupabaseAuthRemoteDataSourceImpl({required supabase.SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<api.AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw ServerException('Falha no login - usuário não retornado');
      }

      final user = response.user!;
      final session = response.session;

      // Criar AuthResponse compatível com o sistema
      final authResponse = api.AuthResponse(
        success: true,
        accessToken: session?.accessToken,
        refreshToken: session?.refreshToken,
        expiresIn: session?.expiresIn,
        tokenType: 'bearer',
        user: UserModel(
          id: user.id,
          authId: user.id,
          fullName: user.userMetadata?['full_name'] ?? '',
          email: user.email ?? '',
          householdId: null,
          household: null,
          createdAt: _parseDateTime(user.createdAt),
          updatedAt: _parseDateTime(user.updatedAt),
        ),
        error: null,
        requiresEmailConfirmation: user.emailConfirmedAt == null,
      );

      return authResponse;
    } on supabase.AuthException catch (e) {
      throw ServerException('Erro de autenticação: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao fazer login: ${e.toString()}');
    }
  }

  @override
  Future<api.AuthResponse> register(String email, String password, String fullName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw ServerException('Falha no registro - usuário não criado');
      }

      final user = response.user!;
      final session = response.session;

      // Criar AuthResponse compatível com o sistema
      final authResponse = api.AuthResponse(
        success: true,
        accessToken: session?.accessToken,
        refreshToken: session?.refreshToken,
        expiresIn: session?.expiresIn,
        tokenType: 'bearer',
        user: UserModel(
          id: user.id,
          authId: user.id,
          fullName: fullName,
          email: user.email ?? '',
          householdId: null,
          household: null,
          createdAt: _parseDateTime(user.createdAt),
          updatedAt: _parseDateTime(user.updatedAt),
        ),
        error: null,
        requiresEmailConfirmation: user.emailConfirmedAt == null,
      );

      return authResponse;
    } on supabase.AuthException catch (e) {
      throw ServerException('Erro de registro: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao fazer registro: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw ServerException('Erro ao fazer logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session?.user == null) {
        throw ServerException('Usuário não autenticado');
      }

      final user = session!.user;
      
      return UserModel(
        id: user.id,
        authId: user.id,
        fullName: user.userMetadata?['full_name'] ?? '',
        email: user.email ?? '',
        householdId: null,
        household: null,
        createdAt: _parseDateTime(user.createdAt),
        updatedAt: _parseDateTime(user.updatedAt),
      );
    } catch (e) {
      throw ServerException('Erro ao buscar perfil: ${e.toString()}');
    }
  }

  @override
  Future<api.AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _supabase.auth.refreshSession();

      if (response.session == null) {
        throw ServerException('Falha ao renovar token');
      }

      final session = response.session!;
      final user = response.user!;

      final authResponse = api.AuthResponse(
        success: true,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresIn: session.expiresIn,
        tokenType: 'bearer',
        user: UserModel(
          id: user.id,
          authId: user.id,
          fullName: user.userMetadata?['full_name'] ?? '',
          email: user.email ?? '',
          householdId: null,
          household: null,
          createdAt: _parseDateTime(user.createdAt),
          updatedAt: _parseDateTime(user.updatedAt),
        ),
        error: null,
        requiresEmailConfirmation: user.emailConfirmedAt == null,
      );

      return authResponse;
    } catch (e) {
      throw ServerException('Erro ao renovar token: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.mealtime.app://reset-password/',
      );
    } catch (e) {
      throw ServerException('Erro ao solicitar recuperação de senha: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    try {
      // No Supabase, o reset de senha é feito através da sessão
      // Este método pode precisar ser ajustado dependendo da implementação
      throw ServerException('Reset de senha via token não implementado para Supabase');
    } catch (e) {
      throw ServerException('Erro ao redefinir senha: ${e.toString()}');
    }
  }

  /// Helper para converter String para DateTime
  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
