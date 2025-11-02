import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/cats/data/models/cat_model.dart';

part 'cats_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrlV2)
abstract class CatsApiService {
  factory CatsApiService(Dio dio, {String baseUrl}) = _CatsApiService;

  // V2 - Cats endpoints
  @GET('/cats')
  Future<ApiResponse<List<CatModel>>> getCats({
    @Query('householdId') String? householdId,
  });

  @POST('/cats')
  Future<ApiResponse<CatModel>> createCat(@Body() CreateCatRequestV2 request);

  // Update and delete methods (V2 compatible)
  @PUT('/cats/{id}')
  Future<ApiResponse<CatModel>> updateCat(
    @Path('id') String id,
    @Body() UpdateCatRequestV2 request,
  );

  @DELETE('/cats/{id}')
  Future<ApiResponse<EmptyResponse>> deleteCat(@Path('id') String id);

  @PATCH('/cats/{id}/weight')
  Future<ApiResponse<CatModel>> updateCatWeight(
    @Path('id') String id,
    @Body() UpdateWeightRequest request,
  );
}

// V2 - Request Model conforme documentação API V2
class CreateCatRequestV2 {
  final String name;
  final String householdId;  // mudou de homeId
  final String? photoUrl;    // mudou de imageUrl
  final DateTime birthdate;  // mudou de birthDate
  final double? weight;
  final int? feedingInterval; // novo campo

  CreateCatRequestV2({
    required this.name,
    required this.householdId,
    this.photoUrl,
    required this.birthdate,
    this.weight,
    this.feedingInterval,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'householdId': householdId,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'birthdate': birthdate.toIso8601String(),
    if (weight != null) 'weight': weight,
    if (feedingInterval != null) 'feeding_interval': feedingInterval,
  };
}

// Request models
class UpdateCatRequestV2 {
  final String? name;
  final String? householdId;
  final String? photoUrl;
  final DateTime? birthdate;
  final double? weight;
  final int? feedingInterval;

  UpdateCatRequestV2({
    this.name,
    this.householdId,
    this.photoUrl,
    this.birthdate,
    this.weight,
    this.feedingInterval,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (householdId != null) 'householdId': householdId,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (birthdate != null) 'birthdate': birthdate!.toIso8601String(),
    if (weight != null) 'weight': weight,
    if (feedingInterval != null) 'feeding_interval': feedingInterval,
  };
}

class UpdateWeightRequest {
  final double weight;

  UpdateWeightRequest({required this.weight});

  Map<String, dynamic> toJson() => {'weight': weight};
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}
