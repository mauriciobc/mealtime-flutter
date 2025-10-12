import 'package:supabase_flutter/supabase_flutter.dart';

/// Arquivo de exemplo para configuração do Supabase
///
/// Para configurar:
/// 1. Copie este arquivo para supabase_config.dart
/// 2. Substitua as credenciais pelas suas do Supabase
/// 3. Execute o projeto

class SupabaseConfigExample {
  // TODO: Substitua pela URL do seu projeto Supabase
  // Encontre em: Dashboard > Settings > API > Project URL
  static const String supabaseUrl = 'https://seu-projeto.supabase.co';

  // TODO: Substitua pela chave pública do seu projeto Supabase
  // Encontre em: Dashboard > Settings > API > anon public key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

  // Deep link scheme para autenticação (não precisa alterar)
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
