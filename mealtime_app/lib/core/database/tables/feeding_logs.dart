import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/tables/cats.dart';
import 'package:mealtime_app/core/database/tables/households.dart';
import 'package:mealtime_app/core/database/tables/profiles.dart';

@DataClassName('FeedingLog')
class FeedingLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  TextColumn get catId => text().references(Cats, #id)();
  TextColumn get householdId => text().references(Households, #id)();
  TextColumn get mealType => text()(); // 'breakfast', 'lunch', 'dinner', 'snack'
  TextColumn get foodType => text().nullable()(); // 'Ração Seca', 'Ração Úmida', 'Sachê', 'Petisco'
  RealColumn get amount => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get fedBy => text().references(Profiles, #id)();
  DateTimeColumn get fedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
  
  List<Index> get indexes => [
    Index('idx_feeding_logs_cat_id', 'cat_id'),
    Index('idx_feeding_logs_fed_at', 'fed_at'),
    Index('idx_feeding_logs_synced_at', 'synced_at'),
  ];
}

