import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

/// Repository abstrato para Feeding Logs V2
/// Segue os princípios da Clean Architecture
abstract class FeedingLogsRepository {
  /// Lista todos os feeding logs com filtros opcionais
  Future<Either<Failure, List<FeedingLog>>> getFeedingLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Busca um feeding log por ID
  Future<Either<Failure, FeedingLog>> getFeedingLogById(String id);

  /// Cria um novo feeding log
  Future<Either<Failure, FeedingLog>> createFeedingLog(FeedingLog feedingLog);

  /// Cria múltiplos feeding logs em lote (batch)
  Future<Either<Failure, List<FeedingLog>>> createFeedingLogsBatch(
    List<FeedingLog> feedingLogs,
  );

  /// Atualiza um feeding log
  Future<Either<Failure, FeedingLog>> updateFeedingLog(FeedingLog feedingLog);

  /// Deleta um feeding log
  Future<Either<Failure, void>> deleteFeedingLog(String id);

  /// Busca feeding logs de um gato específico
  Future<Either<Failure, List<FeedingLog>>> getFeedingLogsByCat(String catId);

  /// Busca feeding logs de hoje
  Future<Either<Failure, List<FeedingLog>>> getTodayFeedingLogs({
    String? householdId,
    bool forceRemote = false,
  });
}
