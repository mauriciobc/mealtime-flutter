import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

class GetTodayFeedingLogs {
  final FeedingLogsRepository repository;

  GetTodayFeedingLogs(this.repository);

  Future<Either<Failure, List<FeedingLog>>> call({String? householdId}) async {
    return await repository.getTodayFeedingLogs(householdId: householdId);
  }
}
