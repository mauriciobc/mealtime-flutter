import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/homes/data/datasources/homes_local_datasource.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/cat_distribution_chart.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/daily_consumption_chart.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/hourly_distribution_chart.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/statistics_filters.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/statistics_header.dart';
import 'package:mealtime_app/features/statistics/presentation/widgets/statistics_summary_cards.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String? _householdId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    String? householdId;
    try {
      final homesLocalDataSource = HomesLocalDataSourceImpl(
        database: GetIt.instance<AppDatabase>(),
        sharedPreferences: GetIt.instance<SharedPreferences>(),
      );
      final activeHome = await homesLocalDataSource.getActiveHome();
      householdId = activeHome?.id;

      if (!mounted) return;
      setState(() {
        _householdId = householdId;
      });
    } catch (e) {
      debugPrint('[StatisticsPage] Erro ao obter household: $e');
      if (!mounted) return;
      setState(() {
        _householdId = null;
      });
    }

    context.read<CatsBloc>().add(const LoadCats());

    if (!mounted) return;

    context.read<StatisticsBloc>().add(
          LoadStatistics(
            periodFilter: PeriodFilter.week,
            householdId: householdId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const LoadingWidget(message: 'Carregando estatísticas...');
          }

          if (state is StatisticsError) {
            return _buildErrorState(state.failure.message);
          }

          if (state is StatisticsLoaded) {
            return _buildContent(state);
          }

          return const LoadingWidget(message: 'Carregando estatísticas...');
        },
      ),
    );
  }

  Widget _buildContent(StatisticsLoaded state) {
    final householdId = state.householdId ?? _householdId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StatisticsHeader(),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          if (state.statistics.hasData) ...[
            StatisticsSummaryCards(statistics: state.statistics),
            const SizedBox(height: 16),
            _buildChartSafe(
              () => DailyConsumptionChart(
                dailyConsumptions: state.statistics.dailyConsumptions,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartSafe(
              () => CatDistributionChart(
                catConsumptions: state.statistics.catConsumptions,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartSafe(
              () => HourlyDistributionChart(
                hourlyFeedings: state.statistics.hourlyFeedings,
              ),
            ),
            const SizedBox(height: 32),
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
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 8),
                  Text(
                    'Erro ao renderizar gráfico',
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
      padding: const EdgeInsets.all(32),
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
            const SizedBox(height: 16),
            Text(
              'Nenhum dado disponível',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Não há alimentações registradas no período selecionado.',
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar estatísticas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<StatisticsBloc>().add(
                      LoadStatistics(
                        periodFilter: PeriodFilter.week,
                        householdId: _householdId,
                      ),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}