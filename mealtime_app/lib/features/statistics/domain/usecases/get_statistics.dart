import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';
import 'package:mealtime_app/features/statistics/domain/repositories/statistics_repository.dart';

/// Parâmetros para buscar estatísticas
class GetStatisticsParams extends Equatable {
  final PeriodFilter periodFilter;
  final String? catId;
  final String? householdId;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const GetStatisticsParams({
    required this.periodFilter,
    this.catId,
    this.householdId,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [
        periodFilter,
        catId,
        householdId,
        customStartDate,
        customEndDate,
      ];
}

/// Use case para buscar estatísticas
class GetStatistics implements UseCase<StatisticsData, GetStatisticsParams> {
  final StatisticsRepository repository;

  GetStatistics(this.repository);

  @override
  Future<Either<Failure, StatisticsData>> call(
    GetStatisticsParams params,
  ) async {
    return await repository.getStatistics(
      periodFilter: params.periodFilter,
      catId: params.catId,
      householdId: params.householdId,
      customStartDate: params.customStartDate,
      customEndDate: params.customEndDate,
    );
  }
}

