import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';
import 'package:mealtime_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mealtime_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mealtime_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final authResponse = await remoteDataSource.login(email, password);

      // Verificar se a autenticação foi bem-sucedida
      if (!authResponse.isSuccess) {
        return Left(ServerFailure(authResponse.error ?? 'Falha no login'));
      }

      if (authResponse.user == null || authResponse.accessToken == null) {
        return Left(ServerFailure('Dados de autenticação inválidos'));
      }

      // Salvar tokens localmente
      await localDataSource.saveTokens(
        authResponse.accessToken!,
        authResponse.refreshToken ?? '',
      );

      // Tentar buscar dados completos da tabela profiles
      try {
        final userId = authResponse.user!.id;
        final profileData = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (profileData != null) {
          // Combinar dados do Auth com dados do Profile
          final completeUser = UserModel(
            id: userId,
            authId: userId,
            fullName: profileData['full_name'] as String? ?? 
                     authResponse.user!.email.split('@').first,
            email: authResponse.user!.email,
            householdId: profileData['household_id'] as String?,
            createdAt: authResponse.user!.createdAt,
            updatedAt: authResponse.user!.updatedAt,
            isEmailVerified: authResponse.user!.isEmailVerified,
          );
          
          await localDataSource.saveUser(completeUser);
          return Right(completeUser.toEntity());
        }
      } catch (e) {
        // Se falhar ao buscar profile, continuar com dados básicos do Auth
        print('Aviso: Não foi possível buscar dados do profile: $e');
      }

      // Fallback: salvar usuário do Supabase Auth
      await localDataSource.saveUser(authResponse.user!);
      return Right(authResponse.user!.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final authResponse = await remoteDataSource.register(
        email,
        password,
        fullName,
      );

      // Verificar se requer confirmação de email
      if (authResponse.requiresEmailConfirmation == true) {
        return Left(ServerFailure(
          authResponse.error ?? 'Verifique seu email para confirmar a conta',
        ));
      }

      // Verificar se a autenticação foi bem-sucedida
      if (!authResponse.isSuccess) {
        return Left(ServerFailure(authResponse.error ?? 'Falha no registro'));
      }

      if (authResponse.user == null || authResponse.accessToken == null) {
        return Left(ServerFailure('Dados de registro inválidos'));
      }

      // Salvar tokens localmente
      await localDataSource.saveTokens(
        authResponse.accessToken!,
        authResponse.refreshToken ?? '',
      );

      // Salvar usuário localmente
      await localDataSource.saveUser(authResponse.user!);

      return Right(authResponse.user!.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Fazer logout no servidor
      await remoteDataSource.logout();

      // Limpar dados locais
      await localDataSource.clearTokens();
      await localDataSource.clearUser();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Verificar se há token de acesso salvo
      final accessToken = await localDataSource.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      // Tentar buscar usuário do cache local primeiro
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // Se não houver usuário local, significa que precisa fazer login novamente
      return Left(ServerFailure('Usuário não autenticado'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(
          UnauthorizedFailure('Token de refresh não encontrado'),
        );
      }

      final authResponse = await remoteDataSource.refreshToken(refreshToken);

      // Verificar se a renovação foi bem-sucedida
      if (!authResponse.isSuccess) {
        return Left(
          ServerFailure(authResponse.error ?? 'Falha no refresh do token'),
        );
      }

      if (authResponse.accessToken == null) {
        return Left(ServerFailure('Token de acesso inválido'));
      }

      // Salvar novos tokens
      await localDataSource.saveTokens(
        authResponse.accessToken!,
        authResponse.refreshToken ?? refreshToken,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String token,
    String password,
  ) async {
    try {
      await remoteDataSource.resetPassword(token, password);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}
