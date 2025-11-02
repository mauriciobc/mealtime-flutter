import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtime_app/core/network/api_response_interceptor.dart';

void main() {
  late ApiResponseInterceptor interceptor;
  late Dio dio;

  setUp(() {
    interceptor = ApiResponseInterceptor();
    dio = Dio(BaseOptions(baseUrl: 'https://test.com'));
    dio.interceptors.add(interceptor);
  });

  group('ApiResponseInterceptor - Successful Responses', () {
    test('deve envolver array direto em ApiResponse', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: [
          {'id': '1', 'name': 'Gato 1'},
          {'id': '2', 'name': 'Gato 2'},
        ],
        statusCode: 200,
      );

      // Act
      final response = await dio.get('/cats');

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['success'], true);
      expect(response.data['data'], isA<List>());
      expect(response.data['data'].length, 2);
      expect(response.data['error'], isNull);
    });

    test('deve envolver objeto direto em ApiResponse', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: {
          'id': '1',
          'name': 'Novo Gato',
          'householdId': '123',
        },
        statusCode: 200,
      );

      // Act
      final response = await dio.post('/cats');

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['success'], true);
      expect(response.data['data'], isA<Map>());
      expect(response.data['data']['id'], '1');
      expect(response.data['data']['name'], 'Novo Gato');
      expect(response.data['error'], isNull);
    });

    test('NÃO deve transformar resposta que já é ApiResponse', () async {
      // Arrange - Simula resposta de /auth/mobile
      dio.httpClientAdapter = _MockAdapter(
        responseBody: {
          'success': true,
          'user': {'id': '1', 'email': 'test@example.com'},
          'access_token': 'jwt_token_here',
          'refresh_token': 'refresh_token_here',
        },
        statusCode: 200,
      );

      // Act
      final response = await dio.post('/auth/mobile');

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['success'], true);
      expect(response.data['user'], isNotNull);
      expect(response.data['access_token'], 'jwt_token_here');
      // Não deve ter campo 'data' adicional
      expect(response.data.containsKey('data'), false);
    });

    test('deve transformar erro disfarçado (status 200 + error)', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: {
          'error': 'Gato não encontrado',
        },
        statusCode: 200,
      );

      // Act
      final response = await dio.get('/cats/999');

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['success'], false);
      expect(response.data['error'], 'Gato não encontrado');
      expect(response.data['data'], isNull);
    });
  });

  group('ApiResponseInterceptor - Error Responses', () {
    test('deve transformar erro 404 em ApiResponse', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: {'error': 'Recurso não encontrado'},
        statusCode: 404,
        throwsError: true,
      );

      // Act & Assert
      try {
        await dio.get('/cats/999');
        fail('Deveria ter lançado exceção');
      } on DioException catch (e) {
        expect(e.response?.data, isA<Map<String, dynamic>>());
        expect(e.response?.data['success'], false);
        expect(e.response?.data['error'], isNotNull);
        expect(e.response?.statusCode, 404);
      }
    });

    test('deve transformar erro 401 em ApiResponse', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: {'error': 'Não autorizado'},
        statusCode: 401,
        throwsError: true,
      );

      // Act & Assert
      try {
        await dio.get('/cats');
        fail('Deveria ter lançado exceção');
      } on DioException catch (e) {
        expect(e.response?.data, isA<Map<String, dynamic>>());
        expect(e.response?.data['success'], false);
        expect(e.response?.data['error'], isNotNull);
        expect(e.response?.statusCode, 401);
      }
    });

    test('deve transformar erro 500 em ApiResponse', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: {'error': 'Erro interno do servidor'},
        statusCode: 500,
        throwsError: true,
      );

      // Act & Assert
      try {
        await dio.get('/cats');
        fail('Deveria ter lançado exceção');
      } on DioException catch (e) {
        expect(e.response?.data, isA<Map<String, dynamic>>());
        expect(e.response?.data['success'], false);
        expect(e.response?.data['error'], isNotNull);
        expect(e.response?.statusCode, 500);
      }
    });

    test('deve fornecer mensagem padrão para erro sem response', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        throwsError: true,
        connectionError: true,
      );

      // Act & Assert
      try {
        await dio.get('/cats');
        fail('Deveria ter lançado exceção');
      } on DioException catch (e) {
        expect(e.message, contains('Erro de conexão'));
      }
    });
  });

  group('ApiResponseInterceptor - Edge Cases', () {
    test('deve lidar com resposta vazia', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: null,
        statusCode: 200,
      );

      // Act
      final response = await dio.get('/empty');

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['success'], true);
      expect(response.data['data'], isNull);
    });

    test('deve lidar com resposta string', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: 'OK',
        statusCode: 200,
      );

      // Act
      final response = await dio.get('/text');

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['success'], true);
      expect(response.data['data'], 'OK');
    });

    test('deve lidar com resposta número', () async {
      // Arrange
      dio.httpClientAdapter = _MockAdapter(
        responseBody: 42,
        statusCode: 200,
      );

      // Act
      final response = await dio.get('/number');

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['success'], true);
      expect(response.data['data'], 42);
    });
  });
}

// Mock HTTP Adapter para simular respostas do servidor
class _MockAdapter implements HttpClientAdapter {
  final dynamic responseBody;
  final int statusCode;
  final bool throwsError;
  final bool connectionError;

  _MockAdapter({
    this.responseBody,
    this.statusCode = 200,
    this.throwsError = false,
    this.connectionError = false,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (connectionError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'Erro de conexão',
      );
    }

    if (throwsError) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          data: responseBody,
          statusCode: statusCode,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return ResponseBody.fromString(
      _encodeResponse(responseBody),
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  String _encodeResponse(dynamic data) {
    if (data == null) return '';
    if (data is String) return json.encode(data);
    return json.encode(data);
  }

  @override
  void close({bool force = false}) {}
}

