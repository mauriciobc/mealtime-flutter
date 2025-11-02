import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';

abstract class SchedulesEvent extends Equatable {
  const SchedulesEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedules extends SchedulesEvent {
  final String householdId;

  const LoadSchedules(this.householdId);

  @override
  List<Object?> get props => [householdId];
}

class CreateScheduleEvent extends SchedulesEvent {
  final Schedule schedule;

  const CreateScheduleEvent(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class UpdateScheduleEvent extends SchedulesEvent {
  final Schedule schedule;

  const UpdateScheduleEvent(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class DeleteScheduleEvent extends SchedulesEvent {
  final String id;

  const DeleteScheduleEvent(this.id);

  @override
  List<Object?> get props => [id];
}



