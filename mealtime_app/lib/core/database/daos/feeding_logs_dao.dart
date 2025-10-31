import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/tables/feeding_logs.dart';

part 'feeding_logs_dao.g.dart';

@DriftAccessor(tables: [FeedingLogs])
class FeedingLogsDao extends DatabaseAccessor<AppDatabase>
    with _$FeedingLogsDaoMixin {
  FeedingLogsDao(AppDatabase db) : super(db);

  Future<List<FeedingLog>> getAllFeedingLogs() =>
      (select(feedingLogs)..where((f) => f.isDeleted.equals(false))).get();

  Stream<List<FeedingLog>> watchAllFeedingLogs() =>
      (select(feedingLogs)..where((f) => f.isDeleted.equals(false))).watch();

  Future<List<FeedingLog>> getFeedingLogsByCat(String catId) =>
      (select(feedingLogs)
            ..where((f) => f.catId.equals(catId))
            ..where((f) => f.isDeleted.equals(false))
            ..orderBy([(f) => OrderingTerm.desc(f.fedAt)]))
          .get();

  Future<List<FeedingLog>> getTodayFeedingLogs() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(feedingLogs)
          ..where((f) => f.fedAt.isBiggerOrEqualValue(startOfDay))
          ..where((f) => f.fedAt.isSmallerThanValue(endOfDay))
          ..where((f) => f.isDeleted.equals(false))
          ..orderBy([(f) => OrderingTerm.desc(f.fedAt)]))
        .get();
  }

  Future<FeedingLog?> getFeedingLogById(String id) =>
      (select(feedingLogs)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<void> upsertFeedingLog(FeedingLog feedingLog) =>
      into(feedingLogs).insertOnConflictUpdate(feedingLog);

  Future<void> deleteFeedingLog(String id) =>
      (update(feedingLogs)..where((f) => f.id.equals(id)))
          .write(const FeedingLogsCompanion(isDeleted: Value(true)));

  Future<void> markAsSynced(String id) => (update(feedingLogs)
        ..where((f) => f.id.equals(id)))
      .write(FeedingLogsCompanion(
        syncedAt: Value(DateTime.now()),
      ));
}

