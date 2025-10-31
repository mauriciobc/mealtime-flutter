import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/network/token_manager.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';

abstract class HomesRemoteDataSource {
  Future<List<HouseholdModel>> getHomes();
  Future<HouseholdModel> createHome({
    required String name,
    String? description,
  });
  Future<HouseholdModel> updateHome({
    required String id,
    required String name,
    String? description,
  });
  Future<void> deleteHome(String id);
  Future<void> setActiveHome(String id);
}

class HomesRemoteDataSourceImpl implements HomesRemoteDataSource {
  final HomesApiService apiService;

  HomesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<HouseholdModel>> getHomes() async {
    try {
      // Obter household_id do perfil do usuário (será enviado via header pelo AuthInterceptor)
      final householdId = await TokenManager.getHouseholdId();
      
      debugPrint('[HomesRemoteDataSource] Chamando API V2 getHouseholds...');
      debugPrint('[HomesRemoteDataSource] Endpoint: GET /api/v2/households');
      if (householdId != null) {
        debugPrint('[HomesRemoteDataSource] Household ID do perfil: $householdId (enviado via header X-Household-ID)');
      } else {
        debugPrint('[HomesRemoteDataSource] Nenhum household_id encontrado no perfil - usando apenas token');
      }
      
      final apiResponse = await apiService.getHouseholds();
      debugPrint('[HomesRemoteDataSource] Resposta recebida - success: ${apiResponse.success}, error: ${apiResponse.error}');
      debugPrint('[HomesRemoteDataSource] Data: ${apiResponse.data?.length ?? 0} items');

      if (!apiResponse.success) {
        final errorMessage = apiResponse.error ?? 'Erro desconhecido ao buscar residências';
        debugPrint('[HomesRemoteDataSource] Erro na resposta: $errorMessage');
        throw ServerException(errorMessage);
      }

      // Retornar lista vazia se data for null, em vez de lançar erro
      final result = apiResponse.data ?? [];
      debugPrint('[HomesRemoteDataSource] Retornando ${result.length} households');
      return result;
    } on DioException catch (e) {
      // Capturar informações detalhadas do DioException
      final statusCode = e.response?.statusCode;
      final statusMessage = e.response?.statusMessage;
      final responseData = e.response?.data;
      final requestPath = e.requestOptions.path;
      final baseUrl = e.requestOptions.baseUrl;
      final fullUrl = '$baseUrl$requestPath';
      final queryParams = e.requestOptions.queryParameters;
      final headers = e.requestOptions.headers;
      
      debugPrint('[HomesRemoteDataSource] DioException capturada:');
      debugPrint('  - Tipo: ${e.type}');
      debugPrint('  - Status Code: $statusCode');
      debugPrint('  - Status Message: $statusMessage');
      debugPrint('  - Base URL: $baseUrl');
      debugPrint('  - Path: $requestPath');
      debugPrint('  - URL Completa: $fullUrl');
      debugPrint('  - Query Parameters: $queryParams');
      debugPrint('  - Headers: ${headers.keys.toList()}');
      debugPrint('  - Response Data: $responseData');
      debugPrint('  - Mensagem: ${e.message}');
      
      // Mensagem de erro mais detalhada
      String errorMessage;
      if (statusCode == 401) {
        errorMessage = 'Não autorizado. Por favor, faça login novamente.';
      } else if (statusCode == 404) {
        errorMessage = 'Endpoint não encontrado. Verifique a configuração da API.';
      } else if (statusCode != null) {
        errorMessage = 'Erro HTTP $statusCode: ${statusMessage ?? e.message ?? "Erro desconhecido"}';
      } else {
        errorMessage = 'Erro de conexão: ${e.message ?? "Não foi possível conectar ao servidor"}';
      }
      
      // Se há dados na resposta de erro, incluí-los
      if (responseData != null) {
        if (responseData is Map) {
          final apiError = responseData['error'] ?? responseData['message'];
          if (apiError != null) {
            errorMessage = apiError.toString();
          }
        }
      }
      
      throw ServerException(errorMessage);
    } catch (e, stackTrace) {
      debugPrint('[HomesRemoteDataSource] Exceção capturada: $e');
      debugPrint('[HomesRemoteDataSource] Stack trace: $stackTrace');
      
      // Se já é ServerException, re-lançar
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Erro ao buscar residências: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> createHome({
    required String name,
    String? description,
  }) async {
    try {
      final apiResponse = await apiService.createHousehold(
        name: name,
        description: description,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao criar residência',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao criar residência: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> updateHome({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      // V2 API usa PATCH com body JSON, não @Field
      final updateData = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
      };
      
      final apiResponse = await apiService.updateHousehold(
        id: id,
        data: updateData,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar residência',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao atualizar residência: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHome(String id) async {
    try {
      final apiResponse = await apiService.deleteHousehold(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao excluir residência',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao excluir residência: ${e.toString()}');
    }
  }

  @override
  Future<void> setActiveHome(String id) async {
    try {
      final apiResponse = await apiService.setActiveHousehold(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao definir residência ativa',
        );
      }
    } catch (e) {
      throw ServerException(
        'Erro ao definir residência ativa: ${e.toString()}',
      );
    }
  }
}
