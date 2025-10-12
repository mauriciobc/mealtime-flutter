import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';

part 'homes_api_service.g.dart';

@RestApi()
abstract class HomesApiService {
  factory HomesApiService(Dio dio, {String baseUrl}) = _HomesApiService;

  /// Lista todos os households do usuário
  /// Endpoint: GET /households
  @GET('/households')
  Future<ApiResponse<List<HouseholdModel>>> getHouseholds();

  /// Cria um novo household
  /// Endpoint: POST /households
  ///
  /// Campos aceitos pela API:
  /// - name (obrigatório)
  /// - description (opcional, mas pode retornar null)
  ///
  /// Campos NÃO suportados:
  /// - address (será ignorado)
  /// - is_active (será ignorado)
  @POST('/households')
  Future<ApiResponse<HouseholdModel>> createHousehold({
    @Field('name') required String name,
    @Field('description') String? description,
  });

  /// Atualiza um household existente
  /// Endpoint: PUT /households/{id}
  @PUT('/households/{id}')
  Future<ApiResponse<HouseholdModel>> updateHousehold({
    @Path('id') required String id,
    @Field('name') required String name,
    @Field('description') String? description,
  });

  /// Deleta um household
  /// Endpoint: DELETE /households/{id}
  @DELETE('/households/{id}')
  Future<ApiResponse<EmptyResponse>> deleteHousehold(@Path('id') String id);

  /// Define household como ativo
  /// Endpoint: POST /households/{id}/set-active
  @POST('/households/{id}/set-active')
  Future<ApiResponse<EmptyResponse>> setActiveHousehold(@Path('id') String id);
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}
