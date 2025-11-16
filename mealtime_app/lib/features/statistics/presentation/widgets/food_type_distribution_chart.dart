import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Gráfico de distribuição por tipo de comida usando gráfico de pizza
class FoodTypeDistributionChart extends StatelessWidget {
  final List<CatConsumption> catConsumptions;

  const FoodTypeDistributionChart({
    super.key,
    required this.catConsumptions,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[FoodTypeDistributionChart] build called with ${catConsumptions.length} consumptions');
    
    // Agregar por tipo de comida
    final foodTypeData = _aggregateByFoodType(catConsumptions);
    
    if (foodTypeData.isEmpty) {
      debugPrint('[FoodTypeDistributionChart] Empty food types, showing empty state');
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);

    // Converter para dados do gráfico com validação rigorosa
    final chartData = foodTypeData.entries
        .map((entry) {
          try {
            // Validar valor para evitar NaN ou Infinity
            final percentage = entry.value;
            if (!percentage.isFinite || 
                percentage.isNaN || 
                percentage < 0 || 
                percentage > 100) {
              return null; // Filtrar valores inválidos
            }
            return MapEntry(entry.key, percentage);
          } catch (e) {
            debugPrint('[FoodTypeDistributionChart] Erro ao processar tipo de comida: $e');
            return null;
          }
        })
        .whereType<MapEntry<String, double>>() // Remove nulls
        .toList();

    // Se após filtragem não houver dados válidos, mostrar empty state
    if (chartData.isEmpty) {
      return _buildEmptyState(context);
    }

    // Ordenar por percentual (maior primeiro)
    chartData.sort((a, b) => b.value.compareTo(a.value));

    // Criar legenda com cores
    final colors = _generateColors(theme, chartData.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição por Tipo de Comida (%)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Percentual do consumo total por tipo de comida.',
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

                // Validar dados finais antes de passar para o gráfico
                final validData = chartData.where((entry) {
                  return entry.value.isFinite && 
                      entry.value >= 0 && 
                      entry.value <= 100 &&
                      !entry.value.isNaN;
                }).toList();

                if (validData.isEmpty) {
                  return SizedBox(
                    height: chartSize,
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
                          title: percentage > 5 
                              ? '${percentage.toStringAsFixed(1)}%'
                              : '',
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
              children: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final dataEntry = entry.value;
                final foodType = dataEntry.key;
                final percentage = dataEntry.value;
                // Garantir que temos cor para este índice
                final colorIndex = index < colors.length ? index : index % colors.length;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[colorIndex],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$foodType: ${percentage.toStringAsFixed(1)}%',
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

  /// Agrega consumo por tipo de comida
  /// Filtra entradas sem tipo de comida especificado
  Map<String, double> _aggregateByFoodType(List<CatConsumption> consumptions) {
    final Map<String, double> foodTypeAmounts = {};
    double totalAmount = 0.0;

    // Agrupar por tipo de comida (apenas se tiver tipo especificado)
    for (final consumption in consumptions) {
      // Validar valor
      if (!consumption.amount.isFinite || 
          consumption.amount.isNaN || 
          consumption.amount < 0) {
        continue;
      }

      // Filtrar entradas sem tipo de comida
      final foodType = consumption.foodType;
      if (foodType == null || foodType.trim().isEmpty) {
        continue; // Pular entradas sem tipo de comida
      }

      totalAmount += consumption.amount;
      foodTypeAmounts[foodType] = (foodTypeAmounts[foodType] ?? 0) + consumption.amount;
    }

    // Converter para percentuais
    final foodTypePercentages = <String, double>{};
    for (final entry in foodTypeAmounts.entries) {
      final percentage = totalAmount > 0 
          ? (entry.value / totalAmount) * 100 
          : 0.0;
      foodTypePercentages[entry.key] = percentage;
    }

    return foodTypePercentages;
  }

  List<Color> _generateColors(ThemeData theme, int count) {
    final colors = <Color>[
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
      theme.colorScheme.errorContainer,
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
              'Distribuição por Tipo de Comida (%)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Percentual do consumo total por tipo de comida.',
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

