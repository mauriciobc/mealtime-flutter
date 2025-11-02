import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeightLogs extends WeightEvent {
  final String? catId;
  final String? householdId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadWeightLogs({
    this.catId,
    this.householdId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [catId, householdId, startDate, endDate];
}

class LoadWeightLogsByCat extends WeightEvent {
  final String catId;

  const LoadWeightLogsByCat(this.catId);

  @override
  List<Object> get props => [catId];
}

class LoadWeightLogById extends WeightEvent {
  final String id;

  const LoadWeightLogById(this.id);

  @override
  List<Object> get props => [id];
}

class CreateWeightLog extends WeightEvent {
  final WeightEntry weightLog;

  const CreateWeightLog(this.weightLog);

  @override
  List<Object> get props => [weightLog];
}

class UpdateWeightLog extends WeightEvent {
  final WeightEntry weightLog;

  const UpdateWeightLog(this.weightLog);

  @override
  List<Object> get props => [weightLog];
}

class DeleteWeightLog extends WeightEvent {
  final String id;

  const DeleteWeightLog(this.id);

  @override
  List<Object> get props => [id];
}

class LoadGoals extends WeightEvent {
  final String? catId;
  final String? householdId;

  const LoadGoals({
    this.catId,
    this.householdId,
  });

  @override
  List<Object?> get props => [catId, householdId];
}

class LoadActiveGoalByCat extends WeightEvent {
  final String catId;

  const LoadActiveGoalByCat(this.catId);

  @override
  List<Object> get props => [catId];
}

class CreateGoal extends WeightEvent {
  final WeightGoal goal;

  const CreateGoal(this.goal);

  @override
  List<Object> get props => [goal];
}

class InitializeWeight extends WeightEvent {
  final List<Cat> cats;
  final String? catId;

  const InitializeWeight({
    required this.cats,
    this.catId,
  });

  @override
  List<Object?> get props => [cats, catId];
}

class SelectCat extends WeightEvent {
  final String? catId;

  const SelectCat(this.catId);

  @override
  List<Object?> get props => [catId];
}

class ChangeTimeRange extends WeightEvent {
  final int days; // 30, 60, 90

  const ChangeTimeRange(this.days);

  @override
  List<Object> get props => [days];
}

class RefreshWeightData extends WeightEvent {
  const RefreshWeightData();
}

class ClearWeightError extends WeightEvent {
  const ClearWeightError();
}

