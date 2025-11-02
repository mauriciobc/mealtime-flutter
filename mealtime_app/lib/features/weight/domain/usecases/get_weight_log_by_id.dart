import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class GetWeightLogById
    implements UseCase<WeightEntry, GetWeightLogByIdParams> {
  final WeightRepository repository;

  GetWeightLogById(this.repository);

  @override
  Future<Either<Failure, WeightEntry>> call(
    GetWeightLogByIdParams params,
  ) async {
    return await repository.getWeightLogById(params.id);
  }
}

class GetWeightLogByIdParams extends Equatable {
  final String id;

  const GetWeightLogByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

