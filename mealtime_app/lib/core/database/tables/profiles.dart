import 'package:drift/drift.dart';

@DataClassName('Profile')
class Profiles extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  TextColumn get username => text().unique().nullable()();
  TextColumn get fullName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get timezone => text().nullable()();
  TextColumn get authId => text().nullable()();
  TextColumn get householdId => text().nullable()();
  BoolColumn get isEmailVerified => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
