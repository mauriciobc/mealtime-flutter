import 'package:drift/drift.dart';

// Importações condicionais para suportar web e nativo
import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.html) 'database_connection_web.dart';

/// Cria uma conexão com o banco de dados apropriada para a plataforma atual
LazyDatabase createDatabaseConnection() {
  return createConnection();
}
