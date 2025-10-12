import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

class DeleteFeedingLog implements UseCase<void, String> {
  final FeedingLogsRepository repository;

  DeleteFeedingLog(this.repository);

  @override
  Future<Either<Failure, void>> call(String mealId) async {
    return await repository.deleteFeedingLog(mealId);
  }
}
