import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';
import 'package:mealtime_app/services/api/feeding_logs_api_service.dart';

/// Data source remoto para buscar estatísticas da API
/// Tenta usar endpoint de stats quando disponível, mas pode fazer
/// fallback para cálculo local se necessário
abstract class StatisticsRemoteDataSource {
  /// Busca estatísticas da API
  /// Retorna StatisticsData se disponível, caso contrário pode lançar
  /// exception para fallback local
  Future<StatisticsData?> getStatistics({
    required PeriodFilter periodFilter,
    String? catId,
    String? householdId,
    DateTime? customStartDate,
    DateTime? customEndDate,
  });
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final FeedingLogsApiService apiService;

  StatisticsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<StatisticsData?> getStatistics({
    required PeriodFilter periodFilter,
    String? catId,
    String? householdId,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    try {
      // O endpoint atual só aceita householdId
      // Se não tiver householdId, retornar null para usar cálculo local
      if (householdId == null) {
        return null;
      }

      // Tentar buscar stats da API
      final apiResponse = await apiService.getFeedingStats(
        householdId: householdId,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        // Se não tiver dados na API, retornar null para fallback local
        return null;
      }

      // O endpoint retorna um Map genérico
      // Por enquanto, vamos retornar null e deixar o cálculo local fazer o trabalho
      // Futuramente, quando o backend retornar dados estruturados,
      // podemos converter aqui
      // TODO: Implementar conversão quando backend retornar dados estruturados
      return null;
    } catch (e) {
      // Se der erro na API, retornar null para usar cálculo local
      // Isso permite que a funcionalidade funcione offline
      return null;
    }
  }
}

