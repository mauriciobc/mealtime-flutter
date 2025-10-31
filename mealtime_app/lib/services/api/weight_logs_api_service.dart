import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/cats/data/models/weight_entry_model.dart';

part 'weight_logs_api_service.g.dart';

/// API Service para Weight Logs V2
/// Baseado no endpoint /api/v2/weight-logs do backend conforme OpenAPI spec
@RestApi()
abstract class WeightLogsApiService {
  factory WeightLogsApiService(Dio dio, {String baseUrl}) =
      _WeightLogsApiService;

  // V2 - Weight Logs endpoints
  /// Lista registros de peso
  /// Endpoint: GET /v2/weight-logs
  @GET(ApiConstants.v2WeightLogs)
  Future<ApiResponse<List<WeightEntryModel>>> getWeightLogs({
    @Query('catId') String? catId,
    @Query('householdId') String? householdId,
  });

  /// Cria um novo registro de peso
  /// Endpoint: POST /v2/weight-logs
  @POST(ApiConstants.v2WeightLogs)
  Future<ApiResponse<WeightEntryModel>> createWeightLog(
    @Body() CreateWeightLogRequest request,
  );

  /// Atualiza um registro de peso existente
  /// Endpoint: PUT /v2/weight-logs (com ID no body ou como query param)
  @PUT(ApiConstants.v2WeightLogs)
  Future<ApiResponse<WeightEntryModel>> updateWeightLog(
    @Body() UpdateWeightLogRequest request,
  );

  /// Deleta um registro de peso
  /// Endpoint: DELETE /v2/weight-logs (com ID como query param)
  @DELETE(ApiConstants.v2WeightLogs)
  Future<ApiResponse<EmptyResponse>> deleteWeightLog({
    @Query('id') required String id,
  });
}

/// Request para criar um novo weight log
class CreateWeightLogRequest {
  final String catId;
  final double weight;
  final DateTime measuredAt;
  final String? notes;

  CreateWeightLogRequest({
    required this.catId,
    required this.weight,
    required this.measuredAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'catId': catId,
    'weight': weight,
    'measuredAt': measuredAt.toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}

/// Request para atualizar um weight log
class UpdateWeightLogRequest {
  final String id;
  final double? weight;
  final DateTime? measuredAt;
  final String? notes;

  UpdateWeightLogRequest({
    required this.id,
    this.weight,
    this.measuredAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    if (weight != null) 'weight': weight,
    if (measuredAt != null) 'measuredAt': measuredAt!.toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}
