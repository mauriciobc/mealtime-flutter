import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mealtime_app/core/database/tables/cats.dart';
import 'package:mealtime_app/core/database/tables/feeding_logs.dart';
import 'package:mealtime_app/core/database/tables/households.dart';
import 'package:mealtime_app/core/database/tables/profiles.dart';
import 'package:mealtime_app/core/database/tables/schedules.dart';
import 'package:mealtime_app/core/database/tables/sync_queue.dart';
import 'package:mealtime_app/core/database/tables/weight_logs.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/cats_dao.dart';
import 'daos/feeding_logs_dao.dart';
import 'daos/households_dao.dart';
import 'daos/schedules_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/weight_logs_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Households,
    Cats,
    FeedingLogs,
    Schedules,
    WeightLogs,
    SyncQueue,
  ],
  daos: [
    CatsDao,
    HouseholdsDao,
    FeedingLogsDao,
    SchedulesDao,
    WeightLogsDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migração da versão 1 para 2
          // Adicionar campos de sincronização e novos campos
          await m.addColumn(cats, cats.syncedAt);
          await m.addColumn(cats, cats.version);
          await m.addColumn(cats, cats.breed);
          await m.addColumn(cats, cats.gender);
          await m.addColumn(cats, cats.color);
          await m.addColumn(cats, cats.description);
          await m.addColumn(cats, cats.imageUrl);
          await m.addColumn(cats, cats.currentWeight);
          await m.addColumn(cats, cats.targetWeight);
          await m.addColumn(cats, cats.isActive);
          await m.addColumn(cats, cats.isDeleted);
          
          await m.addColumn(households, households.syncedAt);
          await m.addColumn(households, households.version);
          await m.addColumn(households, households.address);
          await m.addColumn(households, households.isActive);
          await m.addColumn(households, households.isDeleted);
          
          await m.addColumn(profiles, profiles.createdAt);
          await m.addColumn(profiles, profiles.syncedAt);
          await m.addColumn(profiles, profiles.version);
          await m.addColumn(profiles, profiles.authId);
          await m.addColumn(profiles, profiles.householdId);
          await m.addColumn(profiles, profiles.isEmailVerified);
          
          // Criar novas tabelas
          await m.createTable(feedingLogs);
          await m.createTable(schedules);
          await m.createTable(weightLogs);
          await m.createTable(syncQueue);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
