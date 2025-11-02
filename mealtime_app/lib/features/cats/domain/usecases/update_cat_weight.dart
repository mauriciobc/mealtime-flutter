import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';

class UpdateCatWeight implements UseCase<Cat, UpdateCatWeightParams> {
  final CatsRepository repository;

  UpdateCatWeight(this.repository);

  @override
  Future<Either<Failure, Cat>> call(UpdateCatWeightParams params) async {
    return await repository.updateCatWeight(params.catId, params.weight);
  }
}

class UpdateCatWeightParams {
  final String catId;
  final double weight;

  UpdateCatWeightParams({required this.catId, required this.weight});
}
