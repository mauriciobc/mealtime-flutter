import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_charts/material_charts.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Gráfico de consumo total diário
class DailyConsumptionChart extends StatelessWidget {
  final List<DailyConsumption> dailyConsumptions;

  const DailyConsumptionChart({
    super.key,
    required this.dailyConsumptions,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[DailyConsumptionChart] build called with ${dailyConsumptions.length} consumptions');
    
    if (dailyConsumptions.isEmpty) {
      debugPrint('[DailyConsumptionChart] Empty consumptions, showing empty state');
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);

    // Determinar se deve agrupar por semanas baseado no número de dias
    final shouldGroupByWeeks = dailyConsumptions.length > 30;
    
    // Converter para dados do gráfico com validação rigorosa
    final chartData = shouldGroupByWeeks 
        ? _groupByWeeks(dailyConsumptions)
        : _mapDailyData(dailyConsumptions);

    // Se após filtragem não houver dados válidos, mostrar empty state
    if (chartData.isEmpty) {
      debugPrint('[DailyConsumptionChart] chartData is empty after filtering');
      return _buildEmptyState(context);
    }
    
    debugPrint('[DailyConsumptionChart] Building chart with ${chartData.length} valid data points');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consumo Total Diário (g)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total de ração consumida por dia no período.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                // Validar largura antes de usar
                final double chartWidth;
                if (availableWidth.isFinite && availableWidth > 0) {
                  chartWidth = availableWidth.clamp(200.0, 800.0);
                } else {
                  chartWidth = 400.0; // Fallback seguro
                }
                final chartHeight = 200.0;

                // Validar dados finais antes de passar para o gráfico
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

                // Validação final de largura e altura antes de passar para o gráfico
                final safeWidth = chartWidth.isFinite && chartWidth > 0 
                    ? chartWidth.clamp(200.0, 1000.0) 
                    : 400.0;
                final safeHeight = chartHeight.isFinite && chartHeight > 0 
                    ? chartHeight.clamp(150.0, 500.0) 
                    : 200.0;
                
                return SizedBox(
                  height: safeHeight,
                  width: safeWidth,
                  child: Builder(
                    builder: (context) {
                      try {
                        // PERFORMANCE: Desabilitar grid e values para melhorar Raster
                        return MaterialBarChart(
                          data: validData,
                          width: safeWidth,
                          height: safeHeight,
                          showGrid: false,  // ✅ Desabilitado para melhorar performance
                          showValues: false,  // ✅ Desabilitado para melhorar performance
                          style: BarChartStyle(
                            barColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surface,
                            barSpacing: 0.3,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: shouldGroupByWeeks ? 8 : 9,
                            ),
                            valueStyle: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      } catch (e, stackTrace) {
                        debugPrint('[DailyConsumptionChart] Erro ao renderizar: $e');
                        debugPrint('[DailyConsumptionChart] Stack: $stackTrace');
                        return SizedBox(
                          height: safeHeight,
                          width: safeWidth,
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

  /// Mapeia dados diários diretamente para o gráfico
  List<BarChartData> _mapDailyData(List<DailyConsumption> consumptions) {
    return consumptions
        .map((consumption) {
          try {
            final dateLabel = DateFormat('dd/MM').format(consumption.date);
            final amount = consumption.amount;
            if (!amount.isFinite || amount < 0 || amount.isNaN) {
              return null;
            }
            return BarChartData(
              label: dateLabel,
              value: amount,
            );
          } catch (e) {
            debugPrint('[DailyConsumptionChart] Erro ao processar consumo: $e');
            return null;
          }
        })
        .whereType<BarChartData>()
        .toList();
  }

  /// Agrupa dados diários por semanas para períodos longos
  List<BarChartData> _groupByWeeks(List<DailyConsumption> consumptions) {
    final Map<int, List<DailyConsumption>> weeklyGroups = {};
    
    // Agrupar por semana do ano
    for (final consumption in consumptions) {
      try {
        final weekYear = _getWeekOfYear(consumption.date);
        weeklyGroups.putIfAbsent(weekYear, () => []).add(consumption);
      } catch (e) {
        debugPrint('[DailyConsumptionChart] Erro ao agrupar por semana: $e');
      }
    }

    // Converter para dados do gráfico
    return weeklyGroups.entries
        .map((entry) {
          try {
            final weekNumber = entry.key;
            final weekData = entry.value;
            
            // Calcular média da semana
            final totalAmount = weekData.fold<double>(
              0.0,
              (sum, c) => sum + (c.amount.isFinite && c.amount >= 0 ? c.amount : 0),
            );
            final averageAmount = weekData.isEmpty ? 0.0 : totalAmount / weekData.length;
            
            if (!averageAmount.isFinite || averageAmount < 0 || averageAmount.isNaN) {
              return null;
            }
            
            // Formatação simplificada: "Sem X"
            final label = 'S${weekNumber.toString().padLeft(2, '0')}';
            
            return BarChartData(
              label: label,
              value: averageAmount,
            );
          } catch (e) {
            debugPrint('[DailyConsumptionChart] Erro ao processar semana: $e');
            return null;
          }
        })
        .whereType<BarChartData>()
        .toList()
      ..sort((a, b) {
        // Ordenar por número da semana
        final aWeek = int.tryParse(a.label.substring(1)) ?? 0;
        final bWeek = int.tryParse(b.label.substring(1)) ?? 0;
        return aWeek.compareTo(bWeek);
      });
  }

  /// Obtém o número da semana do ano (1-52)
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    final weekNumber = ((daysDiff + firstDayOfYear.weekday) / 7).ceil();
    return weekNumber.clamp(1, 52);
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
              'Consumo Total Diário (g)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total de ração consumida por dia no período.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

