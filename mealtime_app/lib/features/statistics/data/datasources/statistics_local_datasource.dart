import 'package:flutter/foundation.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/daos/cats_dao.dart';
import 'package:mealtime_app/core/database/daos/feeding_logs_dao.dart';
import 'package:mealtime_app/core/database/mappers/feeding_log_mapper.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart' as domain;
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Data source local para calcular estatísticas a partir de dados locais
/// Implementa lógica offline-first calculando estatísticas a partir de
/// feeding logs armazenados no banco local (Drift)
abstract class StatisticsLocalDataSource {
  Future<StatisticsData> calculateStatistics({
    required PeriodFilter periodFilter,
    String? catId,
    String? householdId,
    DateTime? customStartDate,
    DateTime? customEndDate,
  });
}

class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  final AppDatabase database;
  late final FeedingLogsDao _feedingLogsDao;
  late final CatsDao _catsDao;

  StatisticsLocalDataSourceImpl({required this.database}) {
    _feedingLogsDao = FeedingLogsDao(database);
    _catsDao = CatsDao(database);
  }

  @override
  Future<StatisticsData> calculateStatistics({
    required PeriodFilter periodFilter,
    String? catId,
    String? householdId,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    debugPrint(
      '[StatisticsLocalDataSource] Calculando estatísticas: '
      'periodFilter=$periodFilter, catId=$catId, householdId=$householdId',
    );
    
    // 1. Calcular range de datas
    final (startDate, endDate) = periodFilter.getDateRange(
      customStart: customStartDate,
      customEnd: customEndDate,
    );
    
    debugPrint(
      '[StatisticsLocalDataSource] Range de datas: '
      '$startDate até $endDate',
    );

    // 2. Buscar feeding logs do período
    final allFeedingLogs = await _feedingLogsDao.getAllFeedingLogs();
    debugPrint(
      '[StatisticsLocalDataSource] Total de feeding logs no banco: '
      '${allFeedingLogs.length}',
    );
    
    // Filtrar logs: período, catId, householdId e isDeleted
    final filteredLogs = allFeedingLogs.where((log) {
      // Filtrar registros deletados
      if (log.isDeleted) {
        return false;
      }
      
      // Filtrar por período
      // Comparar apenas a data (sem hora) para incluir todo o dia
      final logDate = DateTime(
        log.fedAt.year,
        log.fedAt.month,
        log.fedAt.day,
      );
      final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      
      // Verificar se a data do log está no intervalo (inclusive)
      if (logDate.isBefore(startDateOnly) || logDate.isAfter(endDateOnly)) {
        return false;
      }

      // Filtrar por catId se especificado
      if (catId != null && log.catId != catId) {
        return false;
      }

      // Filtrar por householdId se especificado
      if (householdId != null && log.householdId != householdId) {
        return false;
      }

      return true;
    }).toList();
    
    debugPrint(
      '[StatisticsLocalDataSource] Feeding logs após filtro: '
      '${filteredLogs.length}',
    );

    // Converter para domain entities
    final domainLogs =
        FeedingLogMapper.fromDriftFeedingLogs(filteredLogs);
    
    debugPrint(
      '[StatisticsLocalDataSource] Domain logs convertidos: '
      '${domainLogs.length}',
    );

    // 3. Buscar gatos para obter nomes
    final allCats = await _catsDao.getAllCats();
    final catsMap = {
      for (final cat in allCats) cat.id: cat.name,
    };

    // Filtrar gatos por householdId se especificado
    final relevantCats = householdId != null
        ? allCats.where((cat) => cat.householdId == householdId).toList()
        : allCats;

    // Filtrar por catId se especificado
    final activeCatsSet = catId != null
        ? {catId}
        : relevantCats.map((cat) => cat.id).toSet();

    // 4. Calcular estatísticas agregadas
    final result = _calculateStatisticsFromLogs(
      domainLogs,
      catsMap,
      activeCatsSet.length,
      startDate,
      endDate,
    );
    
    debugPrint(
      '[StatisticsLocalDataSource] Estatísticas calculadas: '
      'totalFeedings=${result.totalFeedings}, '
      'hasData=${result.hasData}',
    );
    
    return result;
  }

  /// Calcula estatísticas a partir de lista de feeding logs
  StatisticsData _calculateStatisticsFromLogs(
    List<domain.FeedingLog> logs,
    Map<String, String> catsMap,
    int activeCats,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (logs.isEmpty) {
      return const StatisticsData(
        totalFeedings: 0,
        averagePortion: 0,
        activeCats: 0,
        totalConsumption: 0,
        dailyConsumptions: [],
        catConsumptions: [],
        hourlyFeedings: [],
      );
    }

    // Converter todas as quantidades para gramas
    final logsWithAmounts = logs.where((log) => log.amount != null).toList();
    final totalFeedings = logs.length;
    final totalConsumption = logsWithAmounts.fold<double>(
      0,
      (sum, log) => sum + _convertToGrams(log.amount!, log.unit ?? 'g'),
    );
    final averagePortion = logsWithAmounts.isEmpty
        ? 0.0
        : totalConsumption / logsWithAmounts.length;

    // Calcular consumo diário
    final dailyConsumptions = _calculateDailyConsumptions(
      logsWithAmounts,
      startDate,
      endDate,
    );

    // Calcular consumo por gato
    final catConsumptions = _calculateCatConsumptions(
      logsWithAmounts,
      catsMap,
      totalConsumption,
    );

    // Calcular distribuição por horário
    final hourlyFeedings = _calculateHourlyFeedings(logs);

    return StatisticsData(
      totalFeedings: totalFeedings,
      averagePortion: averagePortion,
      activeCats: activeCats,
      totalConsumption: totalConsumption,
      dailyConsumptions: dailyConsumptions,
      catConsumptions: catConsumptions,
      hourlyFeedings: hourlyFeedings,
    );
  }

  /// Converte quantidade para gramas
  double _convertToGrams(double amount, String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case 'gram':
      case 'grams':
        return amount;
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return amount * 1000;
      case 'ml':
      case 'milliliter':
      case 'milliliters':
        // Assumindo que 1ml ≈ 1g para ração úmida
        return amount;
      default:
        // Assumir gramas como padrão
        return amount;
    }
  }

  /// Calcula consumo diário agrupado por data
  List<DailyConsumption> _calculateDailyConsumptions(
    List<domain.FeedingLog> logs,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<DateTime, double> dailyMap = {};

    // Inicializar todos os dias do período com 0
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    while (!currentDate.isAfter(end)) {
      dailyMap[currentDate] = 0;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Agrupar logs por dia
    for (final log in logs) {
      final logDate = DateTime(
        log.fedAt.year,
        log.fedAt.month,
        log.fedAt.day,
      );
      if (log.amount != null) {
        final amountInGrams =
            _convertToGrams(log.amount!, log.unit ?? 'g');
        dailyMap[logDate] = (dailyMap[logDate] ?? 0) + amountInGrams;
      }
    }

    // Converter para lista ordenada
    return dailyMap.entries
        .map((entry) => DailyConsumption(
              date: entry.key,
              amount: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Calcula consumo por gato com percentuais
  /// Agrupa por gato e tipo de comida quando disponível
  List<CatConsumption> _calculateCatConsumptions(
    List<domain.FeedingLog> logs,
    Map<String, String> catsMap,
    double totalConsumption,
  ) {
    // Usar chave composta: catId + foodType (ou apenas catId se foodType for null)
    final Map<String, double> catAmounts = {};
    final Map<String, String?> catFoodTypes = {};

    // Agrupar por gato e tipo de comida
    for (final log in logs) {
      if (log.amount != null) {
        final amountInGrams = _convertToGrams(log.amount!, log.unit ?? 'g');
        // Criar chave única: catId + foodType (ou apenas catId)
        final key = log.foodType != null 
            ? '${log.catId}_${log.foodType}'
            : log.catId;
        
        catAmounts[key] = (catAmounts[key] ?? 0) + amountInGrams;
        // Armazenar o foodType para esta chave
        if (log.foodType != null) {
          catFoodTypes[key] = log.foodType;
        }
      }
    }

    // Converter para lista com percentuais
    final catConsumptions = catAmounts.entries.map((entry) {
      final key = entry.key;
      final catId = key.contains('_') ? key.split('_').first : key;
      final percentage = totalConsumption > 0
          ? (entry.value / totalConsumption) * 100
          : 0.0;
      return CatConsumption(
        catId: catId,
        catName: catsMap[catId] ?? 'Gato desconhecido',
        amount: entry.value,
        percentage: percentage,
        foodType: catFoodTypes[key],
      );
    }).toList();

    // Ordenar por quantidade (maior primeiro)
    catConsumptions.sort((a, b) => b.amount.compareTo(a.amount));

    return catConsumptions;
  }

  /// Calcula distribuição de alimentações por hora do dia
  List<HourlyFeeding> _calculateHourlyFeedings(List<domain.FeedingLog> logs) {
    final Map<int, int> hourlyMap = {};

    // Inicializar todas as horas com 0
    for (int hour = 0; hour < 24; hour++) {
      hourlyMap[hour] = 0;
    }

    // Contar alimentações por hora
    for (final log in logs) {
      final hour = log.fedAt.hour;
      hourlyMap[hour] = (hourlyMap[hour] ?? 0) + 1;
    }

    // Converter para lista ordenada
    return hourlyMap.entries
        .map((entry) => HourlyFeeding(
              hour: entry.key,
              count: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.hour.compareTo(b.hour));
  }
}

