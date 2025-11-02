import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';

part 'homes_api_service.g.dart';

/// API Service para Households V2
/// Baseado no endpoint /api/v2/households do backend conforme OpenAPI spec
/// NOTA: A maioria dos endpoints V1 foram removidos na V2
/// Usa Dio com baseUrl V2 para garantir uso da API V2 com autenticação JWT/Session
@RestApi()
abstract class HomesApiService {
  factory HomesApiService(Dio dio, {String baseUrl}) = _HomesApiService;

  // V2 - Households endpoints (apenas endpoints disponíveis na V2)
  // Nota: Dio já está configurado com baseUrl /api/v2, então endpoints são relativos a isso
  
  /// Lista todos os households do usuário
  /// Endpoint: GET /households (completo: /api/v2/households)
  /// Nota: O household_id do usuário é enviado automaticamente via header X-Household-ID
  @GET('/households')
  Future<ApiResponse<List<HouseholdModel>>> getHouseholds();

  /// Cria um novo household
  /// Endpoint: POST /households (completo: /api/v2/households)
  @POST('/households')
  Future<ApiResponse<HouseholdModel>> createHousehold({
    @Field('name') required String name,
    @Field('description') String? description,
  });

  /// Busca detalhes de um household específico
  /// Endpoint: GET /households/{id} (completo: /api/v2/households/{id})
  /// Retorna household completo com membros, gatos e owner
  @GET('/households/{id}')
  Future<ApiResponse<HouseholdModel>> getHouseholdById(@Path('id') String id);

  /// Atualiza um household
  /// Endpoint: PATCH /households/{id} (completo: /api/v2/households/{id})
  /// Apenas ADMINs podem atualizar
  @PATCH('/households/{id}')
  Future<ApiResponse<HouseholdModel>> updateHousehold({
    @Path('id') required String id,
    @Body() required Map<String, dynamic> data,
  });

  /// Deleta um household
  /// Endpoint: DELETE /households/{id} (completo: /api/v2/households/{id})
  @DELETE('/households/{id}')
  Future<ApiResponse<EmptyResponse>> deleteHousehold(@Path('id') String id);

  /// Define o household ativo
  /// Endpoint: POST /households/{id}/set-active (completo: /api/v2/households/{id}/set-active)
  @POST('/households/{id}/set-active')
  Future<ApiResponse<EmptyResponse>> setActiveHousehold(@Path('id') String id);

  /// Lista gatos do household
  /// Endpoint: GET /households/{id}/cats (completo: /api/v2/households/{id}/cats)
  @GET('/households/{householdId}/cats')
  Future<ApiResponse<List<dynamic>>> getHouseholdCats(
    @Path('householdId') String householdId,
  );

  /// Adiciona gato ao household
  /// Endpoint: POST /households/{id}/cats (completo: /api/v2/households/{id}/cats)
  @POST('/households/{householdId}/cats')
  Future<ApiResponse<dynamic>> addCatToHousehold(
    @Path('householdId') String householdId,
    @Body() Map<String, dynamic> catData,
  );

  /// Convida membro para household
  /// Endpoint: POST /households/{id}/invite (completo: /api/v2/households/{id}/invite)
  @POST('/households/{householdId}/invite')
  Future<ApiResponse<dynamic>> inviteMember(
    @Path('householdId') String householdId,
    @Body() Map<String, dynamic> inviteData,
  );

  /// Regenera código de convite
  /// Endpoint: PATCH /households/{id}/invite-code (completo: /api/v2/households/{id}/invite-code)
  @PATCH('/households/{householdId}/invite-code')
  Future<ApiResponse<dynamic>> regenerateInviteCode(
    @Path('householdId') String householdId,
  );

  // ==========================================
  // Endpoints de Membros (NOVOS na V2)
  // ==========================================

  /// Lista membros do household
  /// Endpoint: GET /households/{id}/members (completo: /api/v2/households/{id}/members)
  @GET('/households/{householdId}/members')
  Future<ApiResponse<List<dynamic>>> getHouseholdMembers(
    @Path('householdId') String householdId,
  );

  /// Adiciona novo membro ao household
  /// Endpoint: POST /households/{id}/members (completo: /api/v2/households/{id}/members)
  @POST('/households/{householdId}/members')
  Future<ApiResponse<dynamic>> addHouseholdMember(
    @Path('householdId') String householdId,
    @Body() Map<String, dynamic> memberData,
  );

  /// Remove membro do household
  /// Endpoint: DELETE /households/{id}/members/{userId} (completo: /api/v2/households/{id}/members/{userId})
  @DELETE('/households/{householdId}/members/{userId}')
  Future<ApiResponse<EmptyResponse>> removeHouseholdMember({
    @Path('householdId') required String householdId,
    @Path('userId') required String userId,
  });

  // ==========================================
  // Endpoints de Feeding Logs (NOVOS na V2)
  // ==========================================

  /// Busca logs de alimentação do household
  /// Endpoint: GET /households/{id}/feeding-logs (completo: /api/v2/households/{id}/feeding-logs)
  /// Suporta paginação e filtro por gato
  @GET('/households/{householdId}/feeding-logs')
  Future<ApiResponse<List<dynamic>>> getHouseholdFeedingLogs({
    @Path('householdId') required String householdId,
    @Query('catId') String? catId,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  // DEPRECATED V1 endpoints - a maioria foi removida na V2
  // Apenas manter se necessário para compatibilidade temporária
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}