import 'dart:developer';

import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/services/api/feeding_logs_api_service.dart';

/// Interface do data source remoto para Feeding Logs V2
abstract class FeedingLogsRemoteDataSource {
  /// Lista feeding logs com filtros opcionais
  Future<List<FeedingLog>> getFeedingLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Busca um feeding log por ID
  Future<FeedingLog> getFeedingLogById(String id);
  
  /// Cria um novo feeding log
  Future<FeedingLog> createFeedingLog(FeedingLog feedingLog);

  /// Cria múltiplos feeding logs em lote (batch)
  /// Retorna lista de feeding logs criados
  Future<List<FeedingLog>> createFeedingLogsBatch(List<FeedingLog> feedingLogs);

  /// Atualiza um feeding log
  Future<FeedingLog> updateFeedingLog(FeedingLog feedingLog);
  
  /// Deleta um feeding log
  Future<void> deleteFeedingLog(String id);
}

/// Implementação do data source remoto usando API REST
class FeedingLogsRemoteDataSourceImpl implements FeedingLogsRemoteDataSource {
  final FeedingLogsApiService apiService;

  FeedingLogsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<FeedingLog>> getFeedingLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // API requires householdId parameter (mandatory per OpenAPI spec)
      if (householdId == null) {
        throw ServerException('householdId é obrigatório para buscar alimentações');
      }

      final apiResponse = await apiService.getFeedingLogs(
        householdId: householdId,
        catId: catId,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar alimentações',
        );
      }

      return apiResponse.data!
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar alimentações: ${e.toString()}');
    }
  }

  @override
  Future<FeedingLog> getFeedingLogById(String id) async {
    try {
      final apiResponse = await apiService.getFeedingLogById(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar alimentação',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao buscar alimentação: ${e.toString()}');
    }
  }

  @override
  Future<List<FeedingLog>> createFeedingLogsBatch(List<FeedingLog> feedingLogs) async {
    try {
      if (feedingLogs.isEmpty) {
        return [];
      }

      // Converter para requests
      final requests = feedingLogs.map((feedingLog) => CreateFeedingLogRequest(
        catId: feedingLog.catId,
        mealType: feedingLog.mealType.name,
        foodType: feedingLog.foodType,
        amount: feedingLog.amount,
        unit: feedingLog.unit,
        notes: feedingLog.notes,
      )).toList();

      // Desabilitar batch endpoint temporariamente - API tem estrutura diferente
      // TODO: Implementar batch endpoint quando API estiver pronta
      log('[FeedingLogsRemoteDataSource] Criando ${requests.length} feedings em paralelo...');
      final results = await Future.wait(
        requests.map((request) async {
          try {
            final apiResponse = await apiService.createFeedingLog(request);
            if (!apiResponse.success) {
              throw ServerException(
                apiResponse.error ?? 'Erro ao registrar alimentação',
              );
            }
            return apiResponse.data!.toEntity();
          } catch (e) {
            throw ServerException(
              'Erro ao registrar alimentação: ${e.toString()}',
            );
          }
        }),
        eagerError: false, // Não falhar imediatamente se uma falhar
      );

      // Filtrar apenas resultados bem-sucedidos
      final successfulResults = results.whereType<FeedingLog>().toList();
      log('[FeedingLogsRemoteDataSource] Feedings criados com sucesso: ${successfulResults.length}/${requests.length}');
      return successfulResults;
    } catch (e) {
      log('[FeedingLogsRemoteDataSource] Erro ao criar feedings em lote: $e');
      throw ServerException(
        'Erro ao registrar alimentações em lote: ${e.toString()}',
      );
    }
  }

  @override
  Future<FeedingLog> createFeedingLog(FeedingLog feedingLog) async {
    try {
      // Validações
      if (feedingLog.catId.isEmpty) {
        throw ServerException('catId é obrigatório para registrar alimentação');
      }
      
      if (feedingLog.fedBy.isEmpty) {
        throw ServerException('fedBy (ID do usuário) é obrigatório para registrar alimentação');
      }

      // API spec expects: { catId, meal_type?, food_type?, amount?, unit?, notes? }
      final request = CreateFeedingLogRequest(
        catId: feedingLog.catId,
        mealType: feedingLog.mealType.name,
        foodType: feedingLog.foodType,
        amount: feedingLog.amount,
        unit: feedingLog.unit ?? 'g', // Default para gramas se não especificado
        notes: feedingLog.notes,
      );

      final apiResponse = await apiService.createFeedingLog(request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao registrar alimentação',
        );
      }

      if (apiResponse.data == null) {
        throw ServerException('Resposta da API não contém dados do feeding log');
      }

      return apiResponse.data!.toEntity();
    } on ServerException {
      rethrow; // Re-lançar ServerException sem modificar
    } catch (e) {
      throw ServerException(
        'Erro ao registrar alimentação: ${e.toString()}',
      );
    }
  }

  @override
  Future<FeedingLog> updateFeedingLog(FeedingLog feedingLog) async {
    try {
      final request = CreateFeedingLogRequest(
        catId: feedingLog.catId,
        mealType: feedingLog.mealType.name,
        foodType: feedingLog.foodType,
        amount: feedingLog.amount,
        unit: feedingLog.unit,
        notes: feedingLog.notes,
      );

      final apiResponse = await apiService.updateFeedingLog(feedingLog.id, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar alimentação',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException(
        'Erro ao atualizar alimentação: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteFeedingLog(String id) async {
    try {
      final apiResponse = await apiService.deleteFeedingLog(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao excluir alimentação',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao excluir alimentação: ${e.toString()}');
    }
  }
}
