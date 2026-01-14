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

  List<MealViewModel> _mapMealsToViewModels(List<Meal> meals) {
    final now = DateTime.now();
    return meals
        .map((meal) => MealViewModel.fromMeal(meal, now))
        .toList()
      ..sort((a, b) => a.meal.scheduledAt.compareTo(b.meal.scheduledAt));
  }

  List<MealViewModel>? _getCurrentViewModels(MealsState state) {
    if (state is MealsLoaded) {
      return state.meals;
    }
    if (state is MealOperationInProgress) {
      return state.meals;
    }
    if (state is MealOperationSuccess) {
      return state.meals;
    }
    return null;
  }

  Future<void> _onLoadMeals(LoadMeals event, Emitter<MealsState> emit) async {
    emit(const MealsLoading());
    final result = await getMeals(NoParams());
    result.fold(
      (failure) => emit(MealsError(failure)),
      (meals) => emit(MealsLoaded(meals: _mapMealsToViewModels(meals))),
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
      (meals) => emit(MealsLoaded(meals: _mapMealsToViewModels(meals))),
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
      (meals) => emit(MealsLoaded(meals: _mapMealsToViewModels(meals))),
    );
  }

  Future<void> _onCreateMeal(CreateMeal event, Emitter<MealsState> emit) async {
    final currentViewModels = _getCurrentViewModels(state);
    if (currentViewModels != null) {
      emit(
        MealOperationInProgress(
          operation: 'Criando refeição...',
          meals: currentViewModels,
        ),
      );
    }

    final result = await createMeal(event.meal);

    result.fold((failure) => emit(MealsError(failure)), (newMeal) {
      final now = DateTime.now();
      final newMealViewModel = MealViewModel.fromMeal(newMeal, now);
      final updatedViewModels = [...(currentViewModels ?? []), newMealViewModel]
        ..sort((a, b) => a.meal.scheduledAt.compareTo(b.meal.scheduledAt));

      emit(
        MealOperationSuccess(
          message: 'Refeição criada com sucesso!',
          meals: updatedViewModels,
          updatedMeal: newMealViewModel,
        ),
      );
    });
  }

  Future<void> _onUpdateMeal(UpdateMeal event, Emitter<MealsState> emit) async {
    final currentViewModels = _getCurrentViewModels(state);
    if (currentViewModels != null) {
      emit(
        MealOperationInProgress(
          operation: 'Atualizando refeição...',
          meals: currentViewModels,
        ),
      );
    }

    final result = await updateMeal(event.meal);

    result.fold((failure) => emit(MealsError(failure)), (updatedMeal) {
      if (currentViewModels != null) {
        final now = DateTime.now();
        final updatedMealViewModel = MealViewModel.fromMeal(updatedMeal, now);
        final updatedViewModels = currentViewModels.map<MealViewModel>((vm) {
          return vm.meal.id == updatedMeal.id ? updatedMealViewModel : vm;
        }).toList()
          ..sort((a, b) => a.meal.scheduledAt.compareTo(b.meal.scheduledAt));

        emit(
          MealOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            meals: updatedViewModels,
            updatedMeal: updatedMealViewModel,
          ),
        );
      }
    });
  }

  Future<void> _onDeleteMeal(DeleteMeal event, Emitter<MealsState> emit) async {
    final currentViewModels = _getCurrentViewModels(state);
    if (currentViewModels != null) {
      emit(
        MealOperationInProgress(
          operation: 'Excluindo refeição...',
          meals: currentViewModels,
        ),
      );
    }

    final result = await deleteMeal(event.mealId);

    result.fold((failure) => emit(MealsError(failure)), (_) {
      if (currentViewModels != null) {
        final updatedViewModels = currentViewModels
            .where((vm) => vm.meal.id != event.mealId)
            .toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            meals: updatedViewModels,
          ),
        );
      }
    });
  }

  Future<void> _onCompleteMeal(
    CompleteMeal event,
    Emitter<MealsState> emit,
  ) async {
    final currentViewModels = _getCurrentViewModels(state);
    if (currentViewModels != null) {
      emit(
        MealOperationInProgress(
          operation: 'Concluindo refeição...',
          meals: currentViewModels,
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
      if (currentViewModels != null) {
        final now = DateTime.now();
        final completedMealViewModel =
            MealViewModel.fromMeal(completedMeal, now);
        final updatedViewModels = currentViewModels.map<MealViewModel>((vm) {
          return vm.meal.id == completedMeal.id ? completedMealViewModel : vm;
        }).toList()
          ..sort((a, b) => a.meal.scheduledAt.compareTo(b.meal.scheduledAt));

        emit(
          MealOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            meals: updatedViewModels,
            updatedMeal: completedMealViewModel,
          ),
        );
      }
    });
  }

  Future<void> _onSkipMeal(SkipMeal event, Emitter<MealsState> emit) async {
    final currentViewModels = _getCurrentViewModels(state);
    if (currentViewModels != null) {
      emit(
        MealOperationInProgress(
          operation: 'Pulando refeição...',
          meals: currentViewModels,
        ),
      );
    }

    final result = await skipMeal(
      skip_meal.SkipMealParams(mealId: event.mealId, reason: event.reason),
    );

    result.fold((failure) => emit(MealsError(failure)), (skippedMeal) {
      if (currentViewModels != null) {
        final now = DateTime.now();
        final skippedMealViewModel = MealViewModel.fromMeal(skippedMeal, now);
        final updatedViewModels = currentViewModels.map<MealViewModel>((vm) {
          return vm.meal.id == skippedMeal.id ? skippedMealViewModel : vm;
        }).toList()
          ..sort((a, b) => a.meal.scheduledAt.compareTo(b.meal.scheduledAt));

        emit(
          MealOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            meals: updatedViewModels,
            updatedMeal: skippedMealViewModel,
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
