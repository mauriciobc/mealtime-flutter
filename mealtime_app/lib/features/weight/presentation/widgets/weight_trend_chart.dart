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
    debugPrint('[WeightTrendChart] 🚀 build() chamado');
    debugPrint('[WeightTrendChart] 📊 weightLogs recebidos: ${weightLogs.length}');
    debugPrint('[WeightTrendChart] 📅 timeRangeDays: $timeRangeDays');
    
    if (weightLogs.isEmpty) {
      debugPrint('[WeightTrendChart] ⚠️ weightLogs está vazio, mostrando empty state');
      return _buildEmptyState(context);
    }

    // Log dos primeiros e últimos logs para debug
    if (weightLogs.isNotEmpty) {
      final firstLog = weightLogs.first;
      final lastLog = weightLogs.last;
      debugPrint('[WeightTrendChart] 📋 Primeiro log: ${firstLog.measuredAt} - ${firstLog.weight}kg');
      debugPrint('[WeightTrendChart] 📋 Último log: ${lastLog.measuredAt} - ${lastLog.weight}kg');
    }

    final theme = Theme.of(context);
    final filteredLogs = _filterByTimeRange(weightLogs);
    
    debugPrint('[WeightTrendChart] 🔍 Logs após filtro: ${filteredLogs.length}');
    
    if (filteredLogs.isEmpty) {
      debugPrint('[WeightTrendChart] ⚠️ filteredLogs está vazio após filtro, mostrando empty state');
      return _buildEmptyState(context);
    }

    // Converter para dados do gráfico
    var chartData = _mapToChartData(filteredLogs);
    debugPrint('[WeightTrendChart] 📈 chartData mapeado: ${chartData.length} pontos');
    
    // Se houver apenas 1 ponto, interpolar para criar um segundo ponto
    if (chartData.length == 1 && filteredLogs.isNotEmpty) {
      debugPrint('[WeightTrendChart] 📊 Apenas 1 registro encontrado, interpolando...');
      chartData = _interpolateSinglePoint(chartData, filteredLogs);
      debugPrint('[WeightTrendChart] 📈 Após interpolação: ${chartData.length} pontos');
    }
    
    if (chartData.isNotEmpty) {
      debugPrint('[WeightTrendChart] 📈 Primeiro ponto: ${chartData.first.label} - ${chartData.first.value}kg');
      debugPrint('[WeightTrendChart] 📈 Último ponto: ${chartData.last.label} - ${chartData.last.value}kg');
    }

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

                // Validar dados com validações mais rigorosas
                final validData = chartData.where((data) {
                  final isValid = data.value.isFinite &&
                      !data.value.isNaN &&
                      !data.value.isInfinite &&
                      data.value > 0 &&
                      data.label.isNotEmpty;
                  
                  if (!isValid) {
                    debugPrint('[WeightTrendChart] ⚠️ Dado inválido filtrado: ${data.label} - ${data.value}');
                    debugPrint('[WeightTrendChart]   isFinite: ${data.value.isFinite}');
                    debugPrint('[WeightTrendChart]   isNaN: ${data.value.isNaN}');
                    debugPrint('[WeightTrendChart]   isInfinite: ${data.value.isInfinite}');
                    debugPrint('[WeightTrendChart]   > 0: ${data.value > 0}');
                  }
                  return isValid;
                }).toList();

                debugPrint('[WeightTrendChart] ✅ Dados válidos: ${validData.length} de ${chartData.length}');

                // Gráfico de linha precisa de pelo menos 2 pontos
                if (validData.length < 2) {
                  debugPrint('[WeightTrendChart] ❌ Insuficientes dados válidos: ${validData.length} pontos (mínimo 2)');
                  return SizedBox(
                    height: chartHeight,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            validData.isEmpty
                                ? 'Dados inválidos'
                                : 'Dados insuficientes',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          Text(
                            'Total: ${chartData.length} pontos, Válidos: ${validData.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          Text(
                            'Mínimo necessário: 2 pontos',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Verificação final antes de passar para o gráfico
                final finalData = validData.map((data) {
                  // Garantir que o valor é absolutamente válido
                  final safeValue = data.value.isFinite &&
                          !data.value.isNaN &&
                          !data.value.isInfinite &&
                          data.value > 0
                      ? data.value
                      : 0.0;
                  
                  if (safeValue != data.value) {
                    debugPrint('[WeightTrendChart] ⚠️ Valor corrigido: ${data.label} de ${data.value} para $safeValue');
                  }
                  
                  return ChartData(
                    label: data.label,
                    value: safeValue,
                  );
                }).where((data) => data.value > 0).toList();

                if (finalData.length < 2) {
                  debugPrint('[WeightTrendChart] ❌ Após validação final, insuficientes dados: ${finalData.length} pontos');
                  return SizedBox(
                    height: chartHeight,
                    child: Center(
                      child: Text(
                        'Dados insuficientes após validação',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }

                debugPrint('[WeightTrendChart] 🎨 Renderizando gráfico com ${finalData.length} pontos válidos');
                return SizedBox(
                  height: chartHeight,
                  width: chartWidth,
                  child: _buildLineChart(context, finalData, chartWidth, chartHeight),
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

  Widget _buildLineChart(
    BuildContext context,
    List<ChartData> data,
    double width,
    double height,
  ) {
    final theme = Theme.of(context);
    
    debugPrint('[WeightTrendChart] 🎨 _buildLineChart chamado com ${data.length} pontos');
    debugPrint('[WeightTrendChart] 📐 Dimensões: $width x $height');
    
    // Validação final dos dados antes de criar o gráfico
    if (data.length < 2) {
      debugPrint('[WeightTrendChart] ❌ Dados insuficientes para gráfico de linha: ${data.length}');
      return SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Text(
            'Gráfico de linha requer pelo menos 2 pontos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }
    
    // Validar dimensões
    if (!width.isFinite || width.isNaN || width <= 0 || 
        !height.isFinite || height.isNaN || height <= 0) {
      debugPrint('[WeightTrendChart] ❌ Dimensões inválidas: $width x $height');
      return SizedBox(
        height: height > 0 ? height : 250.0,
        width: width > 0 ? width : 400.0,
        child: Center(
          child: Text(
            'Dimensões inválidas do gráfico',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }
    
    if (data.isNotEmpty) {
      debugPrint('[WeightTrendChart] 📊 Validação dos dados:');
      bool hasInvalidData = false;
      for (int i = 0; i < data.length; i++) {
        final isValid = data[i].value.isFinite &&
            !data[i].value.isNaN &&
            !data[i].value.isInfinite &&
            data[i].value > 0;
        if (!isValid) {
          hasInvalidData = true;
          debugPrint('[WeightTrendChart] ❌ Ponto inválido [$i]: ${data[i].label} - ${data[i].value}');
        } else if (i < 3) {
          debugPrint('[WeightTrendChart] ✅ Ponto válido [$i]: ${data[i].label} - ${data[i].value}kg');
        }
      }
      if (hasInvalidData) {
        debugPrint('[WeightTrendChart] ❌ ENCONTRADOS DADOS INVÁLIDOS! Não deveria chegar aqui.');
        return SizedBox(
          height: height,
          width: width,
          child: Center(
            child: Text(
              'Dados inválidos detectados',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        );
      }
      if (data.length > 3) {
        debugPrint('[WeightTrendChart]   ... e mais ${data.length - 3} pontos');
      }
    }
    
    try {
      debugPrint('[WeightTrendChart] 🎨 Criando MaterialChartLine...');
      // PERFORMANCE: Desabilitar grid, points e tooltips para melhorar Raster
      final chart = MaterialChartLine(
        data: data,
        width: width,
        height: height,
        showGrid: false,  // ✅ Desabilitado para melhorar performance
        showPoints: false,  // ✅ Desabilitado para melhorar performance
        showTooltips: false,
        style: LineChartStyle(
          lineColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          pointColor: theme.colorScheme.primary,
          strokeWidth: 2.0,
          pointRadius: 3.0,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: data.length > 20 ? 7 : 9,
          ),
        ),
      );
      debugPrint('[WeightTrendChart] ✅ MaterialChartLine criado com sucesso');
      return chart;
    } catch (e, stackTrace) {
      debugPrint('[WeightTrendChart] ❌ Erro ao renderizar: $e');
      debugPrint('[WeightTrendChart] ❌ StackTrace: $stackTrace');
      debugPrint('[WeightTrendChart] ❌ Dados que causaram erro:');
      for (final point in data) {
        debugPrint('[WeightTrendChart]   - ${point.label}: ${point.value} (isFinite: ${point.value.isFinite}, isNaN: ${point.value.isNaN})');
      }
      return SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Erro ao exibir gráfico',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              Text(
                '$e',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
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
    debugPrint('[WeightTrendChart] 🔍 _filterByTimeRange chamado');
    debugPrint('[WeightTrendChart] 📊 Logs recebidos: ${logs.length}');
    
    if (logs.isEmpty) {
      debugPrint('[WeightTrendChart] ⚠️ Logs vazio, retornando lista vazia');
      return [];
    }
    
    // Encontrar a data mais recente (última data registrada)
    final lastDate = logs
        .map((log) => log.measuredAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    
    debugPrint('[WeightTrendChart] 📅 Última data encontrada: $lastDate');
    debugPrint('[WeightTrendChart] 📅 Intervalo: $timeRangeDays dias');
    
    // Calcular a data de início indo para trás a partir da última data
    final startDate = lastDate.subtract(Duration(days: timeRangeDays));
    
    debugPrint('[WeightTrendChart] 📅 Data de início: $startDate');
    debugPrint('[WeightTrendChart] 📅 Data de fim: $lastDate');
    
    final filtered = logs
        .where((log) {
          final isInRange = log.measuredAt.isAfter(startDate) ||
              log.measuredAt.isAtSameMomentAs(startDate);
          if (!isInRange) {
            debugPrint('[WeightTrendChart] ⏭️ Log descartado (antes de startDate): ${log.measuredAt} - ${log.weight}kg');
          }
          return isInRange;
        })
        .where((log) {
          final isBeforeLast = log.measuredAt.isBefore(lastDate) ||
              log.measuredAt.isAtSameMomentAs(lastDate);
          if (!isBeforeLast) {
            debugPrint('[WeightTrendChart] ⏭️ Log descartado (depois de lastDate): ${log.measuredAt} - ${log.weight}kg');
          }
          return isBeforeLast;
        })
        .toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    
    debugPrint('[WeightTrendChart] ✅ Logs filtrados: ${filtered.length} de ${logs.length}');
    if (filtered.isNotEmpty) {
      debugPrint('[WeightTrendChart] 📋 Primeiro log filtrado: ${filtered.first.measuredAt} - ${filtered.first.weight}kg');
      debugPrint('[WeightTrendChart] 📋 Último log filtrado: ${filtered.last.measuredAt} - ${filtered.last.weight}kg');
    }
    
    return filtered;
  }

  List<ChartData> _mapToChartData(List<WeightEntry> logs) {
    debugPrint('[WeightTrendChart] 🗺️ _mapToChartData chamado com ${logs.length} logs');
    
    // Validar e filtrar logs inválidos primeiro
    final validLogs = logs.where((log) {
      final isValid = log.weight.isFinite &&
          !log.weight.isNaN &&
          log.weight > 0;
      if (!isValid) {
        debugPrint('[WeightTrendChart] ⚠️ Log inválido ignorado: ${log.measuredAt} - ${log.weight}kg');
      }
      return isValid;
    }).toList();
    
    debugPrint('[WeightTrendChart] ✅ Logs válidos: ${validLogs.length} de ${logs.length}');
    
    if (validLogs.isEmpty) {
      debugPrint('[WeightTrendChart] ❌ Nenhum log válido encontrado!');
      return [];
    }
    
    // Se houver muitos pontos, agrupar por semana
    if (validLogs.length > 30) {
      debugPrint('[WeightTrendChart] 📅 Agrupando por semanas (${validLogs.length} > 30)');
      return _groupByWeeks(validLogs);
    }

    // Caso contrário, mostrar por dia
    debugPrint('[WeightTrendChart] 📅 Mapeando por dia (${validLogs.length} <= 30)');
    final chartData = validLogs.map((log) {
      final dateLabel = DateFormat('dd/MM').format(log.measuredAt);
      // Garantir que o valor seja válido
      final safeWeight = log.weight.isFinite && !log.weight.isNaN && log.weight > 0
          ? log.weight
          : 0.0;
      final chartPoint = ChartData(
        label: dateLabel,
        value: safeWeight,
      );
      debugPrint('[WeightTrendChart]   📍 $dateLabel: ${safeWeight}kg (original: ${log.weight}kg)');
      return chartPoint;
    }).where((point) {
      // Validação adicional para garantir que não há NaN
      final isValid = point.value.isFinite &&
          !point.value.isNaN &&
          point.value >= 0;
      if (!isValid) {
        debugPrint('[WeightTrendChart] ❌ ChartData inválido filtrado: ${point.label} - ${point.value}');
      }
      return isValid;
    }).toList();
    
    debugPrint('[WeightTrendChart] ✅ ChartData criado: ${chartData.length} pontos');
    return chartData;
  }

  List<ChartData> _groupByWeeks(List<WeightEntry> logs) {
    debugPrint('[WeightTrendChart] 📅 _groupByWeeks chamado com ${logs.length} logs');
    
    final Map<String, List<WeightEntry>> weeklyGroups = {};

    for (final log in logs) {
      // Validar antes de adicionar ao grupo
      if (!log.weight.isFinite || log.weight.isNaN || log.weight <= 0) {
        debugPrint('[WeightTrendChart] ⚠️ Log inválido ignorado no agrupamento: ${log.measuredAt} - ${log.weight}kg');
        continue;
      }
      
      final weekKey = _getWeekKey(log.measuredAt);
      weeklyGroups.putIfAbsent(weekKey, () => []).add(log);
    }

    debugPrint('[WeightTrendChart] 📅 Grupos semanais criados: ${weeklyGroups.length}');

    var chartData = weeklyGroups.entries.map((entry) {
      final weekLabel = entry.key;
      final weekData = entry.value;

      // Filtrar dados inválidos antes de calcular média
      final validWeights = weekData
          .where((log) => log.weight.isFinite && !log.weight.isNaN && log.weight > 0)
          .map((log) => log.weight)
          .toList();

      if (validWeights.isEmpty) {
        debugPrint('[WeightTrendChart] ⚠️ Semana $weekLabel: nenhum peso válido encontrado');
        return null;
      }

      // Calcular média da semana usando apenas valores válidos
      final totalWeight = validWeights.fold<double>(0.0, (sum, weight) => sum + weight);
      final averageWeight = totalWeight / validWeights.length;

      // Validação final para garantir que não há NaN
      if (!averageWeight.isFinite || averageWeight.isNaN || averageWeight <= 0) {
        debugPrint('[WeightTrendChart] ❌ Média inválida calculada para semana $weekLabel: $averageWeight');
        return null;
      }

      debugPrint('[WeightTrendChart]   📍 Semana $weekLabel: ${validWeights.length}/${weekData.length} registros válidos, média ${averageWeight.toStringAsFixed(2)}kg');

      return ChartData(
        label: weekLabel,
        value: averageWeight,
      );
    })
        .whereType<ChartData>()
        .where((point) {
          // Validação adicional para garantir que não há NaN
          final isValid = point.value.isFinite &&
              !point.value.isNaN &&
              point.value > 0;
          if (!isValid) {
            debugPrint('[WeightTrendChart] ❌ ChartData inválido filtrado: ${point.label} - ${point.value}');
          }
          return isValid;
        })
        .toList()
      ..sort((a, b) {
        // Ordenar por semana
        final aWeek = _parseWeekKey(a.label);
        final bWeek = _parseWeekKey(b.label);
        return aWeek.compareTo(bWeek);
      });
    
    debugPrint('[WeightTrendChart] ✅ ChartData agrupado criado: ${chartData.length} pontos');
    
    // Se houver apenas 1 ponto após agrupamento, interpolar
    if (chartData.length == 1 && logs.isNotEmpty) {
      debugPrint('[WeightTrendChart] 📊 Apenas 1 semana encontrada após agrupamento, interpolando...');
      chartData = _interpolateSinglePointForWeeks(chartData, logs);
      debugPrint('[WeightTrendChart] 📈 Após interpolação semanal: ${chartData.length} pontos');
    }
    
    return chartData;
  }

  /// Interpola quando há apenas uma semana no agrupamento
  List<ChartData> _interpolateSinglePointForWeeks(
    List<ChartData> chartData,
    List<WeightEntry> logs,
  ) {
    if (chartData.isEmpty || logs.isEmpty) {
      return chartData;
    }

    final singlePoint = chartData.first;
    
    // Encontrar a última data e calcular início do intervalo
    final lastDate = logs
        .map((log) => log.measuredAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final startDate = lastDate.subtract(Duration(days: timeRangeDays));
    
    // Criar um ponto interpolado no início do intervalo
    final interpolatedLabel = DateFormat('dd/MM').format(startDate);
    final interpolatedPoint = ChartData(
      label: interpolatedLabel,
      value: singlePoint.value,
    );
    
    debugPrint('[WeightTrendChart] 📊 Ponto interpolado (semanal) criado:');
    debugPrint('[WeightTrendChart]   - Início do intervalo: $interpolatedLabel - ${singlePoint.value}kg');
    debugPrint('[WeightTrendChart]   - Semana real: ${singlePoint.label} - ${singlePoint.value}kg');
    
    final result = [interpolatedPoint, singlePoint];
    
    // Ordenar por data
    result.sort((a, b) {
      final aWeek = _parseWeekKey(a.label);
      final bWeek = _parseWeekKey(b.label);
      return aWeek.compareTo(bWeek);
    });
    
    return result;
  }

  /// Interpola quando há apenas um registro no intervalo
  /// Cria um segundo ponto no início do intervalo com o mesmo valor
  List<ChartData> _interpolateSinglePoint(
    List<ChartData> chartData,
    List<WeightEntry> filteredLogs,
  ) {
    if (chartData.isEmpty || filteredLogs.isEmpty) {
      return chartData;
    }

    final singlePoint = chartData.first;
    
    // Calcular o início do intervalo (última data - intervalo)
    final lastDate = filteredLogs
        .map((log) => log.measuredAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final startDate = lastDate.subtract(Duration(days: timeRangeDays));
    
    // Criar um ponto interpolado no início do intervalo
    final interpolatedLabel = DateFormat('dd/MM').format(startDate);
    final interpolatedPoint = ChartData(
      label: interpolatedLabel,
      value: singlePoint.value,
    );
    
    debugPrint('[WeightTrendChart] 📊 Ponto interpolado criado:');
    debugPrint('[WeightTrendChart]   - Início do intervalo: $interpolatedLabel - ${singlePoint.value}kg');
    debugPrint('[WeightTrendChart]   - Dado real: ${singlePoint.label} - ${singlePoint.value}kg');
    
    // Retornar lista ordenada: ponto interpolado (início) e ponto real
    final result = [interpolatedPoint, singlePoint];
    
    // Ordenar por data se necessário (normalmente já estará ordenado)
    result.sort((a, b) {
      try {
        final aParts = a.label.split('/');
        final bParts = b.label.split('/');
        if (aParts.length == 2 && bParts.length == 2) {
          final aMonth = int.tryParse(aParts[1]) ?? 0;
          final aDay = int.tryParse(aParts[0]) ?? 0;
          final bMonth = int.tryParse(bParts[1]) ?? 0;
          final bDay = int.tryParse(bParts[0]) ?? 0;
          
          // Comparar mês primeiro, depois dia
          if (aMonth != bMonth) {
            return aMonth.compareTo(bMonth);
          }
          return aDay.compareTo(bDay);
        }
      } catch (e) {
        debugPrint('[WeightTrendChart] ⚠️ Erro ao ordenar pontos interpolados: $e');
      }
      return 0;
    });
    
    return result;
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

