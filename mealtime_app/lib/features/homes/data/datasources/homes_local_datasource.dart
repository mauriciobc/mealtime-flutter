import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealtime_app/features/homes/data/models/home_model.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';

abstract class HomesLocalDataSource {
  Future<List<Home>> getCachedHomes();
  Future<void> cacheHomes(List<Home> homes);
  Future<void> cacheHome(Home home);
  Future<void> removeCachedHome(String id);
  Future<void> setActiveHome(String id);
  Future<Home?> getActiveHome();
}

class HomesLocalDataSourceImpl implements HomesLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _homesKey = 'cached_homes';
  static const String _activeHomeKey = 'active_home_id';

  HomesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Home>> getCachedHomes() async {
    final homesJson = sharedPreferences.getStringList(_homesKey) ?? [];
    return homesJson
        .map(
          (json) => HomeModel.fromJson(
            Map<String, dynamic>.from(
              json.split(',').fold({}, (map, item) {
                final parts = item.split(':');
                if (parts.length == 2) {
                  map[parts[0]] = parts[1];
                }
                return map;
              }),
            ),
          ),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> cacheHomes(List<Home> homes) async {
    final homesJson = homes
        .map((home) => HomeModel.fromEntity(home).toJson().toString())
        .toList();
    await sharedPreferences.setStringList(_homesKey, homesJson);
  }

  @override
  Future<void> cacheHome(Home home) async {
    final cachedHomes = await getCachedHomes();
    final existingIndex = cachedHomes.indexWhere((h) => h.id == home.id);

    if (existingIndex != -1) {
      cachedHomes[existingIndex] = home;
    } else {
      cachedHomes.add(home);
    }

    await cacheHomes(cachedHomes);
  }

  @override
  Future<void> removeCachedHome(String id) async {
    final cachedHomes = await getCachedHomes();
    cachedHomes.removeWhere((home) => home.id == id);
    await cacheHomes(cachedHomes);
  }

  @override
  Future<void> setActiveHome(String id) async {
    await sharedPreferences.setString(_activeHomeKey, id);
  }

  @override
  Future<Home?> getActiveHome() async {
    final activeHomeId = sharedPreferences.getString(_activeHomeKey);
    if (activeHomeId == null) return null;

    final cachedHomes = await getCachedHomes();
    try {
      return cachedHomes.firstWhere((home) => home.id == activeHomeId);
    } catch (e) {
      return null;
    }
  }
}
