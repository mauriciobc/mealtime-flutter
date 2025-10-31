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
        amount: feedingLog.amount,
        unit: feedingLog.unit,
        notes: feedingLog.notes,
      )).toList();

      // Tentar usar batch endpoint primeiro
      try {
        final batchRequest = CreateFeedingLogsBatchRequest(feedings: requests);
        final apiResponse = await apiService.createFeedingLogsBatch(batchRequest);

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!.map((model) => model.toEntity()).toList();
        }
      } catch (e) {
        // Se batch endpoint não existir (404) ou falhar, usar criação paralela
        // Isso é esperado se o endpoint batch não estiver implementado no backend
      }

      // Fallback: criar em paralelo usando Future.wait
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
      return results.whereType<FeedingLog>().toList();
    } catch (e) {
      throw ServerException(
        'Erro ao registrar alimentações em lote: ${e.toString()}',
      );
    }
  }

  @override
  Future<FeedingLog> createFeedingLog(FeedingLog feedingLog) async {
    try {
      // API spec expects: { catId, meal_type?, amount?, unit?, notes? }
      final request = CreateFeedingLogRequest(
        catId: feedingLog.catId,
        mealType: feedingLog.mealType.name,
        amount: feedingLog.amount,
        unit: feedingLog.unit,
        notes: feedingLog.notes,
      );

      final apiResponse = await apiService.createFeedingLog(request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao registrar alimentação',
        );
      }

      return apiResponse.data!.toEntity();
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
