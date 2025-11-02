import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart' as drift_db;
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart'
    as domain;

/// Mappers para converter entre entidade de domínio WeightGoal e tabela
/// WeightGoals do Drift
class WeightGoalMapper {
  /// Converte entidade de domínio para WeightGoalsCompanion (Drift)
  static drift_db.WeightGoalsCompanion toDriftCompanion(
    domain.WeightGoal entity, {
    DateTime? syncedAt,
    int? version,
    bool? isDeleted,
  }) {
    return drift_db.WeightGoalsCompanion(
      id: Value(entity.id),
      catId: Value(entity.catId),
      targetWeight: Value(entity.targetWeight),
      startWeight: Value(entity.startWeight),
      startDate: Value(entity.startDate),
      targetDate: Value(entity.targetDate),
      endDate: Value(entity.endDate),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncedAt: Value(syncedAt),
      version: Value(version ?? 1),
      isDeleted: Value(isDeleted ?? false),
    );
  }

  /// Converte WeightGoal row do Drift para entidade de domínio
  static domain.WeightGoal fromDriftWeightGoal(
    drift_db.WeightGoal driftWeightGoal,
  ) {
    return domain.WeightGoal(
      id: driftWeightGoal.id,
      catId: driftWeightGoal.catId,
      targetWeight: driftWeightGoal.targetWeight,
      startWeight: driftWeightGoal.startWeight,
      startDate: driftWeightGoal.startDate,
      targetDate: driftWeightGoal.targetDate,
      endDate: driftWeightGoal.endDate,
      notes: driftWeightGoal.notes,
      createdAt: driftWeightGoal.createdAt,
      updatedAt: driftWeightGoal.updatedAt,
    );
  }

  /// Converte lista de WeightGoal rows do Drift para lista de entidades
  static List<domain.WeightGoal> fromDriftWeightGoals(
    List<drift_db.WeightGoal> driftWeightGoals,
  ) {
    return driftWeightGoals.map(fromDriftWeightGoal).toList();
  }
}

