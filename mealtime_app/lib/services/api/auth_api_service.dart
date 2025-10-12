import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/auth/data/models/user_model.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST(ApiConstants.login)
  Future<ApiResponse<AuthResponse>> login(@Body() LoginRequest request);

  @POST(ApiConstants.register)
  Future<ApiResponse<AuthResponse>> register(@Body() RegisterRequest request);

  @PUT(ApiConstants.refreshToken)
  Future<ApiResponse<AuthResponse>> refreshToken(
    @Body() RefreshTokenRequest request,
  );

  @POST(ApiConstants.logout)
  Future<ApiResponse<EmptyResponse>> logout();

  @POST(ApiConstants.forgotPassword)
  Future<ApiResponse<EmptyResponse>> forgotPassword(
    @Body() ForgotPasswordRequest request,
  );

  @POST(ApiConstants.resetPassword)
  Future<ApiResponse<EmptyResponse>> resetPassword(
    @Body() ResetPasswordRequest request,
  );

  @GET(ApiConstants.profile)
  Future<ApiResponse<UserModel>> getProfile();

  @PUT(ApiConstants.updateProfile)
  Future<ApiResponse<UserModel>> updateProfile(
    @Body() UpdateProfileRequest request,
  );

  @POST(ApiConstants.changePassword)
  Future<ApiResponse<EmptyResponse>> changePassword(
    @Body() ChangePasswordRequest request,
  );
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'household_name')
  final String? householdName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.householdName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'full_name': fullName,
    if (householdName != null) 'household_name': householdName,
  };
}

class RefreshTokenRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String token;
  final String password;

  ResetPasswordRequest({required this.token, required this.password});

  Map<String, dynamic> toJson() => {'token': token, 'password': password};
}

class UpdateProfileRequest {
  final String name;
  final String? avatar;

  UpdateProfileRequest({required this.name, this.avatar});

  Map<String, dynamic> toJson() => {
    'name': name,
    if (avatar != null) 'avatar': avatar,
  };
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'current_password': currentPassword,
    'new_password': newPassword,
  };
}

// ✅ AuthResponse compatível com Supabase Authentication
@JsonSerializable()
class AuthResponse {
  // Campo success só existe em respostas de erro, não em sucesso
  final bool? success;
  
  // Campos do Supabase Auth (snake_case -> camelCase)
  @JsonKey(name: 'access_token')
  final String? accessToken;
  
  @JsonKey(name: 'token_type')
  final String? tokenType;
  
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  
  @JsonKey(name: 'expires_at')
  final int? expiresAt;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  
  // User do Supabase (estrutura diferente de UserModel)
  final UserModel? user;
  
  // Apenas em respostas de erro
  final String? error;
  
  @JsonKey(name: 'requires_email_confirmation')
  final bool? requiresEmailConfirmation;
  
  @JsonKey(name: 'weak_password')
  final dynamic weakPassword;

  AuthResponse({
    this.success,
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.expiresAt,
    this.refreshToken,
    this.user,
    this.error,
    this.requiresEmailConfirmation,
    this.weakPassword,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
  
  /// Helper para verificar se a autenticação foi bem-sucedida
  /// Em sucesso: accessToken existe
  /// Em erro: success == false e error existe
  bool get isSuccess => accessToken != null && accessToken!.isNotEmpty;
  
  /// Verifica se houve erro
  bool get hasError => error != null;
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) =>
      const EmptyResponse();

  Map<String, dynamic> toJson() => {};
}
