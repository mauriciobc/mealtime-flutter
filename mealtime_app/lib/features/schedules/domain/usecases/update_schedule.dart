import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';
import 'package:mealtime_app/features/schedules/domain/repositories/schedules_repository.dart';

class UpdateSchedule {
  final SchedulesRepository repository;

  UpdateSchedule(this.repository);

  Future<Either<Failure, Schedule>> call(Schedule schedule) async {
    return await repository.updateSchedule(schedule);
  }
}

