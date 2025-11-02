import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/daos/weight_logs_dao.dart';
import 'package:mealtime_app/core/database/mappers/weight_entry_mapper.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart'
    as domain;

/// Data source local para cache de weight logs usando Drift
/// Persiste dados localmente e permite acesso offline
abstract class WeightLogsLocalDataSource {
  Future<void> cacheWeightLogs(List<domain.WeightEntry> weightLogs);
  Future<List<domain.WeightEntry>> getCachedWeightLogs();
  Future<List<domain.WeightEntry>> getCachedWeightLogsByCat(String catId);
  Future<domain.WeightEntry?> getCachedWeightLog(String weightLogId);
  Future<void> cacheWeightLog(domain.WeightEntry weightLog);
  Future<void> markAsSynced(String id);
  Stream<List<domain.WeightEntry>> watchWeightLogs();
  Stream<List<domain.WeightEntry>> watchWeightLogsByCat(String catId);
}

class WeightLogsLocalDataSourceImpl implements WeightLogsLocalDataSource {
  final AppDatabase database;
  late final WeightLogsDao _weightLogsDao;

  WeightLogsLocalDataSourceImpl({required this.database}) {
    _weightLogsDao = WeightLogsDao(database);
  }

  @override
  Future<void> cacheWeightLogs(
    List<domain.WeightEntry> weightLogs,
  ) async {
    for (final weightLog in weightLogs) {
      await cacheWeightLog(weightLog);
    }
  }

  @override
  Future<List<domain.WeightEntry>> getCachedWeightLogs() async {
    final driftWeightLogs = await _weightLogsDao.getAllWeightLogs();
    return WeightEntryMapper.fromDriftWeightLogs(driftWeightLogs);
  }

  @override
  Future<List<domain.WeightEntry>> getCachedWeightLogsByCat(
    String catId,
  ) async {
    final driftWeightLogs = await _weightLogsDao.getWeightLogsByCat(catId);
    return WeightEntryMapper.fromDriftWeightLogs(driftWeightLogs);
  }

  @override
  Future<domain.WeightEntry?> getCachedWeightLog(
    String weightLogId,
  ) async {
    final driftWeightLog = await _weightLogsDao.getWeightLogById(weightLogId);
    if (driftWeightLog == null) return null;
    return WeightEntryMapper.fromDriftWeightLog(driftWeightLog);
  }

  @override
  Future<void> cacheWeightLog(domain.WeightEntry weightLog) async {
    final companion = WeightEntryMapper.toDriftCompanion(
      weightLog,
      syncedAt: DateTime.now(),
      version: 1,
      isDeleted: false,
    );
    await database
        .into(database.weightLogs)
        .insertOnConflictUpdate(companion);
  }

  @override
  Future<void> markAsSynced(String id) async {
    await _weightLogsDao.markAsSynced(id);
  }

  @override
  Stream<List<domain.WeightEntry>> watchWeightLogs() {
    return _weightLogsDao.watchAllWeightLogs().map((driftWeightLogs) {
      return WeightEntryMapper.fromDriftWeightLogs(driftWeightLogs);
    });
  }

  @override
  Stream<List<domain.WeightEntry>> watchWeightLogsByCat(String catId) {
    return _weightLogsDao.watchAllWeightLogs().map((driftWeightLogs) {
      final filtered = driftWeightLogs.where((log) => log.catId == catId);
      return WeightEntryMapper.fromDriftWeightLogs(filtered.toList());
    });
  }
}

