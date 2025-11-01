import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Repository abstrato para Estatísticas
/// Segue os princípios da Clean Architecture
abstract class StatisticsRepository {
  /// Busca estatísticas baseado em filtros
  /// [periodFilter]: Filtro de período
  /// [catId]: ID do gato (null para todos)
  /// [householdId]: ID da residência (null para usar ativa)
  /// [customStartDate]: Data inicial para período customizado
  /// [customEndDate]: Data final para período customizado
  Future<Either<Failure, StatisticsData>> getStatistics({
    required PeriodFilter periodFilter,
    String? catId,
    String? householdId,
    DateTime? customStartDate,
    DateTime? customEndDate,
  });
}

