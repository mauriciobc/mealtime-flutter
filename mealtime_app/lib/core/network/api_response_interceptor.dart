import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor que envolve automaticamente as respostas do backend
/// no formato ApiResponse esperado pelo Flutter.
///
/// O backend Next.js retorna dados diretamente (arrays, objetos, ou {error}),
/// enquanto o Flutter espera todas as respostas no formato:
/// ```dart
/// {
///   success: bool,
///   data: T?,
///   error: String?
/// }
/// ```
///
/// Este interceptor detecta automaticamente se a resposta já está no formato
/// ApiResponse (ex: endpoints /auth/mobile) e só transforma quando necessário.
class ApiResponseInterceptor extends Interceptor {
  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      if (kDebugMode) {
        print('[ApiResponseInterceptor] Received response for path: ${response.requestOptions.path}');
        print('[ApiResponseInterceptor] Data keys: ${(response.data is Map) ? (response.data as Map).keys.toList() : "not a map"}');
      }
      
      final transformedResponse = _wrapInApiResponse(response);
      
      if (kDebugMode) {
        print('[ApiResponseInterceptor] Transformed response for ${response.requestOptions.path}');
      }
      
      handler.next(transformedResponse);
    } catch (e) {
      if (kDebugMode) {
        print('[ApiResponseInterceptor] Error transforming response: $e');
      }
      // Se falhar a transformação, passa a resposta original
      handler.next(response);
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    try {
      // Transforma erro em ApiResponse format
      final transformedError = _wrapErrorInApiResponse(err);
      
      if (kDebugMode) {
        print('[ApiResponseInterceptor] Transformed error for ${err.requestOptions.path}');
      }
      
      handler.next(transformedError);
    } catch (e) {
      if (kDebugMode) {
        print('[ApiResponseInterceptor] Error transforming error response: $e');
      }
      // Se falhar a transformação, passa o erro original
      handler.next(err);
    }
  }

  /// Envolve a resposta no formato ApiResponse se necessário
  Response _wrapInApiResponse(Response response) {
    // Special handling for /auth/mobile endpoint
    // The backend returns {success, user, access_token, ...} all at top level
    // We need to wrap these into the 'data' field for ApiResponse structure
    final path = response.requestOptions.path;
    if ((path == '/auth/mobile' || path.contains('/auth/mobile')) && 
        response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      
      if (data.containsKey('success') && !data.containsKey('data')) {
        // Remove success and error from top level
        final success = data.remove('success');
        final error = data.remove('error');
        
        // Everything else (user, access_token, refresh_token, etc.) goes in 'data'
        response.data = {
          'success': success,
          'data': data.isNotEmpty ? data : null,
          'error': error,
        };
        
        if (kDebugMode) {
          print('[ApiResponseInterceptor] Wrapped auth response for /auth/mobile');
          print('[ApiResponseInterceptor] Path was: $path');
          print('[ApiResponseInterceptor] Wrapped data keys: ${data.keys.toList()}');
        }
        return response;
      }
    }
    
    // Se já é ApiResponse (tem campo 'success' booleano E campo 'data' separado), retorna sem modificar
    if (_isAlreadyApiResponse(response.data)) {
      if (kDebugMode) {
        print('[ApiResponseInterceptor] Response already in ApiResponse format');
      }
      return response;
    }

    // Verifica se é erro disfarçado de sucesso (status 200 mas tem {error})
    if (_isErrorResponse(response.data)) {
      if (kDebugMode) {
        print('[ApiResponseInterceptor] Detected error response with status ${response.statusCode}');
      }
      
      response.data = {
        'success': false,
        'error': response.data['error'],
        'data': null,
      };
      return response;
    }

    // Envolve dados de sucesso em ApiResponse
    if (kDebugMode) {
      print('[ApiResponseInterceptor] Wrapping successful response in ApiResponse format');
    }
    
    response.data = {
      'success': true,
      'data': response.data,
      'error': null,
    };
    
    return response;
  }

  /// Transforma DioException em ApiResponse format
  DioException _wrapErrorInApiResponse(DioException err) {
    String errorMessage;
    
    // Extrair mensagem de erro da resposta
    if (err.response?.data != null) {
      final data = err.response!.data;
      
      if (data is Map && data.containsKey('error')) {
        errorMessage = data['error'].toString();
      } else if (data is String) {
        errorMessage = data;
      } else {
        errorMessage = _getDefaultErrorMessage(err);
      }
    } else {
      errorMessage = _getDefaultErrorMessage(err);
    }

    // Se a resposta já está no formato ApiResponse com success: false,
    // não precisa transformar
    if (err.response?.data != null && _isAlreadyApiResponse(err.response!.data)) {
      return err;
    }

    // Criar response no formato ApiResponse
    final apiResponseData = {
      'success': false,
      'error': errorMessage,
      'data': null,
    };

    // Criar uma nova response com o formato ApiResponse
    final response = Response(
      requestOptions: err.requestOptions,
      data: apiResponseData,
      statusCode: err.response?.statusCode ?? 500,
      statusMessage: err.response?.statusMessage,
      headers: err.response?.headers ?? Headers(),
    );

    // Retornar um novo DioException com a response transformada
    return DioException(
      requestOptions: err.requestOptions,
      response: response,
      type: err.type,
      error: err.error,
      message: errorMessage,
    );
  }

  /// Verifica se os dados já estão no formato ApiResponse
  /// (deve ter campo 'success' E 'data' separados)
  bool _isAlreadyApiResponse(dynamic data) {
    return data is Map<String, dynamic> &&
           data.containsKey('success') &&
           data.containsKey('data') &&
           data['success'] is bool;
  }

  /// Verifica se é uma resposta de erro (tem campo 'error' mas status 2xx)
  bool _isErrorResponse(dynamic data) {
    return data is Map<String, dynamic> && data.containsKey('error');
  }

  /// Retorna mensagem de erro padrão baseada no tipo de DioException
  String _getDefaultErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão excedido. Verifique sua internet.';
      
      case DioExceptionType.connectionError:
        return 'Erro de conexão. Verifique sua internet.';
      
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Requisição inválida';
          case 401:
            return 'Não autorizado. Faça login novamente.';
          case 403:
            return 'Acesso negado';
          case 404:
            return 'Recurso não encontrado';
          case 500:
            return 'Erro interno do servidor';
          case 503:
            return 'Serviço temporariamente indisponível';
          default:
            return 'Erro no servidor (código: $statusCode)';
        }
      
      case DioExceptionType.cancel:
        return 'Requisição cancelada';
      
      case DioExceptionType.badCertificate:
        return 'Erro de certificado de segurança';
      
      case DioExceptionType.unknown:
        return 'Erro desconhecido. Tente novamente.';
    }
  }
}






