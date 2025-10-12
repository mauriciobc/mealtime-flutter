import 'package:dio/dio.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/features/feeding_logs/data/models/meal_model.dart';

class FeedingLogsApiService {
  final Dio _dio;

  FeedingLogsApiService(this._dio);

  Future<List<FeedingLogModel>> getFeedingLogs() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/feeding_logs');
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => FeedingLogModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<FeedingLogModel>> getFeedingLogsByCat(String catId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/feeding_logs?cat_id=$catId',
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => FeedingLogModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<FeedingLogModel> getFeedingLogById(String mealId) async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/feeding_logs/$mealId');
      return FeedingLogModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<FeedingLogModel>> getTodayFeedingLogs() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/feeding_logs?date=$today',
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => FeedingLogModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<FeedingLogModel> createFeedingLog(FeedingLogModel meal) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/feeding_logs',
        data: meal.toJson(),
      );
      return FeedingLogModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<FeedingLogModel> updateFeedingLog(FeedingLogModel meal) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.baseUrl}/feeding_logs/${meal.id}',
        data: meal.toJson(),
      );
      return FeedingLogModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteFeedingLog(String mealId) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/feeding_logs/$mealId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<FeedingLogModel> completeFeedingLog(
    String mealId,
    String? notes,
    double? amount,
  ) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/feeding_logs/$mealId/complete',
        data: {
          if (notes != null) 'notes': notes,
          if (amount != null) 'amount': amount,
        },
      );
      return FeedingLogModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<FeedingLogModel> skipFeedingLog(String mealId, String? reason) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/feeding_logs/$mealId/skip',
        data: {if (reason != null) 'reason': reason},
      );
      return FeedingLogModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Timeout de conexão. Verifique sua internet.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Não autorizado. Faça login novamente.');
        } else if (statusCode == 404) {
          return Exception('Refeição não encontrada.');
        } else if (statusCode == 422) {
          return Exception('Dados inválidos. Verifique os campos.');
        } else if (statusCode == 500) {
          return Exception('Erro interno do servidor. Tente novamente.');
        }
        return Exception('Erro do servidor: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Operação cancelada.');
      case DioExceptionType.connectionError:
        return Exception('Erro de conexão. Verifique sua internet.');
      default:
        return Exception('Erro inesperado: ${e.message}');
    }
  }
}
