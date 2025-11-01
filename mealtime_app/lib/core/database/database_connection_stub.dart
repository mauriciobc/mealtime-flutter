import 'package:drift/drift.dart';

/// Stub para plataformas não suportadas
LazyDatabase createConnection() {
  throw UnsupportedError('Plataforma não suportada');
}

