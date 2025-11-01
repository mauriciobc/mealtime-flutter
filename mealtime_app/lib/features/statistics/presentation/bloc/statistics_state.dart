import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final StatisticsData statistics;
  final PeriodFilter periodFilter;
  final String? catId;
  final String? householdId;

  const StatisticsLoaded({
    required this.statistics,
    required this.periodFilter,
    this.catId,
    this.householdId,
  });

  @override
  List<Object?> get props => [
        statistics,
        periodFilter,
        catId,
        householdId,
      ];
}

class StatisticsError extends StatisticsState {
  final Failure failure;

  const StatisticsError(this.failure);

  @override
  List<Object> get props => [failure];
}

