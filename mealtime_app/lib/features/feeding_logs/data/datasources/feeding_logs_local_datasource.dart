import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/daos/feeding_logs_dao.dart';
import 'package:mealtime_app/core/database/mappers/feeding_log_mapper.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart'
    as domain;

/// Data source local para cache de feeding logs usando Drift
/// Persiste dados localmente e permite acesso offline
abstract class FeedingLogsLocalDataSource {
  Future<void> cacheFeedingLogs(List<domain.FeedingLog> feedingLogs);
  Future<List<domain.FeedingLog>> getCachedFeedingLogs();
  Future<List<domain.FeedingLog>> getCachedFeedingLogsByCat(String catId);
  Future<List<domain.FeedingLog>> getTodayFeedingLogs();
  Future<domain.FeedingLog?> getCachedFeedingLog(String feedingLogId);
  Future<void> cacheFeedingLog(domain.FeedingLog feedingLog);
  Future<void> markAsSynced(String id);
  Stream<List<domain.FeedingLog>> watchFeedingLogs();
  Stream<List<domain.FeedingLog>> watchFeedingLogsByCat(String catId);
}

class FeedingLogsLocalDataSourceImpl implements FeedingLogsLocalDataSource {
  final AppDatabase database;
  late final FeedingLogsDao _feedingLogsDao;

  FeedingLogsLocalDataSourceImpl({required this.database}) {
    _feedingLogsDao = FeedingLogsDao(database);
  }

  @override
  Future<void> cacheFeedingLogs(List<domain.FeedingLog> feedingLogs) async {
    for (final feedingLog in feedingLogs) {
      await cacheFeedingLog(feedingLog);
    }
  }

  @override
  Future<List<domain.FeedingLog>> getCachedFeedingLogs() async {
    final driftFeedingLogs = await _feedingLogsDao.getAllFeedingLogs();
    return FeedingLogMapper.fromDriftFeedingLogs(driftFeedingLogs);
  }

  @override
  Future<List<domain.FeedingLog>> getCachedFeedingLogsByCat(
    String catId,
  ) async {
    final driftFeedingLogs = await _feedingLogsDao.getFeedingLogsByCat(catId);
    return FeedingLogMapper.fromDriftFeedingLogs(driftFeedingLogs);
  }

  @override
  Future<List<domain.FeedingLog>> getTodayFeedingLogs() async {
    final driftFeedingLogs = await _feedingLogsDao.getTodayFeedingLogs();
    return FeedingLogMapper.fromDriftFeedingLogs(driftFeedingLogs);
  }

  @override
  Future<domain.FeedingLog?> getCachedFeedingLog(
    String feedingLogId,
  ) async {
    final driftFeedingLog = await _feedingLogsDao.getFeedingLogById(
      feedingLogId,
    );
    if (driftFeedingLog == null) return null;
    return FeedingLogMapper.fromDriftFeedingLog(driftFeedingLog);
  }

  @override
  Future<void> cacheFeedingLog(domain.FeedingLog feedingLog) async {
    final companion = FeedingLogMapper.toDriftCompanion(
      feedingLog,
      syncedAt: DateTime.now(),
      version: 1,
      isDeleted: false,
    );
    await database
        .into(database.feedingLogs)
        .insertOnConflictUpdate(companion);
  }

  @override
  Future<void> markAsSynced(String id) async {
    await _feedingLogsDao.markAsSynced(id);
  }

  @override
  Stream<List<domain.FeedingLog>> watchFeedingLogs() {
    return _feedingLogsDao.watchAllFeedingLogs().map((driftFeedingLogs) {
      return FeedingLogMapper.fromDriftFeedingLogs(driftFeedingLogs);
    });
  }

  @override
  Stream<List<domain.FeedingLog>> watchFeedingLogsByCat(String catId) {
    // O DAO não tem watch por cat, então vamos criar um stream que filtra
    return _feedingLogsDao.watchAllFeedingLogs().map((driftFeedingLogs) {
      final filtered = driftFeedingLogs.where((log) => log.catId == catId);
      return FeedingLogMapper.fromDriftFeedingLogs(filtered.toList());
    });
  }
}

