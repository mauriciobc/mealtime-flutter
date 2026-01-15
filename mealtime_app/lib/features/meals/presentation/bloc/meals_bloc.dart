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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateText;
    if (mealDate == today) {
      dateText = 'Hoje';
    } else if (mealDate == today.add(const Duration(days: 1))) {
      dateText = 'Amanhã';
    } else if (mealDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Ontem';
    } else {
      final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      final months = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      dateText =
          '${weekdays[mealDate.weekday % 7]}, ${mealDate.day} ${months[mealDate.month - 1]}';
    }

    final timeText =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$dateText às $timeText';
  }

  List<MealViewModel> _mapMealsToViewModels(List<Meal> meals) {
    return meals
        .map(
          (meal) => MealViewModel(
            meal: meal,
            formattedDateTime: _formatDateTime(meal.scheduledAt),
          ),
        )
        .toList();
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
      (meal) => emit(
        MealLoaded(
          meal: MealViewModel(
            meal: meal,
            formattedDateTime: _formatDateTime(meal.scheduledAt),
          ),
        ),
      ),
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
            meals: _mapMealsToViewModels(updatedMeals),
            updatedMeal: MealViewModel(
              meal: newMeal,
              formattedDateTime: _formatDateTime(newMeal.scheduledAt),
            ),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição criada com sucesso!',
            meals: _mapMealsToViewModels([newMeal]),
            updatedMeal: MealViewModel(
              meal: newMeal,
              formattedDateTime: _formatDateTime(newMeal.scheduledAt),
            ),
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
        final updatedMeals =
            currentState.meals.map<Meal>((mealViewModel) {
          return mealViewModel.meal.id == updatedMeal.id
              ? updatedMeal
              : mealViewModel.meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            meals: _mapMealsToViewModels(updatedMeals),
            updatedMeal: MealViewModel(
              meal: updatedMeal,
              formattedDateTime: _formatDateTime(updatedMeal.scheduledAt),
            ),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            meals: _mapMealsToViewModels([updatedMeal]),
            updatedMeal: MealViewModel(
              meal: updatedMeal,
              formattedDateTime: _formatDateTime(updatedMeal.scheduledAt),
            ),
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
            .where((mealViewModel) => mealViewModel.meal.id != event.mealId)
            .map((e) => e.meal)
            .toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            meals: _mapMealsToViewModels(updatedMeals),
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
        final updatedMeals =
            currentState.meals.map<Meal>((mealViewModel) {
          return mealViewModel.meal.id == completedMeal.id
              ? completedMeal
              : mealViewModel.meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            meals: _mapMealsToViewModels(updatedMeals),
            updatedMeal: MealViewModel(
              meal: completedMeal,
              formattedDateTime: _formatDateTime(completedMeal.scheduledAt),
            ),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            meals: _mapMealsToViewModels([completedMeal]),
            updatedMeal: MealViewModel(
              meal: completedMeal,
              formattedDateTime: _formatDateTime(completedMeal.scheduledAt),
            ),
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
        final updatedMeals =
            currentState.meals.map<Meal>((mealViewModel) {
          return mealViewModel.meal.id == skippedMeal.id
              ? skippedMeal
              : mealViewModel.meal;
        }).toList();
        emit(
          MealOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            meals: _mapMealsToViewModels(updatedMeals),
            updatedMeal: MealViewModel(
              meal: skippedMeal,
              formattedDateTime: _formatDateTime(skippedMeal.scheduledAt),
            ),
          ),
        );
      } else {
        emit(
          MealOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            meals: _mapMealsToViewModels([skippedMeal]),
            updatedMeal: MealViewModel(
              meal: skippedMeal,
              formattedDateTime: _formatDateTime(skippedMeal.scheduledAt),
            ),
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
