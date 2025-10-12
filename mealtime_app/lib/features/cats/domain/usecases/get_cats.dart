import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';

class GetCats implements UseCase<List<Cat>, NoParams> {
  final CatsRepository repository;

  GetCats(this.repository);

  @override
  Future<Either<Failure, List<Cat>>> call(NoParams params) async {
    return await repository.getCats();
  }
}
