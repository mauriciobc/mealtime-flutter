import 'package:drift/drift.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/app_database.dart' as drift_db;
import 'package:mealtime_app/features/cats/domain/entities/cat.dart' as domain;

/// Mappers para converter entre entidade de domínio Cat e tabela Cats do Drift
class CatMapper {
  /// Converte entidade de domínio para CatsCompanion (Drift)
  static CatsCompanion toDriftCompanion(
    domain.Cat entity, {
    DateTime? syncedAt,
    int? version,
    bool? isDeleted,
  }) {
    return CatsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      breed: Value(entity.breed),
      birthDate: Value(entity.birthDate),
      gender: Value(entity.gender),
      color: Value(entity.color),
      description: Value(entity.description),
      imageUrl: Value(entity.imageUrl),
      photoUrl: Value(entity.imageUrl), // Usar imageUrl como photoUrl também
      currentWeight: Value(entity.currentWeight),
      targetWeight: Value(entity.targetWeight),
      householdId: Value(entity.homeId), // Mapear homeId para householdId
      ownerId: Value(entity.ownerId),
      portionSize: Value(entity.portionSize),
      portionUnit: Value(entity.portionUnit),
      restrictions: Value(entity.restrictions),
      feedingInterval: Value(entity.feedingInterval),
      isActive: Value(entity.isActive),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncedAt: Value(syncedAt),
      version: Value(version ?? 1),
      isDeleted: Value(isDeleted ?? false),
    );
  }

  /// Converte Cat row do Drift para entidade de domínio
  static domain.Cat fromDriftCat(drift_db.Cat driftCat) {
    return domain.Cat(
      id: driftCat.id,
      name: driftCat.name,
      breed: driftCat.breed,
      birthDate: driftCat.birthDate ?? DateTime.now(),
      gender: driftCat.gender,
      color: driftCat.color,
      description: driftCat.description,
      imageUrl: driftCat.imageUrl ?? driftCat.photoUrl,
      currentWeight: driftCat.currentWeight,
      targetWeight: driftCat.targetWeight,
      homeId: driftCat.householdId, // Mapear householdId para homeId
      ownerId: driftCat.ownerId,
      portionSize: driftCat.portionSize,
      portionUnit: driftCat.portionUnit,
      feedingInterval: driftCat.feedingInterval,
      restrictions: driftCat.restrictions,
      createdAt: driftCat.createdAt,
      updatedAt: driftCat.updatedAt,
      isActive: driftCat.isActive,
    );
  }

  /// Converte lista de Cat rows do Drift para lista de entidades de domínio
  static List<domain.Cat> fromDriftCats(List<drift_db.Cat> driftCats) {
    return driftCats.map(fromDriftCat).toList();
  }
}

