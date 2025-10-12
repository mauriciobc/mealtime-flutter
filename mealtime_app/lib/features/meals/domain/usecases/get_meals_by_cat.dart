import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class GetMealsByCat implements UseCase<List<Meal>, String> {
  final MealsRepository repository;

  GetMealsByCat(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(String catId) async {
    return await repository.getMealsByCat(catId);
  }
}
