import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';

part 'goals_api_service.g.dart';

/// API Service para Goals V2
/// Baseado no endpoint /api/v2/goals do backend conforme OpenAPI spec
@RestApi()
abstract class GoalsApiService {
  factory GoalsApiService(Dio dio, {String baseUrl}) = _GoalsApiService;

  // V2 - Goals endpoints
  /// Lista metas de peso
  /// Endpoint: GET /v2/goals
  @GET(ApiConstants.v2Goals)
  Future<ApiResponse<List<GoalModel>>> getGoals({
    @Query('catId') String? catId,
    @Query('householdId') String? householdId,
  });

  /// Cria uma nova meta de peso
  /// Endpoint: POST /v2/goals
  @POST(ApiConstants.v2Goals)
  Future<ApiResponse<GoalModel>> createGoal(@Body() CreateGoalRequest request);
}

/// Model de meta de peso
class GoalModel {
  final String id;
  final String catId;
  final double targetWeight;
  final DateTime targetDate;
  final String? notes;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.catId,
    required this.targetWeight,
    required this.targetDate,
    this.notes,
    required this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id: json['id'] as String,
    catId: json['cat_id'] as String,
    targetWeight: (json['target_weight'] as num).toDouble(),
    targetDate: DateTime.parse(json['target_date'] as String),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cat_id': catId,
    'target_weight': targetWeight,
    'target_date': targetDate.toIso8601String(),
    if (notes != null) 'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };
}

/// Request para criar uma nova meta
class CreateGoalRequest {
  final String catId;
  final double targetWeight;
  final DateTime targetDate;
  final String? notes;

  CreateGoalRequest({
    required this.catId,
    required this.targetWeight,
    required this.targetDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'catId': catId,
    'targetWeight': targetWeight,
    'targetDate': targetDate.toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}
