import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/app_database.dart' as drift_db;
import 'package:mealtime_app/features/homes/domain/entities/home.dart' as domain;

/// Mappers para converter entre entidade de domínio Home e tabela Households do Drift
class HomeMapper {
  /// Converte entidade de domínio para HouseholdsCompanion (Drift)
  static HouseholdsCompanion toDriftCompanion(
    domain.Home entity, {
    DateTime? syncedAt,
    int? version,
    bool? isDeleted,
    String? inviteCode,
  }) {
    return HouseholdsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      address: Value(entity.address),
      description: Value(entity.description),
      ownerId: Value(entity.userId), // Mapear userId para ownerId
      inviteCode: Value(inviteCode),
      isActive: Value(entity.isActive),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncedAt: Value(syncedAt),
      version: Value(version ?? 1),
      isDeleted: Value(isDeleted ?? false),
    );
  }

  /// Converte Household row do Drift para entidade de domínio
  static domain.Home fromDriftHousehold(drift_db.Household driftHousehold) {
    return domain.Home(
      id: driftHousehold.id,
      name: driftHousehold.name,
      address: driftHousehold.address,
      description: driftHousehold.description,
      userId: driftHousehold.ownerId, // Mapear ownerId para userId
      createdAt: driftHousehold.createdAt,
      updatedAt: driftHousehold.updatedAt,
      isActive: driftHousehold.isActive,
    );
  }

  /// Converte lista de Household rows do Drift para lista de entidades de domínio
  static List<domain.Home> fromDriftHouseholds(
    List<drift_db.Household> driftHouseholds,
  ) {
    return driftHouseholds.map(fromDriftHousehold).toList();
  }
}

