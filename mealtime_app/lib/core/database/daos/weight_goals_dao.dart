import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/tables/weight_goals.dart';

part 'weight_goals_dao.g.dart';

@DriftAccessor(tables: [WeightGoals])
class WeightGoalsDao extends DatabaseAccessor<AppDatabase>
    with _$WeightGoalsDaoMixin {
  WeightGoalsDao(super.db);

  Future<List<WeightGoal>> getAllWeightGoals() =>
      (select(weightGoals)..where((w) => w.isDeleted.equals(false))).get();

  Stream<List<WeightGoal>> watchAllWeightGoals() =>
      (select(weightGoals)..where((w) => w.isDeleted.equals(false))).watch();

  Future<List<WeightGoal>> getWeightGoalsByCat(String catId) =>
      (select(weightGoals)
            ..where((w) => w.catId.equals(catId))
            ..where((w) => w.isDeleted.equals(false))
            ..orderBy([(w) => OrderingTerm.desc(w.createdAt)]))
          .get();

  Future<WeightGoal?> getWeightGoalById(String id) =>
      (select(weightGoals)..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<WeightGoal?> getActiveWeightGoalByCat(String catId) =>
      (select(weightGoals)
            ..where((w) => w.catId.equals(catId))
            ..where((w) => w.isDeleted.equals(false))
            ..where((w) => w.endDate.isNull())
            ..orderBy([(w) => OrderingTerm.desc(w.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertWeightGoal(WeightGoal weightGoal) =>
      into(weightGoals).insertOnConflictUpdate(weightGoal);

  Future<void> deleteWeightGoal(String id) =>
      (update(weightGoals)..where((w) => w.id.equals(id)))
          .write(const WeightGoalsCompanion(isDeleted: Value(true)));

  Future<void> markAsSynced(String id) => (update(weightGoals)
        ..where((w) => w.id.equals(id)))
      .write(WeightGoalsCompanion(
        syncedAt: Value(DateTime.now()),
      ));
}

