import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/cats/data/models/cat_model.dart';
import 'package:mealtime_app/features/cats/data/models/weight_entry_model.dart';

part 'cats_api_service.g.dart';

@RestApi()
abstract class CatsApiService {
  factory CatsApiService(Dio dio, {String baseUrl}) = _CatsApiService;

  @GET(ApiConstants.cats)
  Future<ApiResponse<List<CatModel>>> getCats();

  @GET('/cats/{id}')
  Future<ApiResponse<CatModel>> getCatById(@Path('id') String id);

  @POST('/cats')
  Future<ApiResponse<CatModel>> createCat(@Body() CreateCatRequest request);

  @PUT('/cats/{id}')
  Future<ApiResponse<CatModel>> updateCat(
    @Path('id') String id,
    @Body() UpdateCatRequest request,
  );

  @DELETE('/cats/{id}')
  Future<ApiResponse<EmptyResponse>> deleteCat(@Path('id') String id);

  @GET('/cats/{catId}/weight')
  Future<ApiResponse<List<WeightEntryModel>>> getWeightHistory(
    @Path('catId') String catId,
  );

  @POST('/cats/{catId}/weight')
  Future<ApiResponse<WeightEntryModel>> addWeightEntry(
    @Path('catId') String catId,
    @Body() AddWeightEntryRequest request,
  );

  @PUT('/cats/{catId}/weight/{entryId}')
  Future<ApiResponse<WeightEntryModel>> updateWeightEntry(
    @Path('catId') String catId,
    @Path('entryId') String entryId,
    @Body() UpdateWeightEntryRequest request,
  );

  @DELETE('/cats/{catId}/weight/{entryId}')
  Future<ApiResponse<EmptyResponse>> deleteWeightEntry(
    @Path('catId') String catId,
    @Path('entryId') String entryId,
  );

  @GET('/homes/{homeId}/cats')
  Future<ApiResponse<List<CatModel>>> getCatsByHome(
    @Path('homeId') String homeId,
  );

  @PUT('/cats/{catId}/weight')
  Future<ApiResponse<CatModel>> updateCatWeight(
    @Path('catId') String catId,
    @Body() UpdateCatWeightRequest request,
  );
}

class CreateCatRequest {
  final String name;
  final String? breed;
  final DateTime birthDate;
  final String? gender;
  final String? color;
  final String? description;
  final String? imageUrl;
  final double? currentWeight;
  final double? targetWeight;
  final String homeId;

  CreateCatRequest({
    required this.name,
    this.breed,
    required this.birthDate,
    this.gender,
    this.color,
    this.description,
    this.imageUrl,
    this.currentWeight,
    this.targetWeight,
    required this.homeId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (breed != null) 'breed': breed,
    'birth_date': birthDate.toIso8601String(),
    if (gender != null) 'gender': gender,
    if (color != null) 'color': color,
    if (description != null) 'description': description,
    if (imageUrl != null) 'image_url': imageUrl,
    if (currentWeight != null) 'current_weight': currentWeight,
    if (targetWeight != null) 'target_weight': targetWeight,
    'home_id': homeId,
  };
}

class UpdateCatRequest {
  final String? name;
  final String? breed;
  final DateTime? birthDate;
  final String? gender;
  final String? color;
  final String? description;
  final String? imageUrl;
  final double? currentWeight;
  final double? targetWeight;
  final String? homeId;

  UpdateCatRequest({
    this.name,
    this.breed,
    this.birthDate,
    this.gender,
    this.color,
    this.description,
    this.imageUrl,
    this.currentWeight,
    this.targetWeight,
    this.homeId,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (breed != null) 'breed': breed,
    if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
    if (gender != null) 'gender': gender,
    if (color != null) 'color': color,
    if (description != null) 'description': description,
    if (imageUrl != null) 'image_url': imageUrl,
    if (currentWeight != null) 'current_weight': currentWeight,
    if (targetWeight != null) 'target_weight': targetWeight,
    if (homeId != null) 'home_id': homeId,
  };
}

class AddWeightEntryRequest {
  final double weight;
  final DateTime measuredAt;
  final String? notes;

  AddWeightEntryRequest({
    required this.weight,
    required this.measuredAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'measured_at': measuredAt.toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}

class UpdateWeightEntryRequest {
  final double? weight;
  final DateTime? measuredAt;
  final String? notes;

  UpdateWeightEntryRequest({this.weight, this.measuredAt, this.notes});

  Map<String, dynamic> toJson() => {
    if (weight != null) 'weight': weight,
    if (measuredAt != null) 'measured_at': measuredAt!.toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}

class UpdateCatWeightRequest {
  final double weight;

  UpdateCatWeightRequest({required this.weight});

  Map<String, dynamic> toJson() => {'weight': weight};
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}
