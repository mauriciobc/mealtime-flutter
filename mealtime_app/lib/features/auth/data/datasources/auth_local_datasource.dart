import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();

  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearUserId();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await sharedPreferences.setString('access_token', accessToken);
      await sharedPreferences.setString('refresh_token', refreshToken);
    } catch (e) {
      throw CacheException('Erro ao salvar tokens: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return sharedPreferences.getString('access_token');
    } catch (e) {
      throw CacheException('Erro ao buscar token de acesso: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return sharedPreferences.getString('refresh_token');
    } catch (e) {
      throw CacheException('Erro ao buscar token de refresh: ${e.toString()}');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await sharedPreferences.remove('access_token');
      await sharedPreferences.remove('refresh_token');
    } catch (e) {
      throw CacheException('Erro ao limpar tokens: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      final userString = jsonEncode(userJson);
      await sharedPreferences.setString('user', userString);
    } catch (e) {
      throw CacheException('Erro ao salvar usuário: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userString = sharedPreferences.getString('user');
      if (userString == null) return null;

      final userJson = jsonDecode(userString) as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } catch (e) {
      throw CacheException('Erro ao buscar usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await sharedPreferences.remove('user');
    } catch (e) {
      throw CacheException('Erro ao limpar usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserId(String userId) async {
    try {
      await sharedPreferences.setString('user_id', userId);
    } catch (e) {
      throw CacheException('Erro ao salvar ID do usuário: ${e.toString()}');
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return sharedPreferences.getString('user_id');
    } catch (e) {
      throw CacheException('Erro ao buscar ID do usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUserId() async {
    try {
      await sharedPreferences.remove('user_id');
    } catch (e) {
      throw CacheException('Erro ao limpar ID do usuário: ${e.toString()}');
    }
  }
}
