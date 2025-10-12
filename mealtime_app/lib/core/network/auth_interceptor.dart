import 'package:dio/dio.dart';
import 'package:mealtime_app/core/network/token_manager.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ✅ Usar TokenManager para obter token válido
    if (!options.path.contains('auth/mobile')) {
      final accessToken = await TokenManager.getValidAccessToken();

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      // ✅ NOVO: Adicionar header x-user-id para requisições autenticadas
      final userId = await TokenManager.getUserId();
      if (userId != null) {
        options.headers['x-user-id'] = userId;
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ✅ Refresh automático de token em caso de erro 401
    if (err.response?.statusCode == 401) {
      final newToken = await TokenManager.refreshAccessToken();

      if (newToken != null) {
        // Reenviar requisição original com novo token
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          final dio = Dio();
          final newResponse = await dio.fetch(requestOptions);
          return handler.resolve(newResponse);
        } catch (e) {
          // Se ainda falhar, limpar tokens
          await TokenManager.clearTokens();
        }
      } else {
        // Refresh falhou, limpar tokens
        await TokenManager.clearTokens();
      }
    }

    super.onError(err, handler);
  }
}
