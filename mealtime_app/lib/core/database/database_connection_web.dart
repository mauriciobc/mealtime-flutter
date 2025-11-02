import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Cria uma conexão com o banco de dados para web usando IndexedDB
LazyDatabase createConnection() {
  return LazyDatabase(() async {
    // WebDatabase é um QueryExecutor que funciona na web
    return WebDatabase('mealtime_db');
  });
}

