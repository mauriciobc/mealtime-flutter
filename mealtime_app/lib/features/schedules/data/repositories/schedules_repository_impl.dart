import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/schedules/data/datasources/schedules_remote_datasource.dart';
import 'package:mealtime_app/features/schedules/data/models/schedule_model.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';
import 'package:mealtime_app/features/schedules/domain/repositories/schedules_repository.dart';

class SchedulesRepositoryImpl implements SchedulesRepository {
  final SchedulesRemoteDataSource remoteDataSource;

  SchedulesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Schedule>>> getSchedules(
      String householdId) async {
    try {
      final scheduleModels = await remoteDataSource.getSchedules(householdId);
      return Right(scheduleModels.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(NetworkFailure('Erro de conexão'));
      }
      return const Left(ServerFailure('Erro ao buscar agendamentos'));
    } catch (e) {
      return const Left(ServerFailure('Erro ao buscar agendamentos'));
    }
  }

  @override
  Future<Either<Failure, Schedule>> createSchedule(Schedule schedule) async {
    try {
      final scheduleModel = ScheduleModel.fromEntity(schedule);
      final createdModel = await remoteDataSource.createSchedule(scheduleModel);
      return Right(createdModel.toEntity());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(NetworkFailure('Erro de conexão'));
      }
      return const Left(ServerFailure('Erro ao criar agendamento'));
    } catch (e) {
      return const Left(ServerFailure('Erro ao criar agendamento'));
    }
  }

  @override
  Future<Either<Failure, Schedule>> updateSchedule(Schedule schedule) async {
    try {
      final scheduleModel = ScheduleModel.fromEntity(schedule);
      final updatedModel = await remoteDataSource.updateSchedule(scheduleModel);
      return Right(updatedModel.toEntity());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(NetworkFailure('Erro de conexão'));
      }
      return const Left(ServerFailure('Erro ao atualizar agendamento'));
    } catch (e) {
      return const Left(ServerFailure('Erro ao atualizar agendamento'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(String id) async {
    try {
      await remoteDataSource.deleteSchedule(id);
      return const Right(null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(NetworkFailure('Erro de conexão'));
      }
      return const Left(ServerFailure('Erro ao deletar agendamento'));
    } catch (e) {
      return const Left(ServerFailure('Erro ao deletar agendamento'));
    }
  }
}

