import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/sync/sync_service.dart';
import 'package:mealtime_app/features/feeding_logs/data/datasources/feeding_logs_remote_datasource.dart';
import 'package:mealtime_app/features/feeding_logs/data/datasources/feeding_logs_local_datasource.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

/// Implementação do repository de Feeding Logs
class FeedingLogsRepositoryImpl implements FeedingLogsRepository {
  final FeedingLogsRemoteDataSource remoteDataSource;
  final FeedingLogsLocalDataSource localDataSource;
  final SyncService syncService;
  final _uuid = const Uuid();

  FeedingLogsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<FeedingLog>>> getFeedingLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final feedingLogs = await remoteDataSource.getFeedingLogs(
        catId: catId,
        householdId: householdId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(feedingLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FeedingLog>> getFeedingLogById(String id) async {
    try {
      // Usar cache local primeiro
      final feedingLog = await localDataSource.getCachedFeedingLog(id);
      if (feedingLog != null) {
        return Right(feedingLog);
      }
      
      // Se não encontrou local, buscar remoto
      final remoteLog = await remoteDataSource.getFeedingLogById(id);
      await localDataSource.cacheFeedingLog(remoteLog);
      return Right(remoteLog);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FeedingLog>> createFeedingLog(
    FeedingLog feedingLog,
  ) async {
    try {
      // Gerar ID temporário se não tiver
      final tempId = feedingLog.id.isEmpty ? 'temp_${_uuid.v4()}' : feedingLog.id;
      final now = DateTime.now();
      
      // Criar feeding log local com ID temporário
      final localFeedingLog = feedingLog.copyWith(
        id: tempId,
        createdAt: now,
        updatedAt: now,
      );

      // Salvar localmente primeiro
      await localDataSource.cacheFeedingLog(localFeedingLog);

      // Tentar sincronizar com API
      try {
        final remoteLog = await remoteDataSource.createFeedingLog(localFeedingLog);
        await localDataSource.cacheFeedingLog(remoteLog);
        await localDataSource.markAsSynced(remoteLog.id);
        return Right(remoteLog);
      } on ServerException catch (e) {
        // Erro do servidor - logar e retornar erro
        debugPrint('[FeedingLogsRepository] Erro ao criar feeding log no servidor: ${e.message}');
        debugPrint('[FeedingLogsRepository] FeedingLog local: $localFeedingLog');
        // Retornar erro ao invés de sucesso local
        return Left(ServerFailure('Erro ao registrar alimentação: ${e.message}'));
      } on NetworkException catch (e) {
        // Erro de rede - manter local e retornar
        debugPrint('[FeedingLogsRepository] Erro de rede ao criar feeding log: ${e.message}');
        debugPrint('[FeedingLogsRepository] FeedingLog salvo localmente com ID: ${localFeedingLog.id}');
        // Retornar mesmo assim - dados salvos localmente
        return Right(localFeedingLog);
      } catch (e, stackTrace) {
        // Erro inesperado - logar detalhes
        debugPrint('[FeedingLogsRepository] Erro inesperado ao criar feeding log: $e');
        debugPrint('[FeedingLogsRepository] Stack trace: $stackTrace');
        debugPrint('[FeedingLogsRepository] FeedingLog local: $localFeedingLog');
        return Left(ServerFailure('Erro inesperado ao registrar alimentação: ${e.toString()}'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FeedingLog>>> createFeedingLogsBatch(
    List<FeedingLog> feedingLogs,
  ) async {
    try {
      final created = await remoteDataSource.createFeedingLogsBatch(feedingLogs);
      // Salvar no cache local após criação
      for (final feedingLog in created) {
        await localDataSource.cacheFeedingLog(feedingLog);
        await localDataSource.markAsSynced(feedingLog.id);
      }
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FeedingLog>> updateFeedingLog(
    FeedingLog feedingLog,
  ) async {
    try {
      final updated = await remoteDataSource.updateFeedingLog(feedingLog);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFeedingLog(String id) async {
    try {
      await remoteDataSource.deleteFeedingLog(id);
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
  Future<Either<Failure, List<FeedingLog>>> getFeedingLogsByCat(
    String catId,
  ) async {
    try {
      final feedingLogs = await remoteDataSource.getFeedingLogs(catId: catId);
      return Right(feedingLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FeedingLog>>> getTodayFeedingLogs({
    String? householdId,
    bool forceRemote = false,
  }) async {
    try {
      // Se forçar busca remota, buscar diretamente da API
      if (forceRemote) {
        debugPrint('[FeedingLogsRepo] Buscando feeding logs remotamente (forceRemote=true)...');
        final feedingLogs = await remoteDataSource.getFeedingLogs(
          householdId: householdId,
        );
        // Salvar no cache
        await localDataSource.cacheFeedingLogs(feedingLogs);
        return Right(feedingLogs);
      }
      
      // 1. Retorna dados do banco local imediatamente (se existir)
      debugPrint('[FeedingLogsRepo] Buscando feeding logs do cache local...');
      
      // Para household, buscar todos os logs e filtrar
      List<FeedingLog> localLogs;
      if (householdId != null) {
        localLogs = await localDataSource.getCachedFeedingLogs();
        localLogs = localLogs.where((log) => log.householdId == householdId).toList();
      } else {
        localLogs = await localDataSource.getCachedFeedingLogs();
      }
      
      // Sort to show most recent first
      localLogs.sort((a, b) => b.fedAt.compareTo(a.fedAt));
      debugPrint('[FeedingLogsRepo] Retornando ${localLogs.length} feeding logs do cache local');
      
      // 2. Sincroniza com API em background (não bloqueia UI)
      _syncWithRemote(householdId: householdId);
      
      // Return all logs (sorted by most recent) so home page can show last feeding
      return Right(localLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  /// Sincroniza dados locais com remoto em background
  void _syncWithRemote({String? householdId}) {
    // Executar em background sem bloquear
    Future.microtask(() async {
      try {
        debugPrint('[FeedingLogsRepo] Iniciando sincronização em background...');
        final allFeedingLogs = await remoteDataSource.getFeedingLogs(
          householdId: householdId,
        );
        await localDataSource.cacheFeedingLogs(allFeedingLogs);
        debugPrint('[FeedingLogsRepo] Sincronização em background concluída');
      } catch (e) {
        debugPrint('[FeedingLogsRepo] Erro na sincronização em background: $e');
        // Não relançar erro - apenas logar
      }
    });
  }
}
