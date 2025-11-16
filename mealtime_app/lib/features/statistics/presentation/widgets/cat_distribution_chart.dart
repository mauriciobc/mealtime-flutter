import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Gráfico de distribuição por gato usando gráfico de pizza (pie chart)
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
            return MapEntry(consumption, percentage);
          } catch (e) {
            debugPrint('[CatDistributionChart] Erro ao processar consumo: $e');
            return null;
          }
        })
        .whereType<MapEntry<CatConsumption, double>>() // Remove nulls
        .toList();

    // Validar dados finais antes de usar no gráfico e legenda
    final validData = chartData.where((entry) {
      return entry.value.isFinite && 
          entry.value >= 0 && 
          entry.value <= 100 &&
          !entry.value.isNaN;
    }).toList();

    // Se após filtragem não houver dados válidos, mostrar empty state
    if (validData.isEmpty) {
      return _buildEmptyState(context);
    }

    // Criar legenda com cores baseado em validData
    final colors = _generateColors(theme, validData.length);

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
              'Percentual do consumo total por gato e tipo de comida.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                // Validar largura antes de usar
                final double chartSize;
                if (availableWidth.isFinite && availableWidth > 0) {
                  chartSize = (availableWidth * 0.8).clamp(200.0, 300.0);
                } else {
                  chartSize = 250.0; // Fallback seguro
                }

                return SizedBox(
                  height: chartSize,
                  width: chartSize,
                  child: PieChart(
                    PieChartData(
                      sections: validData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dataEntry = entry.value;
                        final percentage = dataEntry.value;
                        
                        return PieChartSectionData(
                          value: percentage,
                          title: '${percentage.toStringAsFixed(1)}%',
                          color: colors[index],
                          radius: chartSize * 0.3,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getContrastColor(colors[index]),
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: chartSize * 0.15,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Feedback visual ao tocar
                        },
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
              children: validData.asMap().entries.map((entry) {
                final index = entry.key;
                final dataEntry = entry.value;
                final consumption = dataEntry.key;
                // Criar label com gato e tipo de comida
                final label = consumption.foodType != null
                    ? '${consumption.catName} - ${consumption.foodType}'
                    : consumption.catName;
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
                    Flexible(
                      child: Text(
                        '$label: ${consumption.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  /// Retorna cor de contraste (branco ou preto) baseada na luminância
  Color _getContrastColor(Color color) {
    // Calcular luminância relativa
    final luminance = color.computeLuminance();
    // Se a cor for clara, usar texto escuro; se for escura, usar texto claro
    return luminance > 0.5 ? Colors.black : Colors.white;
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
              'Percentual do consumo total por gato e tipo de comida.',
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

