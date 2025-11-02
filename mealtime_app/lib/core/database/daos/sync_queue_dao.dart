import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/tables/sync_queue.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncOperation>> getPendingOperations() =>
      (select(syncQueue)
            ..where((s) => s.isCompleted.equals(false))
            ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
          .get();

  Future<List<SyncOperation>> getPendingOperationsByEntity(
    String entityType,
  ) =>
      (select(syncQueue)
            ..where((s) => s.entityType.equals(entityType))
            ..where((s) => s.isCompleted.equals(false))
            ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
          .get();

  Future<SyncOperation?> getOperationById(int id) =>
      (select(syncQueue)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> addOperation(SyncQueueCompanion operation) =>
      into(syncQueue).insert(operation);

  Future<void> markAsCompleted(int id) =>
      (update(syncQueue)..where((s) => s.id.equals(id)))
          .write(const SyncQueueCompanion(isCompleted: Value(true)));

  Future<void> updateAttempt(
    int id,
    DateTime lastAttempt,
    int attemptCount, {
    String? errorMessage,
  }) =>
      (update(syncQueue)..where((s) => s.id.equals(id)))
          .write(SyncQueueCompanion(
            lastAttempt: Value(lastAttempt),
            attemptCount: Value(attemptCount),
            errorMessage: Value(errorMessage),
          ));

  Future<void> updateRemoteId(int id, String remoteId) =>
      (update(syncQueue)..where((s) => s.id.equals(id)))
          .write(SyncQueueCompanion(remoteId: Value(remoteId)));

  Future<void> deleteOperation(int id) =>
      (delete(syncQueue)..where((s) => s.id.equals(id))).go();

  Future<int> getPendingCount() =>
      (selectOnly(syncQueue)
            ..addColumns([syncQueue.id.count()])
            ..where(syncQueue.isCompleted.equals(false)))
          .getSingle()
          .then((row) => row.read(syncQueue.id.count()) ?? 0);
}

