import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/meals/data/models/meal_model.dart';

part 'meals_api_service.g.dart';

@RestApi()
abstract class MealsApiService {
  factory MealsApiService(Dio dio, {String baseUrl}) = _MealsApiService;

  @GET(ApiConstants.meals)
  Future<ApiResponse<List<MealModel>>> getMeals({
    @Query('cat_id') String? catId,
    @Query('home_id') String? homeId,
    @Query('status') String? status,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
  });

  @GET('/meals/{id}')
  Future<ApiResponse<MealModel>> getMealById(@Path('id') String id);

  @POST('/meals')
  Future<ApiResponse<MealModel>> createMeal(@Body() CreateMealRequest request);

  @PUT('/meals/{id}')
  Future<ApiResponse<MealModel>> updateMeal(
    @Path('id') String id,
    @Body() UpdateMealRequest request,
  );

  @DELETE('/meals/{id}')
  Future<ApiResponse<EmptyResponse>> deleteMeal(@Path('id') String id);

  @POST('/meals/{id}/complete')
  Future<ApiResponse<MealModel>> completeMeal(
    @Path('id') String id,
    @Body() CompleteMealRequest request,
  );

  @POST('/meals/{id}/skip')
  Future<ApiResponse<MealModel>> skipMeal(
    @Path('id') String id,
    @Body() SkipMealRequest request,
  );
}

class CreateMealRequest {
  final String catId;
  final String homeId;
  final String type;
  final DateTime scheduledAt;
  final String? notes;
  final double? amount;
  final String? foodType;

  CreateMealRequest({
    required this.catId,
    required this.homeId,
    required this.type,
    required this.scheduledAt,
    this.notes,
    this.amount,
    this.foodType,
  });

  Map<String, dynamic> toJson() => {
    'cat_id': catId,
    'home_id': homeId,
    'type': type,
    'scheduled_at': scheduledAt.toIso8601String(),
    if (notes != null) 'notes': notes,
    if (amount != null) 'amount': amount,
    if (foodType != null) 'food_type': foodType,
  };
}

class UpdateMealRequest {
  final String? type;
  final DateTime? scheduledAt;
  final String? notes;
  final double? amount;
  final String? foodType;

  UpdateMealRequest({
    this.type,
    this.scheduledAt,
    this.notes,
    this.amount,
    this.foodType,
  });

  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
    if (notes != null) 'notes': notes,
    if (amount != null) 'amount': amount,
    if (foodType != null) 'food_type': foodType,
  };
}

class CompleteMealRequest {
  final String? notes;
  final double? amount;

  CompleteMealRequest({this.notes, this.amount});

  Map<String, dynamic> toJson() => {
    if (notes != null) 'notes': notes,
    if (amount != null) 'amount': amount,
  };
}

class SkipMealRequest {
  final String? reason;

  SkipMealRequest({this.reason});

  Map<String, dynamic> toJson() => {if (reason != null) 'reason': reason};
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}
