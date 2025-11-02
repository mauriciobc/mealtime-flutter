import 'package:equatable/equatable.dart';

/// Entidade de meta de peso seguindo Clean Architecture
class WeightGoal extends Equatable {
  final String id;
  final String catId;
  final double targetWeight;
  final double startWeight;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeightGoal({
    required this.id,
    required this.catId,
    required this.targetWeight,
    required this.startWeight,
    required this.startDate,
    required this.targetDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        catId,
        targetWeight,
        startWeight,
        startDate,
        targetDate,
        endDate,
        notes,
        createdAt,
        updatedAt,
      ];

  WeightGoal copyWith({
    String? id,
    String? catId,
    double? targetWeight,
    double? startWeight,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? endDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightGoal(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      targetWeight: targetWeight ?? this.targetWeight,
      startWeight: startWeight ?? this.startWeight,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calcula o progresso em porcentagem
  /// Retorna um valor entre 0.0 e 1.0
  double calculateProgress(double currentWeight) {
    // Validação de entrada para evitar NaN
    if (!targetWeight.isFinite || !startWeight.isFinite || !currentWeight.isFinite) {
      return 0.0;
    }
    
    final totalChange = targetWeight - startWeight;
    if (totalChange == 0) return 0.0;
    
    final currentChange = currentWeight - startWeight;
    final progress = currentChange / totalChange;
    
    // Limitar entre 0.0 e 1.0 e garantir que é finito
    final clampedProgress = progress.clamp(0.0, 1.0);
    return clampedProgress.isFinite ? clampedProgress : 0.0;
  }

  /// Verifica se a meta está completa
  bool isCompleted(double currentWeight) {
    final isGaining = targetWeight > startWeight;
    if (isGaining) {
      return currentWeight >= targetWeight;
    } else {
      return currentWeight <= targetWeight;
    }
  }

  /// Retorna o número de dias restantes até a data alvo
  int daysRemaining() {
    final now = DateTime.now();
    if (now.isAfter(targetDate)) return 0;
    return targetDate.difference(now).inDays;
  }
}

