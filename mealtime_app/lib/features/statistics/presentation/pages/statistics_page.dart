import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/cat_distribution_chart.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/daily_consumption_chart.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/food_type_distribution_chart.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/hourly_distribution_chart.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/statistics_filters.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/statistics_header.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/statistics_summary_cards.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    context.read<CatsBloc>().add(const LoadCats());
    context.read<StatisticsBloc>().add(
          const LoadStatistics(
            periodFilter: PeriodFilter.week,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statistics_title),
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return LoadingWidget(message: context.l10n.statistics_loading);
          }

          if (state is StatisticsError) {
            return _buildErrorState(state.failure.message);
          }

          if (state is StatisticsLoaded) {
            return _buildContent(state);
          }

          return LoadingWidget(message: context.l10n.statistics_loading);
        },
      ),
    );
  }

  Widget _buildContent(StatisticsLoaded state) {
    final householdId = state.householdId;

    return SingleChildScrollView(
      padding: const M3EdgeInsets.all(M3SpacingToken.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StatisticsHeader(),
          SizedBox(height: M3SpacingToken.space16.value),
          BlocBuilder<CatsBloc, CatsState>(
            builder: (context, catsState) {
              String? effectiveHouseholdId = householdId;
              if (effectiveHouseholdId == null &&
                  catsState is CatsLoaded &&
                  catsState.cats.isNotEmpty) {
                effectiveHouseholdId = catsState.cats.first.homeId;
              }
              return StatisticsFilters(
                selectedPeriod: state.periodFilter,
                selectedCatId: state.catId,
                householdId: effectiveHouseholdId,
              );
            },
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          if (state.statistics.hasData) ...[
            StatisticsSummaryCards(statistics: state.statistics),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildChartSafe(
              () => DailyConsumptionChart(
                dailyConsumptions: state.statistics.dailyConsumptions,
              ),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildChartSafe(
              () => CatDistributionChart(
                catConsumptions: state.statistics.catConsumptions,
              ),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildChartSafe(
              () => FoodTypeDistributionChart(
                catConsumptions: state.statistics.catConsumptions,
              ),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildChartSafe(
              () => HourlyDistributionChart(
                hourlyFeedings: state.statistics.hourlyFeedings,
              ),
            ),
            SizedBox(height: M3SpacingToken.space32.value),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildChartSafe(Widget Function() builder) {
    return Builder(
      builder: (context) {
        try {
          return builder();
        } catch (e, stackTrace) {
          debugPrint('[StatisticsPage] Erro ao renderizar gráfico: $e');
          debugPrint('[StatisticsPage] Stack: $stackTrace');
          return Container(
            height: 200,
            margin: const M3EdgeInsets.symmetric(vertical: M3SpacingToken.space8),
            padding: const M3EdgeInsets.all(M3SpacingToken.space16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  SizedBox(height: M3SpacingToken.space8.value),
                  Text(
                    context.l10n.statistics_chartError,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }



  Widget _buildEmptyState() {
    return Padding(
      padding: const M3EdgeInsets.all(M3SpacingToken.space32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            Text(
              context.l10n.statistics_noData,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: M3SpacingToken.space8.value),
            Text(
              context.l10n.statistics_noDataPeriod,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            Text(
              context.l10n.statistics_errorLoading,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: M3SpacingToken.space8.value),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            ElevatedButton.icon(
              onPressed: () {
                context.read<StatisticsBloc>().add(
                      const LoadStatistics(
                        periodFilter: PeriodFilter.week,
                      ),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.common_retry),
            ),
          ],
        ),
      ),
    );
  }
}