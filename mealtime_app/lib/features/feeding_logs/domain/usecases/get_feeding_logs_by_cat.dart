import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

class GetFeedingLogsByCat implements UseCase<List<FeedingLog>, String> {
  final FeedingLogsRepository repository;

  GetFeedingLogsByCat(this.repository);

  @override
  Future<Either<Failure, List<FeedingLog>>> call(String catId) async {
    return await repository.getFeedingLogsByCat(catId);
  }
}
