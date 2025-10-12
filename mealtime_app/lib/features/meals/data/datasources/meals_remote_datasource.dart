import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/services/api/meals_api_service.dart';

abstract class MealsRemoteDataSource {
  Future<List<Meal>> getMeals();
  Future<List<Meal>> getMealsByCat(String catId);
  Future<Meal> getMealById(String mealId);
  Future<List<Meal>> getTodayMeals();
  Future<Meal> createMeal(Meal meal);
  Future<Meal> updateMeal(Meal meal);
  Future<void> deleteMeal(String mealId);
  Future<Meal> completeMeal(String mealId, String? notes, double? amount);
  Future<Meal> skipMeal(String mealId, String? reason);
}

class MealsRemoteDataSourceImpl implements MealsRemoteDataSource {
  final MealsApiService apiService;

  MealsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<Meal>> getMeals() async {
    try {
      final apiResponse = await apiService.getMeals();

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar refeições',
        );
      }

      return apiResponse.data!
          .map((mealModel) => mealModel.toEntity())
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar refeições: ${e.toString()}');
    }
  }

  @override
  Future<List<Meal>> getMealsByCat(String catId) async {
    try {
      final apiResponse = await apiService.getMeals(catId: catId);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar refeições do gato',
        );
      }

      return apiResponse.data!
          .map((mealModel) => mealModel.toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        'Erro ao buscar refeições do gato: ${e.toString()}',
      );
    }
  }

  @override
  Future<Meal> getMealById(String mealId) async {
    try {
      final apiResponse = await apiService.getMealById(mealId);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar refeição',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao buscar refeição: ${e.toString()}');
    }
  }

  @override
  Future<List<Meal>> getTodayMeals() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final apiResponse = await apiService.getMeals(
        dateFrom: today,
        dateTo: today,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar refeições de hoje',
        );
      }

      return apiResponse.data!
          .map((mealModel) => mealModel.toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        'Erro ao buscar refeições de hoje: ${e.toString()}',
      );
    }
  }

  @override
  Future<Meal> createMeal(Meal meal) async {
    try {
      final request = CreateMealRequest(
        catId: meal.catId,
        homeId: meal.homeId,
        type: meal.type.name,
        scheduledAt: meal.scheduledAt,
        notes: meal.notes,
        amount: meal.amount,
        foodType: meal.foodType,
      );

      final apiResponse = await apiService.createMeal(request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao criar refeição',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao criar refeição: ${e.toString()}');
    }
  }

  @override
  Future<Meal> updateMeal(Meal meal) async {
    try {
      final request = UpdateMealRequest(
        type: meal.type.name,
        scheduledAt: meal.scheduledAt,
        notes: meal.notes,
        amount: meal.amount,
        foodType: meal.foodType,
      );

      final apiResponse = await apiService.updateMeal(meal.id, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar refeição',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao atualizar refeição: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    try {
      final apiResponse = await apiService.deleteMeal(mealId);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao excluir refeição',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao excluir refeição: ${e.toString()}');
    }
  }

  @override
  Future<Meal> completeMeal(
    String mealId,
    String? notes,
    double? amount,
  ) async {
    try {
      final request = CompleteMealRequest(notes: notes, amount: amount);

      final apiResponse = await apiService.completeMeal(mealId, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao completar refeição',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao completar refeição: ${e.toString()}');
    }
  }

  @override
  Future<Meal> skipMeal(String mealId, String? reason) async {
    try {
      final request = SkipMealRequest(reason: reason);

      final apiResponse = await apiService.skipMeal(mealId, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao pular refeição',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao pular refeição: ${e.toString()}');
    }
  }
}
