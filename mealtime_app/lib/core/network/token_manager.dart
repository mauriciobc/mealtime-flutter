import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/services/api/auth_api_service.dart';
import 'package:mealtime_app/core/auth/simple_auth_manager.dart';

/// Gerenciador centralizado de tokens de autenticação
class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  /// Obtém o token de acesso atual (prioriza SharedPreferences/backend, depois Supabase)
  static Future<String?> getAccessToken() async {
    // Prioriza SharedPreferences (backend API)
    final prefs = await SharedPreferences.getInstance();
    final backendToken = prefs.getString(_accessTokenKey);
    if (backendToken != null) {
      return backendToken;
    }
    
    // Fallback: Supabase (para compatibilidade)
    final supabaseToken = SimpleAuthManager.currentAccessToken;
    if (supabaseToken != null) {
      return supabaseToken;
    }
    
    return null;
  }

  /// Obtém o token de refresh atual
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Salva os tokens de autenticação
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    if (expiresIn != null) {
      final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
      await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
    }
  }

  /// Limpa todos os tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// Verifica se o token está próximo do vencimento (últimos 5 minutos)
  static Future<bool> isTokenNearExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);

    if (expiryString == null) return false;

    final expiry = DateTime.parse(expiryString);
    final now = DateTime.now();
    final timeUntilExpiry = expiry.difference(now);

    // Considera próximo do vencimento se restam menos de 5 minutos
    return timeUntilExpiry.inMinutes < 5;
  }

  /// Verifica se o token está válido
  static Future<bool> isTokenValid() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    return !await isTokenNearExpiry();
  }

  /// Tenta renovar o token de acesso usando o refresh token
  static Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final dio = Dio();
      final response = await dio.put(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);

        if (authResponse.success == true && authResponse.accessToken != null) {
          // Salvar novos tokens
          await saveTokens(
            accessToken: authResponse.accessToken!,
            refreshToken: authResponse.refreshToken ?? refreshToken,
            expiresIn: authResponse.expiresIn,
          );

          return authResponse.accessToken;
        }
      }
    } catch (e) {
      // Se o refresh falhar, limpar tokens
      await clearTokens();
    }

    return null;
  }

  /// Obtém o token de acesso válido, renovando se necessário
  static Future<String?> getValidAccessToken() async {
    if (await isTokenValid()) {
      return await getAccessToken();
    }

    // Token próximo do vencimento ou inválido, tentar renovar
    return await refreshAccessToken();
  }

  /// Extrai o userId (decodifica JWT do token, com fallback para Supabase)
  static Future<String?> getUserId() async {
    // Decodificar JWT do token (backend ou Supabase)
    final token = await getAccessToken();
    if (token == null) {
      // Fallback: Supabase
      final supabaseUser = SimpleAuthManager.currentUser;
      if (supabaseUser != null) {
        return supabaseUser.id;
      }
      return null;
    }

    try {
      // Decodificar JWT
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Payload é a segunda parte
      final payload = parts[1];

      // Normalizar base64 (adicionar padding se necessário)
      var normalized = payload;
      switch (payload.length % 4) {
        case 2:
          normalized = '$payload==';
          break;
        case 3:
          normalized = '$payload=';
          break;
      }

      // Decodificar
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Extrair sub (subject) que é o userId
      return payloadMap['sub'] as String?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao extrair userId do token: $e');
      }
      return null;
    }
  }

  /// Obtém o household_id do perfil do usuário salvo localmente
  static Future<String?> getHouseholdId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      
      if (userString == null) {
        if (kDebugMode) {
          debugPrint('[TokenManager] Nenhum usuário salvo localmente');
        }
        return null;
      }

      final userJson = json.decode(userString) as Map<String, dynamic>;
      
      // Extrair household_id do user salvos
      final householdId = userJson['household_id'] as String?;
      
      if (kDebugMode && householdId != null) {
        debugPrint('[TokenManager] Household ID encontrado: $householdId');
      } else if (kDebugMode) {
        debugPrint('[TokenManager] Nenhum household_id encontrado no perfil do usuário');
      }
      
      return householdId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter household_id: $e');
      }
      return null;
    }
  }
}
