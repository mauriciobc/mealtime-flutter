import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_remote_datasource.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';

class CatsRepositoryImpl implements CatsRepository {
  final CatsRemoteDataSource remoteDataSource;

  CatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Cat>>> getCats() async {
    try {
      final cats = await remoteDataSource.getCats();
      return Right(cats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cat>> getCatById(String id) async {
    try {
      final cat = await remoteDataSource.getCatById(id);
      return Right(cat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cat>> createCat(Cat cat) async {
    try {
      final createdCat = await remoteDataSource.createCat(cat);
      return Right(createdCat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cat>> updateCat(Cat cat) async {
    try {
      final updatedCat = await remoteDataSource.updateCat(cat);
      return Right(updatedCat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCat(String id) async {
    try {
      await remoteDataSource.deleteCat(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Cat>>> getCatsByHome(String homeId) async {
    try {
      final cats = await remoteDataSource.getCatsByHome(homeId);
      return Right(cats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cat>> updateCatWeight(
    String catId,
    double weight,
  ) async {
    try {
      final cat = await remoteDataSource.updateCatWeight(catId, weight);
      return Right(cat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
