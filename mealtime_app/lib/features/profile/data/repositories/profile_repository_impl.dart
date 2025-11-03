import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mealtime_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Profile>> getProfile(String idOrUsername) async {
    try {
      // 1. Tentar buscar do cache local primeiro
      final localProfile = await localDataSource.getCachedProfile(idOrUsername);
      if (localProfile != null) {
        // Sincronizar em background
        _syncWithRemote(idOrUsername);
        return Right(localProfile);
      }

      // 2. Se não encontrar localmente, buscar da API
      final remoteProfile = await remoteDataSource.getProfile(idOrUsername);
      await localDataSource.cacheProfile(remoteProfile);
      return Right(remoteProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  /// Sincroniza dados locais com remoto em background
  void _syncWithRemote(String idOrUsername) {
    Future.microtask(() async {
      try {
        final remoteProfile = await remoteDataSource.getProfile(idOrUsername);
        await localDataSource.cacheProfile(remoteProfile);
        debugPrint('[ProfileRepository] Sincronização em background concluída');
      } catch (e) {
        debugPrint('[ProfileRepository] Erro na sincronização em background: $e');
      }
    });
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(
    String idOrUsername,
    Profile profile,
  ) async {
    try {
      // 1. Atualizar no servidor
      final updatedProfile = await remoteDataSource.updateProfile(
        idOrUsername,
        profile,
      );

      // 2. Atualizar cache local
      await localDataSource.cacheProfile(updatedProfile);

      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      final url = await remoteDataSource.uploadAvatar(filePath);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}

