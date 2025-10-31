import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';

abstract class SchedulesState extends Equatable {
  const SchedulesState();

  @override
  List<Object?> get props => [];
}

class SchedulesInitial extends SchedulesState {}

class SchedulesLoading extends SchedulesState {}

class SchedulesLoaded extends SchedulesState {
  final List<Schedule> schedules;

  const SchedulesLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleCreated extends SchedulesState {
  final Schedule schedule;

  const ScheduleCreated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleUpdated extends SchedulesState {
  final Schedule schedule;

  const ScheduleUpdated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleDeleted extends SchedulesState {
  final String id;

  const ScheduleDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class SchedulesError extends SchedulesState {
  final String message;

  const SchedulesError(this.message);

  @override
  List<Object?> get props => [message];
}



