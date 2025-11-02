import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/tables/cats.dart';

@DataClassName('WeightLog')
class WeightLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  TextColumn get catId => text().references(Cats, #id)();
  RealColumn get weight => real()(); // em kg
  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

