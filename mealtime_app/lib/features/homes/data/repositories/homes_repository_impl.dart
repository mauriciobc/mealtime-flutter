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
      final homeModels = await remoteDataSource.getHomes();
      final homes = homeModels.map((model) => model.toEntity()).toList();
      await localDataSource.cacheHomes(homes);
      return homes;
    } catch (e) {
      // Fallback para dados locais em caso de erro
      return await localDataSource.getCachedHomes();
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
