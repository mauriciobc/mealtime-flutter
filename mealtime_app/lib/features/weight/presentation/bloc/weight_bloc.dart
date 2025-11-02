import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';
import 'package:mealtime_app/features/weight/domain/usecases/create_goal.dart' as create_goal_usecase;
import 'package:mealtime_app/features/weight/domain/usecases/create_weight_log.dart' as create_weight_log_usecase;
import 'package:mealtime_app/features/weight/domain/usecases/delete_weight_log.dart' as delete_weight_log_usecase;
import 'package:mealtime_app/features/weight/domain/usecases/get_active_goal_by_cat.dart';
import 'package:mealtime_app/features/weight/domain/usecases/get_goals.dart';
import 'package:mealtime_app/features/weight/domain/usecases/get_weight_log_by_id.dart';
import 'package:mealtime_app/features/weight/domain/usecases/get_weight_logs.dart';
import 'package:mealtime_app/features/weight/domain/usecases/get_weight_logs_by_cat.dart';
import 'package:mealtime_app/features/weight/domain/usecases/update_weight_log.dart' as update_weight_log_usecase;
import 'package:mealtime_app/features/weight/presentation/bloc/weight_event.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final GetWeightLogs getWeightLogs;
  final GetWeightLogsByCat getWeightLogsByCat;
  final GetWeightLogById getWeightLogById;
  final create_weight_log_usecase.CreateWeightLog createWeightLog;
  final update_weight_log_usecase.UpdateWeightLog updateWeightLog;
  final delete_weight_log_usecase.DeleteWeightLog deleteWeightLog;
  final GetGoals getGoals;
  final GetActiveGoalByCat getActiveGoalByCat;
  final create_goal_usecase.CreateGoal createGoal;

  WeightBloc({
    required this.getWeightLogs,
    required this.getWeightLogsByCat,
    required this.getWeightLogById,
    required this.createWeightLog,
    required this.updateWeightLog,
    required this.deleteWeightLog,
    required this.getGoals,
    required this.getActiveGoalByCat,
    required this.createGoal,
  }) : super(const WeightInitial()) {
    on<LoadWeightLogs>(_onLoadWeightLogs);
    on<LoadWeightLogsByCat>(_onLoadWeightLogsByCat);
    on<LoadWeightLogById>(_onLoadWeightLogById);
    on<CreateWeightLog>(_onCreateWeightLog);
    on<UpdateWeightLog>(_onUpdateWeightLog);
    on<DeleteWeightLog>(_onDeleteWeightLog);
    on<LoadGoals>(_onLoadGoals);
    on<LoadActiveGoalByCat>(_onLoadActiveGoalByCat);
    on<CreateGoal>(_onCreateGoal);
    on<SelectCat>(_onSelectCat);
    on<ChangeTimeRange>(_onChangeTimeRange);
    on<RefreshWeightData>(_onRefreshWeightData);
    on<ClearWeightError>(_onClearWeightError);
    on<InitializeWeight>(_onInitializeWeight);
  }

  Future<void> _onLoadWeightLogs(
    LoadWeightLogs event,
    Emitter<WeightState> emit,
  ) async {
    // Preservar estado atual ao invés de emitir WeightLoading
    final currentState = state;
    Cat? selectedCat;
    List<Cat> cats = [];
    WeightGoal? activeGoal;

    if (currentState is WeightLoaded) {
      selectedCat = currentState.selectedCat;
      cats = currentState.cats;
      activeGoal = currentState.activeGoal;
    } else {
      // Apenas emitir loading se não temos estado carregado
      emit(const WeightLoading());
    }

    final result = await getWeightLogs(
      GetWeightLogsParams(
        catId: event.catId,
        householdId: event.householdId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(WeightError(failure)),
      (weightLogs) {
        // Se já tínhamos estado carregado, pegamos os valores preservados
        final finalSelectedCat = currentState is WeightLoaded
            ? currentState.selectedCat
            : selectedCat;
        final finalCats = currentState is WeightLoaded
            ? currentState.cats
            : cats;
        final finalActiveGoal = currentState is WeightLoaded
            ? currentState.activeGoal
            : activeGoal;

        emit(
          WeightLoaded(
            selectedCat: finalSelectedCat,
            weightLogs: weightLogs,
            activeGoal: finalActiveGoal,
            cats: finalCats,
          ),
        );
      },
    );
  }

  Future<void> _onLoadWeightLogsByCat(
    LoadWeightLogsByCat event,
    Emitter<WeightState> emit,
  ) async {
    // Preservar estado atual ao invés de emitir WeightLoading
    final currentState = state;
    Cat? selectedCat;
    List<Cat> cats = [];
    WeightGoal? activeGoal;

    if (currentState is WeightLoaded) {
      selectedCat = currentState.selectedCat;
      cats = currentState.cats;
      activeGoal = currentState.activeGoal;
    } else {
      // Apenas emitir loading se não temos estado carregado
      emit(const WeightLoading());
    }

    final result = await getWeightLogsByCat(
      GetWeightLogsByCatParams(catId: event.catId),
    );

    result.fold(
      (failure) => emit(WeightError(failure)),
      (weightLogs) {
        // Se já tínhamos estado carregado, pegamos os valores preservados
        final finalSelectedCat = currentState is WeightLoaded
            ? currentState.selectedCat
            : selectedCat;
        final finalCats = currentState is WeightLoaded
            ? currentState.cats
            : cats;
        final finalActiveGoal = currentState is WeightLoaded
            ? currentState.activeGoal
            : activeGoal;

        emit(
          WeightLoaded(
            selectedCat: finalSelectedCat,
            weightLogs: weightLogs,
            activeGoal: finalActiveGoal,
            cats: finalCats,
          ),
        );
      },
    );
  }

  Future<void> _onLoadWeightLogById(
    LoadWeightLogById event,
    Emitter<WeightState> emit,
  ) async {
    emit(const WeightLoading());

    final result = await getWeightLogById(
      GetWeightLogByIdParams(id: event.id),
    );

    result.fold(
      (failure) => emit(WeightError(failure)),
      (weightLog) {
        final currentState = state;
        if (currentState is WeightLoaded) {
          final updatedLogs = currentState.weightLogs.map((log) {
            return log.id == weightLog.id ? weightLog : log;
          }).toList();
          emit(
            WeightLoaded(
              selectedCat: currentState.selectedCat,
              weightLogs: updatedLogs,
              activeGoal: currentState.activeGoal,
              cats: currentState.cats,
            ),
          );
        }
      },
    );
  }

  Future<void> _onCreateWeightLog(
    CreateWeightLog event,
    Emitter<WeightState> emit,
  ) async {
    final currentState = state;
    if (currentState is WeightLoaded) {
      emit(
        WeightOperationInProgress(
          operation: 'Registrando peso...',
          weightLogs: currentState.weightLogs,
          activeGoal: currentState.activeGoal,
          selectedCat: currentState.selectedCat,
        ),
      );
    }

    final result = await createWeightLog(event.weightLog);

    result.fold(
      (failure) => emit(WeightError(failure)),
      (newWeightLog) {
        if (currentState is WeightLoaded) {
          final updatedLogs = <WeightEntry>[
            ...currentState.weightLogs,
            newWeightLog,
          ];
          emit(
            WeightOperationSuccess(
              message: 'Peso registrado com sucesso!',
              weightLogs: updatedLogs,
              activeGoal: currentState.activeGoal,
              selectedCat: currentState.selectedCat,
              updatedWeightLog: newWeightLog,
            ),
          );
        } else {
          emit(
            WeightOperationSuccess(
              message: 'Peso registrado com sucesso!',
              weightLogs: [newWeightLog],
              updatedWeightLog: newWeightLog,
            ),
          );
        }
      },
    );
  }

  Future<void> _onUpdateWeightLog(
    UpdateWeightLog event,
    Emitter<WeightState> emit,
  ) async {
    final currentState = state;
    if (currentState is WeightLoaded) {
      emit(
        WeightOperationInProgress(
          operation: 'Atualizando peso...',
          weightLogs: currentState.weightLogs,
          activeGoal: currentState.activeGoal,
          selectedCat: currentState.selectedCat,
        ),
      );
    }

    final result = await updateWeightLog(event.weightLog);

    result.fold(
      (failure) => emit(WeightError(failure)),
      (updatedWeightLog) {
        if (currentState is WeightLoaded) {
          final updatedLogs = currentState.weightLogs.map((log) {
            return log.id == updatedWeightLog.id ? updatedWeightLog : log;
          }).toList();
          emit(
            WeightOperationSuccess(
              message: 'Peso atualizado com sucesso!',
              weightLogs: updatedLogs,
              activeGoal: currentState.activeGoal,
              selectedCat: currentState.selectedCat,
              updatedWeightLog: updatedWeightLog,
            ),
          );
        } else {
          emit(
            WeightOperationSuccess(
              message: 'Peso atualizado com sucesso!',
              weightLogs: [updatedWeightLog],
              updatedWeightLog: updatedWeightLog,
            ),
          );
        }
      },
    );
  }

  Future<void> _onDeleteWeightLog(
    DeleteWeightLog event,
    Emitter<WeightState> emit,
  ) async {
    final currentState = state;
    if (currentState is WeightLoaded) {
      emit(
        WeightOperationInProgress(
          operation: 'Excluindo registro...',
          weightLogs: currentState.weightLogs,
          activeGoal: currentState.activeGoal,
          selectedCat: currentState.selectedCat,
        ),
      );
    }

    final result = await deleteWeightLog(delete_weight_log_usecase.DeleteWeightLogParams(id: event.id));

    result.fold(
      (failure) => emit(WeightError(failure)),
      (_) {
        if (currentState is WeightLoaded) {
          final updatedLogs = currentState.weightLogs
              .where((log) => log.id != event.id)
              .toList();
          emit(
            WeightOperationSuccess(
              message: 'Registro excluído com sucesso!',
              weightLogs: updatedLogs,
              activeGoal: currentState.activeGoal,
              selectedCat: currentState.selectedCat,
            ),
          );
        } else {
          emit(
            const WeightOperationSuccess(
              message: 'Registro excluído com sucesso!',
              weightLogs: [],
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<WeightState> emit,
  ) async {
    final result = await getGoals(
      GetGoalsParams(
        catId: event.catId,
        householdId: event.householdId,
      ),
    );

    result.fold(
      (failure) => emit(WeightError(failure)),
      (goals) {
        final currentState = state;
        WeightGoal? activeGoal;
        if (goals.isNotEmpty && event.catId != null) {
          // Buscar a meta ativa (sem endDate) para o gato
          final activeGoals = goals
              .where((g) => g.catId == event.catId && g.endDate == null)
              .toList();
          activeGoal = activeGoals.isNotEmpty ? activeGoals.first : null;
        }

        if (currentState is WeightLoaded) {
          emit(
            WeightLoaded(
              selectedCat: currentState.selectedCat,
              weightLogs: currentState.weightLogs,
              activeGoal: activeGoal ?? currentState.activeGoal,
              timeRangeDays: currentState.timeRangeDays,
              cats: currentState.cats,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadActiveGoalByCat(
    LoadActiveGoalByCat event,
    Emitter<WeightState> emit,
  ) async {
    final result = await getActiveGoalByCat(
      GetActiveGoalByCatParams(catId: event.catId),
    );

    result.fold(
      (failure) => emit(WeightError(failure)),
      (goal) {
        final currentState = state;
        if (currentState is WeightLoaded) {
          emit(
            WeightLoaded(
              selectedCat: currentState.selectedCat,
              weightLogs: currentState.weightLogs,
              activeGoal: goal,
              timeRangeDays: currentState.timeRangeDays,
              cats: currentState.cats,
            ),
          );
        }
      },
    );
  }

  Future<void> _onCreateGoal(
    CreateGoal event,
    Emitter<WeightState> emit,
  ) async {
    final currentState = state;
    if (currentState is WeightLoaded) {
      emit(
        WeightOperationInProgress(
          operation: 'Criando meta...',
          weightLogs: currentState.weightLogs,
          activeGoal: currentState.activeGoal,
          selectedCat: currentState.selectedCat,
        ),
      );
    }

    final result = await createGoal(event.goal);

    result.fold(
      (failure) => emit(WeightError(failure)),
      (newGoal) {
        if (currentState is WeightLoaded) {
          emit(
            WeightOperationSuccess(
              message: 'Meta criada com sucesso!',
              weightLogs: currentState.weightLogs,
              activeGoal: newGoal,
              selectedCat: currentState.selectedCat,
              updatedGoal: newGoal,
            ),
          );
        } else {
          emit(
            WeightOperationSuccess(
              message: 'Meta criada com sucesso!',
              weightLogs: [],
              activeGoal: newGoal,
              updatedGoal: newGoal,
            ),
          );
        }
      },
    );
  }

  void _onSelectCat(SelectCat event, Emitter<WeightState> emit) {
    final currentState = state;
    if (currentState is WeightLoaded) {
      final selectedCat = event.catId != null
          ? currentState.cats.firstWhere(
              (cat) => cat.id == event.catId,
              orElse: () => currentState.cats.first,
            )
          : null;

      emit(
        WeightLoaded(
          selectedCat: selectedCat,
          weightLogs: currentState.weightLogs,
          activeGoal: currentState.activeGoal,
          timeRangeDays: currentState.timeRangeDays,
          cats: currentState.cats,
        ),
      );

      // Carregar dados do gato selecionado
      if (selectedCat != null) {
        add(LoadWeightLogsByCat(selectedCat.id));
        add(LoadActiveGoalByCat(selectedCat.id));
      }
    }
  }

  void _onChangeTimeRange(
    ChangeTimeRange event,
    Emitter<WeightState> emit,
  ) {
    final currentState = state;
    if (currentState is WeightLoaded) {
      emit(
        WeightLoaded(
          selectedCat: currentState.selectedCat,
          weightLogs: currentState.weightLogs,
          activeGoal: currentState.activeGoal,
          timeRangeDays: event.days,
          cats: currentState.cats,
        ),
      );
    }
  }

  Future<void> _onRefreshWeightData(
    RefreshWeightData event,
    Emitter<WeightState> emit,
  ) async {
    final currentState = state;
    if (currentState is WeightLoaded) {
      if (currentState.selectedCat != null) {
        add(LoadWeightLogsByCat(currentState.selectedCat!.id));
        add(LoadActiveGoalByCat(currentState.selectedCat!.id));
      } else {
        add(const LoadWeightLogs());
      }
    }
  }

  void _onClearWeightError(
    ClearWeightError event,
    Emitter<WeightState> emit,
  ) {
    if (state is WeightError) {
      emit(const WeightInitial());
    }
  }

  void _onInitializeWeight(
    InitializeWeight event,
    Emitter<WeightState> emit,
  ) {
    final currentState = state;
    Cat? selectedCat;

    if (event.cats.isNotEmpty) {
      selectedCat = event.catId != null
          ? event.cats.firstWhere(
              (cat) => cat.id == event.catId,
              orElse: () => event.cats.first,
            )
          : event.cats.first;
    }

    final existingLogs = currentState is WeightLoaded
        ? currentState.weightLogs
        : <WeightEntry>[];
    final existingGoal = currentState is WeightLoaded
        ? currentState.activeGoal
        : null;
    final existingTimeRange = currentState is WeightLoaded
        ? currentState.timeRangeDays
        : 30;

    emit(
      WeightLoaded(
        selectedCat: selectedCat,
        weightLogs: existingLogs,
        activeGoal: existingGoal,
        timeRangeDays: existingTimeRange,
        cats: event.cats,
      ),
    );

    // Carregar dados do gato selecionado
    if (selectedCat != null) {
      add(LoadWeightLogsByCat(selectedCat.id));
      add(LoadActiveGoalByCat(selectedCat.id));
    }
  }
}

