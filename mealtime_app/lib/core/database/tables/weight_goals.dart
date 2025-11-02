import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/tables/cats.dart';

@DataClassName('WeightGoal')
class WeightGoals extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  TextColumn get catId => text().references(Cats, #id)();
  RealColumn get targetWeight => real()(); // em kg
  RealColumn get startWeight => real()(); // em kg
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

