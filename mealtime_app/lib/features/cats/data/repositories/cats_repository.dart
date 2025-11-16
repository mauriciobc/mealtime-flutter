import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/app_database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cats_repository.g.dart';

class CatsRepository {
  final AppDatabase _db;

  CatsRepository(this._db);

  Stream<List<Cat>> watchAllCats() => _db.catsDao.watchAllCats();

  Future<void> upsertCat(Cat cat) => _db.catsDao.upsertCat(cat);

  Future<void> deleteCat(String id) => _db.catsDao.deleteCat(id);
}

@Riverpod(keepAlive: true)
CatsRepository catsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CatsRepository(db);
}
