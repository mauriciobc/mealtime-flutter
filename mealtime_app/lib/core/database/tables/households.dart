import 'package:drift/drift.dart';

import 'profiles.dart';

@DataClassName('Household')
class Households extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get ownerId => text().references(Profiles, #id)();
  TextColumn get inviteCode => text().unique().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
