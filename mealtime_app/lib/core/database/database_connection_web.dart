// TODO: Migrar para package:drift/wasm.dart quando possível
// https://drift.simonbinder.eu/web
// ignore: deprecated_member_use
import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

/// Cria uma conexão com o banco de dados para web usando IndexedDB
LazyDatabase createConnection() {
  return LazyDatabase(() async {
    // WebDatabase é um QueryExecutor que funciona na web
    return WebDatabase('mealtime_db');
  });
}

