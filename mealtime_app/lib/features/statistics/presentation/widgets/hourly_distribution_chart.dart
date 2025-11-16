import 'package:flutter/material.dart';
import 'package:material_charts/material_charts.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Gráfico de distribuição por horário
class HourlyDistributionChart extends StatelessWidget {
  final List<HourlyFeeding> hourlyFeedings;

  const HourlyDistributionChart({
    super.key,
    required this.hourlyFeedings,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[HourlyDistributionChart] build called with ${hourlyFeedings.length} feedings');
    
    if (hourlyFeedings.isEmpty) {
      debugPrint('[HourlyDistributionChart] Empty feedings, showing empty state');
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);

    // Agrupar horas em intervalos de 3 horas para melhor visualização
    final chartData = _groupHourlyData(hourlyFeedings);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição por Horário',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quantidade de alimentações por hora do dia.',
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

                // Calcular raio máximo para bordas completamente arredondadas
                // barWidth = (chartArea.width / data.length) * (1 - barSpacing)
                // maxRadius = barWidth / 2 (Flutter limita automaticamente)
                final barSpacing = 0.3;
                final barWidth = (chartWidth / validData.length) * (1 - barSpacing);
                final maxCornerRadius = (barWidth / 2).clamp(4.0, 50.0);

                return SizedBox(
                  height: chartHeight,
                  width: chartWidth,
                  child: MaterialBarChart(
                    data: validData,
                    width: chartWidth,
                    height: chartHeight,
                    showGrid: false,  // ✅ Desabilitado para melhorar performance
                    showValues: false,  // ✅ Desabilitado para melhorar performance
                    style: BarChartStyle(
                      barColor: theme.colorScheme.tertiary,
                      backgroundColor: theme.colorScheme.surface,
                      barSpacing: barSpacing,
                      cornerRadius: maxCornerRadius,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 8,
                      ),
                      valueStyle: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Agrupa dados horários em intervalos de 3 horas para melhor visualização
  List<BarChartData> _groupHourlyData(List<HourlyFeeding> hourlyFeedings) {
    final Map<int, int> groupedData = {};

    // Inicializar todos os intervalos de 3 horas com 0
    for (int hour = 0; hour < 24; hour += 3) {
      groupedData[hour] = 0;
    }

    // Agrupar dados por intervalo de 3 horas
    for (final feeding in hourlyFeedings) {
      final groupHour = (feeding.hour ~/ 3) * 3;
      groupedData[groupHour] = (groupedData[groupHour] ?? 0) + feeding.count;
    }

    // Converter para lista ordenada com validação rigorosa
    return groupedData.entries
        .map((entry) {
          try {
            final startHour = entry.key;
            final endHour = (startHour + 3) % 24;
            final label = _formatHourRange(startHour, endHour);
            // Validar valor para evitar NaN ou Infinity
            final value = entry.value.toDouble();
            if (!value.isFinite || value.isNaN || value < 0) {
              return null; // Filtrar valores inválidos
            }
            return BarChartData(
              label: label,
              value: value,
            );
          } catch (e) {
            debugPrint('[HourlyDistributionChart] Erro ao processar entrada: $e');
            return null;
          }
        })
        .whereType<BarChartData>() // Remove nulls
        .toList()
      ..sort((a, b) {
        try {
          // Extrair hora inicial do label para ordenar
          final aHourStr = a.label.split(':')[0];
          final bHourStr = b.label.split(':')[0];
          final aHour = int.tryParse(aHourStr) ?? 0;
          final bHour = int.tryParse(bHourStr) ?? 0;
          return aHour.compareTo(bHour);
        } catch (e) {
          debugPrint('[HourlyDistributionChart] Erro ao ordenar: $e');
          return 0; // Manter ordem original em caso de erro
        }
      });
  }

  String _formatHourRange(int startHour, int endHour) {
    return '${startHour}h-${endHour}h';
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
              'Distribuição por Horário',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quantidade de alimentações por hora do dia.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_outlined,
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

