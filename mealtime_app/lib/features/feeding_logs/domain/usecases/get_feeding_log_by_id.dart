import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

class GetFeedingLogById implements UseCase<FeedingLog, String> {
  final FeedingLogsRepository repository;

  GetFeedingLogById(this.repository);

  @override
  Future<Either<Failure, FeedingLog>> call(String mealId) async {
    return await repository.getFeedingLogById(mealId);
  }
}
