import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class CreateGoal implements UseCase<WeightGoal, WeightGoal> {
  final WeightRepository repository;

  CreateGoal(this.repository);

  @override
  Future<Either<Failure, WeightGoal>> call(WeightGoal goal) async {
    return await repository.createGoal(goal);
  }
}

