import 'package:flutter/material.dart';
import 'package:material_charts/material_charts.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Gráfico de distribuição por gato
/// Usa gráfico de barras horizontais já que material_charts não tem pie chart
class CatDistributionChart extends StatelessWidget {
  final List<CatConsumption> catConsumptions;

  const CatDistributionChart({
    super.key,
    required this.catConsumptions,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[CatDistributionChart] build called with ${catConsumptions.length} consumptions');
    
    if (catConsumptions.isEmpty) {
      debugPrint('[CatDistributionChart] Empty consumptions, showing empty state');
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);

    // Converter para dados do gráfico com validação rigorosa
    final chartData = catConsumptions
        .map((consumption) {
          try {
            // Validar valor para evitar NaN ou Infinity
            final percentage = consumption.percentage;
            if (!percentage.isFinite || 
                percentage.isNaN || 
                percentage < 0 || 
                percentage > 100) {
              return null; // Filtrar valores inválidos
            }
            return BarChartData(
              label: consumption.catName,
              value: percentage,
            );
          } catch (e) {
            debugPrint('[CatDistributionChart] Erro ao processar consumo: $e');
            return null;
          }
        })
        .whereType<BarChartData>() // Remove nulls
        .toList();

    // Se após filtragem não houver dados válidos, mostrar empty state
    if (chartData.isEmpty) {
      return _buildEmptyState(context);
    }

    // Criar legenda com cores
    final colors = _generateColors(theme, chartData.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição por Gato (%)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Percentual do consumo total por gato.',
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
                      data.value <= 100 &&
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
                  child: MaterialBarChart(
                    data: validData,
                    width: chartWidth,
                    height: chartHeight,
                    showGrid: true,
                    showValues: true,
                    style: BarChartStyle(
                      barColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surface,
                      barSpacing: 0.3,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      valueStyle: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Legenda com cores e percentuais
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: catConsumptions.asMap().entries.map((entry) {
                final index = entry.key;
                final consumption = entry.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${consumption.catName}: ${consumption.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _generateColors(ThemeData theme, int count) {
    final colors = <Color>[
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
    ];

    // Repetir cores se necessário
    while (colors.length < count) {
      colors.addAll(colors);
    }

    return colors.take(count).toList();
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
              'Distribuição por Gato (%)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Percentual do consumo total por gato.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart,
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

