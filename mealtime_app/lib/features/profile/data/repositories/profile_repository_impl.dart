import 'dart:async';
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

  // Rastreamento de sincronizações em andamento para evitar race conditions
  final Map<String, Future<void>> _inFlightSyncs = {};
  
  // Timers para debounce de sincronizações
  final Map<String, Timer> _debounceTimers = {};
  
  // Rastreamento de requisições iniciais em andamento para deduplicação
  final Map<String, Future<Profile>> _inFlightFetches = {};

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
        // Sincronizar em background com proteção contra race condition
        _syncWithRemote(idOrUsername);
        return Right(localProfile);
      }

      // 2. Se não encontrar localmente, buscar da API com deduplicação
      final remoteProfile = await _getProfileWithDeduplication(
        idOrUsername,
      );
      return Right(remoteProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }
  
  /// Busca perfil remoto com deduplicação de requisições concorrentes
  Future<Profile> _getProfileWithDeduplication(
    String idOrUsername,
  ) async {
    // Verificar se já existe uma requisição em andamento
    if (_inFlightFetches.containsKey(idOrUsername)) {
      debugPrint(
        '[ProfileRepository] Requisição já em andamento para '
        '$idOrUsername, reutilizando Future existente',
      );
      return _inFlightFetches[idOrUsername]!;
    }
    
    // Criar nova requisição
    final fetchFuture = Future.microtask(() async {
      try {
        debugPrint(
          '[ProfileRepository] Iniciando busca remota para '
          '$idOrUsername',
        );
        final remoteProfile = await remoteDataSource.getProfile(
          idOrUsername,
        );
        await localDataSource.cacheProfile(remoteProfile);
        debugPrint(
          '[ProfileRepository] Busca remota concluída para '
          '$idOrUsername',
        );
        return remoteProfile;
      } catch (e) {
        debugPrint(
          '[ProfileRepository] Erro na busca remota para '
          '$idOrUsername: $e',
        );
        // Re-lançar erro para propagar aos chamadores
        rethrow;
      } finally {
        // Sempre remover da lista de requisições em andamento
        _inFlightFetches.remove(idOrUsername);
        debugPrint(
          '[ProfileRepository] Requisição removida do rastreamento para '
          '$idOrUsername',
        );
      }
    });
    
    // Armazenar o Future no mapa antes de iniciar
    _inFlightFetches[idOrUsername] = fetchFuture;
    
    return fetchFuture;
  }

  /// Sincroniza dados locais com remoto em background
  /// Utiliza rastreamento de operações em andamento para evitar race conditions
  /// e debounce para reduzir sincronizações duplicadas
  void _syncWithRemote(String idOrUsername) {
    // Cancelar timer de debounce anterior se existir
    _debounceTimers[idOrUsername]?.cancel();

    // Criar novo timer de debounce (300ms)
    final timer = Timer(const Duration(milliseconds: 300), () {
      _debounceTimers.remove(idOrUsername);
      _performSync(idOrUsername);
    });
    _debounceTimers[idOrUsername] = timer;
  }

  /// Executa a sincronização real com proteção contra race condition
  Future<void> _performSync(String idOrUsername) async {
    // Verificar se já existe uma sincronização em andamento
    if (_inFlightSyncs.containsKey(idOrUsername)) {
      debugPrint(
        '[ProfileRepository] Sincronização já em andamento para '
        '$idOrUsername, reutilizando Future existente',
      );
      return _inFlightSyncs[idOrUsername]!;
    }

    // Criar nova sincronização
    final syncFuture = Future.microtask(() async {
      try {
        debugPrint(
          '[ProfileRepository] Iniciando sincronização para '
          '$idOrUsername',
        );
        final remoteProfile = await remoteDataSource.getProfile(idOrUsername);
        await localDataSource.cacheProfile(remoteProfile);
        debugPrint(
          '[ProfileRepository] Sincronização em background concluída para '
          '$idOrUsername',
        );
      } catch (e) {
        debugPrint(
          '[ProfileRepository] Erro na sincronização em background para '
          '$idOrUsername: $e',
        );
        // Re-lançar erro para que possa ser tratado se necessário
        rethrow;
      } finally {
        // Sempre remover da lista de sincronizações em andamento
        _inFlightSyncs.remove(idOrUsername);
        debugPrint(
          '[ProfileRepository] Sincronização removida do rastreamento para '
          '$idOrUsername',
        );
      }
    });

    // Armazenar o Future no mapa antes de iniciar
    _inFlightSyncs[idOrUsername] = syncFuture;

    // Aguardar a conclusão (sem bloquear o método que chamou)
    syncFuture.catchError((error) {
      // Erro já foi logado no try-catch acima
      // Apenas garantir que a entrada seja removida (já está no finally)
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

