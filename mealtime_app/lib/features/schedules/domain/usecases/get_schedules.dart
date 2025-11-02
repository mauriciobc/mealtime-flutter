import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';
import 'package:mealtime_app/features/schedules/domain/repositories/schedules_repository.dart';

class GetSchedules {
  final SchedulesRepository repository;

  GetSchedules(this.repository);

  Future<Either<Failure, List<Schedule>>> call(String householdId) async {
    return await repository.getSchedules(householdId);
  }
}

