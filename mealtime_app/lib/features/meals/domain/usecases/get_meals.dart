import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class GetMeals implements UseCase<List<Meal>, NoParams> {
  final MealsRepository repository;

  GetMeals(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(NoParams params) async {
    return await repository.getMeals();
  }
}
