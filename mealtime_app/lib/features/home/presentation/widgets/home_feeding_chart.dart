import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design/material_design.dart';
import 'package:material_charts/material_charts.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

class HomeFeedingChart extends StatelessWidget {
  final List<FeedingLog> feedingLogs;
  final Map<String, int> catsCount;

  const HomeFeedingChart({
    super.key,
    required this.feedingLogs,
    required this.catsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (feedingLogs.isEmpty) {
      return _buildEmptyState(context);
    }

    final chartData = _prepareChartData(context);

    if (chartData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alimentações (7 dias)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: M3SpacingToken.space4.value),
                    Text(
                      'Número de alimentações por dia',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const M3EdgeInsets.all(M3SpacingToken.space8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.15),
                        colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: M3Shapes.shapeSmall,
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;

                final double chartWidth;
                if (availableWidth.isFinite && availableWidth > 0) {
                  chartWidth = availableWidth.clamp(200.0, 800.0);
                } else {
                  chartWidth = 400.0;
                }
                final chartHeight = 170.0;

                final validData = chartData.where((data) {
                  return data.value.isFinite &&
                      data.value >= 0 &&
                      !data.value.isNaN;
                }).toList();

                if (validData.isEmpty) {
                  return SizedBox(
                    height: chartHeight,
                    child: Center(
                      child: Text(
                        'Dados inválidos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }

                final safeWidth = chartWidth.isFinite && chartWidth > 0
                    ? chartWidth.clamp(200.0, 1000.0)
                    : 400.0;
                final safeHeight = chartHeight.isFinite && chartHeight > 0
                    ? chartHeight.clamp(150.0, 500.0)
                    : 180.0;

                final barSpacing = 0.3;
                final barWidth =
                    (safeWidth / validData.length) * (1 - barSpacing);
                final maxCornerRadius = (barWidth / 2).clamp(4.0, 50.0);

                return SizedBox(
                  height: safeHeight,
                  width: safeWidth,
                  child: Builder(
                    builder: (context) {
                      try {
                        return MaterialBarChart(
                          data: validData,
                          width: safeWidth,
                          height: safeHeight,
                          showGrid: false,
                          showValues: false,
                          style: BarChartStyle(
                            barColor: colorScheme.primary,
                            backgroundColor: colorScheme.surface,
                            barSpacing: barSpacing,
                            cornerRadius: maxCornerRadius,
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                            valueStyle: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      } catch (e, stackTrace) {
                        debugPrint('[HomeFeedingChart] Erro ao renderizar: $e');
                        debugPrint('[HomeFeedingChart] Stack: $stackTrace');
                        return _buildChartErrorState(
                          context,
                          safeWidth,
                          safeHeight,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartData> _prepareChartData(BuildContext context) {
    final now = DateTime.now();
    final List<BarChartData> chartData = [];
    final locale = Localizations.localeOf(context).toString();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final dayLabel =
          DateFormat('E', locale).format(date).substring(0, 3);

      final dayFeedings = feedingLogs.where((log) {
        final logDateKey = DateFormat('yyyy-MM-dd').format(log.fedAt);
        return logDateKey == dateKey;
      }).length;

      final feedingsValue = dayFeedings.toDouble();
      if (feedingsValue.isFinite &&
          feedingsValue >= 0 &&
          !feedingsValue.isNaN) {
        chartData.add(BarChartData(value: feedingsValue, label: dayLabel));
      }
    }

    return chartData;
  }

  Widget _buildChartErrorState(
    BuildContext context,
    double width,
    double height,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: M3Shapes.shapeMedium,
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hide_image,
              size: 32,
              color: colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: M3SpacingToken.space8.value),
            Text(
              'Gráfico temporariamente indisponível',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alimentações (7 dias)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: M3SpacingToken.space4.value),
                    Text(
                      'Número de alimentações por dia',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const M3EdgeInsets.all(M3SpacingToken.space8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.15),
                        colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: M3Shapes.shapeSmall,
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            SizedBox(
              height: 170,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    SizedBox(height: M3SpacingToken.space8.value),
                    Text(
                      'Nenhuma alimentação registrada',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (catsCount.isEmpty) ...[
                      SizedBox(height: M3SpacingToken.space8.value),
                      Text(
                        'Adicione um gato para começar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
