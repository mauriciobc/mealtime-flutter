import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';

/// Gerenciador simplificado de autenticação usando apenas Supabase
class SimpleAuthManager {
  static SupabaseClient get _supabase => SupabaseConfig.client;

  /// Verifica se o usuário está autenticado
  static bool get isAuthenticated {
    return _supabase.auth.currentSession != null;
  }

  /// Obtém o usuário atual
  static User? get currentUser {
    return _supabase.auth.currentUser;
  }

  /// Obtém o token de acesso atual
  static String? get currentAccessToken {
    return _supabase.auth.currentSession?.accessToken;
  }

  /// Faz login com email e senha
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Faz cadastro com email e senha
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Faz logout
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Stream de mudanças de autenticação
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
