import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class GetWeightLogsByCat
    implements UseCase<List<WeightEntry>, GetWeightLogsByCatParams> {
  final WeightRepository repository;

  GetWeightLogsByCat(this.repository);

  @override
  Future<Either<Failure, List<WeightEntry>>> call(
    GetWeightLogsByCatParams params,
  ) async {
    return await repository.getWeightLogsByCat(params.catId);
  }
}

class GetWeightLogsByCatParams extends Equatable {
  final String catId;

  const GetWeightLogsByCatParams({required this.catId});

  @override
  List<Object?> get props => [catId];
}

