import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/feeding_logs/data/models/feeding_log_model.dart';

part 'feeding_logs_api_service.g.dart';

/// API Service para Feeding Logs V2
/// Baseado no endpoint /api/v2/feedings do backend conforme OpenAPI spec
@RestApi()
abstract class FeedingLogsApiService {
  factory FeedingLogsApiService(Dio dio, {String baseUrl}) =
      _FeedingLogsApiService;

  // V2 - Feedings endpoints
  /// Lista feeding logs com filtros
  /// Endpoint: GET /v2/feedings
  @GET(ApiConstants.v2Feedings)
  Future<ApiResponse<List<FeedingLogModel>>> getFeedingLogs({
    @Query('householdId') String? householdId,
    @Query('catId') String? catId,
  });

  /// Busca um feeding log específico por ID
  /// Endpoint: GET /v2/feedings/{id}
  @GET('/v2/feedings/{id}')
  Future<ApiResponse<FeedingLogModel>> getFeedingLogById(@Path('id') String id);

  /// Cria um novo feeding log
  /// Endpoint: POST /v2/feedings
  @POST(ApiConstants.v2Feedings)
  Future<ApiResponse<FeedingLogModel>> createFeedingLog(
    @Body() CreateFeedingLogRequest request,
  );

  /// Cria múltiplos feeding logs em lote (batch)
  /// Endpoint: POST /v2/feedings/batch
  /// Nota: Se o endpoint não existir, usar createFeedingLog múltiplas vezes
  @POST('/v2/feedings/batch')
  Future<ApiResponse<List<FeedingLogModel>>> createFeedingLogsBatch(
    @Body() CreateFeedingLogsBatchRequest request,
  );

  /// Atualiza um feeding log
  /// Endpoint: PUT /v2/feedings/{id}
  @PUT('/v2/feedings/{id}')
  Future<ApiResponse<FeedingLogModel>> updateFeedingLog(
    @Path('id') String id,
    @Body() CreateFeedingLogRequest request,
  );

  /// Deleta um feeding log
  /// Endpoint: DELETE /v2/feedings/{id}
  @DELETE('/v2/feedings/{id}')
  Future<ApiResponse<EmptyResponse>> deleteFeedingLog(@Path('id') String id);

  /// Estatísticas de alimentação
  /// Endpoint: GET /v2/feedings/stats
  @GET(ApiConstants.v2FeedingStats)
  Future<ApiResponse<FeedingStatsModel>> getFeedingStats({
    @Query('householdId') String? householdId,
  });
}

/// Request para criar múltiplos feeding logs em lote
class CreateFeedingLogsBatchRequest {
  final List<CreateFeedingLogRequest> feedings;

  CreateFeedingLogsBatchRequest({required this.feedings});

  Map<String, dynamic> toJson() => {
        'feedings': feedings.map((f) => f.toJson()).toList(),
      };
}

/// Request para criar um novo feeding log
/// Uses camelCase to match OpenAPI spec (not snake_case)
class CreateFeedingLogRequest {
  final String catId;
  final String? mealType;  // 'breakfast', 'lunch', 'dinner', 'snack' - optional, defaults to 'manual'
  final double? amount;
  final String? unit;  // optional, defaults to 'g'
  final String? notes;  // optional, maxLength 255

  CreateFeedingLogRequest({
    required this.catId,
    this.mealType,
    this.amount,
    this.unit,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'catId': catId,  // camelCase per OpenAPI spec
        if (mealType != null) 'meal_type': mealType,  // snake_case per OpenAPI spec
        if (amount != null) 'amount': amount,  // camelCase per OpenAPI spec
        if (unit != null) 'unit': unit,  // camelCase per OpenAPI spec
        if (notes != null) 'notes': notes,  // camelCase per OpenAPI spec
      };
}

// UpdateFeedingLogRequest removido - V2 não suporta atualização de feeding logs

/// Modelo para estatísticas de alimentação
/// Aceita qualquer estrutura de dados do backend
class FeedingStatsModel {
  final Map<String, dynamic> data;

  const FeedingStatsModel({required this.data});

  factory FeedingStatsModel.fromJson(Map<String, dynamic> json) {
    // O backend retorna o Map diretamente, então retornamos ele mesmo
    return FeedingStatsModel(data: json);
  }

  Map<String, dynamic> toJson() => data;
}

/// Classe para respostas vazias da API
@JsonSerializable()
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      _$EmptyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmptyResponseToJson(this);
}
