import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

class CreateFeedingLogsBatch implements UseCase<List<FeedingLog>, List<FeedingLog>> {
  final FeedingLogsRepository repository;

  CreateFeedingLogsBatch(this.repository);

  @override
  Future<Either<Failure, List<FeedingLog>>> call(List<FeedingLog> feedingLogs) async {
    return await repository.createFeedingLogsBatch(feedingLogs);
  }
}

