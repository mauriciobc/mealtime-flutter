import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

abstract class FeedingLogsEvent extends Equatable {
  const FeedingLogsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedingLogs extends FeedingLogsEvent {
  const LoadFeedingLogs();
}

class LoadFeedingLogsByCat extends FeedingLogsEvent {
  final String catId;

  const LoadFeedingLogsByCat(this.catId);

  @override
  List<Object> get props => [catId];
}

class LoadFeedingLogById extends FeedingLogsEvent {
  final String mealId;

  const LoadFeedingLogById(this.mealId);

  @override
  List<Object> get props => [mealId];
}

class LoadTodayFeedingLogs extends FeedingLogsEvent {
  final String? householdId;

  const LoadTodayFeedingLogs({this.householdId});

  @override
  List<Object?> get props => [householdId];
}

class CreateFeedingLog extends FeedingLogsEvent {
  final FeedingLog meal;

  const CreateFeedingLog(this.meal);

  @override
  List<Object> get props => [meal];
}

class CreateFeedingLogsBatch extends FeedingLogsEvent {
  final List<FeedingLog> meals;

  const CreateFeedingLogsBatch(this.meals);

  @override
  List<Object> get props => [meals];
}

class UpdateFeedingLog extends FeedingLogsEvent {
  final FeedingLog meal;

  const UpdateFeedingLog(this.meal);

  @override
  List<Object> get props => [meal];
}

class DeleteFeedingLog extends FeedingLogsEvent {
  final String mealId;

  const DeleteFeedingLog(this.mealId);

  @override
  List<Object> get props => [mealId];
}

class RefreshFeedingLogs extends FeedingLogsEvent {
  const RefreshFeedingLogs();
}

class ClearFeedingLogsError extends FeedingLogsEvent {
  const ClearFeedingLogsError();
}
