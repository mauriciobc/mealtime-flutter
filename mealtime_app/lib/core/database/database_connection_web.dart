import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Cria uma conexão com o banco de dados para web usando WasmDatabase
LazyDatabase createConnection() {
  return LazyDatabase(() async {
    // WasmDatabase usa WebAssembly para SQLite na web
    // sqlite3_flutter_libs fornece os arquivos sqlite3.wasm e drift_worker.dart.js
    final result = await WasmDatabase.open(
      databaseName: 'mealtime_db',
      sqlite3Uri: Uri.parse('/sqlite3.wasm'),
      driftWorkerUri: Uri.parse('/drift_worker.dart.js'),
      initializeDatabase: (db) async {
        // Callback para inicialização/migração de dados
        // 
        // Nota: O WebDatabase antigo usava um formato diferente no IndexedDB,
        // então uma migração manual seria necessária se houver dados existentes.
        // Como o formato é completamente diferente (WebDatabase vs SQLite/WASM),
        // a migração exigiria:
        // 1. Acessar o IndexedDB antigo usando dart:html
        // 2. Ler todos os dados do formato antigo
        // 3. Inserir os dados no novo banco SQLite através do WasmDatabase
        // 
        // Por enquanto, este callback está vazio. Se necessário no futuro,
        // implementar a migração aqui.
      },
    );

    return result.resolvedExecutor;
  });
}

