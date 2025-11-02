import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:dartz/dartz.dart';

abstract class CatsRepository {
  /// Obtém todos os gatos do usuário (com filtro opcional por household)
  Future<Either<Failure, List<Cat>>> getCats({String? householdId});

  /// Obtém um gato específico por ID (usa cache local)
  Future<Either<Failure, Cat?>> getCatById(String id);

  /// Cria um novo gato
  Future<Either<Failure, Cat>> createCat(Cat cat);

  /// Atualiza um gato existente
  Future<Either<Failure, Cat>> updateCat(Cat cat);

  /// Deleta um gato
  Future<Either<Failure, void>> deleteCat(String catId);

  /// Atualiza o peso de um gato
  Future<Either<Failure, Cat>> updateCatWeight(String catId, double weight);
}
