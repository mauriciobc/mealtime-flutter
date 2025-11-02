import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/schedules/domain/usecases/create_schedule.dart';
import 'package:mealtime_app/features/schedules/domain/usecases/delete_schedule.dart';
import 'package:mealtime_app/features/schedules/domain/usecases/get_schedules.dart';
import 'package:mealtime_app/features/schedules/domain/usecases/update_schedule.dart';
import 'package:mealtime_app/features/schedules/presentation/bloc/schedules_event.dart';
import 'package:mealtime_app/features/schedules/presentation/bloc/schedules_state.dart';

class SchedulesBloc extends Bloc<SchedulesEvent, SchedulesState> {
  final GetSchedules getSchedules;
  final CreateSchedule createSchedule;
  final UpdateSchedule updateSchedule;
  final DeleteSchedule deleteSchedule;

  SchedulesBloc({
    required this.getSchedules,
    required this.createSchedule,
    required this.updateSchedule,
    required this.deleteSchedule,
  }) : super(SchedulesInitial()) {
    on<LoadSchedules>(_onLoadSchedules);
    on<CreateScheduleEvent>(_onCreateSchedule);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<DeleteScheduleEvent>(_onDeleteSchedule);
  }

  Future<void> _onLoadSchedules(
    LoadSchedules event,
    Emitter<SchedulesState> emit,
  ) async {
    emit(SchedulesLoading());

    final result = await getSchedules(event.householdId);

    result.fold(
      (failure) => emit(const SchedulesError('Falha ao carregar agendamentos')),
      (schedules) => emit(SchedulesLoaded(schedules)),
    );
  }

  Future<void> _onCreateSchedule(
    CreateScheduleEvent event,
    Emitter<SchedulesState> emit,
  ) async {
    final result = await createSchedule(event.schedule);

    result.fold(
      (failure) => emit(const SchedulesError('Falha ao criar agendamento')),
      (schedule) => emit(ScheduleCreated(schedule)),
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<SchedulesState> emit,
  ) async {
    final result = await updateSchedule(event.schedule);

    result.fold(
      (failure) => emit(const SchedulesError('Falha ao atualizar agendamento')),
      (schedule) => emit(ScheduleUpdated(schedule)),
    );
  }

  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<SchedulesState> emit,
  ) async {
    final result = await deleteSchedule(event.id);

    result.fold(
      (failure) => emit(const SchedulesError('Falha ao deletar agendamento')),
      (_) => emit(ScheduleDeleted(event.id)),
    );
  }
}



