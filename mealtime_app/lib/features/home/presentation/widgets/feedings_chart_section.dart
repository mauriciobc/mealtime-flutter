import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_charts/material_charts.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';

class FeedingsChartSection extends StatelessWidget {
  const FeedingsChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          return previous.cats.length != current.cats.length ||
              previous.cats.map((e) => e.id).toSet() !=
                  current.cats.map((e) => e.id).toSet();
        }
        return false;
      },
      builder: (context, catsState) {
        return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            final prevLogs = _getFeedingLogsFromState(previous);
            final currLogs = _getFeedingLogsFromState(current);
            return prevLogs.length != currLogs.length;
          },
          builder: (context, feedingLogsState) {
            final cats = catsState is CatsLoaded ? catsState.cats : <Cat>[];
            final feedingLogs = _getFeedingLogsFromState(feedingLogsState);
            final chartData = _prepareChartData(context, feedingLogs, cats);

            return Padding(
              padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.home_feedings_title,
                    style: Theme.of(context).textTheme.titleLargeEmphasized?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space4.value),
                  Text(
                    context.l10n.home_last_7_days,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space12.value),
                  Container(
                    constraints: const BoxConstraints(minHeight: 200, maxHeight: 200),
                    padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: M3Shapes.shapeMedium,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: !chartData.isEmpty
                        ? _ChartWithErrorHandling(chartData: chartData)
                        : const _EmptyChart(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<FeedingLog> _getFeedingLogsFromState(FeedingLogsState state) {
    if (state is FeedingLogsLoaded) return state.feedingLogs;
    if (state is FeedingLogOperationSuccess) return state.feedingLogs;
    if (state is FeedingLogOperationInProgress) return state.feedingLogs;
    return [];
  }

  static List<Color> _getCatColors(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [cs.primary, cs.tertiary, cs.secondary, cs.error, cs.inversePrimary];
  }

  _ChartDataResult _prepareChartData(
    BuildContext context,
    List<FeedingLog> feedingLogs,
    List<Cat> cats,
  ) {
    final now = DateTime.now();
    final catsCount = cats.length;
    final useStackedChart = catsCount <= 5 && catsCount > 0;
    final locale = Localizations.localeOf(context);

    if (useStackedChart) {
      final stackedData = <StackedBarData>[];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final dayLabel = DateFormat('E', locale.toString()).format(date).substring(0, 3);
        final segments = <StackedBarSegment>[];
        final colors = _getCatColors(context);
        for (int catIndex = 0; catIndex < catsCount; catIndex++) {
          if (catIndex >= cats.length) continue;
          final cat = cats[catIndex];
          final count = feedingLogs.where((log) {
            return DateFormat('yyyy-MM-dd').format(log.fedAt) == dateKey &&
                log.catId == cat.id;
          }).length;
          final safeValue = count.toDouble().clamp(0.0, double.maxFinite);
          segments.add(StackedBarSegment(
            value: safeValue.isFinite ? safeValue : 0.0,
            color: colors[catIndex % colors.length],
            label: cat.name,
          ));
        }
        if (segments.isNotEmpty) {
          stackedData.add(StackedBarData(label: dayLabel, segments: segments));
        }
      }
      return _ChartDataResult.stacked(stackedData);
    } else {
      final barData = <BarChartData>[];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final dayLabel = DateFormat('E', locale.toString()).format(date).substring(0, 3);
        final count = feedingLogs.where((log) {
          return DateFormat('yyyy-MM-dd').format(log.fedAt) == dateKey;
        }).length;
        final safeValue = count.toDouble();
        barData.add(BarChartData(
          value: safeValue.isFinite && !safeValue.isNaN ? safeValue : 0.0,
          label: dayLabel,
        ));
      }
      return _ChartDataResult.bar(barData);
    }
  }
}

/// Internal result type for chart data
class _ChartDataResult {
  const _ChartDataResult._({this.stackedData, this.barData});
  factory _ChartDataResult.stacked(List<StackedBarData> data) =>
      _ChartDataResult._(stackedData: data);
  factory _ChartDataResult.bar(List<BarChartData> data) =>
      _ChartDataResult._(barData: data);

  final List<StackedBarData>? stackedData;
  final List<BarChartData>? barData;

  bool get isEmpty =>
      (stackedData == null || stackedData!.isEmpty) &&
      (barData == null || barData!.isEmpty);
}

class _ChartWithErrorHandling extends StatelessWidget {
  const _ChartWithErrorHandling({required this.chartData});
  final _ChartDataResult chartData;

  @override
  Widget build(BuildContext context) {
    try {
      return _ChartWidget(chartData: chartData);
    } catch (_) {
      return const _EmptyChart();
    }
  }
}

class _ChartWidget extends StatelessWidget {
  const _ChartWidget({required this.chartData});
  final _ChartDataResult chartData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;

          final chartWidth = availableWidth.isFinite && availableWidth > 0
              ? availableWidth.clamp(200.0, 1000.0)
              : 400.0;
          final chartHeight = availableHeight.isFinite && availableHeight > 0
              ? availableHeight.clamp(150.0, 500.0)
              : 160.0;

          if (!chartWidth.isFinite || chartWidth <= 0 ||
              !chartHeight.isFinite || chartHeight <= 0) {
            return const _EmptyChart();
          }

          final colorScheme = Theme.of(context).colorScheme;

          if (chartData.stackedData != null) {
            final validData = chartData.stackedData!
                .where((d) => d.segments.every((s) => s.value.isFinite && s.value >= 0))
                .toList();
            if (validData.isEmpty) return const _EmptyChart();
            final hasNonZero = validData.expand((d) => d.segments).any((s) => s.value > 0);
            if (!hasNonZero) return const _EmptyChart();

            return SizedBox(
              width: chartWidth,
              height: chartHeight,
              child: MaterialStackedBarChart(
                data: validData,
                width: chartWidth,
                height: chartHeight,
                showGrid: false,
                showValues: false,
                style: StackedBarChartStyle(
                  backgroundColor: colorScheme.surface,
                  gridColor: colorScheme.outline.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
                  valueStyle: TextStyle(color: colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.w500),
                  barSpacing: 0.3,
                  cornerRadius: 2,
                ),
              ),
            );
          } else {
            final validData = chartData.barData!
                .where((d) => d.value.isFinite && d.value >= 0)
                .toList();
            if (validData.isEmpty) return const _EmptyChart();
            final hasNonZero = validData.any((d) => d.value > 0);
            if (!hasNonZero) return const _EmptyChart();

            const barSpacing = 0.3;
            if (validData.isEmpty || !chartWidth.isFinite || chartWidth <= 0) {
              return const _EmptyChart();
            }
            final calculatedBarWidth = (chartWidth / validData.length) * (1 - barSpacing);
            if (!calculatedBarWidth.isFinite || calculatedBarWidth <= 0) {
              return const _EmptyChart();
            }
            final maxCornerRadius = (calculatedBarWidth / 2).clamp(4.0, 50.0);

            return SizedBox(
              width: chartWidth,
              height: chartHeight,
              child: MaterialBarChart(
                data: validData,
                width: chartWidth,
                height: chartHeight,
                showGrid: false,
                showValues: false,
                style: BarChartStyle(
                  barColor: colorScheme.primary,
                  backgroundColor: colorScheme.surface,
                  barSpacing: barSpacing,
                  cornerRadius: maxCornerRadius,
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
                  valueStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }
        } catch (_) {
          return const _EmptyChart();
        }
      },
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            Text(
              context.l10n.home_no_feeding_recorded,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: M3SpacingToken.space8.value),
            Text(
              context.l10n.home_register_feeding_chart,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
