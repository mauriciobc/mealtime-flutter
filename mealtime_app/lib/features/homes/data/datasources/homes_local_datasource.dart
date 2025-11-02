import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/daos/households_dao.dart';
import 'package:mealtime_app/core/database/mappers/home_mapper.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart' as domain;

abstract class HomesLocalDataSource {
  Future<List<domain.Home>> getCachedHomes();
  Future<void> cacheHomes(List<domain.Home> homes);
  Future<void> cacheHome(domain.Home home);
  Future<void> removeCachedHome(String id);
  Future<void> setActiveHome(String id);
  Future<domain.Home?> getActiveHome();
  Future<void> markAsSynced(String id);
  Stream<List<domain.Home>> watchHomes();
}

class HomesLocalDataSourceImpl implements HomesLocalDataSource {
  final AppDatabase database;
  final SharedPreferences sharedPreferences;
  late final HouseholdsDao _householdsDao;
  static const String _activeHomeKey = 'active_home_id';

  HomesLocalDataSourceImpl({
    required this.database,
    required this.sharedPreferences,
  }) {
    _householdsDao = HouseholdsDao(database);
  }

  @override
  Future<List<domain.Home>> getCachedHomes() async {
    final driftHomes = await _householdsDao.getAllHouseholds();
    return HomeMapper.fromDriftHouseholds(driftHomes);
  }

  @override
  Future<void> cacheHomes(List<domain.Home> homes) async {
    for (final home in homes) {
      await cacheHome(home);
    }
  }

  @override
  Future<void> cacheHome(domain.Home home) async {
    final companion = HomeMapper.toDriftCompanion(
      home,
      syncedAt: DateTime.now(),
      version: 1,
      isDeleted: false,
    );
    await database.into(database.households).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> removeCachedHome(String id) async {
    await _householdsDao.deleteHousehold(id);
  }

  @override
  Future<void> setActiveHome(String id) async {
    await sharedPreferences.setString(_activeHomeKey, id);
  }

  @override
  Future<domain.Home?> getActiveHome() async {
    final activeHomeId = sharedPreferences.getString(_activeHomeKey);
    if (activeHomeId == null) return null;

    final driftHome = await _householdsDao.getHouseholdById(activeHomeId);
    if (driftHome == null) return null;
    return HomeMapper.fromDriftHousehold(driftHome);
  }

  @override
  Future<void> markAsSynced(String id) async {
    await _householdsDao.markAsSynced(id);
  }

  @override
  Stream<List<domain.Home>> watchHomes() {
    return _householdsDao.watchAllHouseholds().map((driftHomes) {
      return HomeMapper.fromDriftHouseholds(driftHomes);
    });
  }
}
