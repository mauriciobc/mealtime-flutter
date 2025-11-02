import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/database/daos/weight_goals_dao.dart';
import 'package:mealtime_app/core/database/mappers/weight_goal_mapper.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart'
    as domain;

/// Data source local para cache de weight goals usando Drift
/// Persiste dados localmente e permite acesso offline
abstract class GoalsLocalDataSource {
  Future<void> cacheGoals(List<domain.WeightGoal> goals);
  Future<List<domain.WeightGoal>> getCachedGoals();
  Future<List<domain.WeightGoal>> getCachedGoalsByCat(String catId);
  Future<domain.WeightGoal?> getCachedGoal(String goalId);
  Future<domain.WeightGoal?> getActiveGoalByCat(String catId);
  Future<void> cacheGoal(domain.WeightGoal goal);
  Future<void> markAsSynced(String id);
  Stream<List<domain.WeightGoal>> watchGoals();
  Stream<List<domain.WeightGoal>> watchGoalsByCat(String catId);
}

class GoalsLocalDataSourceImpl implements GoalsLocalDataSource {
  final AppDatabase database;
  late final WeightGoalsDao _weightGoalsDao;

  GoalsLocalDataSourceImpl({required this.database}) {
    _weightGoalsDao = WeightGoalsDao(database);
  }

  @override
  Future<void> cacheGoals(List<domain.WeightGoal> goals) async {
    for (final goal in goals) {
      await cacheGoal(goal);
    }
  }

  @override
  Future<List<domain.WeightGoal>> getCachedGoals() async {
    final driftGoals = await _weightGoalsDao.getAllWeightGoals();
    return WeightGoalMapper.fromDriftWeightGoals(driftGoals);
  }

  @override
  Future<List<domain.WeightGoal>> getCachedGoalsByCat(String catId) async {
    final driftGoals = await _weightGoalsDao.getWeightGoalsByCat(catId);
    return WeightGoalMapper.fromDriftWeightGoals(driftGoals);
  }

  @override
  Future<domain.WeightGoal?> getCachedGoal(String goalId) async {
    final driftGoal = await _weightGoalsDao.getWeightGoalById(goalId);
    if (driftGoal == null) return null;
    return WeightGoalMapper.fromDriftWeightGoal(driftGoal);
  }

  @override
  Future<domain.WeightGoal?> getActiveGoalByCat(String catId) async {
    final driftGoal = await _weightGoalsDao.getActiveWeightGoalByCat(catId);
    if (driftGoal == null) return null;
    return WeightGoalMapper.fromDriftWeightGoal(driftGoal);
  }

  @override
  Future<void> cacheGoal(domain.WeightGoal goal) async {
    final companion = WeightGoalMapper.toDriftCompanion(
      goal,
      syncedAt: DateTime.now(),
      version: 1,
      isDeleted: false,
    );
    await database
        .into(database.weightGoals)
        .insertOnConflictUpdate(companion);
  }

  @override
  Future<void> markAsSynced(String id) async {
    await _weightGoalsDao.markAsSynced(id);
  }

  @override
  Stream<List<domain.WeightGoal>> watchGoals() {
    return _weightGoalsDao.watchAllWeightGoals().map((driftGoals) {
      return WeightGoalMapper.fromDriftWeightGoals(driftGoals);
    });
  }

  @override
  Stream<List<domain.WeightGoal>> watchGoalsByCat(String catId) {
    return _weightGoalsDao.watchAllWeightGoals().map((driftGoals) {
      final filtered = driftGoals.where((goal) => goal.catId == catId);
      return WeightGoalMapper.fromDriftWeightGoals(filtered.toList());
    });
  }
}

