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

      // ✅ Adicionar header X-User-ID para requisições autenticadas
      final userId = await TokenManager.getUserId();
      if (userId != null) {
        options.headers['X-User-ID'] = userId;
      }

      // ✅ Adicionar header X-Household-ID do perfil do usuário (quando disponível)
      final householdId = await TokenManager.getHouseholdId();
      if (householdId != null) {
        options.headers['X-Household-ID'] = householdId;
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
        // Reenviar requisição original com novo token usando o mesmo Dio
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          // Usar o mesmo Dio da requisição original para manter interceptors e configurações
          // Criar novo Dio com as mesmas configurações base
          final dio = Dio(BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            connectTimeout: err.requestOptions.connectTimeout,
            receiveTimeout: err.requestOptions.receiveTimeout,
            headers: requestOptions.headers,
          ));
          
          // Reenviar requisição com novo token
          final opts = Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          );
          
          final newResponse = await dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: opts,
          );
          
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
