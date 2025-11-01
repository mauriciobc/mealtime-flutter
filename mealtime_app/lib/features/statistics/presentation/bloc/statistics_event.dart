import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Carrega estatísticas com filtros
class LoadStatistics extends StatisticsEvent {
  final PeriodFilter periodFilter;
  final String? catId;
  final String? householdId;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const LoadStatistics({
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

/// Atualiza filtro de período
class UpdatePeriodFilter extends StatisticsEvent {
  final PeriodFilter periodFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const UpdatePeriodFilter({
    required this.periodFilter,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [periodFilter, customStartDate, customEndDate];
}

/// Atualiza filtro de gato
class UpdateCatFilter extends StatisticsEvent {
  final String? catId;

  const UpdateCatFilter({this.catId});

  @override
  List<Object?> get props => [catId];
}

/// Atualiza filtro de residência
class UpdateHouseholdFilter extends StatisticsEvent {
  final String? householdId;

  const UpdateHouseholdFilter({this.householdId});

  @override
  List<Object?> get props => [householdId];
}

/// Recarrega estatísticas (refresh manual)
class RefreshStatistics extends StatisticsEvent {
  const RefreshStatistics();
}

/// Limpa erro atual
class ClearStatisticsError extends StatisticsEvent {
  const ClearStatisticsError();
}

