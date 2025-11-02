import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/weight/domain/repositories/weight_repository.dart';

class DeleteWeightLog implements UseCase<void, DeleteWeightLogParams> {
  final WeightRepository repository;

  DeleteWeightLog(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteWeightLogParams params) async {
    return await repository.deleteWeightLog(params.id);
  }
}

class DeleteWeightLogParams extends Equatable {
  final String id;

  const DeleteWeightLogParams({required this.id});

  @override
  List<Object?> get props => [id];
}

