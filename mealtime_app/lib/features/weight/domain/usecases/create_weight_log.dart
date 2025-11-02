import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class CreateWeightLog implements UseCase<WeightEntry, WeightEntry> {
  final WeightRepository repository;

  CreateWeightLog(this.repository);

  @override
  Future<Either<Failure, WeightEntry>> call(WeightEntry weightLog) async {
    return await repository.createWeightLog(weightLog);
  }
}

