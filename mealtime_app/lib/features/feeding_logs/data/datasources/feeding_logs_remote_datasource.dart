import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/services/api/feeding_logs_api_service.dart';

/// Interface do data source remoto para Feeding Logs
abstract class FeedingLogsRemoteDataSource {
  Future<List<FeedingLog>> getFeedingLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<FeedingLog> getFeedingLogById(String id);
  Future<FeedingLog> createFeedingLog(FeedingLog feedingLog);
  Future<FeedingLog> updateFeedingLog(FeedingLog feedingLog);
  Future<void> deleteFeedingLog(String id);
  Future<FeedingLog?> getLastFeeding(String catId);
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
      final apiResponse = await apiService.getFeedingLogs(
        catId: catId,
        householdId: householdId,
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
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
  Future<FeedingLog> createFeedingLog(FeedingLog feedingLog) async {
    try {
      final request = CreateFeedingLogRequest(
        catId: feedingLog.catId,
        householdId: feedingLog.householdId,
        mealType: feedingLog.mealType.name,
        amount: feedingLog.amount,
        unit: feedingLog.unit,
        notes: feedingLog.notes,
        fedBy: feedingLog.fedBy,
        fedAt: feedingLog.fedAt,
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
      final request = UpdateFeedingLogRequest(
        mealType: feedingLog.mealType.name,
        amount: feedingLog.amount,
        unit: feedingLog.unit,
        notes: feedingLog.notes,
        fedAt: feedingLog.fedAt,
      );

      final apiResponse = await apiService.updateFeedingLog(
        feedingLog.id,
        request,
      );

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

  @override
  Future<FeedingLog?> getLastFeeding(String catId) async {
    try {
      final apiResponse = await apiService.getLastFeeding(catId);

      if (!apiResponse.success) {
        // Não lançar exceção se não houver última alimentação
        return null;
      }

      return apiResponse.data?.toEntity();
    } catch (e) {
      // Retornar null ao invés de lançar exceção
      return null;
    }
  }
}
