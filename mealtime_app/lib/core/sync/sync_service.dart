import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/daos/sync_queue_dao.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_remote_datasource.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_local_datasource.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart' as domain;

/// Serviço de sincronização que processa operações pendentes na fila
/// Sincroniza dados locais com o servidor quando há conexão
class SyncService {
  final AppDatabase database;
  final Dio dio;
  final CatsRemoteDataSource catsRemoteDataSource;
  final CatsLocalDataSource catsLocalDataSource;
  final SyncQueueDao syncQueueDao;

  Timer? _syncTimer;
  bool _isSyncing = false;
  final int maxAttempts = 5;
  final Duration syncInterval = const Duration(minutes: 5);

  SyncService({
    required this.database,
    required this.dio,
    required this.catsRemoteDataSource,
    required this.catsLocalDataSource,
  }) : syncQueueDao = SyncQueueDao(database);

  /// Inicia o serviço de sincronização periódica
  void startPeriodicSync() {
    if (_syncTimer != null) {
      return; // Já está rodando
    }

    _syncTimer = Timer.periodic(syncInterval, (_) {
      syncPendingOperations();
    });

    // Sincronizar imediatamente ao iniciar
    syncPendingOperations();
  }

  /// Para o serviço de sincronização periódica
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Verifica se há conexão com a internet
  Future<bool> checkConnectivity() async {
    try {
      // Tentar fazer uma requisição simples para verificar conectividade
      // Usar um endpoint que sempre existe (ou retorna 404, que também indica conectividade)
      await dio.get(
        '/',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      ).timeout(const Duration(seconds: 5));

      // Qualquer resposta (até 404) indica que há conectividade
      // Ignorar o response, apenas verificar que não houve exceção
      return true;
    } catch (e) {
      debugPrint('[SyncService] Sem conectividade: $e');
      return false;
    }
  }

  /// Adiciona uma operação à fila de sincronização
  Future<int> addToSyncQueue({
    required String entityType,
    required String operation,
    required String localId,
    required Map<String, dynamic> payload,
  }) async {
    final companion = SyncQueueCompanion(
      entityType: Value(entityType),
      operation: Value(operation),
      localId: Value(localId),
      payload: Value(jsonEncode(payload)),
      createdAt: Value(DateTime.now()),
      attemptCount: const Value(0),
      isCompleted: const Value(false),
    );

    return await syncQueueDao.addOperation(companion);
  }

  /// Processa todas as operações pendentes na fila
  Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      debugPrint('[SyncService] Sincronização já em andamento');
      return;
    }

    // Verificar conectividade
    final hasConnection = await checkConnectivity();
    if (!hasConnection) {
      debugPrint('[SyncService] Sem conexão, pulando sincronização');
      return;
    }

    _isSyncing = true;
    debugPrint('[SyncService] Iniciando sincronização...');

    try {
      final pendingOps = await syncQueueDao.getPendingOperations();

      if (pendingOps.isEmpty) {
        debugPrint('[SyncService] Nenhuma operação pendente');
        return;
      }

      debugPrint('[SyncService] Processando ${pendingOps.length} operações');

      for (final operation in pendingOps) {
        // Limitar tentativas
        if (operation.attemptCount >= maxAttempts) {
          debugPrint(
            '[SyncService] Operação $operation atingiu limite de tentativas',
          );
          continue;
        }

        try {
          await _processOperation(operation);
        } catch (e) {
          debugPrint('[SyncService] Erro ao processar operação: $e');
          await _handleOperationError(operation, e.toString());
        }
      }
    } catch (e) {
      debugPrint('[SyncService] Erro geral na sincronização: $e');
    } finally {
      _isSyncing = false;
      debugPrint('[SyncService] Sincronização concluída');
    }
  }

  /// Processa uma operação específica
  Future<void> _processOperation(SyncOperation operation) async {
    debugPrint(
      '[SyncService] Processando: ${operation.entityType}.${operation.operation} '
      '(${operation.localId})',
    );

    try {
      switch (operation.entityType) {
        case 'cat':
          await _syncCatOperation(operation);
          break;
        case 'household':
          await _syncHouseholdOperation(operation);
          break;
        case 'feeding_log':
          await _syncFeedingLogOperation(operation);
          break;
        case 'schedule':
          await _syncScheduleOperation(operation);
          break;
        case 'weight_log':
          await _syncWeightLogOperation(operation);
          break;
        default:
          debugPrint(
            '[SyncService] Tipo de entidade desconhecido: ${operation.entityType}',
          );
      }

      // Marcar como concluída
      await syncQueueDao.markAsCompleted(operation.id);
      debugPrint('[SyncService] Operação ${operation.id} concluída');
    } catch (e) {
      rethrow;
    }
  }

  /// Sincroniza operações relacionadas a gatos
  Future<void> _syncCatOperation(SyncOperation operation) async {
    final payload = jsonDecode(operation.payload) as Map<String, dynamic>;

    switch (operation.operation) {
      case 'create':
        final catData = payload;
        final cat = domain.Cat(
          id: operation.localId,
          name: catData['name'] as String,
          breed: catData['breed'] as String?,
          birthDate: DateTime.parse(catData['birthDate'] as String),
          gender: catData['gender'] as String?,
          color: catData['color'] as String?,
          description: catData['description'] as String?,
          imageUrl: catData['imageUrl'] as String?,
          currentWeight: (catData['currentWeight'] as num?)?.toDouble(),
          targetWeight: (catData['targetWeight'] as num?)?.toDouble(),
          homeId: catData['homeId'] as String,
          ownerId: catData['ownerId'] as String?,
          portionSize: (catData['portionSize'] as num?)?.toDouble(),
          portionUnit: catData['portionUnit'] as String?,
          feedingInterval: catData['feedingInterval'] as int?,
          restrictions: catData['restrictions'] as String?,
          createdAt: DateTime.parse(catData['createdAt'] as String),
          updatedAt: DateTime.parse(catData['updatedAt'] as String),
          isActive: catData['isActive'] as bool? ?? true,
        );

        final createdCat = await catsRemoteDataSource.createCat(cat);
        await catsLocalDataSource.cacheCat(createdCat);
        await catsLocalDataSource.markAsSynced(createdCat.id);

        // Atualizar ID remoto na fila se necessário
        if (operation.localId != createdCat.id) {
          await syncQueueDao.updateRemoteId(operation.id, createdCat.id);
        }

        break;

      case 'update':
        // Similar ao create, mas usando updateCat
        final catData = payload;
        final cat = domain.Cat(
          id: operation.localId,
          name: catData['name'] as String,
          breed: catData['breed'] as String?,
          birthDate: DateTime.parse(catData['birthDate'] as String),
          gender: catData['gender'] as String?,
          color: catData['color'] as String?,
          description: catData['description'] as String?,
          imageUrl: catData['imageUrl'] as String?,
          currentWeight: (catData['currentWeight'] as num?)?.toDouble(),
          targetWeight: (catData['targetWeight'] as num?)?.toDouble(),
          homeId: catData['homeId'] as String,
          ownerId: catData['ownerId'] as String?,
          portionSize: (catData['portionSize'] as num?)?.toDouble(),
          portionUnit: catData['portionUnit'] as String?,
          feedingInterval: catData['feedingInterval'] as int?,
          restrictions: catData['restrictions'] as String?,
          createdAt: DateTime.parse(catData['createdAt'] as String),
          updatedAt: DateTime.parse(catData['updatedAt'] as String),
          isActive: catData['isActive'] as bool? ?? true,
        );

        final updatedCat = await catsRemoteDataSource.updateCat(cat);
        await catsLocalDataSource.cacheCat(updatedCat);
        await catsLocalDataSource.markAsSynced(updatedCat.id);
        break;

      case 'delete':
        await catsRemoteDataSource.deleteCat(operation.localId);
        // Remover do cache local se necessário
        break;

      default:
        throw Exception('Operação desconhecida: ${operation.operation}');
    }
  }

  /// Sincroniza operações relacionadas a households
  Future<void> _syncHouseholdOperation(SyncOperation operation) async {
    // TODO: Implementar quando HomesRemoteDataSource estiver disponível
    debugPrint('[SyncService] Sync de household não implementado ainda');
  }

  /// Sincroniza operações relacionadas a feeding logs
  Future<void> _syncFeedingLogOperation(SyncOperation operation) async {
    // TODO: Implementar quando FeedingLogsRemoteDataSource estiver disponível
    debugPrint('[SyncService] Sync de feeding log não implementado ainda');
  }

  /// Sincroniza operações relacionadas a schedules
  Future<void> _syncScheduleOperation(SyncOperation operation) async {
    // TODO: Implementar quando SchedulesRemoteDataSource estiver disponível
    debugPrint('[SyncService] Sync de schedule não implementado ainda');
  }

  /// Sincroniza operações relacionadas a weight logs
  Future<void> _syncWeightLogOperation(SyncOperation operation) async {
    // TODO: Implementar quando WeightLogsRemoteDataSource estiver disponível
    debugPrint('[SyncService] Sync de weight log não implementado ainda');
  }

  /// Trata erros durante o processamento de operações
  Future<void> _handleOperationError(
    SyncOperation operation,
    String errorMessage,
  ) async {
    final newAttemptCount = operation.attemptCount + 1;

      await syncQueueDao.updateAttempt(
        operation.id,
        DateTime.now(),
        newAttemptCount,
        errorMessage: errorMessage,
      );

    // Se excedeu tentativas, manter na fila mas não tentar mais
    if (newAttemptCount >= maxAttempts) {
      debugPrint(
        '[SyncService] Operação ${operation.id} excedeu tentativas máximas',
      );
    }
  }

  /// Retorna o número de operações pendentes
  Future<int> getPendingCount() => syncQueueDao.getPendingCount();

  /// Força sincronização imediata (útil para pull-to-refresh)
  Future<void> forceSync() => syncPendingOperations();

  /// Limpa operações concluídas antigas (mais de 7 dias)
  Future<void> cleanCompletedOperations() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final allOps = await syncQueueDao.getPendingOperations();
    // Como não temos método direto, vamos filtrar e deletar manualmente
    // Isso pode ser otimizado depois
    for (final op in allOps) {
      if (op.isCompleted && op.createdAt.isBefore(sevenDaysAgo)) {
        await syncQueueDao.deleteOperation(op.id);
      }
    }
  }
}

