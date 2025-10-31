import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/tables/weight_logs.dart';

part 'weight_logs_dao.g.dart';

@DriftAccessor(tables: [WeightLogs])
class WeightLogsDao extends DatabaseAccessor<AppDatabase>
    with _$WeightLogsDaoMixin {
  WeightLogsDao(AppDatabase db) : super(db);

  Future<List<WeightLog>> getAllWeightLogs() =>
      (select(weightLogs)..where((w) => w.isDeleted.equals(false))).get();

  Stream<List<WeightLog>> watchAllWeightLogs() =>
      (select(weightLogs)..where((w) => w.isDeleted.equals(false))).watch();

  Future<List<WeightLog>> getWeightLogsByCat(String catId) =>
      (select(weightLogs)
            ..where((w) => w.catId.equals(catId))
            ..where((w) => w.isDeleted.equals(false))
            ..orderBy([(w) => OrderingTerm.desc(w.measuredAt)]))
          .get();

  Future<WeightLog?> getWeightLogById(String id) =>
      (select(weightLogs)..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<void> upsertWeightLog(WeightLog weightLog) =>
      into(weightLogs).insertOnConflictUpdate(weightLog);

  Future<void> deleteWeightLog(String id) =>
      (update(weightLogs)..where((w) => w.id.equals(id)))
          .write(const WeightLogsCompanion(isDeleted: Value(true)));

  Future<void> markAsSynced(String id) => (update(weightLogs)
        ..where((w) => w.id.equals(id)))
      .write(WeightLogsCompanion(
        syncedAt: Value(DateTime.now()),
      ));
}

