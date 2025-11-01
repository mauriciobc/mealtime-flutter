import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:mealtime_app/features/statistics/data/datasources/statistics_remote_datasource.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';
import 'package:mealtime_app/features/statistics/domain/repositories/statistics_repository.dart';

/// Implementação do repository de estatísticas
/// Segue padrão offline-first: calcula sempre a partir de dados locais
/// e sincroniza em background se necessário
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsLocalDataSource localDataSource;
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, StatisticsData>> getStatistics({
    required PeriodFilter periodFilter,
    String? catId,
    String? householdId,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    try {
      // Estratégia 100% offline-first: SEMPRE calcular a partir de dados locais
      // Não depende de network ou dados remotos - funciona totalmente offline
      debugPrint(
        '[StatisticsRepository] Calculando estatísticas APENAS do banco local...',
      );

      final statistics = await localDataSource.calculateStatistics(
        periodFilter: periodFilter,
        catId: catId,
        householdId: householdId,
        customStartDate: customStartDate,
        customEndDate: customEndDate,
      );

      debugPrint(
        '[StatisticsRepository] Estatísticas calculadas (100% local): '
        '${statistics.totalFeedings} alimentações, '
        'hasData=${statistics.hasData}',
      );

      // Sincronização em background é opcional e não bloqueia
      // Pode falhar silenciosamente sem afetar a experiência do usuário
      _syncInBackground(
        periodFilter: periodFilter,
        catId: catId,
        householdId: householdId,
        customStartDate: customStartDate,
        customEndDate: customEndDate,
      );

      return Right(statistics);
    } catch (e, stackTrace) {
      // Qualquer erro deve ser tratado graciosamente
      // Retornar estatísticas vazias ao invés de falhar completamente
      debugPrint('[StatisticsRepository] Erro ao calcular estatísticas: $e');
      debugPrint('[StatisticsRepository] Stack: $stackTrace');
      
      // Retornar estatísticas vazias para que a UI possa mostrar estado vazio
      // ao invés de uma tela de erro
      return Right(
        const StatisticsData(
          totalFeedings: 0,
          averagePortion: 0,
          activeCats: 0,
          totalConsumption: 0,
          dailyConsumptions: [],
          catConsumptions: [],
          hourlyFeedings: [],
        ),
      );
    }
  }

  /// Sincroniza dados em background
  /// Atualmente apenas loga, mas pode ser usado para atualizar cache
  /// quando o backend retornar dados estruturados
  void _syncInBackground({
    required PeriodFilter periodFilter,
    String? catId,
    String? householdId,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    Future.microtask(() async {
      try {
        debugPrint('[StatisticsRepository] Iniciando sincronização em background...');
        // Tentar buscar da API (pode retornar null se não disponível)
        final remoteStats = await remoteDataSource.getStatistics(
          periodFilter: periodFilter,
          catId: catId,
          householdId: householdId,
          customStartDate: customStartDate,
          customEndDate: customEndDate,
        );

        if (remoteStats != null) {
          debugPrint(
            '[StatisticsRepository] Estatísticas remotas recebidas, '
            'mas usando cálculo local por enquanto',
          );
          // TODO: Quando backend retornar dados estruturados,
          // atualizar cache local aqui se necessário
        }
      } catch (e) {
        debugPrint(
          '[StatisticsRepository] Erro na sincronização em background: $e',
        );
        // Não relançar erro - apenas logar
      }
    });
  }
}

