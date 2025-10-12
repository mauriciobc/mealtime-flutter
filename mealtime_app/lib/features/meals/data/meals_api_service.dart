import 'package:dio/dio.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/features/meals/data/models/meal_model.dart';

class MealsApiService {
  final Dio _dio;

  MealsApiService(this._dio);

  Future<List<MealModel>> getMeals() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/meals');
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => MealModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<MealModel>> getMealsByCat(String catId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/meals?cat_id=$catId',
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => MealModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<MealModel> getMealById(String mealId) async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/meals/$mealId');
      return MealModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<MealModel>> getTodayMeals() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/meals?date=$today',
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => MealModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<MealModel> createMeal(MealModel meal) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/meals',
        data: meal.toJson(),
      );
      return MealModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<MealModel> updateMeal(MealModel meal) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.baseUrl}/meals/${meal.id}',
        data: meal.toJson(),
      );
      return MealModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/meals/$mealId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<MealModel> completeMeal(
    String mealId,
    String? notes,
    double? amount,
  ) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/meals/$mealId/complete',
        data: {
          if (notes != null) 'notes': notes,
          if (amount != null) 'amount': amount,
        },
      );
      return MealModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<MealModel> skipMeal(String mealId, String? reason) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/meals/$mealId/skip',
        data: {if (reason != null) 'reason': reason},
      );
      return MealModel.fromJson(response.data['data'] ?? response.data);
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
