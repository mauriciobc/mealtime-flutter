import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:dartz/dartz.dart';

abstract class CatsRepository {
  /// Obtém todos os gatos do usuário
  Future<Either<Failure, List<Cat>>> getCats();

  /// Obtém um gato específico por ID
  Future<Either<Failure, Cat>> getCatById(String id);

  /// Cria um novo gato
  Future<Either<Failure, Cat>> createCat(Cat cat);

  /// Atualiza um gato existente
  Future<Either<Failure, Cat>> updateCat(Cat cat);

  /// Exclui um gato
  Future<Either<Failure, void>> deleteCat(String id);

  /// Obtém gatos por residência
  Future<Either<Failure, List<Cat>>> getCatsByHome(String homeId);

  /// Atualiza o peso atual de um gato
  Future<Either<Failure, Cat>> updateCatWeight(String catId, double weight);
}
