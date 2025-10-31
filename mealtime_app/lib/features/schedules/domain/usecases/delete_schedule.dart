import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/schedules/domain/repositories/schedules_repository.dart';

class DeleteSchedule {
  final SchedulesRepository repository;

  DeleteSchedule(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteSchedule(id);
  }
}

