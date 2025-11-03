import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/profile/data/models/profile_model.dart';

part 'profile_api_service.g.dart';

/// API Service para Profile V2
/// Baseado no endpoint /api/v2/profile do backend conforme OpenAPI spec
/// Usa Dio com baseUrl V2 para garantir uso da API V2 com autenticação JWT/Session
@RestApi(baseUrl: ApiConstants.baseUrlV2)
abstract class ProfileApiService {
  factory ProfileApiService(Dio dio, {String baseUrl}) = _ProfileApiService;

  /// Busca perfil público por ID ou username
  /// Endpoint: GET /profile/{idOrUsername} (completo: /api/v2/profile/{idOrUsername})
  @GET('/profile/{idOrUsername}')
  Future<ApiResponse<ProfileModel>> getProfile(
    @Path('idOrUsername') String idOrUsername,
  );

  /// Atualiza perfil público
  /// Endpoint: PUT /profile/{idOrUsername} (completo: /api/v2/profile/{idOrUsername})
  /// 
  /// NOTA: O parâmetro `request` é não-nullable. Após regenerar o código com
  /// build_runner, verificar se a validação de null foi preservada no arquivo .g.dart
  /// na linha onde `request.toJson()` é chamado.
  @PUT('/profile/{idOrUsername}')
  Future<ApiResponse<ProfileModel>> updateProfile(
    @Path('idOrUsername') String idOrUsername,
    @Body() ProfileInputModel request,
  );

  // Upload será feito diretamente via Dio no datasource
  // devido a limitações do Retrofit com MultipartFile
}

/// Response model para upload
class UploadResponse {
  final String url;
  final String? filename;

  const UploadResponse({
    required this.url,
    this.filename,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) =>
      UploadResponse(
        url: json['url'] as String,
        filename: json['filename'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        if (filename != null) 'filename': filename,
      };
}

