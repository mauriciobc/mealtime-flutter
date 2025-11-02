import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class GetActiveGoalByCat
    implements UseCase<WeightGoal?, GetActiveGoalByCatParams> {
  final WeightRepository repository;

  GetActiveGoalByCat(this.repository);

  @override
  Future<Either<Failure, WeightGoal?>> call(
    GetActiveGoalByCatParams params,
  ) async {
    return await repository.getActiveGoalByCat(params.catId);
  }
}

class GetActiveGoalByCatParams extends Equatable {
  final String catId;

  const GetActiveGoalByCatParams({required this.catId});

  @override
  List<Object?> get props => [catId];
}

