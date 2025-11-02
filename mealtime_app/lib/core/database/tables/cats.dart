import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/tables/profiles.dart';
import 'households.dart';

@DataClassName('Cat')
class Cats extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  TextColumn get name => text()();
  TextColumn get breed => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().withLength(max: 2048).nullable()();
  RealColumn get currentWeight => real().nullable()();
  RealColumn get targetWeight => real().nullable()();
  TextColumn get householdId => text().references(Households, #id)();
  TextColumn get ownerId => text().references(Profiles, #id).nullable()();
  RealColumn get portionSize => real().nullable()();
  TextColumn get portionUnit => text().withLength(max: 255).nullable()();
  TextColumn get photoUrl => text().withLength(max: 2048).nullable()();
  TextColumn get restrictions => text().nullable()();
  IntColumn get feedingInterval => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
  
  List<Index> get indexes => [
    Index('idx_cats_household_id', 'household_id'),
    Index('idx_cats_created_at', 'created_at'),
    Index('idx_cats_synced_at', 'synced_at'),
  ];
}
