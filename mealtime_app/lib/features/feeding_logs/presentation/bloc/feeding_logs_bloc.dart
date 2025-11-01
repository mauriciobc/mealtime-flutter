import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/create_feeding_log.dart'
    as create_feeding_log;
import 'package:mealtime_app/features/feeding_logs/domain/usecases/create_feeding_logs_batch.dart'
    as create_feeding_logs_batch;
import 'package:mealtime_app/features/feeding_logs/domain/usecases/delete_feeding_log.dart'
    as delete_feeding_log;
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_log_by_id.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_logs.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_logs_by_cat.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_today_feeding_logs.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/update_feeding_log.dart'
    as update_feeding_log;
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';

class FeedingLogsBloc extends Bloc<FeedingLogsEvent, FeedingLogsState> {
  final GetFeedingLogs getFeedingLogs;
  final GetFeedingLogsByCat getFeedingLogsByCat;
  final GetFeedingLogById getFeedingLogById;
  final GetTodayFeedingLogs getTodayFeedingLogs;
  final create_feeding_log.CreateFeedingLog createFeedingLog;
  final create_feeding_logs_batch.CreateFeedingLogsBatch createFeedingLogsBatch;
  final update_feeding_log.UpdateFeedingLog updateFeedingLog;
  final delete_feeding_log.DeleteFeedingLog deleteFeedingLog;

  FeedingLogsBloc({
    required this.getFeedingLogs,
    required this.getFeedingLogsByCat,
    required this.getFeedingLogById,
    required this.getTodayFeedingLogs,
    required this.createFeedingLog,
    required this.createFeedingLogsBatch,
    required this.updateFeedingLog,
    required this.deleteFeedingLog,
  }) : super(const FeedingLogsInitial()) {
    on<LoadFeedingLogs>(_onLoadFeedingLogs);
    on<LoadFeedingLogsByCat>(_onLoadFeedingLogsByCat);
    on<LoadFeedingLogById>(_onLoadFeedingLogById);
    on<LoadTodayFeedingLogs>(_onLoadTodayFeedingLogs);
    on<CreateFeedingLog>(_onCreateFeedingLog);
    on<CreateFeedingLogsBatch>(_onCreateFeedingLogsBatch);
    on<UpdateFeedingLog>(_onUpdateFeedingLog);
    on<DeleteFeedingLog>(_onDeleteFeedingLog);
    on<RefreshFeedingLogs>(_onRefreshFeedingLogs);
    on<ClearFeedingLogsError>(_onClearFeedingLogsError);
  }

  Future<void> _onLoadFeedingLogs(LoadFeedingLogs event, Emitter<FeedingLogsState> emit) async {
    emit(const FeedingLogsLoading());

    final result = await getFeedingLogs(NoParams());

    result.fold(
      (failure) => emit(FeedingLogsError(failure)),
      (feedingLogs) => emit(FeedingLogsLoaded(feedingLogs: feedingLogs)),
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
      (feedingLogs) => emit(FeedingLogsLoaded(feedingLogs: feedingLogs)),
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

    final result = await getTodayFeedingLogs(householdId: event.householdId);

    result.fold(
      (failure) => emit(FeedingLogsError(failure)),
      (feedingLogs) => emit(FeedingLogsLoaded(feedingLogs: feedingLogs)),
    );
  }

  Future<void> _onCreateFeedingLog(CreateFeedingLog event, Emitter<FeedingLogsState> emit) async {
    final currentState = state;
    if (currentState is FeedingLogsLoaded) {
      emit(
        FeedingLogOperationInProgress(
          operation: 'Criando refeição...',
          feedingLogs: currentState.feedingLogs,
        ),
      );
    }

    final result = await createFeedingLog(event.meal);

    result.fold((failure) => emit(FeedingLogsError(failure)), (newFeedingLog) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = <FeedingLog>[...currentState.feedingLogs, newFeedingLog];
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição criada com sucesso!',
            feedingLogs: updatedFeedingLogs,
            updatedFeedingLog: newFeedingLog,
          ),
        );
      } else {
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição criada com sucesso!',
            feedingLogs: [newFeedingLog],
            updatedFeedingLog: newFeedingLog,
          ),
        );
      }
    });
  }

  Future<void> _onCreateFeedingLogsBatch(
    CreateFeedingLogsBatch event,
    Emitter<FeedingLogsState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedingLogsLoaded) {
      emit(
        FeedingLogOperationInProgress(
          operation: 'Criando ${event.meals.length} refeição(ões)...',
          feedingLogs: currentState.feedingLogs,
        ),
      );
    }

    final result = await createFeedingLogsBatch(event.meals);

    result.fold((failure) => emit(FeedingLogsError(failure)), (newFeedingLogs) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = <FeedingLog>[
          ...currentState.feedingLogs,
          ...newFeedingLogs,
        ];
        emit(
          FeedingLogOperationSuccess(
            message: '${newFeedingLogs.length} refeição(ões) criada(s) com sucesso!',
            feedingLogs: updatedFeedingLogs,
          ),
        );
      } else {
        emit(
          FeedingLogOperationSuccess(
            message: '${newFeedingLogs.length} refeição(ões) criada(s) com sucesso!',
            feedingLogs: newFeedingLogs,
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
          feedingLogs: currentState.feedingLogs,
        ),
      );
    }

    final result = await updateFeedingLog(event.meal);

    result.fold((failure) => emit(FeedingLogsError(failure)), (updatedFeedingLog) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = currentState.feedingLogs.map<FeedingLog>((meal) {
          return meal.id == updatedFeedingLog.id ? updatedFeedingLog : meal;
        }).toList();
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            feedingLogs: updatedFeedingLogs,
            updatedFeedingLog: updatedFeedingLog,
          ),
        );
      } else {
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição atualizada com sucesso!',
            feedingLogs: [updatedFeedingLog],
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
          feedingLogs: currentState.feedingLogs,
        ),
      );
    }

    final result = await deleteFeedingLog(event.mealId);

    result.fold((failure) => emit(FeedingLogsError(failure)), (_) {
      if (currentState is FeedingLogsLoaded) {
        final updatedFeedingLogs = currentState.feedingLogs
            .where((meal) => meal.id != event.mealId)
            .toList();
        emit(
          FeedingLogOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            feedingLogs: updatedFeedingLogs,
          ),
        );
      } else {
        emit(
          const FeedingLogOperationSuccess(
            message: 'Refeição excluída com sucesso!',
            feedingLogs: [],
          ),
        );
      }
    });
  }

  // Métodos complete e skip não são necessários para feeding_logs
  // pois são registros de alimentação já realizados, não agendamentos

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
