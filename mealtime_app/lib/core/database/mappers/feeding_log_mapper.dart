import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart' as drift_db;
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart'
    as domain;

/// Mappers para converter entre entidade de domínio FeedingLog e tabela
/// FeedingLogs do Drift
class FeedingLogMapper {
  /// Converte entidade de domínio para FeedingLogsCompanion (Drift)
  static drift_db.FeedingLogsCompanion toDriftCompanion(
    domain.FeedingLog entity, {
    DateTime? syncedAt,
    int? version,
    bool? isDeleted,
  }) {
    return drift_db.FeedingLogsCompanion(
      id: Value(entity.id),
      catId: Value(entity.catId),
      householdId: Value(entity.householdId),
      mealType: Value(entity.mealType.name),
      amount: Value(entity.amount),
      unit: Value(entity.unit),
      notes: Value(entity.notes),
      fedBy: Value(entity.fedBy),
      fedAt: Value(entity.fedAt),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncedAt: Value(syncedAt),
      version: Value(version ?? 1),
      isDeleted: Value(isDeleted ?? false),
    );
  }

  /// Converte FeedingLog row do Drift para entidade de domínio
  static domain.FeedingLog fromDriftFeedingLog(
    drift_db.FeedingLog driftFeedingLog,
  ) {
    return domain.FeedingLog(
      id: driftFeedingLog.id,
      catId: driftFeedingLog.catId,
      householdId: driftFeedingLog.householdId,
      mealType: _parseMealType(driftFeedingLog.mealType),
      amount: driftFeedingLog.amount,
      unit: driftFeedingLog.unit,
      notes: driftFeedingLog.notes,
      fedBy: driftFeedingLog.fedBy,
      fedAt: driftFeedingLog.fedAt,
      createdAt: driftFeedingLog.createdAt,
      updatedAt: driftFeedingLog.updatedAt,
    );
  }

  /// Converte lista de FeedingLog rows do Drift para lista de entidades
  static List<domain.FeedingLog> fromDriftFeedingLogs(
    List<drift_db.FeedingLog> driftFeedingLogs,
  ) {
    return driftFeedingLogs.map(fromDriftFeedingLog).toList();
  }

  /// Parse string do mealType para enum
  static domain.MealType _parseMealType(String mealTypeString) {
    switch (mealTypeString.toLowerCase()) {
      case 'breakfast':
        return domain.MealType.breakfast;
      case 'lunch':
        return domain.MealType.lunch;
      case 'dinner':
        return domain.MealType.dinner;
      case 'snack':
        return domain.MealType.snack;
      default:
        return domain.MealType.snack;
    }
  }
}

