import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

/// Repository abstrato para Feeding Logs
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

  /// Atualiza um feeding log existente
  Future<Either<Failure, FeedingLog>> updateFeedingLog(FeedingLog feedingLog);

  /// Deleta um feeding log
  Future<Either<Failure, void>> deleteFeedingLog(String id);

  /// Busca a última alimentação de um gato
  Future<Either<Failure, FeedingLog?>> getLastFeeding(String catId);
}
