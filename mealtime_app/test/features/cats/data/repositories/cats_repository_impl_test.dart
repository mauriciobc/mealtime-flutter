import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/core/sync/sync_service.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_local_datasource.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_remote_datasource.dart';
import 'package:mealtime_app/features/cats/data/repositories/cats_repository_impl.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart' as domain;

void main() {
  group('CatsRepositoryImpl', () {
    late CatsRepositoryImpl repository;
    late MockCatsLocalDataSource localDataSource;
    late MockCatsRemoteDataSource remoteDataSource;
    late SyncService syncService;

    final cat1 = domain.Cat(
      id: 'cat-1',
      name: 'Cat One',
      birthDate: DateTime(2020, 1, 1),
      homeId: 'h1',
      createdAt: DateTime(2021, 1, 1),
      updatedAt: DateTime(2021, 1, 1),
    );

    setUp(() {
      localDataSource = MockCatsLocalDataSource();
      remoteDataSource = MockCatsRemoteDataSource();
      final db = AppDatabase.withExecutor(NativeDatabase.memory());
      syncService = SyncService(
        database: db,
        dio: Dio(),
        catsRemoteDataSource: remoteDataSource,
        catsLocalDataSource: localDataSource,
      );
      repository = CatsRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        syncService: syncService,
      );
    });

    group('deleteCat', () {
      test('após deletar com sucesso na API NÃO chama clearCache()', () async {
        localDataSource.getCachedCatResult = Future.value(cat1);
        remoteDataSource.deleteCatResult = Future.value();

        final result = await repository.deleteCat('cat-1');

        expect(result, const Right(null));
        expect(
          localDataSource.clearCacheCallCount,
          0,
          reason: 'clearCache não deve ser chamado ao deletar um gato',
        );
      });

      test('marca gato como inativo localmente e chama cacheCat', () async {
        localDataSource.getCachedCatResult = Future.value(cat1);
        remoteDataSource.deleteCatResult = Future.value();

        await repository.deleteCat('cat-1');

        expect(localDataSource.cacheCatCalls.length, 1);
        final savedCat = localDataSource.cacheCatCalls.single;
        expect(savedCat.isActive, false);
        expect(savedCat.id, 'cat-1');
      });
    });
  });
}

class MockCatsLocalDataSource implements CatsLocalDataSource {
  int clearCacheCallCount = 0;
  Future<domain.Cat?>? getCachedCatResult;
  final List<domain.Cat> cacheCatCalls = [];

  @override
  Future<void> clearCache() async {
    clearCacheCallCount++;
  }

  @override
  Future<domain.Cat?> getCachedCat(String catId) async => getCachedCatResult;

  @override
  Future<void> cacheCat(domain.Cat cat) async {
    cacheCatCalls.add(cat);
  }

  @override
  Future<void> cacheCats(List<domain.Cat> cats) async {}

  @override
  Future<List<domain.Cat>> getCachedCats() async => [];

  @override
  Future<List<domain.Cat>> getCachedCatsByHousehold(String householdId) async =>
      [];

  @override
  Future<void> markAsSynced(String id) async {}

  @override
  Stream<List<domain.Cat>> watchCats() => const Stream.empty();

  @override
  Stream<List<domain.Cat>> watchCatsByHousehold(String householdId) =>
      const Stream.empty();
}

class MockCatsRemoteDataSource implements CatsRemoteDataSource {
  Future<void>? deleteCatResult;

  @override
  Future<void> deleteCat(String catId) async => deleteCatResult;

  @override
  Future<List<domain.Cat>> getCats({String? householdId}) async => [];

  @override
  Future<domain.Cat> createCat(domain.Cat cat) async => cat;

  @override
  Future<domain.Cat> updateCat(domain.Cat cat) async => cat;

  @override
  Future<domain.Cat> updateCatWeight(String catId, double weight) async =>
      throw UnimplementedError();
}
