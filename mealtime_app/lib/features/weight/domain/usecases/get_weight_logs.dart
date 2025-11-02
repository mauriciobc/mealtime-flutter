import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class GetWeightLogs implements UseCase<List<WeightEntry>, GetWeightLogsParams> {
  final WeightRepository repository;

  GetWeightLogs(this.repository);

  @override
  Future<Either<Failure, List<WeightEntry>>> call(
    GetWeightLogsParams params,
  ) async {
    return await repository.getWeightLogs(
      catId: params.catId,
      householdId: params.householdId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetWeightLogsParams extends Equatable {
  final String? catId;
  final String? householdId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetWeightLogsParams({
    this.catId,
    this.householdId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [catId, householdId, startDate, endDate];
}

