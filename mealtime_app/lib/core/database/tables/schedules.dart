import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/tables/cats.dart';

@DataClassName('Schedule')
class Schedules extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  TextColumn get catId => text().references(Cats, #id)();
  TextColumn get type => text()(); // 'interval' ou 'fixedTime'
  IntColumn get interval => integer().nullable()(); // minutos entre alimentações
  TextColumn get times => text()(); // JSON array de horários HH:MM
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

