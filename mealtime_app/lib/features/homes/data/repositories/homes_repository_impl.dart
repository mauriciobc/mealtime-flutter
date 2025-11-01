import 'package:flutter/foundation.dart';
import 'package:mealtime_app/features/homes/data/datasources/homes_remote_datasource.dart';
import 'package:mealtime_app/features/homes/data/datasources/homes_local_datasource.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class HomesRepositoryImpl implements HomesRepository {
  final HomesRemoteDataSource remoteDataSource;
  final HomesLocalDataSource localDataSource;

  HomesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Home>> getHomes() async {
    try {
      // 1. Retorna dados do banco local imediatamente (se existir)
      debugPrint('[HomesRepository] Buscando households do cache local...');
      final localHomes = await localDataSource.getCachedHomes();
      
      // 2. Sincroniza com API em background (não bloqueia UI)
      _syncWithRemote();
      
      debugPrint('[HomesRepository] Retornando ${localHomes.length} households do cache local');
      return localHomes;
    } catch (e) {
      debugPrint('[HomesRepository] Erro ao buscar households locais: $e');
      // Se não há dados no cache, tentar API como último recurso
      try {
        debugPrint('[HomesRepository] Tentando buscar do servidor...');
        final homeModels = await remoteDataSource.getHomes();
        final homes = homeModels.map((model) => model.toEntity()).toList();
        await localDataSource.cacheHomes(homes);
        return homes;
      } catch (apiError) {
        debugPrint('[HomesRepository] Erro ao buscar do servidor: $apiError');
        // Se ainda assim falhar, retornar lista vazia ao invés de quebrar
        return [];
      }
    }
  }

  /// Sincroniza dados locais com remoto em background
  void _syncWithRemote() {
    // Executar em background sem bloquear
    Future.microtask(() async {
      try {
        debugPrint('[HomesRepository] Iniciando sincronização em background...');
        final homeModels = await remoteDataSource.getHomes();
        final homes = homeModels.map((model) => model.toEntity()).toList();
        await localDataSource.cacheHomes(homes);
        debugPrint('[HomesRepository] Sincronização em background concluída');
      } catch (e) {
        debugPrint('[HomesRepository] Erro na sincronização em background: $e');
        // Não relançar erro - apenas logar
      }
    });
  }

  @override
  Future<Home> createHome({required String name, String? description}) async {
    final homeModel = await remoteDataSource.createHome(
      name: name,
      description: description,
    );
    final home = homeModel.toEntity();
    await localDataSource.cacheHome(home);
    return home;
  }

  @override
  Future<Home> updateHome({
    required String id,
    required String name,
    String? description,
  }) async {
    final homeModel = await remoteDataSource.updateHome(
      id: id,
      name: name,
      description: description,
    );
    final home = homeModel.toEntity();
    await localDataSource.cacheHome(home);
    return home;
  }

  @override
  Future<void> deleteHome(String id) async {
    await remoteDataSource.deleteHome(id);
    await localDataSource.removeCachedHome(id);
  }

  @override
  Future<void> setActiveHome(String id) async {
    await remoteDataSource.setActiveHome(id);
    await localDataSource.setActiveHome(id);
  }

  @override
  Future<Home?> getActiveHome() async {
    return await localDataSource.getActiveHome();
  }
}
