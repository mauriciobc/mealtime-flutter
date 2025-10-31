import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/schedules/data/models/schedule_model.dart';

part 'schedules_api_service.g.dart';

/// API Service para Schedules V2
/// Baseado no endpoint /api/v2/schedules do backend conforme OpenAPI spec
@RestApi()
abstract class SchedulesApiService {
  factory SchedulesApiService(Dio dio, {String baseUrl}) =
      _SchedulesApiService;

  // V2 - Schedules endpoints
  @GET('/v2/schedules')
  Future<ApiResponse<List<ScheduleModel>>> getSchedules({
    @Query('householdId') String? householdId,
  });

  @POST('/v2/schedules')
  Future<ApiResponse<ScheduleModel>> createSchedule(@Body() ScheduleModel schedule);

  @GET('/v2/schedules/{id}')
  Future<ApiResponse<ScheduleModel>> getScheduleById(@Path('id') String id);

  @PATCH('/v2/schedules/{id}')
  Future<ApiResponse<ScheduleModel>> updateSchedule(
    @Path('id') String id,
    @Body() ScheduleModel schedule,
  );

  @DELETE('/v2/schedules/{id}')
  Future<ApiResponse<EmptyResponse>> deleteSchedule(@Path('id') String id);
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}



