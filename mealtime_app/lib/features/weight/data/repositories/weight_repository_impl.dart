import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';
import 'package:mealtime_app/features/weight/data/datasources/weight_logs_local_datasource.dart';
import 'package:mealtime_app/features/weight/data/datasources/goals_local_datasource.dart';
import 'package:mealtime_app/features/weight/data/datasources/goals_remote_datasource.dart';
import 'package:mealtime_app/features/cats/data/datasources/weight_logs_remote_datasource.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightLogsRemoteDataSource weightLogsRemoteDataSource;
  final WeightLogsLocalDataSource weightLogsLocalDataSource;
  final GoalsRemoteDataSource goalsRemoteDataSource;
  final GoalsLocalDataSource goalsLocalDataSource;

  // Flags para evitar sincronizações concorrentes que causam loops
  bool _isSyncingWeightLogs = false;
  bool _isSyncingGoals = false;

  WeightRepositoryImpl({
    required this.weightLogsRemoteDataSource,
    required this.weightLogsLocalDataSource,
    required this.goalsRemoteDataSource,
    required this.goalsLocalDataSource,
  });

  @override
  Future<Either<Failure, List<WeightEntry>>> getWeightLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 1. Retorna dados do banco local imediatamente (se existir)
      debugPrint('[WeightRepository] Buscando weight logs do cache local...');
      List<WeightEntry> localLogs;
      if (catId != null) {
        localLogs = await weightLogsLocalDataSource.getCachedWeightLogsByCat(
          catId,
        );
      } else {
        localLogs = await weightLogsLocalDataSource.getCachedWeightLogs();
      }

      // Filtrar por datas se fornecidas
      if (startDate != null || endDate != null) {
        localLogs = localLogs.where((log) {
          if (startDate != null && log.measuredAt.isBefore(startDate)) {
            return false;
          }
          if (endDate != null && log.measuredAt.isAfter(endDate)) {
            return false;
          }
          return true;
        }).toList();
      }

      // 2. Sincroniza com API em background (não bloqueia UI)
      _syncWeightLogsWithRemote(catId: catId, householdId: householdId);

      debugPrint(
        '[WeightRepository] Retornando ${localLogs.length} weight logs do cache local',
      );
      return Right(localLogs);
      } catch (e) {
      debugPrint('[WeightRepository] Erro ao buscar weight logs locais: $e');
      // Se não há dados no cache, tentar API como último recurso
      try {
        debugPrint('[WeightRepository] Tentando buscar do servidor...');
        final remoteLogs = await weightLogsRemoteDataSource.getWeightLogs(
          catId: catId,
          householdId: householdId,
        );
        await weightLogsLocalDataSource.cacheWeightLogs(remoteLogs);
        return Right(remoteLogs);
      } on NetworkException catch (e) {
        debugPrint('[WeightRepository] Erro de rede: ${e.message}');
        return Left(NetworkFailure('Sem conexão com a internet. Verifique sua conexão e tente novamente.'));
      } on ServerException catch (e) {
        debugPrint('[WeightRepository] Erro do servidor: ${e.message}');
        return Left(ServerFailure('Erro no servidor: ${e.message}'));
      } on CacheException catch (e) {
        debugPrint('[WeightRepository] Erro de cache: ${e.message}');
        return Left(CacheFailure('Erro ao acessar dados locais: ${e.message}'));
      } catch (apiError) {
        debugPrint('[WeightRepository] Erro inesperado ao buscar do servidor: $apiError');
        return Left(ServerFailure('Erro inesperado ao buscar registros de peso. Tente novamente mais tarde.'));
      }
    }
  }

  /// Sincroniza dados locais com remoto em background
  void _syncWeightLogsWithRemote({String? catId, String? householdId}) {
    // Evitar múltiplas sincronizações simultâneas
    if (_isSyncingWeightLogs) {
      debugPrint('[WeightRepository] Sincronização já em andamento, ignorando...');
      debugPrint('[WeightRepository] Parâmetros da sync ignorada: catId=$catId, householdId=$householdId');
      return;
    }

    _isSyncingWeightLogs = true;
    debugPrint('[WeightRepository] 🚀 Iniciando sincronização de weight logs (catId=$catId, householdId=$householdId)');
    
    Future.microtask(() async {
      try {
        debugPrint('[WeightRepository] 📡 Chamando remote datasource...');
        final remoteLogs = await weightLogsRemoteDataSource.getWeightLogs(
          catId: catId,
          householdId: householdId,
        );
        debugPrint('[WeightRepository] ✅ Remote datasource retornou ${remoteLogs.length} registros');
        
        debugPrint('[WeightRepository] 💾 Salvando no cache local...');
        await weightLogsLocalDataSource.cacheWeightLogs(remoteLogs);
        debugPrint('[WeightRepository] ✅ Sincronização em background concluída com sucesso!');
      } on NetworkException catch (e) {
        debugPrint('[WeightRepository] ❌ Erro de rede na sincronização: ${e.message}');
        debugPrint('[WeightRepository] Stack trace: ${StackTrace.current}');
      } on ServerException catch (e) {
        debugPrint('[WeightRepository] ❌ Erro do servidor na sincronização: ${e.message}');
        debugPrint('[WeightRepository] Stack trace: ${StackTrace.current}');
      } on Exception catch (e, stackTrace) {
        debugPrint('[WeightRepository] ❌ Erro na sincronização: $e');
        debugPrint('[WeightRepository] Stack trace completo: $stackTrace');
      } catch (e, stackTrace) {
        debugPrint('[WeightRepository] ❌ Erro inesperado na sincronização: $e');
        debugPrint('[WeightRepository] Tipo do erro: ${e.runtimeType}');
        debugPrint('[WeightRepository] Stack trace completo: $stackTrace');
      } finally {
        _isSyncingWeightLogs = false;
        debugPrint('[WeightRepository] 🔓 Flag de sincronização liberada');
      }
    });
  }

  @override
  Future<Either<Failure, WeightEntry>> getWeightLogById(String id) async {
    try {
      // Tenta buscar do cache local primeiro
      final localLog = await weightLogsLocalDataSource.getCachedWeightLog(id);
      if (localLog != null) {
        return Right(localLog);
      }

      // Se não encontrou localmente, busca remoto
      // Nota: A API atual não tem endpoint GET por ID
      // Então retornamos erro ou buscamos todos e filtramos
      return Left(ServerFailure('Weight log não encontrado'));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar weight log: $e'));
    }
  }

  @override
  Future<Either<Failure, WeightEntry>> createWeightLog(
    WeightEntry weightLog,
  ) async {
    try {
      final createdLog = await weightLogsRemoteDataSource.createWeightLog(
        weightLog.catId,
        weightLog.weight,
        weightLog.measuredAt,
        notes: weightLog.notes,
      );

      // Cache local
      await weightLogsLocalDataSource.cacheWeightLog(createdLog);
      await weightLogsLocalDataSource.markAsSynced(createdLog.id);

      return Right(createdLog);
    } on NetworkException catch (e) {
      debugPrint('[WeightRepository] Erro de rede ao criar: ${e.message}');
      return Left(NetworkFailure('Sem conexão com a internet. Verifique sua conexão e tente novamente.'));
    } on ServerException catch (e) {
      debugPrint('[WeightRepository] Erro do servidor ao criar: ${e.message}');
      return Left(ServerFailure('Erro ao salvar registro: ${e.message}'));
    } on ValidationException catch (e) {
      debugPrint('[WeightRepository] Erro de validação ao criar: ${e.message}');
      return Left(ValidationFailure(e.message));
    } catch (e) {
      debugPrint('[WeightRepository] Erro inesperado ao criar: $e');
      return Left(ServerFailure('Erro inesperado ao registrar peso. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, WeightEntry>> updateWeightLog(
    WeightEntry weightLog,
  ) async {
    try {
      final updatedLog = await weightLogsRemoteDataSource.updateWeightLog(
        weightLog.id,
        weightLog.weight,
        measuredAt: weightLog.measuredAt,
        notes: weightLog.notes,
      );

      // Atualiza cache local
      await weightLogsLocalDataSource.cacheWeightLog(updatedLog);
      await weightLogsLocalDataSource.markAsSynced(updatedLog.id);

      return Right(updatedLog);
    } on NetworkException catch (e) {
      debugPrint('[WeightRepository] Erro de rede ao atualizar: ${e.message}');
      return Left(NetworkFailure('Sem conexão com a internet. Verifique sua conexão e tente novamente.'));
    } on ServerException catch (e) {
      debugPrint('[WeightRepository] Erro do servidor ao atualizar: ${e.message}');
      return Left(ServerFailure('Erro ao atualizar registro: ${e.message}'));
    } on NotFoundException catch (e) {
      debugPrint('[WeightRepository] Registro não encontrado ao atualizar: ${e.message}');
      return Left(NotFoundFailure('Registro não encontrado. Ele pode ter sido removido.'));
    } on ValidationException catch (e) {
      debugPrint('[WeightRepository] Erro de validação ao atualizar: ${e.message}');
      return Left(ValidationFailure(e.message));
    } catch (e) {
      debugPrint('[WeightRepository] Erro inesperado ao atualizar: $e');
      return Left(ServerFailure('Erro inesperado ao atualizar peso. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWeightLog(String id) async {
    try {
      await weightLogsRemoteDataSource.deleteWeightLog(id);
      // Deleta do cache local também
      // Nota: Pode ser implementado soft delete no local datasource
      return const Right(null);
    } on NetworkException catch (e) {
      debugPrint('[WeightRepository] Erro de rede ao deletar: ${e.message}');
      return Left(NetworkFailure('Sem conexão com a internet. Verifique sua conexão e tente novamente.'));
    } on ServerException catch (e) {
      debugPrint('[WeightRepository] Erro do servidor ao deletar: ${e.message}');
      return Left(ServerFailure('Erro ao remover registro: ${e.message}'));
    } on NotFoundException catch (e) {
      debugPrint('[WeightRepository] Registro não encontrado ao deletar: ${e.message}');
      return Left(NotFoundFailure('Registro não encontrado. Ele pode já ter sido removido.'));
    } catch (e) {
      debugPrint('[WeightRepository] Erro inesperado ao deletar: $e');
      return Left(ServerFailure('Erro inesperado ao remover peso. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, List<WeightEntry>>> getWeightLogsByCat(
    String catId,
  ) async {
    return getWeightLogs(catId: catId);
  }

  @override
  Future<Either<Failure, List<WeightGoal>>> getGoals({
    String? catId,
    String? householdId,
  }) async {
    try {
      // 1. Retorna dados do banco local imediatamente (se existir)
      debugPrint('[WeightRepository] Buscando goals do cache local...');
      List<WeightGoal> localGoals;
      if (catId != null) {
        localGoals = await goalsLocalDataSource.getCachedGoalsByCat(catId);
      } else {
        localGoals = await goalsLocalDataSource.getCachedGoals();
      }

      // 2. Sincroniza com API em background
      _syncGoalsWithRemote(catId: catId, householdId: householdId);

      debugPrint(
        '[WeightRepository] Retornando ${localGoals.length} goals do cache local',
      );
      return Right(localGoals);
      } catch (e) {
      debugPrint('[WeightRepository] Erro ao buscar goals locais: $e');
      try {
        debugPrint('[WeightRepository] Tentando buscar do servidor...');
        final remoteGoals = await goalsRemoteDataSource.getGoals(
          catId: catId,
          householdId: householdId,
        );
        await goalsLocalDataSource.cacheGoals(remoteGoals);
        return Right(remoteGoals);
      } on NetworkException catch (e) {
        debugPrint('[WeightRepository] Erro de rede: ${e.message}');
        return Left(NetworkFailure('Sem conexão com a internet. Verifique sua conexão e tente novamente.'));
      } on ServerException catch (e) {
        debugPrint('[WeightRepository] Erro do servidor: ${e.message}');
        return Left(ServerFailure('Erro no servidor: ${e.message}'));
      } on CacheException catch (e) {
        debugPrint('[WeightRepository] Erro de cache: ${e.message}');
        return Left(CacheFailure('Erro ao acessar dados locais: ${e.message}'));
      } catch (apiError) {
        debugPrint('[WeightRepository] Erro inesperado ao buscar do servidor: $apiError');
        return Left(ServerFailure('Erro inesperado ao buscar metas. Tente novamente mais tarde.'));
      }
    }
  }

  /// Sincroniza goals locais com remoto em background
  void _syncGoalsWithRemote({String? catId, String? householdId}) {
    // Evitar múltiplas sincronizações simultâneas
    if (_isSyncingGoals) {
      debugPrint('[WeightRepository] Sincronização de goals já em andamento, ignorando...');
      debugPrint('[WeightRepository] Parâmetros da sync ignorada: catId=$catId, householdId=$householdId');
      return;
    }

    _isSyncingGoals = true;
    debugPrint('[WeightRepository] 🚀 Iniciando sincronização de goals (catId=$catId, householdId=$householdId)');
    
    Future.microtask(() async {
      try {
        debugPrint('[WeightRepository] 📡 Chamando remote datasource de goals...');
        final remoteGoals = await goalsRemoteDataSource.getGoals(
          catId: catId,
          householdId: householdId,
        );
        debugPrint('[WeightRepository] ✅ Remote datasource retornou ${remoteGoals.length} goals');
        
        debugPrint('[WeightRepository] 💾 Salvando goals no cache local...');
        await goalsLocalDataSource.cacheGoals(remoteGoals);
        debugPrint('[WeightRepository] ✅ Sincronização de goals concluída com sucesso!');
      } on NetworkException catch (e) {
        debugPrint('[WeightRepository] ❌ Erro de rede na sincronização de goals: ${e.message}');
        debugPrint('[WeightRepository] Stack trace: ${StackTrace.current}');
      } on ServerException catch (e) {
        debugPrint('[WeightRepository] ❌ Erro do servidor na sincronização de goals: ${e.message}');
        debugPrint('[WeightRepository] Stack trace: ${StackTrace.current}');
      } on Exception catch (e, stackTrace) {
        debugPrint('[WeightRepository] ❌ Erro na sincronização de goals: $e');
        debugPrint('[WeightRepository] Stack trace completo: $stackTrace');
      } catch (e, stackTrace) {
        debugPrint('[WeightRepository] ❌ Erro inesperado na sincronização de goals: $e');
        debugPrint('[WeightRepository] Tipo do erro: ${e.runtimeType}');
        debugPrint('[WeightRepository] Stack trace completo: $stackTrace');
      } finally {
        _isSyncingGoals = false;
        debugPrint('[WeightRepository] 🔓 Flag de sincronização de goals liberada');
      }
    });
  }

  @override
  Future<Either<Failure, WeightGoal>> getGoalById(String id) async {
    try {
      final localGoal = await goalsLocalDataSource.getCachedGoal(id);
      if (localGoal != null) {
        return Right(localGoal);
      }
      return Left(ServerFailure('Goal não encontrado'));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar goal: $e'));
    }
  }

  @override
  Future<Either<Failure, WeightGoal?>> getActiveGoalByCat(String catId) async {
    try {
      final localGoal = await goalsLocalDataSource.getActiveGoalByCat(catId);
      return Right(localGoal);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar goal ativo: $e'));
    }
  }

  @override
  Future<Either<Failure, WeightGoal>> createGoal(WeightGoal goal) async {
    try {
      final createdGoal = await goalsRemoteDataSource.createGoal(
        goal.catId,
        goal.targetWeight,
        goal.targetDate,
        notes: goal.notes,
        startWeight: goal.startWeight,
        startDate: goal.startDate,
      );

      // Cache local
      await goalsLocalDataSource.cacheGoal(createdGoal);

      return Right(createdGoal);
    } on NetworkException catch (e) {
      debugPrint('[WeightRepository] Erro de rede ao criar meta: ${e.message}');
      return Left(NetworkFailure('Sem conexão com a internet. Verifique sua conexão e tente novamente.'));
    } on ServerException catch (e) {
      debugPrint('[WeightRepository] Erro do servidor ao criar meta: ${e.message}');
      return Left(ServerFailure('Erro ao criar meta: ${e.message}'));
    } on ValidationException catch (e) {
      debugPrint('[WeightRepository] Erro de validação ao criar meta: ${e.message}');
      return Left(ValidationFailure(e.message));
    } catch (e) {
      debugPrint('[WeightRepository] Erro inesperado ao criar meta: $e');
      return Left(ServerFailure('Erro inesperado ao criar meta. Tente novamente.'));
    }
  }
}

