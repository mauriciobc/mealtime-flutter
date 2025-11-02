import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';

abstract class WeightState extends Equatable {
  const WeightState();

  @override
  List<Object?> get props => [];
}

class WeightInitial extends WeightState {
  const WeightInitial();
}

class WeightLoading extends WeightState {
  const WeightLoading();
}

class WeightLoaded extends WeightState {
  final Cat? selectedCat;
  final List<WeightEntry> weightLogs;
  final WeightGoal? activeGoal;
  final int timeRangeDays; // 30, 60, 90
  final List<Cat> cats;

  const WeightLoaded({
    this.selectedCat,
    required this.weightLogs,
    this.activeGoal,
    this.timeRangeDays = 30,
    required this.cats,
  });

  /// Filtra weight logs pelo timeRange selecionado
  List<WeightEntry> get filteredWeightLogs {
    if (weightLogs.isEmpty) return [];
    
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: timeRangeDays));
    
    return weightLogs.where((log) => log.measuredAt.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  /// Peso atual do gato selecionado
  double? get currentWeight {
    if (weightLogs.isEmpty) return null;
    final sortedLogs = List<WeightEntry>.from(weightLogs)
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return sortedLogs.first.weight;
  }

  /// Calcula o progresso da meta em porcentagem
  double? get progressPercentage {
    if (activeGoal == null || currentWeight == null) return null;
    return activeGoal!.calculateProgress(currentWeight!) * 100;
  }

  @override
  List<Object?> get props => [
        selectedCat,
        weightLogs,
        activeGoal,
        timeRangeDays,
        cats,
      ];
}

class WeightOperationInProgress extends WeightState {
  final String operation;
  final List<WeightEntry> weightLogs;
  final WeightGoal? activeGoal;
  final Cat? selectedCat;

  const WeightOperationInProgress({
    required this.operation,
    required this.weightLogs,
    this.activeGoal,
    this.selectedCat,
  });

  @override
  List<Object?> get props => [operation, weightLogs, activeGoal, selectedCat];
}

class WeightOperationSuccess extends WeightState {
  final String message;
  final List<WeightEntry> weightLogs;
  final WeightGoal? activeGoal;
  final Cat? selectedCat;
  final WeightEntry? updatedWeightLog;
  final WeightGoal? updatedGoal;

  const WeightOperationSuccess({
    required this.message,
    required this.weightLogs,
    this.activeGoal,
    this.selectedCat,
    this.updatedWeightLog,
    this.updatedGoal,
  });

  @override
  List<Object?> get props => [
        message,
        weightLogs,
        activeGoal,
        selectedCat,
        updatedWeightLog,
        updatedGoal,
      ];
}

class WeightError extends WeightState {
  final Failure failure;

  const WeightError(this.failure);

  @override
  List<Object> get props => [failure];
}

