import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/sync/sync_service.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_remote_datasource.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_local_datasource.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';

class CatsRepositoryImpl implements CatsRepository {
  final CatsRemoteDataSource remoteDataSource;
  final CatsLocalDataSource localDataSource;
  final SyncService syncService;
  final _uuid = const Uuid();

  CatsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<Cat>>> getCats({String? householdId}) async {
    try {
      // 1. Retorna dados do banco local imediatamente (se existir)
      List<Cat> localCats;
      if (householdId != null) {
        localCats = await localDataSource.getCachedCatsByHousehold(householdId);
      } else {
        localCats = await localDataSource.getCachedCats();
      }

      // 2. Sincroniza com API em background (não bloqueia UI)
      _syncWithRemote(householdId: householdId);

      return Right(localCats);
    } catch (e) {
      debugPrint('[CatsRepository] Erro ao buscar gatos locais: $e');
      return Left(ServerFailure('Erro ao buscar gatos: ${e.toString()}'));
    }
  }

  /// Sincroniza dados locais com remoto em background
  void _syncWithRemote({String? householdId}) {
    // Executar em background sem bloquear
    Future.microtask(() async {
      try {
        final remoteCats = await remoteDataSource.getCats(householdId: householdId);
        await localDataSource.cacheCats(remoteCats);
        debugPrint('[CatsRepository] Sincronização em background concluída');
      } catch (e) {
        debugPrint('[CatsRepository] Erro na sincronização em background: $e');
        // Não relançar erro - apenas logar
      }
    });
  }

  @override
  Future<Either<Failure, Cat?>> getCatById(String id) async {
    try {
      // Usar cache local para obter gato por ID
      final cat = await localDataSource.getCachedCat(id);
      return Right(cat);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cat>> createCat(Cat cat) async {
    try {
      // 1. Gerar ID temporário se não tiver
      final tempId = cat.id.isEmpty ? 'temp_${_uuid.v4()}' : cat.id;
      final now = DateTime.now();
      
      // 2. Criar cat local com ID temporário
      final localCat = cat.copyWith(
        id: tempId,
        createdAt: now,
        updatedAt: now,
      );

      // 3. Salvar localmente primeiro
      await localDataSource.cacheCat(localCat);

      // 4. Preparar payload para sincronização
      final payload = {
        'id': localCat.id,
        'name': localCat.name,
        'breed': localCat.breed,
        'birthDate': localCat.birthDate.toIso8601String(),
        'gender': localCat.gender,
        'color': localCat.color,
        'description': localCat.description,
        'imageUrl': localCat.imageUrl,
        'currentWeight': localCat.currentWeight,
        'targetWeight': localCat.targetWeight,
        'homeId': localCat.homeId,
        'ownerId': localCat.ownerId,
        'portionSize': localCat.portionSize,
        'portionUnit': localCat.portionUnit,
        'feedingInterval': localCat.feedingInterval,
        'restrictions': localCat.restrictions,
        'createdAt': localCat.createdAt.toIso8601String(),
        'updatedAt': localCat.updatedAt.toIso8601String(),
        'isActive': localCat.isActive,
      };

      // 5. Tentar sincronizar com API
      try {
        final remoteCat = await remoteDataSource.createCat(localCat);
        // 6. Atualizar com ID real do servidor
        await localDataSource.cacheCat(remoteCat);
        await localDataSource.markAsSynced(remoteCat.id);
        return Right(remoteCat);
      } catch (e) {
        // 7. Se falhar, adicionar à fila de sincronização
        debugPrint('[CatsRepository] Erro ao criar gato no servidor: $e');
        await syncService.addToSyncQueue(
          entityType: 'cat',
          operation: 'create',
          localId: tempId,
          payload: payload,
        );
        // Retornar mesmo assim - dados salvos localmente
        return Right(localCat);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cat>> updateCat(Cat cat) async {
    try {
      final now = DateTime.now();
      final updatedCat = cat.copyWith(updatedAt: now);

      // 1. Atualizar localmente primeiro
      await localDataSource.cacheCat(updatedCat);

      // 2. Preparar payload para sincronização
      final payload = {
        'id': updatedCat.id,
        'name': updatedCat.name,
        'breed': updatedCat.breed,
        'birthDate': updatedCat.birthDate.toIso8601String(),
        'gender': updatedCat.gender,
        'color': updatedCat.color,
        'description': updatedCat.description,
        'imageUrl': updatedCat.imageUrl,
        'currentWeight': updatedCat.currentWeight,
        'targetWeight': updatedCat.targetWeight,
        'homeId': updatedCat.homeId,
        'ownerId': updatedCat.ownerId,
        'portionSize': updatedCat.portionSize,
        'portionUnit': updatedCat.portionUnit,
        'feedingInterval': updatedCat.feedingInterval,
        'restrictions': updatedCat.restrictions,
        'createdAt': updatedCat.createdAt.toIso8601String(),
        'updatedAt': updatedCat.updatedAt.toIso8601String(),
        'isActive': updatedCat.isActive,
      };

      // 3. Tentar sincronizar com API
      try {
        final remoteCat = await remoteDataSource.updateCat(updatedCat);
        await localDataSource.cacheCat(remoteCat);
        await localDataSource.markAsSynced(remoteCat.id);
        return Right(remoteCat);
      } catch (e) {
        // 4. Se falhar, adicionar à fila de sincronização
        debugPrint('[CatsRepository] Erro ao atualizar gato no servidor: $e');
        await syncService.addToSyncQueue(
          entityType: 'cat',
          operation: 'update',
          localId: updatedCat.id,
          payload: payload,
        );
        return Right(updatedCat);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCat(String catId) async {
    try {
      // 1. Marcar como deletado localmente (soft delete)
      final cat = await localDataSource.getCachedCat(catId);
      if (cat != null) {
        final deletedCat = cat.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await localDataSource.cacheCat(deletedCat);

        // 2. Preparar payload para sincronização
        final payload = {
          'id': cat.id,
          'name': cat.name,
          'birthDate': cat.birthDate.toIso8601String(),
          'homeId': cat.homeId,
          'createdAt': cat.createdAt.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        // 3. Tentar deletar na API
        try {
          await remoteDataSource.deleteCat(catId);
          // Sucesso remoto: o gato já foi marcado como inativo/deletado
          // localmente em cacheCat(deletedCat); não limpar cache global.
          return const Right(null);
        } catch (e) {
          // 4. Se falhar, adicionar à fila de sincronização
          debugPrint('[CatsRepository] Erro ao deletar gato no servidor: $e');
          await syncService.addToSyncQueue(
            entityType: 'cat',
            operation: 'delete',
            localId: catId,
            payload: payload,
          );
          return const Right(null);
        }
      } else {
        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cat>> updateCatWeight(String catId, double weight) async {
    try {
      // Buscar cat local
      final cat = await localDataSource.getCachedCat(catId);
      if (cat == null) {
        return Left(ServerFailure('Gato não encontrado'));
      }

      final updatedCat = cat.copyWith(
        currentWeight: weight,
        updatedAt: DateTime.now(),
      );

      // Usar updateCat para sincronização
      return updateCat(updatedCat);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
