import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/daos/cats_dao.dart';
import 'package:mealtime_app/core/database/mappers/cat_mapper.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart' as domain;

/// Data source local para cache de gatos usando Drift
/// Persiste dados localmente e permite acesso offline
abstract class CatsLocalDataSource {
  Future<void> cacheCats(List<domain.Cat> cats);
  Future<List<domain.Cat>> getCachedCats();
  Future<List<domain.Cat>> getCachedCatsByHousehold(String householdId);
  Future<domain.Cat?> getCachedCat(String catId);
  Future<void> cacheCat(domain.Cat cat);
  Future<void> clearCache();
  Future<void> markAsSynced(String id);
  Stream<List<domain.Cat>> watchCats();
  Stream<List<domain.Cat>> watchCatsByHousehold(String householdId);
}

class CatsLocalDataSourceImpl implements CatsLocalDataSource {
  final AppDatabase database;
  late final CatsDao _catsDao;

  CatsLocalDataSourceImpl({required this.database}) {
    _catsDao = CatsDao(database);
  }

  @override
  Future<void> cacheCats(List<domain.Cat> cats) async {
    for (final cat in cats) {
      await cacheCat(cat);
    }
  }

  @override
  Future<List<domain.Cat>> getCachedCats() async {
    final driftCats = await _catsDao.getAllCats();
    return CatMapper.fromDriftCats(driftCats);
  }

  @override
  Future<List<domain.Cat>> getCachedCatsByHousehold(String householdId) async {
    final driftCats = await _catsDao.getCatsByHousehold(householdId);
    return CatMapper.fromDriftCats(driftCats);
  }

  @override
  Future<domain.Cat?> getCachedCat(String catId) async {
    final driftCat = await _catsDao.getCatById(catId);
    if (driftCat == null) return null;
    return CatMapper.fromDriftCat(driftCat);
  }

  @override
  Future<void> cacheCat(domain.Cat cat) async {
    final companion = CatMapper.toDriftCompanion(
      cat,
      syncedAt: DateTime.now(),
      version: 1,
      isDeleted: !cat.isActive,
    );
    // Usar insertOnConflictUpdate com companion
    await database.into(database.cats).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> clearCache() async {
    // Não deleta fisicamente, apenas marca como deletado
    // Para limpeza completa, seria necessário deletar todos os registros
    final allCats = await _catsDao.getAllCats();
    for (final driftCat in allCats) {
      await _catsDao.deleteCat(driftCat.id);
    }
  }

  @override
  Future<void> markAsSynced(String id) async {
    await _catsDao.markAsSynced(id);
  }

  @override
  Stream<List<domain.Cat>> watchCats() {
    return _catsDao.watchAllCats().map((driftCats) {
      return CatMapper.fromDriftCats(driftCats);
    });
  }

  @override
  Stream<List<domain.Cat>> watchCatsByHousehold(String householdId) {
    // O DAO não tem watchCatsByHousehold, então vamos criar um stream
    // que filtra os resultados do watchAllCats
    return _catsDao.watchAllCats().map((driftCats) {
      final filtered = driftCats
          .where((cat) => cat.householdId == householdId)
          .toList();
      return CatMapper.fromDriftCats(filtered);
    });
  }
}
