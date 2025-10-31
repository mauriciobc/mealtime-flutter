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
      debugPrint('[HomesRepository] Buscando households do servidor...');
      final homeModels = await remoteDataSource.getHomes();
      debugPrint('[HomesRepository] Recebidos ${homeModels.length} households do servidor');
      
      final homes = homeModels.map((model) => model.toEntity()).toList();
      await localDataSource.cacheHomes(homes);
      debugPrint('[HomesRepository] Households armazenados em cache local');
      
      return homes;
    } catch (e, stackTrace) {
      debugPrint('[HomesRepository] Erro ao buscar households do servidor: $e');
      debugPrint('[HomesRepository] Stack trace: $stackTrace');
      
      // Tentar buscar dados do cache local
      try {
        final cachedHomes = await localDataSource.getCachedHomes();
        if (cachedHomes.isNotEmpty) {
          debugPrint('[HomesRepository] Retornando ${cachedHomes.length} households do cache local');
          return cachedHomes;
        }
      } catch (cacheError) {
        debugPrint('[HomesRepository] Erro ao buscar cache local: $cacheError');
      }
      
      // Se não há dados no cache, relançar a exceção para que o erro seja mostrado ao usuário
      debugPrint('[HomesRepository] Nenhum dado encontrado, relançando exceção...');
      rethrow;
    }
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
