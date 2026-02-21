import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'package:mealtime_app/core/auth/simple_auth_manager.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';

/// Repository simplificado de autenticação usando apenas Supabase
class SimpleAuthRepository {
  
  /// Faz login com email e senha
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await SimpleAuthManager.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Left(ServerFailure('Falha no login'));
      }

      final user = response.user!;
      
      return Right(User(
        id: user.id,
        authId: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? '',
        createdAt: _parseDateTime(user.createdAt),
        updatedAt: _parseDateTime(user.updatedAt),
        isEmailVerified: user.emailConfirmedAt != null,
      ));
    } catch (e) {
      return Left(ServerFailure('Erro no login: ${e.toString()}'));
    }
  }

  /// Faz cadastro com email, senha e nome
  Future<Either<Failure, User>> register(String email, String password, String fullName) async {
    try {
      final response = await SimpleAuthManager.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        return Left(ServerFailure('Falha no cadastro'));
      }

      final user = response.user!;
      
      return Right(User(
        id: user.id,
        authId: user.id,
        email: user.email ?? '',
        fullName: fullName,
        createdAt: _parseDateTime(user.createdAt),
        updatedAt: _parseDateTime(user.updatedAt),
        isEmailVerified: user.emailConfirmedAt != null,
      ));
    } catch (e) {
      return Left(ServerFailure('Erro no cadastro: ${e.toString()}'));
    }
  }

  /// Verifica se o usuário está autenticado
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      if (!SimpleAuthManager.isAuthenticated) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      final user = SimpleAuthManager.currentUser!;
      
      return Right(User(
        id: user.id,
        authId: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? '',
        createdAt: _parseDateTime(user.createdAt),
        updatedAt: _parseDateTime(user.updatedAt),
        isEmailVerified: user.emailConfirmedAt != null,
      ));
    } catch (e) {
      return Left(ServerFailure('Erro ao verificar usuário: ${e.toString()}'));
    }
  }

  /// Faz logout
  Future<Either<Failure, void>> logout() async {
    try {
      await SimpleAuthManager.signOut();
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro no logout: ${e.toString()}'));
    }
  }

  /// Inicia login com Google (OAuth). Retorna Right quando o fluxo foi
  /// iniciado; a sessão chega depois via deep link e authStateChanges.
  Future<Either<Failure, void>> loginWithGoogle() async {
    try {
      await SimpleAuthManager.signInWithGoogle();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro ao entrar com Google: ${e.toString()}'));
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
