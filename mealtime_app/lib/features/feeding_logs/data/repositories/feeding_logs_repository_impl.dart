import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/feeding_logs/data/datasources/feeding_logs_remote_datasource.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';

/// Implementação do repository de Feeding Logs
class FeedingLogsRepositoryImpl implements FeedingLogsRepository {
  final FeedingLogsRemoteDataSource remoteDataSource;

  FeedingLogsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<FeedingLog>>> getFeedingLogs({
    String? catId,
    String? householdId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final feedingLogs = await remoteDataSource.getFeedingLogs(
        catId: catId,
        householdId: householdId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(feedingLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FeedingLog>> getFeedingLogById(String id) async {
    try {
      final feedingLog = await remoteDataSource.getFeedingLogById(id);
      return Right(feedingLog);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FeedingLog>> createFeedingLog(
    FeedingLog feedingLog,
  ) async {
    try {
      final created = await remoteDataSource.createFeedingLog(feedingLog);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FeedingLog>>> createFeedingLogsBatch(
    List<FeedingLog> feedingLogs,
  ) async {
    try {
      final created = await remoteDataSource.createFeedingLogsBatch(feedingLogs);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FeedingLog>> updateFeedingLog(
    FeedingLog feedingLog,
  ) async {
    try {
      final updated = await remoteDataSource.updateFeedingLog(feedingLog);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFeedingLog(String id) async {
    try {
      await remoteDataSource.deleteFeedingLog(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FeedingLog>>> getFeedingLogsByCat(
    String catId,
  ) async {
    try {
      final feedingLogs = await remoteDataSource.getFeedingLogs(catId: catId);
      return Right(feedingLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FeedingLog>>> getTodayFeedingLogs({String? householdId}) async {
    try {
      // Get all feeding logs for the household
      // Note: This method name suggests "today" but we return all logs
      // because the home page shows "Última Alimentação" (Last Feeding), not just today's
      final allFeedingLogs = await remoteDataSource.getFeedingLogs(
        householdId: householdId,
      );
      
      debugPrint('[FeedingLogsRepo] Total feeding logs from API: ${allFeedingLogs.length}');
      
      if (allFeedingLogs.isNotEmpty) {
        // Sort to show most recent first
        allFeedingLogs.sort((a, b) => b.fedAt.compareTo(a.fedAt));
        debugPrint('[FeedingLogsRepo] Most recent feeding: ${allFeedingLogs.first.id} at ${allFeedingLogs.first.fedAt}');
        
        // Log today's feedings count for reference
        final now = DateTime.now();
        final todayCount = allFeedingLogs.where((feeding) {
          final feedingDate = feeding.fedAt;
          return feedingDate.year == now.year &&
                 feedingDate.month == now.month &&
                 feedingDate.day == now.day;
        }).length;
        debugPrint('[FeedingLogsRepo] Today feedings count: $todayCount');
      }
      
      // Return all logs (sorted by most recent) so home page can show last feeding
      // The FeedingLogsLoaded state will compute lastFeeding from all logs
      return Right(allFeedingLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}
