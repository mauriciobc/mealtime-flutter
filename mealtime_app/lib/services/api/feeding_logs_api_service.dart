import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/feeding_logs/data/models/feeding_log_model.dart';

part 'feeding_logs_api_service.g.dart';

/// API Service para Feeding Logs
/// Baseado nos endpoints /feeding-logs e /feedings do backend Next.js
@RestApi()
abstract class FeedingLogsApiService {
  factory FeedingLogsApiService(Dio dio, {String baseUrl}) =
      _FeedingLogsApiService;

  /// Lista feeding logs com filtros opcionais
  /// Endpoint: GET /feeding-logs
  @GET(ApiConstants.feedingLogs)
  Future<ApiResponse<List<FeedingLogModel>>> getFeedingLogs({
    @Query('catId') String? catId,
    @Query('householdId') String? householdId,
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
  });

  /// Busca um feeding log específico por ID
  /// Endpoint: GET /feeding-logs/{id}
  @GET('/feeding-logs/{id}')
  Future<ApiResponse<FeedingLogModel>> getFeedingLogById(@Path('id') String id);

  /// Cria um novo feeding log
  /// Endpoint: POST /feeding-logs
  @POST(ApiConstants.feedingLogs)
  Future<ApiResponse<FeedingLogModel>> createFeedingLog(
    @Body() CreateFeedingLogRequest request,
  );

  /// Atualiza um feeding log existente
  /// Endpoint: PUT /feeding-logs/{id}
  @PUT('/feeding-logs/{id}')
  Future<ApiResponse<FeedingLogModel>> updateFeedingLog(
    @Path('id') String id,
    @Body() UpdateFeedingLogRequest request,
  );

  /// Deleta um feeding log
  /// Endpoint: DELETE /feeding-logs/{id}
  @DELETE('/feeding-logs/{id}')
  Future<ApiResponse<EmptyResponse>> deleteFeedingLog(@Path('id') String id);

  /// Busca a última alimentação de um gato
  /// Endpoint: GET /feedings/last/{catId}
  @GET('/feedings/last/{catId}')
  Future<ApiResponse<FeedingLogModel?>> getLastFeeding(
    @Path('catId') String catId,
  );
}

/// Request para criar um novo feeding log
class CreateFeedingLogRequest {
  final String catId;
  final String householdId;
  final String mealType;  // 'breakfast', 'lunch', 'dinner', 'snack'
  final double? amount;
  final String? unit;
  final String? notes;
  final String fedBy;  // userId de quem alimentou
  final DateTime fedAt;

  CreateFeedingLogRequest({
    required this.catId,
    required this.householdId,
    required this.mealType,
    this.amount,
    this.unit,
    this.notes,
    required this.fedBy,
    required this.fedAt,
  });

  Map<String, dynamic> toJson() => {
        'cat_id': catId,
        'household_id': householdId,
        'meal_type': mealType,
        if (amount != null) 'amount': amount,
        if (unit != null) 'unit': unit,
        if (notes != null) 'notes': notes,
        'fed_by': fedBy,
        'fed_at': fedAt.toIso8601String(),
      };
}

/// Request para atualizar um feeding log
class UpdateFeedingLogRequest {
  final String? mealType;
  final double? amount;
  final String? unit;
  final String? notes;
  final DateTime? fedAt;

  UpdateFeedingLogRequest({
    this.mealType,
    this.amount,
    this.unit,
    this.notes,
    this.fedAt,
  });

  Map<String, dynamic> toJson() => {
        if (mealType != null) 'meal_type': mealType,
        if (amount != null) 'amount': amount,
        if (unit != null) 'unit': unit,
        if (notes != null) 'notes': notes,
        if (fedAt != null) 'fed_at': fedAt!.toIso8601String(),
      };
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}
