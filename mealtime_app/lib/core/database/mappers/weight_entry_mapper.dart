import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart' as drift_db;
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart'
    as domain;

/// Mappers para converter entre entidade de domínio WeightEntry e tabela
/// WeightLogs do Drift
class WeightEntryMapper {
  /// Converte entidade de domínio para WeightLogsCompanion (Drift)
  static drift_db.WeightLogsCompanion toDriftCompanion(
    domain.WeightEntry entity, {
    DateTime? syncedAt,
    int? version,
    bool? isDeleted,
  }) {
    return drift_db.WeightLogsCompanion(
      id: Value(entity.id),
      catId: Value(entity.catId),
      weight: Value(entity.weight),
      measuredAt: Value(entity.measuredAt),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncedAt: Value(syncedAt),
      version: Value(version ?? 1),
      isDeleted: Value(isDeleted ?? false),
    );
  }

  /// Converte WeightLog row do Drift para entidade de domínio
  static domain.WeightEntry fromDriftWeightLog(
    drift_db.WeightLog driftWeightLog,
  ) {
    return domain.WeightEntry(
      id: driftWeightLog.id,
      catId: driftWeightLog.catId,
      weight: driftWeightLog.weight,
      measuredAt: driftWeightLog.measuredAt,
      notes: driftWeightLog.notes,
      createdAt: driftWeightLog.createdAt,
      updatedAt: driftWeightLog.updatedAt,
    );
  }

  /// Converte lista de WeightLog rows do Drift para lista de entidades
  static List<domain.WeightEntry> fromDriftWeightLogs(
    List<drift_db.WeightLog> driftWeightLogs,
  ) {
    return driftWeightLogs.map(fromDriftWeightLog).toList();
  }
}

