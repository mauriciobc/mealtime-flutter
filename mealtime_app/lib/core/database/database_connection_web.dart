import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Cria uma conexão com o banco de dados para web usando WasmDatabase
LazyDatabase createConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'mealtime_db',
      sqlite3Uri: Uri.parse('/sqlite3.wasm'),
      driftWorkerUri: Uri.parse('/drift_worker.dart.js'),
      initializeDatabase: () async => null,
    );

    return result.resolvedExecutor;
  });
}
