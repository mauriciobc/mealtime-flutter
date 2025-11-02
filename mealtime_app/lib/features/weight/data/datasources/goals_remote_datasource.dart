import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';
import 'package:mealtime_app/services/api/goals_api_service.dart';

/// Interface do data source remoto para Goals V2
abstract class GoalsRemoteDataSource {
  /// Lista metas de peso com filtros opcionais
  Future<List<WeightGoal>> getGoals({
    String? catId,
    String? householdId,
  });

  /// Cria uma nova meta de peso
  Future<WeightGoal> createGoal(
    String catId,
    double targetWeight,
    DateTime targetDate, {
    String? notes,
    double? startWeight,
    DateTime? startDate,
  });
}

/// Implementação do data source remoto usando API V2
class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  final GoalsApiService apiService;

  GoalsRemoteDataSourceImpl({
    required this.apiService,
  });

  @override
  Future<List<WeightGoal>> getGoals({
    String? catId,
    String? householdId,
  }) async {
    try {
      final apiResponse = await apiService.getGoals(
        catId: catId,
        householdId: householdId,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar metas',
        );
      }

      // Converter GoalModel para WeightGoal entity
      // A API pode retornar start_weight, se não usar o primeiro registro de peso
      final goals = <WeightGoal>[];
      for (final goalModel in apiResponse.data!) {
        double startWeight;
        DateTime startDate;
        
        // Se a API retornou start_weight, usar ele e created_at como start_date
        if (goalModel.startWeight != null) {
          startWeight = goalModel.startWeight!;
          startDate = goalModel.createdAt; // Usar created_at como start_date
        } else {
          // Fallback: buscar do primeiro registro de peso (mas isso pode causar loops!)
          // Por enquanto, usar valores padrão
          startWeight = goalModel.targetWeight;
          startDate = goalModel.createdAt;
        }

        final goal = WeightGoal(
          id: goalModel.id,
          catId: goalModel.catId,
          targetWeight: goalModel.targetWeight,
          startWeight: startWeight,
          startDate: startDate,
          targetDate: goalModel.targetDate,
          notes: goalModel.notes,
          createdAt: goalModel.createdAt,
          updatedAt: goalModel.updatedAt ?? goalModel.createdAt,
        );
        goals.add(goal);
      }

      return goals;
    } catch (e) {
      throw ServerException('Erro ao buscar metas: ${e.toString()}');
    }
  }

  @override
  Future<WeightGoal> createGoal(
    String catId,
    double targetWeight,
    DateTime targetDate, {
    String? notes,
    double? startWeight,
    DateTime? startDate,
  }) async {
    try {
      final request = CreateGoalRequest(
        catId: catId,
        targetWeight: targetWeight,
        targetDate: targetDate,
        notes: notes,
      );

      final apiResponse = await apiService.createGoal(request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao criar meta',
        );
      }

      final goalModel = apiResponse.data!;
      
      // Usar start_weight da API se disponível
      double finalStartWeight;
      DateTime finalStartDate;
      
      if (goalModel.startWeight != null) {
        finalStartWeight = goalModel.startWeight!;
        finalStartDate = goalModel.createdAt; // Usar created_at como start_date
      } else {
        // Fallback para os valores fornecidos
        finalStartWeight = startWeight ?? goalModel.targetWeight;
        finalStartDate = startDate ?? goalModel.createdAt;
      }

      return WeightGoal(
        id: goalModel.id,
        catId: goalModel.catId,
        targetWeight: goalModel.targetWeight,
        startWeight: finalStartWeight,
        startDate: finalStartDate,
        targetDate: goalModel.targetDate,
        notes: goalModel.notes,
        createdAt: goalModel.createdAt,
        updatedAt: goalModel.updatedAt ?? goalModel.createdAt,
      );
    } catch (e) {
      throw ServerException('Erro ao criar meta: ${e.toString()}');
    }
  }
}

