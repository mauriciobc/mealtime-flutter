import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';

abstract class SchedulesRepository {
  /// Buscar todos os agendamentos de um household
  Future<Either<Failure, List<Schedule>>> getSchedules(String householdId);

  /// Criar novo agendamento
  Future<Either<Failure, Schedule>> createSchedule(Schedule schedule);

  /// Atualizar agendamento existente
  Future<Either<Failure, Schedule>> updateSchedule(Schedule schedule);

  /// Deletar agendamento
  Future<Either<Failure, void>> deleteSchedule(String id);
}

