import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/tables/cats.dart';
import 'package:mealtime_app/core/database/tables/feeding_logs.dart';
import 'package:mealtime_app/core/database/tables/households.dart';
import 'package:mealtime_app/core/database/tables/profiles.dart';
import 'package:mealtime_app/core/database/tables/schedules.dart';
import 'package:mealtime_app/core/database/tables/sync_queue.dart';
import 'package:mealtime_app/core/database/tables/weight_logs.dart';
import 'package:mealtime_app/core/database/tables/weight_goals.dart';
import 'package:mealtime_app/core/database/database_connection.dart';

import 'daos/cats_dao.dart';
import 'daos/feeding_logs_dao.dart';
import 'daos/households_dao.dart';
import 'daos/schedules_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/weight_logs_dao.dart';
import 'daos/weight_goals_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Households,
    Cats,
    FeedingLogs,
    Schedules,
    WeightLogs,
    WeightGoals,
    SyncQueue,
  ],
  daos: [
    CatsDao,
    HouseholdsDao,
    FeedingLogsDao,
    SchedulesDao,
    WeightLogsDao,
    WeightGoalsDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(createDatabaseConnection());

  /// Construtor para testes com executor in-memory (ex: NativeDatabase.memory()).
  AppDatabase.withExecutor(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 5;

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
        if (from < 3) {
          // Migração da versão 2 para 3
          // Adicionar tabela de weight goals
          await m.createTable(weightGoals);
        }
        if (from < 4) {
          // Migração da versão 3 para 4
          // Adicionar campo food_type na tabela feeding_logs
          await m.addColumn(feedingLogs, feedingLogs.foodType);
        }
        if (from < 5) {
          // Migração da versão 4 para 5
          // Adicionar campo website na tabela profiles
          await m.addColumn(profiles, profiles.website);
        }
      },
    );
  }
}

