import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_charts/material_charts.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';

/// Gráfico de tendência de peso ao longo do tempo
class WeightTrendChart extends StatelessWidget {
  final List<WeightEntry> weightLogs;
  final WeightGoal? goal;
  final int timeRangeDays;
  final ValueChanged<int>? onTimeRangeChanged;

  const WeightTrendChart({
    super.key,
    required this.weightLogs,
    this.goal,
    this.timeRangeDays = 30,
    this.onTimeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (weightLogs.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    final filteredLogs = _filterByTimeRange(weightLogs);
    
    if (filteredLogs.isEmpty) {
      return _buildEmptyState(context);
    }

    // Converter para dados do gráfico
    final chartData = _mapToChartData(filteredLogs);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendência de Peso',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Evolução do peso ao longo do tempo.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Período',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 30, label: Text('30 dias')),
                    ButtonSegment(value: 60, label: Text('60 dias')),
                    ButtonSegment(value: 90, label: Text('90 dias')),
                  ],
                  selected: {timeRangeDays},
                  onSelectionChanged: (Set<int> selected) {
                    if (onTimeRangeChanged != null) {
                      onTimeRangeChanged!(selected.first);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final double chartWidth;
                if (availableWidth.isFinite && availableWidth > 0) {
                  chartWidth = availableWidth.clamp(200.0, 800.0);
                } else {
                  chartWidth = 400.0;
                }
                final chartHeight = 250.0;

                // Validar dados
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
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: chartHeight,
                  width: chartWidth,
                  child: _buildChart(context, validData, chartWidth, chartHeight),
                );
              },
            ),
            if (goal != null) ...[
              const SizedBox(height: 8),
              _buildGoalLine(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<BarChartData> data,
    double width,
    double height,
  ) {
    final theme = Theme.of(context);
    
    try {
      return MaterialBarChart(
        data: data,
        width: width,
        height: height,
        showGrid: true,
        showValues: false, // Não mostrar valores para não poluir
        style: BarChartStyle(
          barColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          barSpacing: 0.1,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: data.length > 20 ? 7 : 9,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[WeightTrendChart] Erro ao renderizar: $e');
      return SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Text(
            'Erro ao exibir gráfico',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildGoalLine(BuildContext context) {
    if (goal == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 2,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Meta: ${goal!.targetWeight.toStringAsFixed(1)} kg até ${DateFormat('dd/MM/yyyy').format(goal!.targetDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  List<WeightEntry> _filterByTimeRange(List<WeightEntry> logs) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: timeRangeDays));
    
    return logs
        .where((log) => log.measuredAt.isAfter(startDate) ||
            log.measuredAt.isAtSameMomentAs(startDate))
        .toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }

  List<BarChartData> _mapToChartData(List<WeightEntry> logs) {
    // Se houver muitos pontos, agrupar por semana
    if (logs.length > 30) {
      return _groupByWeeks(logs);
    }

    // Caso contrário, mostrar por dia
    return logs.map((log) {
      final dateLabel = DateFormat('dd/MM').format(log.measuredAt);
      return BarChartData(
        label: dateLabel,
        value: log.weight,
      );
    }).toList();
  }

  List<BarChartData> _groupByWeeks(List<WeightEntry> logs) {
    final Map<String, List<WeightEntry>> weeklyGroups = {};

    for (final log in logs) {
      final weekKey = _getWeekKey(log.measuredAt);
      weeklyGroups.putIfAbsent(weekKey, () => []).add(log);
    }

    return weeklyGroups.entries.map((entry) {
      final weekLabel = entry.key;
      final weekData = entry.value;

      // Calcular média da semana
      final totalWeight = weekData.fold<double>(
        0.0,
        (sum, log) => sum + (log.weight.isFinite ? log.weight : 0),
      );
      final averageWeight =
          weekData.isEmpty ? 0.0 : totalWeight / weekData.length;

      return BarChartData(
        label: weekLabel,
        value: averageWeight,
      );
    }).toList()
      ..sort((a, b) {
        // Ordenar por semana
        final aWeek = _parseWeekKey(a.label);
        final bWeek = _parseWeekKey(b.label);
        return aWeek.compareTo(bWeek);
      });
  }

  String _getWeekKey(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return DateFormat('dd/MM').format(startOfWeek);
  }

  int _parseWeekKey(String weekKey) {
    try {
      final parts = weekKey.split('/');
      if (parts.length == 2) {
        final day = int.tryParse(parts[0]) ?? 0;
        final month = int.tryParse(parts[1]) ?? 0;
        return month * 100 + day; // Ordenação simples
      }
    } catch (e) {
      debugPrint('[WeightTrendChart] Erro ao parsear semana: $e');
    }
    return 0;
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendência de Peso',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Evolução do peso ao longo do tempo.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.show_chart_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum dado disponível',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registre pesos para ver a evolução',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

