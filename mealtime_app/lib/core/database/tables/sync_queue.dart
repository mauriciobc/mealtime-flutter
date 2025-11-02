import 'package:drift/drift.dart';

@DataClassName('SyncOperation')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'cat', 'feeding_log', 'schedule', etc
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get localId => text()(); // ID local/temporário
  TextColumn get remoteId => text().nullable()(); // ID do servidor
  TextColumn get payload => text()(); // JSON com dados
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get errorMessage => text().nullable()();

  List<Index> get indexes => [
    Index('idx_sync_queue_entity_type', 'entity_type'),
    Index('idx_sync_queue_is_completed', 'is_completed'),
    Index('idx_sync_queue_created_at', 'created_at'),
    Index('idx_sync_queue_local_id', 'local_id'),
  ];
}

