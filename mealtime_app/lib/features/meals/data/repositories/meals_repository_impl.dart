import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/meals/data/datasources/meals_remote_datasource.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class MealsRepositoryImpl implements MealsRepository {
  final MealsRemoteDataSource remoteDataSource;

  MealsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Meal>>> getMeals() async {
    try {
      final meals = await remoteDataSource.getMeals();
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByCat(String catId) async {
    try {
      final meals = await remoteDataSource.getMealsByCat(catId);
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Meal>> getMealById(String mealId) async {
    try {
      final meal = await remoteDataSource.getMealById(mealId);
      return Right(meal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getTodayMeals() async {
    try {
      final meals = await remoteDataSource.getTodayMeals();
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Meal>> createMeal(Meal meal) async {
    try {
      final createdMeal = await remoteDataSource.createMeal(meal);
      return Right(createdMeal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Meal>> updateMeal(Meal meal) async {
    try {
      final updatedMeal = await remoteDataSource.updateMeal(meal);
      return Right(updatedMeal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String mealId) async {
    try {
      await remoteDataSource.deleteMeal(mealId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Meal>> completeMeal(
    String mealId,
    String? notes,
    double? amount,
  ) async {
    try {
      final completedMeal = await remoteDataSource.completeMeal(
        mealId,
        notes,
        amount,
      );
      return Right(completedMeal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Meal>> skipMeal(String mealId, String? reason) async {
    try {
      final skippedMeal = await remoteDataSource.skipMeal(mealId, reason);
      return Right(skippedMeal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}
