import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
import 'package:mealtime_app/features/meals/presentation/view_models/meal_view_model.dart';

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
      (meals) => _emitMealsLoaded(meals, emit),
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
      (meals) => _emitMealsLoaded(meals, emit),
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
      (meal) => emit(MealLoaded(meal: _transformMealToViewModel(meal))),
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
      (meals) => _emitMealsLoaded(meals, emit),
    );
  }

  // This is a performance optimization. By transforming the `Meal` entities into
  // `MealViewModel` objects here, we can pre-calculate the values that will be
  // displayed in the UI. This avoids doing expensive calculations in the `build`
  // method of the widgets, which can cause jank and performance issues.
  void _emitMealsLoaded(List<Meal> meals, Emitter<MealsState> emit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // This is a performance optimization. By sorting the list of completed meals
    // here, we can avoid doing it in the UI. This is especially important for
    // long lists of meals.
    final completedMeals = meals
        .where((meal) => meal.status == MealStatus.completed)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    final mealViewModels =
        meals.map((meal) => _transformMealToViewModel(meal)).toList();

    // This is a performance optimization. By calculating the number of today's
    // meals here, we can avoid doing it in the UI.
    final todayMealsCount = meals
        .where((meal) =>
            meal.scheduledAt.year == today.year &&
            meal.scheduledAt.month == today.month &&
            meal.scheduledAt.day == today.day)
        .length;

    final lastMeal = completedMeals.isNotEmpty
        ? _transformMealToViewModel(completedMeals.first)
        : null;

    emit(MealsLoaded(
      meals: mealViewModels,
      todayMealsCount: todayMealsCount,
      lastMeal: lastMeal,
    ));
  }

  // This is a performance optimization. By transforming the `Meal` entity into
  // a `MealViewModel` here, we can pre-calculate the values that will be
  // displayed in the UI. This avoids doing expensive calculations in the `build`
  // method of the widgets, which can cause jank and performance issues.
  MealViewModel _transformMealToViewModel(Meal meal) {
    final completedAt = meal.completedAt ?? meal.scheduledAt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    // This is a performance optimization. By calculating the relative date here,
    // we can avoid doing it in the UI.
    String relativeDate;
    if (completedAt.year == today.year &&
        completedAt.month == today.month &&
        completedAt.day == today.day) {
      relativeDate = 'Hoje';
    } else if (completedAt.year == yesterday.year &&
        completedAt.month == yesterday.month &&
        completedAt.day == yesterday.day) {
      relativeDate = 'Ontem';
    } else {
      relativeDate = DateFormat('dd/MM/yyyy').format(completedAt);
    }

    return MealViewModel(
      id: meal.id,
      formattedTime: DateFormat('HH:mm').format(completedAt),
      relativeDate: relativeDate,
      amount: meal.amount,
      meal: meal,
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
        final updatedMeals = [
          ...currentState.meals.map((vm) => vm.meal),
          newMeal
        ];
        emit(
          MealOperationSuccess(
            message: 'Refeição criada com sucesso!',
            meals: updatedMeals.map((meal) => _transformMealToViewModel(meal)).toList(),
            updatedMeal: _transformMealToViewModel(newMeal),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição criada com sucesso!',
            meals: [_transformMealToViewModel(newMeal)],
            updatedMeal: _transformMealToViewModel(newMeal),
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
        final updatedMeals = currentState.meals.map<Meal>((vm) {
          return vm.meal.id == updatedMeal.id ? updatedMeal : vm.meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            meals: updatedMeals.map((meal) => _transformMealToViewModel(meal)).toList(),
            updatedMeal: _transformMealToViewModel(updatedMeal),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            meals: [_transformMealToViewModel(updatedMeal)],
            updatedMeal: _transformMealToViewModel(updatedMeal),
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
            .where((vm) => vm.meal.id != event.mealId)
            .map((vm) => vm.meal)
            .toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            meals: updatedMeals.map((meal) => _transformMealToViewModel(meal)).toList(),
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
        final updatedMeals = currentState.meals.map<Meal>((vm) {
          return vm.meal.id == completedMeal.id ? completedMeal : vm.meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            meals: updatedMeals.map((meal) => _transformMealToViewModel(meal)).toList(),
            updatedMeal: _transformMealToViewModel(completedMeal),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            meals: [_transformMealToViewModel(completedMeal)],
            updatedMeal: _transformMealToViewModel(completedMeal),
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
        final updatedMeals = currentState.meals.map<Meal>((vm) {
          return vm.meal.id == skippedMeal.id ? skippedMeal : vm.meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            meals: updatedMeals.map((meal) => _transformMealToViewModel(meal)).toList(),
            updatedMeal: _transformMealToViewModel(skippedMeal),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            meals: [_transformMealToViewModel(skippedMeal)],
            updatedMeal: _transformMealToViewModel(skippedMeal),
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
