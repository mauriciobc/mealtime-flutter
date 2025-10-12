import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/auth/data/models/user_profile.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart'
    as app_user;

abstract class SupabaseAuthDataSource {
  Future<Either<Failure, app_user.User>> signInWithEmail(String email);
  Future<Either<Failure, app_user.User>> signUpWithEmail(
    String email,
    String password,
    String fullName,
  );
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, app_user.User?>> getCurrentUser();
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
  Stream<supabase.AuthState> get authStateChanges;
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final supabase.SupabaseClient _supabase;

  SupabaseAuthDataSourceImpl({required supabase.SupabaseClient supabase})
    : _supabase = supabase;

  @override
  Future<Either<Failure, app_user.User>> signInWithEmail(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.mealtime.app://login-callback/',
      );

      // Para Magic Links, o usuário será redirecionado
      // O estado de autenticação será gerenciado pelo stream
      return Right(
        app_user.User(
          id: '',
          authId: '',
          email: '',
          fullName: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: false,
        ),
      );
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, app_user.User>> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
        emailRedirectTo: 'io.mealtime.app://login-callback/',
      );

      if (response.user == null) {
        return const Left(AuthFailure('Falha ao criar usuário'));
      }

      // Criar perfil do usuário
      await _createUserProfile(response.user!, fullName);

      return Right(
        app_user.User(
          id: response.user!.id,
          authId: response.user!.id,
          email: response.user!.email ?? '',
          fullName: fullName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: response.user!.emailConfirmedAt != null,
        ),
      );
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Right(null);
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, app_user.User?>> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session?.user == null) {
        return const Right(null);
      }

      final user = session!.user;
      return Right(
        app_user.User(
          id: user.id,
          authId: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] ?? '',
          createdAt: user.createdAt is DateTime
              ? user.createdAt as DateTime
              : DateTime.now(),
          updatedAt: user.updatedAt is DateTime
              ? user.updatedAt as DateTime
              : DateTime.now(),
          isEmailVerified: user.emailConfirmedAt != null,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(response);
      return Right(profile);
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile profile,
  ) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      await _supabase.from('profiles').upsert(updatedProfile.toJson());

      return Right(updatedProfile);
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Stream<supabase.AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  /// Cria o perfil inicial do usuário
  Future<void> _createUserProfile(supabase.User user, String fullName) async {
    final profile = UserProfile(
      id: user.id,
      fullName: fullName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _supabase.from('profiles').insert(profile.toJson());
  }
}
