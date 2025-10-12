import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/complete_meal.dart'
    as complete_meal;
import 'package:mealtime_app/features/feeding_logs/domain/usecases/create_meal.dart'
    as create_meal;
import 'package:mealtime_app/features/feeding_logs/domain/usecases/delete_meal.dart'
    as delete_meal;
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_meal_by_id.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_logs.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_logs_by_cat.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_today_feeding_logs.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/skip_meal.dart'
    as skip_meal;
import 'package:mealtime_app/features/feeding_logs/domain/usecases/update_meal.dart'
    as update_meal;
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';

class FeedingLogsBloc extends Bloc<FeedingLogsEvent, FeedingLogsState> {
  final GetFeedingLogs getFeedingLogs;
  final GetFeedingLogsByCat getFeedingLogsByCat;
  final GetFeedingLogById getFeedingLogById;
  final GetTodayFeedingLogs getTodayFeedingLogs;
  final create_meal.CreateFeedingLog createFeedingLog;
  final update_meal.UpdateFeedingLog updateFeedingLog;
  final delete_meal.DeleteFeedingLog deleteFeedingLog;
  final complete_meal.CompleteFeedingLog completeFeedingLog;
  final skip_meal.SkipFeedingLog skipFeedingLog;

  FeedingLogsBloc({
    required this.getFeedingLogs,
    required this.getFeedingLogsByCat,
    required this.getFeedingLogById,
    required this.getTodayFeedingLogs,
    required this.createFeedingLog,
    required this.updateFeedingLog,
    required this.deleteFeedingLog,
    required this.completeFeedingLog,
    required this.skipFeedingLog,
  }) : super(const FeedingLogsInitial()) {
    on<LoadFeedingLogs>(_onLoadFeedingLogs);
    on<LoadFeedingLogsByCat>(_onLoadFeedingLogsByCat);
    on<LoadFeedingLogById>(_onLoadFeedingLogById);
    on<LoadTodayFeedingLogs>(_onLoadTodayFeedingLogs);
    on<CreateFeedingLog>(_onCreateFeedingLog);
    on<UpdateFeedingLog>(_onUpdateFeedingLog);
    on<DeleteFeedingLog>(_onDeleteFeedingLog);
    on<CompleteFeedingLog>(_onCompleteFeedingLog);
    on<SkipFeedingLog>(_onSkipFeedingLog);
    on<RefreshFeedingLogs>(_onRefreshFeedingLogs);
    on<ClearFeedingLogsError>(_onClearFeedingLogsError);
  }

  Future<void> _onLoadFeedingLogs(LoadFeedingLogs event, Emitter<FeedingLogsState> emit) async {
    emit(const FeedingLogsLoading());

    final result = await getFeedingLogs(NoParams());

    result.fold(
      (failure) => emit(FeedingLogsError(failure)),
      (feeding_logs) => emit(FeedingLogsLoaded(feeding_logs: feeding_logs)),
    );
  }

  Future<void> _onLoadFeedingLogsByCat(
    LoadFeedingLogsByCat event,
    Emitter<FeedingLogsState> emit,
  ) async {
    emit(const FeedingLogsLoading());

    final result = await getFeedingLogsByCat(event.catId);

    result.fold(
      (failure) => emit(FeedingLogsError(failure)),
      (feeding_logs) => emit(FeedingLogsLoaded(feeding_logs: feeding_logs)),
    );
  }

  Future<void> _onLoadFeedingLogById(
    LoadFeedingLogById event,
    Emitter<FeedingLogsState> emit,
  ) async {
    emit(const FeedingLogsLoading());

    final result = await getFeedingLogById(event.mealId);

    result.fold(
      (failure) => emit(FeedingLogsError(failure)),
      (meal) => emit(FeedingLogLoaded(meal: meal)),
    );
  }

  Future<void> _onLoadTodayFeedingLogs(
    LoadTodayFeedingLogs event,
    Emitter<FeedingLogsState> emit,
  ) async {
    emit(const FeedingLogsLoading());

    final result = await getTodayFeedingLogs(NoParams());

    result.fold(
      (failure) => emit(FeedingLogsError(failure)),
      (feeding_logs) => emit(FeedingLogsLoaded(feeding_logs: feeding_logs)),
    );
  }

  Future<void> _onCreateFeedingLog(CreateFeedingLog event, Emitter<FeedingLogsState> emit) async {
    final currentState = state;
    if (currentState is FeedingLogsLoaded) {
      emit(
        FeedingLogOperationInProgress(
          operation: 'Criando refeição...',
          feeding_logs: currentState.feeding_logs,
        ),
      );
    }

    final result = await createFeedingLog(event.meal);

    result.fold((failure) => emit(FeedingLogsError(failure)), (newFeedingLog) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = <FeedingLog>[...currentState.feeding_logs, newFeedingLog];
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição criada com sucesso!',
            feeding_logs: updatedFeedingLogs,
            updatedFeedingLog: newFeedingLog,
          ),
        );
      } else {
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição criada com sucesso!',
            feeding_logs: [newFeedingLog],
            updatedFeedingLog: newFeedingLog,
          ),
        );
      }
    });
  }

  Future<void> _onUpdateFeedingLog(UpdateFeedingLog event, Emitter<FeedingLogsState> emit) async {
    final currentState = state;
    if (currentState is FeedingLogsLoaded) {
      emit(
        FeedingLogOperationInProgress(
          operation: 'Atualizando refeição...',
          feeding_logs: currentState.feeding_logs,
        ),
      );
    }

    final result = await updateFeedingLog(event.meal);

    result.fold((failure) => emit(FeedingLogsError(failure)), (updatedFeedingLog) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = currentState.feeding_logs.map<FeedingLog>((meal) {
          return meal.id == updatedFeedingLog.id ? updatedFeedingLog : meal;
        }).toList();
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            feeding_logs: updatedFeedingLogs,
            updatedFeedingLog: updatedFeedingLog,
          ),
        );
      } else {
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            feeding_logs: [updatedFeedingLog],
            updatedFeedingLog: updatedFeedingLog,
          ),
        );
      }
    });
  }

  Future<void> _onDeleteFeedingLog(DeleteFeedingLog event, Emitter<FeedingLogsState> emit) async {
    final currentState = state;
    if (currentState is FeedingLogsLoaded) {
      emit(
        FeedingLogOperationInProgress(
          operation: 'Excluindo refeição...',
          feeding_logs: currentState.feeding_logs,
        ),
      );
    }

    final result = await deleteFeedingLog(event.mealId);

    result.fold((failure) => emit(FeedingLogsError(failure)), (_) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = currentState.feeding_logs
            .where((meal) => meal.id != event.mealId)
            .toList();
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            feeding_logs: updatedFeedingLogs,
          ),
        );
      } else {
        emit(
          const FeedingLogOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            feeding_logs: [],
          ),
        );
      }
    });
  }

  Future<void> _onCompleteFeedingLog(
    CompleteFeedingLog event,
    Emitter<FeedingLogsState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedingLogsLoaded) {
      emit(
        FeedingLogOperationInProgress(
          operation: 'Concluindo refeição...',
          feeding_logs: currentState.feeding_logs,
        ),
      );
    }

    final result = await completeFeedingLog(
      complete_meal.CompleteFeedingLogParams(
        mealId: event.mealId,
        notes: event.notes,
        amount: event.amount,
      ),
    );

    result.fold((failure) => emit(FeedingLogsError(failure)), (completedFeedingLog) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = currentState.feeding_logs.map<FeedingLog>((meal) {
          return meal.id == completedFeedingLog.id ? completedFeedingLog : meal;
        }).toList();
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            feeding_logs: updatedFeedingLogs,
            updatedFeedingLog: completedFeedingLog,
          ),
        );
      } else {
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição concluída com sucesso!',
            feeding_logs: [completedFeedingLog],
            updatedFeedingLog: completedFeedingLog,
          ),
        );
      }
    });
  }

  Future<void> _onSkipFeedingLog(SkipFeedingLog event, Emitter<FeedingLogsState> emit) async {
    final currentState = state;
    if (currentState is FeedingLogsLoaded) {
      emit(
        FeedingLogOperationInProgress(
          operation: 'Pulando refeição...',
          feeding_logs: currentState.feeding_logs,
        ),
      );
    }

    final result = await skipFeedingLog(
      skip_meal.SkipFeedingLogParams(mealId: event.mealId, reason: event.reason),
    );

    result.fold((failure) => emit(FeedingLogsError(failure)), (skippedFeedingLog) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = currentState.feeding_logs.map<FeedingLog>((meal) {
          return meal.id == skippedFeedingLog.id ? skippedFeedingLog : meal;
        }).toList();
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            feeding_logs: updatedFeedingLogs,
            updatedFeedingLog: skippedFeedingLog,
          ),
        );
      } else {
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição pulada com sucesso!',
            feeding_logs: [skippedFeedingLog],
            updatedFeedingLog: skippedFeedingLog,
          ),
        );
      }
    });
  }

  Future<void> _onRefreshFeedingLogs(
    RefreshFeedingLogs event,
    Emitter<FeedingLogsState> emit,
  ) async {
    add(const LoadFeedingLogs());
  }

  void _onClearFeedingLogsError(ClearFeedingLogsError event, Emitter<FeedingLogsState> emit) {
    if (state is FeedingLogsError) {
      emit(const FeedingLogsInitial());
    }
  }
}
