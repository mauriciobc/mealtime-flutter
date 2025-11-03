import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart' as domain;
import 'package:drift/drift.dart' as drift;

/// Data source local para cache de profile usando Drift
/// Persiste dados localmente e permite acesso offline
abstract class ProfileLocalDataSource {
  Future<void> cacheProfile(domain.Profile profile);
  Future<domain.Profile?> getCachedProfile(String id);
  Future<void> clearCache();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final AppDatabase database;

  ProfileLocalDataSourceImpl({required this.database});

  @override
  Future<void> cacheProfile(domain.Profile profile) async {
    final companion = ProfilesCompanion.insert(
      id: profile.id,
      username: drift.Value(profile.username),
      fullName: drift.Value(profile.fullName),
      email: drift.Value(profile.email),
      avatarUrl: drift.Value(profile.avatarUrl),
      timezone: drift.Value(profile.timezone),
      createdAt: drift.Value(profile.createdAt),
      updatedAt: drift.Value(profile.updatedAt),
      syncedAt: drift.Value(DateTime.now()),
      version: const drift.Value(1),
    );
    await database.into(database.profiles).insertOnConflictUpdate(companion);
  }

  @override
  Future<domain.Profile?> getCachedProfile(String id) async {
    final query = database.select(database.profiles)
      ..where((p) => p.id.equals(id));
    final profileData = await query.getSingleOrNull();
    
    if (profileData == null) return null;
    
    return domain.Profile(
      id: profileData.id,
      username: profileData.username,
      fullName: profileData.fullName,
      email: profileData.email,
      avatarUrl: profileData.avatarUrl,
      timezone: profileData.timezone,
      createdAt: profileData.createdAt,
      updatedAt: profileData.updatedAt,
    );
  }

  @override
  Future<void> clearCache() async {
    await database.delete(database.profiles).go();
  }
}

