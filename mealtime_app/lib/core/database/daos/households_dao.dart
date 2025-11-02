import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/tables/households.dart';

part 'households_dao.g.dart';

@DriftAccessor(tables: [Households])
class HouseholdsDao extends DatabaseAccessor<AppDatabase>
    with _$HouseholdsDaoMixin {
  HouseholdsDao(super.db);

  Future<List<Household>> getAllHouseholds() =>
      (select(households)..where((h) => h.isDeleted.equals(false))).get();

  Stream<List<Household>> watchAllHouseholds() =>
      (select(households)..where((h) => h.isDeleted.equals(false))).watch();

  Future<Household?> getHouseholdById(String id) =>
      (select(households)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<void> upsertHousehold(Household household) =>
      into(households).insertOnConflictUpdate(household);

  Future<void> deleteHousehold(String id) =>
      (update(households)..where((h) => h.id.equals(id)))
          .write(const HouseholdsCompanion(isDeleted: Value(true)));

  Future<void> markAsSynced(String id) => (update(households)
        ..where((h) => h.id.equals(id)))
      .write(HouseholdsCompanion(
        syncedAt: Value(DateTime.now()),
      ));
}

