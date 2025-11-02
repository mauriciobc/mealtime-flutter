import 'package:mealtime_app/features/schedules/data/models/schedule_model.dart';
import 'package:mealtime_app/services/api/schedules_api_service.dart';

abstract class SchedulesRemoteDataSource {
  Future<List<ScheduleModel>> getSchedules(String householdId);
  Future<ScheduleModel> createSchedule(ScheduleModel schedule);
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
}

class SchedulesRemoteDataSourceImpl implements SchedulesRemoteDataSource {
  final SchedulesApiService apiService;

  SchedulesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<ScheduleModel>> getSchedules(String householdId) async {
    final apiResponse = await apiService.getSchedules(householdId: householdId);
    return apiResponse.data ?? [];
  }

  @override
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final apiResponse = await apiService.createSchedule(schedule);
    return apiResponse.data!;
  }

  @override
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule) async {
    final apiResponse = await apiService.updateSchedule(schedule.id, schedule);
    return apiResponse.data!;
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await apiService.deleteSchedule(id);
  }
}

