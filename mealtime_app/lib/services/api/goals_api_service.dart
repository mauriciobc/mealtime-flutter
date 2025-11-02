import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';

part 'goals_api_service.g.dart';

/// API Service para Goals V2
/// Baseado no endpoint /api/v2/goals do backend conforme OpenAPI spec
@RestApi(baseUrl: ApiConstants.baseUrlV2)
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
@JsonSerializable()
class GoalModel {
  final String id;
  @JsonKey(name: 'cat_id')
  final String catId;
  @JsonKey(name: 'target_weight', fromJson: _weightFromJson)
  final double targetWeight;
  @JsonKey(name: 'target_date')
  final DateTime targetDate;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'goal_name', includeFromJson: true)
  final String? goalName;
  @JsonKey(name: 'start_weight', includeFromJson: true, fromJson: _nullableWeightFromJson)
  final double? startWeight;
  @JsonKey(name: 'unit', includeFromJson: true)
  final String? unit;
  @JsonKey(name: 'status', includeFromJson: true)
  final String? status;
  @JsonKey(name: 'updated_at', includeFromJson: true)
  final DateTime? updatedAt;

  GoalModel({
    required this.id,
    required this.catId,
    required this.targetWeight,
    required this.targetDate,
    this.notes,
    required this.createdAt,
    this.goalName,
    this.startWeight,
    this.unit,
    this.status,
    this.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => _$GoalModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$GoalModelToJson(this);

  /// Helper para converter weight de String para double
  static double _weightFromJson(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Cannot convert $value to double');
  }

  /// Helper para converter weight nullable de String para double
  static double? _nullableWeightFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Cannot convert $value to double');
  }

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
