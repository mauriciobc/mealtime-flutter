import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/tables/cats.dart';

part 'cats_dao.g.dart';

@DriftAccessor(tables: [Cats])
class CatsDao extends DatabaseAccessor<AppDatabase> with _$CatsDaoMixin {
  CatsDao(super.db);

  Future<List<Cat>> getAllCats() =>
      (select(cats)..where((c) => c.isDeleted.equals(false))).get();

  Stream<List<Cat>> watchAllCats() =>
      (select(cats)..where((c) => c.isDeleted.equals(false))).watch();

  Future<List<Cat>> getCatsByHousehold(String householdId) =>
      (select(cats)
            ..where((c) => c.householdId.equals(householdId))
            ..where((c) => c.isDeleted.equals(false))
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();

  Future<Cat?> getCatById(String id) =>
      (select(cats)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<void> upsertCat(Cat cat) =>
      into(cats).insertOnConflictUpdate(cat);

  Future<void> deleteCat(String id) =>
      (update(cats)..where((c) => c.id.equals(id)))
          .write(const CatsCompanion(isDeleted: Value(true)));

  Future<void> markAsSynced(String id) => (update(cats)
        ..where((c) => c.id.equals(id)))
      .write(CatsCompanion(
        syncedAt: Value(DateTime.now()),
      ));
}
