import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart' as domain;
import 'package:drift/drift.dart' as drift;

/// Exceção lançada quando há conflito de versão durante atualização
class ProfileVersionConflictException implements Exception {
  final String message;
  ProfileVersionConflictException(this.message);
  
  @override
  String toString() => 'ProfileVersionConflictException: $message';
}

/// Data source local para cache de profile usando Drift
/// Persiste dados localmente e permite acesso offline
abstract class ProfileLocalDataSource {
  Future<void> cacheProfile(domain.Profile profile);
  /// [idOrUsername] Identificador do usuário (ID ou username).
  Future<domain.Profile?> getCachedProfile(String idOrUsername);
  Future<void> clearCache();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final AppDatabase database;
  static const int _maxRetries = 3;

  ProfileLocalDataSourceImpl({required this.database});

  /// Compara dois perfis para determinar se os dados realmente mudaram
  bool _hasDataChanged(domain.Profile incoming, Profile? existing) {
    if (existing == null) return true;
    
    return incoming.username != existing.username ||
        incoming.fullName != existing.fullName ||
        incoming.email != existing.email ||
        incoming.website != existing.website ||
        incoming.avatarUrl != existing.avatarUrl ||
        incoming.timezone != existing.timezone ||
        incoming.createdAt != existing.createdAt ||
        incoming.updatedAt != existing.updatedAt;
  }

  @override
  Future<void> cacheProfile(domain.Profile profile) async {
    int attempt = 0;
    
    while (attempt < _maxRetries) {
      // Busca o perfil existente para obter a versão atual
      final query = database.select(database.profiles)
        ..where((p) => p.id.equals(profile.id));
      final existing = await query.getSingleOrNull();

      // Se não existe, cria novo registro com versão 1
      if (existing == null) {
        final companion = ProfilesCompanion.insert(
          id: profile.id,
          username: drift.Value(profile.username),
          fullName: drift.Value(profile.fullName),
          email: drift.Value(profile.email),
          website: drift.Value(profile.website),
          avatarUrl: drift.Value(profile.avatarUrl),
          timezone: drift.Value(profile.timezone),
          createdAt: drift.Value(profile.createdAt),
          updatedAt: drift.Value(profile.updatedAt),
          syncedAt: drift.Value(DateTime.now()),
          version: const drift.Value(1),
        );
        await database.into(database.profiles).insert(companion);
        return;
      }

      // Verifica se os dados realmente mudaram
      final dataChanged = _hasDataChanged(profile, existing);
      
      // Se não mudou, não precisa atualizar
      if (!dataChanged) {
        return;
      }

      // Calcula a nova versão apenas se os dados mudaram
      final oldVersion = existing.version;
      final newVersion = oldVersion + 1;

      // Atualização condicional com optimistic locking
      // WHERE version = oldVersion garante que só atualiza se a versão não mudou
      final affectedRows = await (database.update(database.profiles)
            ..where((p) => 
                p.id.equals(profile.id) & 
                p.version.equals(oldVersion)))
          .write(ProfilesCompanion(
            username: drift.Value(profile.username),
            fullName: drift.Value(profile.fullName),
            email: drift.Value(profile.email),
            website: drift.Value(profile.website),
            avatarUrl: drift.Value(profile.avatarUrl),
            timezone: drift.Value(profile.timezone),
            createdAt: drift.Value(profile.createdAt),
            updatedAt: drift.Value(profile.updatedAt),
            syncedAt: drift.Value(DateTime.now()),
            version: drift.Value(newVersion),
          ));

      // Se atualizou com sucesso (affectedRows > 0), terminamos
      if (affectedRows > 0) {
        return;
      }

      // Se affectedRows == 0, houve conflito de versão (outro processo atualizou)
      // Incrementa tentativa e retenta
      attempt++;
      
      if (attempt >= _maxRetries) {
        throw ProfileVersionConflictException(
          'Falha ao atualizar perfil após $_maxRetries tentativas. '
          'Conflito de versão detectado.',
        );
      }
      
      // Pequeno delay antes de retentar para reduzir contenção
      await Future.delayed(Duration(milliseconds: 10 * attempt));
    }
  }

  @override
  Future<domain.Profile?> getCachedProfile(String idOrUsername) async {
    // Primeiro tenta por ID (único); getSingleOrNull é seguro aqui.
    final byId = database.select(database.profiles)
      ..where((p) => p.id.equals(idOrUsername));
    final idHit = await byId.getSingleOrNull();
    if (idHit != null) {
      return domain.Profile(
        id: idHit.id,
        username: idHit.username,
        fullName: idHit.fullName,
        email: idHit.email,
        website: idHit.website,
        avatarUrl: idHit.avatarUrl,
        timezone: idHit.timezone,
        createdAt: idHit.createdAt,
        updatedAt: idHit.updatedAt,
      );
    }
    // Fallback: busca por username; limit 1 evita exceção por múltiplos matches.
    final byUsername = database.select(database.profiles)
      ..where((p) => p.username.equals(idOrUsername))
      ..limit(1);
    final usernameResults = await byUsername.get();
    final profileData = usernameResults.isNotEmpty ? usernameResults.first : null;
    if (profileData == null) return null;
    return domain.Profile(
      id: profileData.id,
      username: profileData.username,
      fullName: profileData.fullName,
      email: profileData.email,
      website: profileData.website,
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

