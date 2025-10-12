import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/usecases/complete_meal.dart'
    as complete_meal;
import 'package:mealtime_app/features/meals/domain/usecases/create_meal.dart'
    as create_meal;
import 'package:mealtime_app/features/meals/domain/usecases/delete_meal.dart'
    as delete_meal;
import 'package:mealtime_app/features/meals/domain/usecases/get_meal_by_id.dart';
import 'package:mealtime_app/features/meals/domain/usecases/get_meals.dart';
import 'package:mealtime_app/features/meals/domain/usecases/get_meals_by_cat.dart';
import 'package:mealtime_app/features/meals/domain/usecases/get_today_meals.dart';
import 'package:mealtime_app/features/meals/domain/usecases/skip_meal.dart'
    as skip_meal;
import 'package:mealtime_app/features/meals/domain/usecases/update_meal.dart'
    as update_meal;
import 'package:mealtime_app/features/meals/presentation/bloc/meals_event.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_state.dart';

class MealsBloc extends Bloc<MealsEvent, MealsState> {
  final GetMeals getMeals;
  final GetMealsByCat getMealsByCat;
  final GetMealById getMealById;
  final GetTodayMeals getTodayMeals;
  final create_meal.CreateMeal createMeal;
  final update_meal.UpdateMeal updateMeal;
  final delete_meal.DeleteMeal deleteMeal;
  final complete_meal.CompleteMeal completeMeal;
  final skip_meal.SkipMeal skipMeal;

  MealsBloc({
    required this.getMeals,
    required this.getMealsByCat,
    required this.getMealById,
    required this.getTodayMeals,
    required this.createMeal,
    required this.updateMeal,
    required this.deleteMeal,
    required this.completeMeal,
    required this.skipMeal,
  }) : super(const MealsInitial()) {
    on<LoadMeals>(_onLoadMeals);
    on<LoadMealsByCat>(_onLoadMealsByCat);
    on<LoadMealById>(_onLoadMealById);
    on<LoadTodayMeals>(_onLoadTodayMeals);
    on<CreateMeal>(_onCreateMeal);
    on<UpdateMeal>(_onUpdateMeal);
    on<DeleteMeal>(_onDeleteMeal);
    on<CompleteMeal>(_onCompleteMeal);
    on<SkipMeal>(_onSkipMeal);
    on<RefreshMeals>(_onRefreshMeals);
    on<ClearMealsError>(_onClearMealsError);
  }

  Future<void> _onLoadMeals(LoadMeals event, Emitter<MealsState> emit) async {
    emit(const MealsLoading());

    final result = await getMeals(NoParams());

    result.fold(
      (failure) => emit(MealsError(failure)),
      (meals) => emit(MealsLoaded(meals: meals)),
    );
  }

  Future<void> _onLoadMealsByCat(
    LoadMealsByCat event,
    Emitter<MealsState> emit,
  ) async {
    emit(const MealsLoading());

    final result = await getMealsByCat(event.catId);

    result.fold(
      (failure) => emit(MealsError(failure)),
      (meals) => emit(MealsLoaded(meals: meals)),
    );
  }

  Future<void> _onLoadMealById(
    LoadMealById event,
    Emitter<MealsState> emit,
  ) async {
    emit(const MealsLoading());

    final result = await getMealById(event.mealId);

    result.fold(
      (failure) => emit(MealsError(failure)),
      (meal) => emit(MealLoaded(meal: meal)),
    );
  }

  Future<void> _onLoadTodayMeals(
    LoadTodayMeals event,
    Emitter<MealsState> emit,
  ) async {
    emit(const MealsLoading());

    final result = await getTodayMeals(NoParams());

    result.fold(
      (failure) => emit(MealsError(failure)),
      (meals) => emit(MealsLoaded(meals: meals)),
    );
  }

  Future<void> _onCreateMeal(CreateMeal event, Emitter<MealsState> emit) async {
    final currentState = state;
    if (currentState is MealsLoaded) {
      emit(
        MealOperationInProgress(
          operation: 'Criando refeição...',
          meals: currentState.meals,
        ),
      );
    }

    final result = await createMeal(event.meal);

    result.fold((failure) => emit(MealsError(failure)), (newMeal) {
      if (currentState is MealsLoaded) {
        final updatedMeals = <Meal>[...currentState.meals, newMeal];
        emit(
          MealOperationSuccess(
            message: 'Refeição criada com sucesso!',
            meals: updatedMeals,
            updatedMeal: newMeal,
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição criada com sucesso!',
            meals: [newMeal],
            updatedMeal: newMeal,
          ),
        );
      }
    });
  }

  Future<void> _onUpdateMeal(UpdateMeal event, Emitter<MealsState> emit) async {
    final currentState = state;
    if (currentState is MealsLoaded) {
      emit(
        MealOperationInProgress(
          operation: 'Atualizando refeição...',
          meals: currentState.meals,
        ),
      );
    }

    final result = await updateMeal(event.meal);

    result.fold((failure) => emit(MealsError(failure)), (updatedMeal) {
      if (currentState is MealsLoaded) {
        final updatedMeals = currentState.meals.map<Meal>((meal) {
          return meal.id == updatedMeal.id ? updatedMeal : meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            meals: updatedMeals,
            updatedMeal: updatedMeal,
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            meals: [updatedMeal],
            updatedMeal: updatedMeal,
          ),
        );
      }
    });
  }

  Future<void> _onDeleteMeal(DeleteMeal event, Emitter<MealsState> emit) async {
    final currentState = state;
    if (currentState is MealsLoaded) {
      emit(
        MealOperationInProgress(
          operation: 'Excluindo refeição...',
          meals: currentState.meals,
        ),
      );
    }

    final result = await deleteMeal(event.mealId);

    result.fold((failure) => emit(MealsError(failure)), (_) {
      if (currentState is MealsLoaded) {
        final updatedMeals = currentState.meals
            .where((meal) => meal.id != event.mealId)
            .toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            meals: updatedMeals,
          ),
        );
      } else {
        emit(
          const MealOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            meals: [],
          ),
        );
      }
    });
  }

  Future<void> _onCompleteMeal(
    CompleteMeal event,
    Emitter<MealsState> emit,
  ) async {
    final currentState = state;
    if (currentState is MealsLoaded) {
      emit(
        MealOperationInProgress(
          operation: 'Concluindo refeição...',
          meals: currentState.meals,
        ),
      );
    }

    final result = await completeMeal(
      complete_meal.CompleteMealParams(
        mealId: event.mealId,
        notes: event.notes,
        amount: event.amount,
      ),
    );

    result.fold((failure) => emit(MealsError(failure)), (completedMeal) {
      if (currentState is MealsLoaded) {
        final updatedMeals = currentState.meals.map<Meal>((meal) {
          return meal.id == completedMeal.id ? completedMeal : meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            meals: updatedMeals,
            updatedMeal: completedMeal,
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            meals: [completedMeal],
            updatedMeal: completedMeal,
          ),
        );
      }
    });
  }

  Future<void> _onSkipMeal(SkipMeal event, Emitter<MealsState> emit) async {
    final currentState = state;
    if (currentState is MealsLoaded) {
      emit(
        MealOperationInProgress(
          operation: 'Pulando refeição...',
          meals: currentState.meals,
        ),
      );
    }

    final result = await skipMeal(
      skip_meal.SkipMealParams(mealId: event.mealId, reason: event.reason),
    );

    result.fold((failure) => emit(MealsError(failure)), (skippedMeal) {
      if (currentState is MealsLoaded) {
        final updatedMeals = currentState.meals.map<Meal>((meal) {
          return meal.id == skippedMeal.id ? skippedMeal : meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            meals: updatedMeals,
            updatedMeal: skippedMeal,
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            meals: [skippedMeal],
            updatedMeal: skippedMeal,
          ),
        );
      }
    });
  }

  Future<void> _onRefreshMeals(
    RefreshMeals event,
    Emitter<MealsState> emit,
  ) async {
    add(const LoadMeals());
  }

  void _onClearMealsError(ClearMealsError event, Emitter<MealsState> emit) {
    if (state is MealsError) {
      emit(const MealsInitial());
    }
  }
}
