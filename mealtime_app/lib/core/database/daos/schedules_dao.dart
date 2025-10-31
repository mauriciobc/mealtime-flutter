import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/tables/schedules.dart';

part 'schedules_dao.g.dart';

@DriftAccessor(tables: [Schedules])
class SchedulesDao extends DatabaseAccessor<AppDatabase>
    with _$SchedulesDaoMixin {
  SchedulesDao(AppDatabase db) : super(db);

  Future<List<Schedule>> getAllSchedules() =>
      (select(schedules)..where((s) => s.isDeleted.equals(false))).get();

  Stream<List<Schedule>> watchAllSchedules() =>
      (select(schedules)..where((s) => s.isDeleted.equals(false))).watch();

  Future<List<Schedule>> getSchedulesByCat(String catId) =>
      (select(schedules)
            ..where((s) => s.catId.equals(catId))
            ..where((s) => s.isDeleted.equals(false))
            ..where((s) => s.enabled.equals(true)))
          .get();

  Future<Schedule?> getScheduleById(String id) =>
      (select(schedules)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> upsertSchedule(Schedule schedule) =>
      into(schedules).insertOnConflictUpdate(schedule);

  Future<void> deleteSchedule(String id) =>
      (update(schedules)..where((s) => s.id.equals(id)))
          .write(const SchedulesCompanion(isDeleted: Value(true)));

  Future<void> markAsSynced(String id) => (update(schedules)
        ..where((s) => s.id.equals(id)))
      .write(SchedulesCompanion(
        syncedAt: Value(DateTime.now()),
      ));
}

