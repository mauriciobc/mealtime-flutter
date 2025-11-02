import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

class GetFeedingLogs implements UseCase<List<FeedingLog>, NoParams> {
  final FeedingLogsRepository repository;

  GetFeedingLogs(this.repository);

  @override
  Future<Either<Failure, List<FeedingLog>>> call(NoParams params) async {
    return await repository.getFeedingLogs();
  }
}
