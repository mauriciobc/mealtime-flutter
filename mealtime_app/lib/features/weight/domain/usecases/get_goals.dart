import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class GetGoals implements UseCase<List<WeightGoal>, GetGoalsParams> {
  final WeightRepository repository;

  GetGoals(this.repository);

  @override
  Future<Either<Failure, List<WeightGoal>>> call(GetGoalsParams params) async {
    return await repository.getGoals(
      catId: params.catId,
      householdId: params.householdId,
    );
  }
}

class GetGoalsParams extends Equatable {
  final String? catId;
  final String? householdId;

  const GetGoalsParams({
    this.catId,
    this.householdId,
  });

  @override
  List<Object?> get props => [catId, householdId];
}

