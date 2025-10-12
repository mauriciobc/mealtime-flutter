import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Credenciais do Supabase configuradas via MCP
  static const String supabaseUrl = 'https://zzvmyzyszsqptgyqwqwt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6dm15enlzenNxcHRneXF3cXd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzNDIxNDYsImV4cCI6MjA2MDkxODE0Nn0.1nP8qAuhG9TptGONMBc1_BQyRups9x7AHndo1r5AD0c';

  // Deep link scheme para autenticação
  static const String deepLinkScheme = 'io.mealtime.app';
  static const String deepLinkHost = 'login-callback';

  /// Inicializa o Supabase com as configurações necessárias
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      storageOptions: const StorageClientOptions(retryAttempts: 3),
    );
  }

  /// Retorna a instância do cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Retorna a URL de deep link completa
  static String get deepLinkUrl => '$deepLinkScheme://$deepLinkHost/';
}
