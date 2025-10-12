import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class CompleteMealParams {
  final String mealId;
  final String? notes;
  final double? amount;

  CompleteMealParams({required this.mealId, this.notes, this.amount});
}

class CompleteMeal implements UseCase<Meal, CompleteMealParams> {
  final MealsRepository repository;

  CompleteMeal(this.repository);

  @override
  Future<Either<Failure, Meal>> call(CompleteMealParams params) async {
    return await repository.completeMeal(
      params.mealId,
      params.notes,
      params.amount,
    );
  }
}
