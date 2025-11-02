import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';

/// Repository abstrato para Weight Management V2
/// Segue os princípios da Clean Architecture
abstract class WeightRepository {
  /// Lista todos os weight logs com filtros opcionais
  Future<Either<Failure, List<WeightEntry>>> getWeightLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Busca um weight log por ID
  Future<Either<Failure, WeightEntry>> getWeightLogById(String id);

  /// Cria um novo weight log
  Future<Either<Failure, WeightEntry>> createWeightLog(WeightEntry weightLog);

  /// Atualiza um weight log
  Future<Either<Failure, WeightEntry>> updateWeightLog(WeightEntry weightLog);

  /// Deleta um weight log
  Future<Either<Failure, void>> deleteWeightLog(String id);

  /// Busca weight logs de um gato específico
  Future<Either<Failure, List<WeightEntry>>> getWeightLogsByCat(String catId);

  /// Lista todas as metas de peso com filtros opcionais
  Future<Either<Failure, List<WeightGoal>>> getGoals({
    String? catId,
    String? householdId,
  });

  /// Busca uma meta de peso por ID
  Future<Either<Failure, WeightGoal>> getGoalById(String id);

  /// Busca a meta ativa de um gato específico
  Future<Either<Failure, WeightGoal?>> getActiveGoalByCat(String catId);

  /// Cria uma nova meta de peso
  Future<Either<Failure, WeightGoal>> createGoal(WeightGoal goal);
}

