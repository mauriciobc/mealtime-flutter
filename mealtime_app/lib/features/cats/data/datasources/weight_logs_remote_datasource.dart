import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/services/api/weight_logs_api_service.dart';

/// Interface do data source remoto para Weight Logs V2
abstract class WeightLogsRemoteDataSource {
  /// Lista registros de peso com filtros opcionais
  Future<List<WeightEntry>> getWeightLogs({String? catId, String? householdId});
  
  /// Cria um novo registro de peso
  Future<WeightEntry> createWeightLog(String catId, double weight, DateTime measuredAt, {String? notes});
  
  /// Atualiza um registro de peso existente
  Future<WeightEntry> updateWeightLog(String logId, double? weight, {DateTime? measuredAt, String? notes});
  
  /// Deleta um registro de peso
  Future<void> deleteWeightLog(String logId);
}

/// Implementação do data source remoto usando API V2
class WeightLogsRemoteDataSourceImpl implements WeightLogsRemoteDataSource {
  final WeightLogsApiService apiService;

  WeightLogsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<WeightEntry>> getWeightLogs({String? catId, String? householdId}) async {
    try {
      final apiResponse = await apiService.getWeightLogs(
        catId: catId,
        householdId: householdId,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar registros de peso',
        );
      }

      return apiResponse.data!.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw ServerException('Erro ao buscar registros de peso: ${e.toString()}');
    }
  }

  @override
  Future<WeightEntry> createWeightLog(String catId, double weight, DateTime measuredAt, {String? notes}) async {
    try {
      final request = CreateWeightLogRequest(
        catId: catId,
        weight: weight,
        measuredAt: measuredAt,
        notes: notes,
      );

      final apiResponse = await apiService.createWeightLog(request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao criar registro de peso',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao criar registro de peso: ${e.toString()}');
    }
  }

  @override
  Future<WeightEntry> updateWeightLog(String logId, double? weight, {DateTime? measuredAt, String? notes}) async {
    try {
      final request = UpdateWeightLogRequest(
        id: logId,
        weight: weight,
        measuredAt: measuredAt,
        notes: notes,
      );

      final apiResponse = await apiService.updateWeightLog(request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar registro de peso',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao atualizar registro de peso: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteWeightLog(String logId) async {
    try {
      final apiResponse = await apiService.deleteWeightLog(id: logId);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao excluir registro de peso',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao excluir registro de peso: ${e.toString()}');
    }
  }
}

